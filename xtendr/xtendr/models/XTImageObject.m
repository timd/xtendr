//
//  XTImageObject.m
//  xtendr
//
//  Created by Tony Million on 19/08/2012.
//  Copyright (c) 2012 Tony Million. All rights reserved.
//

#import "XTImageObject.h"

@implementation XTImageObject

-(id)initWithAttributes:(NSDictionary*)attributes
{
	self = [super init];
	if(self)
	{
		//TODO: error checking here pls
		_width	= [attributes objectForKey:@"width"];
		_height = [attributes objectForKey:@"height"];
		_url	= [NSURL URLWithString:[attributes objectForKey:@"url"]];
	}

	return self;
}


@end
