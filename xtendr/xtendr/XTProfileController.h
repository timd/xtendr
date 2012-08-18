//
//  XTProfileController.h
//  xtendr
//
//  Created by Tony Million on 18/08/2012.
//  Copyright (c) 2012 Tony Million. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const kXTProfileValidityChangedNotification;


@interface XTProfileController : NSObject

+(XTProfileController*)sharedInstance;

-(BOOL)isSessionValid;
-(NSString*)accesstoken;

-(void)loginWithToken:(NSString*)token;
-(void)logout;

@end
