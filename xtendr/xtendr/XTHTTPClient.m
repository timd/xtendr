//
//  XTHTTPClient.m
//  xtendr
//
//  Created by Tony Million on 18/08/2012.
//  Copyright (c) 2012 Tony Million. All rights reserved.
//

#import "XTHTTPClient.h"

static NSString * const kADNBaseURLString = @"https://alpha-api.app.net/stream/0/";
	

@implementation XTHTTPClient

+(XTHTTPClient *)sharedClient
{
    static XTHTTPClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSLog(@"Endpoint: %@", kADNBaseURLString);
        _sharedClient = [[XTHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:kADNBaseURLString]];
    });

    return _sharedClient;
}

@end
