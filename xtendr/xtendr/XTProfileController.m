//
//  XTProfileController.m
//  xtendr
//
//  Created by Tony Million on 18/08/2012.
//  Copyright (c) 2012 Tony Million. All rights reserved.
//

#import "XTProfileController.h"

NSString *const kXTProfileValidityChangedNotification   = @"kXTProfileValidityChangedNotification";


@implementation XTProfileController

+(XTProfileController*)sharedInstance
{
	static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init]; // or some other init method
    });
    return _sharedObject;
}

-(BOOL)isSessionValid
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

	NSString * token = [defaults objectForKey:@"access_token"];

	if(token)
	{
		NSLog(@"token = %@", token);
		return YES;
	}

	return NO;
}

-(void)loginWithToken:(NSString*)token
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:token forKey:@"access_token"];
	[defaults synchronize];

	//TODO: call
	//https://alpha-api.app.net/stream/0/token?access_token=<token>
	// get user object and send out a kXTProfileValidityChangedNotification
}

-(void)logout
{
	//TODO: delete token change profile validity
}

@end
