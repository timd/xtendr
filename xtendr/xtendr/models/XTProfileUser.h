//
//  XTProfileUser.h
//  xtendr
//
//  Created by Tony Million on 19/08/2012.
//  Copyright (c) 2012 Tony Million. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "XTImageObject.h"

@interface XTProfileUser : NSObject

@property(readonly)		NSString	*id;
@property(readonly)		NSString	*username;
@property(readonly)		NSString	*name;
@property(readonly)		NSDate		*created_at;

@property(readonly)		NSNumber	*follows_you;
@property(readonly)		NSNumber	*you_follow;
@property(readonly)		NSNumber	*you_muted;

@property(readonly)		NSNumber	*follows;
@property(readonly)		NSNumber	*followed_by;
@property(readonly)		NSNumber	*post_count;

@property(readonly)		XTImageObject	*avatar_image;
@property(readonly)		XTImageObject	*cover_image;

-(id)initWithAttributes:(NSDictionary*)attributes;

@end
