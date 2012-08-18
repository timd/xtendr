//
//  UIImage+NetworkLoad.h
//  xtendr
//
//  Created by Tony Million on 09/06/2012.
//  Copyright (c) 2012 OmniTyke. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TMDiskCache.h"

@interface UIImage (NetworkLoad)

+(UIImage*)imageWithDataImmediate:(NSData*)data;

@end

extern NSString *const kUIImageViewNetworkLoadDidStartNotification;
extern NSString *const kUIImageViewNetworkLoadDidFinishNotification;

@interface UIImageView (NetworkLoad)

@property(strong, nonatomic) NSURL *downloadingURL;
@property(strong, nonatomic) NSURL *finalURL;

-(void)loadFromURL:(NSURL *)url 
  placeholderImage:(UIImage *)placeholderImage
		 fromCache:(TMDiskCache*)cache;

-(void)loadWithRequest:(NSMutableURLRequest*)request
      placeholderImage:(UIImage *)placeholderImage
			 fromCache:(TMDiskCache*)cache;

@end
