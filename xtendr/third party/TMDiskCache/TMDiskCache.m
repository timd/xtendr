//
//  TMDiskCache.m
//  ZummZumm
//
//  Created by Tony Million on 14/04/2012.
//  Copyright (c) 2012 OmniTyke. All rights reserved.
//
#import <CommonCrypto/CommonDigest.h>


#import "TMDiskCache.h"

@interface TMDiskCache ()

@property (assign) dispatch_queue_t trimQueue;

@property(strong) NSURL             *diskCacheURL;

@property(strong) NSCache           *imageCache;

@property(strong) NSOperationQueue  *downloadOperationQueue;

@end


@implementation TMDiskCache
{
	UIBackgroundTaskIdentifier trimCacheTask;
}


-(NSString *)md5:(NSString *)str
{
	const char *cStr = [str UTF8String];
	unsigned char result[16];
	CC_MD5( cStr, strlen(cStr), result );
	return [NSString stringWithFormat:
			@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
			result[0], result[1], result[2], result[3],
			result[4], result[5], result[6], result[7],
			result[8], result[9], result[10], result[11],
			result[12], result[13], result[14], result[15]
			];
}

-(id)initWithDirectoryName:(NSString*)directoryName
{
	// default 10MB Cache!
	return [self initWithDirectoryName:directoryName andCacheSize:10];
}

-(id)initWithDirectoryName:(NSString*)directoryName andCacheSize:(NSUInteger)size
{
    self = [super init];
    
    if(self)
    {
        NSURL * cacheURL = [[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory 
                                                                   inDomains:NSUserDomainMask] lastObject];
        
        self.diskCacheURL   = [cacheURL URLByAppendingPathComponent:directoryName];
        NSError * error;
        if(![self.diskCacheURL checkResourceIsReachableAndReturnError:&error])
        {
            [[NSFileManager defaultManager] createDirectoryAtURL:self.diskCacheURL
                                     withIntermediateDirectories:YES
                                                      attributes:nil
                                                           error:NULL];
        }

		
        // create a serial queue on which we deliver touch/trim stuff
        self.trimQueue        = dispatch_queue_create("com.zummer.trimqueue", DISPATCH_QUEUE_SERIAL);
        dispatch_set_target_queue(self.trimQueue, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0));


		
        // create a download operation queue!
        self.downloadOperationQueue = [[NSOperationQueue alloc] init];
        self.downloadOperationQueue.name = @"TMDiskCacheDownloadQueue";



        self.imageCache = [[NSCache alloc] init];
        self.imageCache.delegate = self;
 		[self.imageCache setName:@"TMImageCache"];

		
        // default cache size is 10megs
        self.cacheSize = size*1024*1024;
    }
    
    return self;
}

-(NSURL*)filenameURLForCachedURL:(NSURL*)url
{
    if(url == nil)
        return nil;
    // because of the way Zummer generates unique filenames anyway
    // we dont need to generate them on device using a MD5 of the url or whatever
    NSString *cachename = nil;
    
    if(self.filenameDelegate && [self.filenameDelegate respondsToSelector:@selector(filenameForURL:)])
    {
        cachename = [self.filenameDelegate filenameForURL:url];
    }
    else 
    {
        cachename = [self md5:[url absoluteString]];
    }
    
    
    // in a *REAL* implementation of this you should probably do that.    
    NSURL * fullthing = [self.diskCacheURL URLByAppendingPathComponent:cachename];
    return fullthing;
}

-(void)touchCachedFile:(NSURL*)url
{
    dispatch_async(self.trimQueue, ^{
        NSError * error;
        
        NSURL * cacheURL = [self filenameURLForCachedURL:url];
        // we have to use the created time, as iOS doesn't honour the last accessed flag
        // update the access time (really the created time but meh)
        if(![cacheURL setResourceValue:[NSDate date] 
                                forKey:NSURLCreationDateKey 
                                 error:&error])
        {
            // we dont care if it errors - it probably will!
        }
    });
}

-(void)trimCache
{
	if(trimCacheTask != UIBackgroundTaskInvalid)
	{
		[[UIApplication sharedApplication] endBackgroundTask:trimCacheTask];
		trimCacheTask = UIBackgroundTaskInvalid;
	}

    trimCacheTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
		if(trimCacheTask != UIBackgroundTaskInvalid)
		{
			[[UIApplication sharedApplication] endBackgroundTask:trimCacheTask];
			trimCacheTask = UIBackgroundTaskInvalid;
		}
	}];
    
    // we do the nasty stuff on a background thread    
    // what we do here is iterate over the folder pull out the last access (created) date
    // then sort by that
    // while the cache on disk is bigger than the set size we start deleting items
    // then we're done!
    
    // all of this is done on a serial dispatch queue, so it'll never interact with itself!
    dispatch_async(self.trimQueue, ^{
        
        // this implements a LRU algorithm
        NSMutableArray * temp = [NSMutableArray arrayWithCapacity:5];
        NSArray *keys = [NSArray arrayWithObjects:NSURLFileSizeKey, NSURLCreationDateKey, nil];
        
        NSDirectoryEnumerator * enumerator = [[NSFileManager defaultManager] enumeratorAtURL:self.diskCacheURL 
                                                                  includingPropertiesForKeys:keys
                                                                                     options:NSDirectoryEnumerationSkipsSubdirectoryDescendants | NSDirectoryEnumerationSkipsPackageDescendants
                                                                                errorHandler:^BOOL(NSURL *url, NSError *error) {
                                                                                    NSLog(@"Error: %@", error);
                                                                                    return YES;
                                                                                }];
        
        for (NSURL *url in enumerator) 
        { 
            [temp addObject:url];
        }
        
        // sort based on the creation date
        [temp sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            NSURL *url1 = (NSURL*)obj1;
            NSURL *url2 = (NSURL*)obj2;
            
            NSDate *date1;
            NSDate *date2;
            
            [url1 getResourceValue:&date1 forKey:NSURLCreationDateKey error:nil];
            [url2 getResourceValue:&date2 forKey:NSURLCreationDateKey error:nil];
            
            return [date1 compare:date2];
        }];
        
        
        // calculate total size of cache
        NSUInteger totalSize = 0;
        
        if(temp.count)
        {
            for (NSURL * file in temp) 
            {
                NSNumber * size;
                [file getResourceValue:&size 
                                forKey:NSURLFileSizeKey error:nil];
                
                totalSize += [size unsignedIntegerValue];
            }
            
            // while we have more files than cache 
            // delete the file, subtract the size
            while(totalSize > self.cacheSize)
            {
                NSURL * topItem = [temp objectAtIndex:0];
                
                NSError * error;
                if(![[NSFileManager defaultManager] removeItemAtURL:topItem 
                                                              error:&error])
                {
                    NSLog(@"Error deleting file: %@, %@", topItem, error);
                }
                
                NSNumber * size;
                [topItem getResourceValue:&size 
                                   forKey:NSURLFileSizeKey error:nil];
                
                totalSize -= [size unsignedIntegerValue];
                
                [temp removeObjectAtIndex:0];
            }
        }
        else 
        {
            NSLog(@"No files!");
        }
        
		if(trimCacheTask != UIBackgroundTaskInvalid)
		{
			[[UIApplication sharedApplication] endBackgroundTask:trimCacheTask];
			trimCacheTask = UIBackgroundTaskInvalid;
		}
    });
}



-(BOOL)setData:(NSData*)data forURL:(NSURL*)url
{
    //save the data to disk!
    if(![data writeToURL:[self filenameURLForCachedURL:url]
              atomically:YES])
    {
        NSLog(@"Error caching data :(");
        return NO;
    }
    
    return YES;
}

-(NSData*)dataForURL:(NSURL*)url
{
    NSURL * localURL = [self filenameURLForCachedURL:url];

	if(localURL)
	{
		NSData * fileData = [NSData dataWithContentsOfURL:localURL
												  options:NSDataReadingMappedIfSafe
													error:nil];
		if(fileData)
		{
			[self touchCachedFile:url];
			return fileData;
		}
	}
    
    return nil;
}


-(UIImage*)imageForURL:(NSURL*)url
{
    UIImage * cacheImage = [self.imageCache objectForKey:url];
    if(cacheImage)
    {
        [self touchCachedFile:url];
        return cacheImage;
    }
    
    NSURL * localURL = [self filenameURLForCachedURL:url];
    UIImage * fileImage = [UIImage imageWithContentsOfFile:[localURL path]];
    if(fileImage)
    {
        [self.imageCache setObject:fileImage 
                            forKey:url];
        
        [self touchCachedFile:url];
        
        return fileImage;
    }
    
    return nil;
}


-(void)downloadImageWithRequest:(NSURLRequest *)request withDelegate:(id<TMDiskCacheDelegate>)delegate
{
    if(request == nil)
    {
        NSLog(@"request IS NIL");
        return;
    }

	NSURL *url = request.URL;
    
    // check if we have it on the calling thread, that way there'll be no turn around!
    UIImage * cacheImage = [self.imageCache objectForKey:url];
    if(cacheImage)
    {
        [delegate diskcache:self 
           willDeliverImage:cacheImage 
                     forURL:url];
        
        [self touchCachedFile:url];
        
        return;
    }

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        // see if we have it on disk maybe?
        UIImage * localImage = [self imageForURL:url];
        
        if(localImage)
        {
            [delegate diskcache:self 
               willDeliverImage:localImage 
                         forURL:url];
            return;
        }
        
        // nope, ok lets go download it if we can!
        [delegate diskcachewillDownloadData:self];

        if(self.activityDelegate && [self.activityDelegate respondsToSelector:@selector(downloaderDidStart:)])
        {
            [self.activityDelegate downloaderDidStart:self];
        }
        
        [NSURLConnection sendAsynchronousRequest:request 
                                           queue:self.downloadOperationQueue 
                               completionHandler:^(NSURLResponse *response, NSData *remoteData, NSError *error) {
                                   
                                   if(self.activityDelegate && [self.activityDelegate respondsToSelector:@selector(downloaderDidFinish:)])
                                   {
                                       [self.activityDelegate downloaderDidFinish:self];
                                   }

                                   
                                   if(remoteData)
                                   {
                                       UIImage * remoteImage = [UIImage imageWithData:remoteData];

									   if(remoteImage)
									   {
										   // we dont cache the NDdata for the image here as I dont think we care.
										   // We do cache the UIImage, and let the cache know it was a little costly (more so than just grabbing the NSData from disk!)
										   [self.imageCache setObject:remoteImage 
															   forKey:url
																 cost:2];
										   
										   [delegate diskcache:self 
											  willDeliverImage:remoteImage 
														forURL:url];
										   
										   [self setData:remoteData 
												  forURL:url];
									   }
									   else
									   {
										   NSLog(@"Invalid Image: %@", error);
										   if(delegate && [delegate respondsToSelector:@selector(diskcache:downloadFailedforURL:)])
										   {
											   [delegate diskcache:self
											  downloadFailedforURL:url];
										   }
									   }
                                   }
                                   else
                                   {
                                       NSLog(@"Downloading Failed: %@", error);
                                       if(delegate && [delegate respondsToSelector:@selector(diskcache:downloadFailedforURL:)])
                                       {
                                           [delegate diskcache:self 
                                          downloadFailedforURL:url];
                                       }
                                   }
                               }];
    }); 
}

-(void)downloadImageFromURL:(NSURL *)url withDelegate:(id<TMDiskCacheDelegate>)delegate
{
	NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:url];

	[self downloadImageWithRequest:request
					  withDelegate:delegate];
}

-(void)loadImageFromURL:(NSURL*)url placeHolder:(UIImage *)placeholder intoImageView:(UIImageView*)imageView
{
	
}

@end
