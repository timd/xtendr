//
//  TMDiskCache.h
//  ZummZumm
//
//  Created by Tony Million on 14/04/2012.
//  Copyright (c) 2012 OmniTyke. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TMDiskCacheDelegate;
@protocol TMDiskCacheActivityDelegate;
@protocol TMFilenameGeneratorDelegate;

@interface TMDiskCache : NSObject <NSCacheDelegate>

@property(weak) id<TMDiskCacheActivityDelegate> activityDelegate;
@property(weak) id<TMFilenameGeneratorDelegate> filenameDelegate;

@property(assign) NSUInteger cacheSize;

-(id)initWithDirectoryName:(NSString*)directoryName;
-(id)initWithDirectoryName:(NSString*)directoryName andCacheSize:(NSUInteger)size;


//cache control
-(void)trimCache;


// accessors for the cache!
-(BOOL)setData:(NSData*)data forURL:(NSURL*)url;

-(NSData*)dataForURL:(NSURL*)url;
-(UIImage*)imageForURL:(NSURL*)url;

-(void)downloadImageWithRequest:(NSURLRequest *)request withDelegate:(id<TMDiskCacheDelegate>)delegate;
-(void)downloadImageFromURL:(NSURL*)url withDelegate:(id<TMDiskCacheDelegate>)delegate;

-(void)loadImageFromURL:(NSURL*)url placeHolder:(UIImage *)placeholder intoImageView:(UIImageView*)imageView;

@end



@protocol TMDiskCacheDelegate <NSObject>

@optional

-(void)diskcachewillDownloadData:(TMDiskCache *)diskcache;

-(void)diskcache:(TMDiskCache *)diskcache willDeliverImage:(UIImage*)data forURL:(NSURL*)url;

-(void)diskcache:(TMDiskCache *)diskcache downloadFailedforURL:(NSURL*)url;

@end



@protocol TMFilenameGeneratorDelegate <NSObject>

-(NSString*)filenameForURL:(NSURL*)url;

@end



@protocol TMDiskCacheActivityDelegate <NSObject>

- (void)downloaderDidStart:(TMDiskCache *)downloader;
- (void)downloaderDidFinish:(TMDiskCache *)downloader;

@end
