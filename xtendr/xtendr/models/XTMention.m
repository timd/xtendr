//
//  XTMention.m
//  xtendr
//
//  Created by Tony Million on 20/08/2012.
//  Copyright (c) 2012 Tony Million. All rights reserved.
//

#import "XTMention.h"

@implementation XTMention

-(id)initWithAttributes:(NSDictionary*)attributes
{
	self = [super init];
	if(self)
	{
		//TODO: error checking here pls
		_name	= [attributes objectForKey:@"name"];
		_id		= [attributes objectForKey:@"id"];

		NSUInteger pos = [[attributes objectForKey:@"pos"] unsignedIntegerValue];
		NSUInteger len = [[attributes objectForKey:@"len"] unsignedIntegerValue];

		_range	= NSMakeRange(pos, len);
	}

	return self;
}


@end
