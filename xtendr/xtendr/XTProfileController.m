//
//  XTProfileController.m
//  xtendr
//
//  Created by Tony Million on 18/08/2012.
//  Copyright (c) 2012 Tony Million. All rights reserved.
//

#import "XTProfileController.h"
#import "XTHTTPClient.h"

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

-(id)init
{
	self = [super init];
	if(self)
	{

		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

		NSString * token = [defaults objectForKey:@"access_token"];

		if(token)
		{
			[[XTHTTPClient sharedClient] setDefaultHeader:@"Authorization"
													value:[NSString stringWithFormat:@"Bearer %@", token]];
		}


		[self refreshProfile];
	}

	return self;
}

-(BOOL)isSessionValid
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

	NSString * token = [defaults objectForKey:@"access_token"];

	if(token)
	{
		DLog(@"token = %@", token);
		return YES;
	}

	return NO;
}

-(NSString*)accesstoken
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

	return [defaults objectForKey:@"access_token"];

}

-(void)loginWithToken:(NSString*)token
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:token forKey:@"access_token"];
	[defaults synchronize];

	//TODO: call
	//https://alpha-api.app.net/stream/0/token?access_token=<token>
	// get user object and send out a kXTProfileValidityChangedNotification
	[[XTHTTPClient sharedClient] setDefaultHeader:@"Authorization"
											value:[NSString stringWithFormat:@"Bearer %@", token]];

	[[XTHTTPClient sharedClient] getPath:@"token"
							  parameters:nil
								 success:^(TMHTTPRequest *operation, id responseObject) {
									 DLog(@"login S: %@", responseObject);
									 [[NSNotificationCenter defaultCenter] postNotificationName:kXTProfileValidityChangedNotification object:nil];
								 }
								 failure:^(TMHTTPRequest *operation, NSError *error) {
									 DLog(@"login F: %@", operation.responseString);
									 [[NSNotificationCenter defaultCenter] postNotificationName:kXTProfileValidityChangedNotification object:nil];
								 }];
}

-(void)logout
{
	//TODO: delete token change profile validity
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults removeObjectForKey:@"access_token"];
	[defaults synchronize];

	[[XTHTTPClient sharedClient] setDefaultHeader:@"Authorization"
											value:nil];

	[[NSNotificationCenter defaultCenter] postNotificationName:kXTProfileValidityChangedNotification object:nil];
}

-(void)refreshProfile
{
	[[XTHTTPClient sharedClient] getPath:@"token"
							  parameters:nil
								 success:^(TMHTTPRequest *operation, id responseObject) {
									 DLog(@"refreshProfile S: %@", responseObject);
									 // we dont send this here cos it screws the UI, innit
									 //[[NSNotificationCenter defaultCenter] postNotificationName:kXTProfileValidityChangedNotification object:nil];
								 }
								 failure:^(TMHTTPRequest *operation, NSError *error) {
									 // if this fails cos the token is bad we need to deal with that!
						
									 DLog(@"refreshProfile F: %@", operation.responseString);
									 [[NSNotificationCenter defaultCenter] postNotificationName:kXTProfileValidityChangedNotification object:nil];
								 }];
}

@end
