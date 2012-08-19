//
//  XTProfileUser.m
//  xtendr
//
//  Created by Tony Million on 19/08/2012.
//  Copyright (c) 2012 Tony Million. All rights reserved.
//

#import "XTProfileUser.h"

@implementation XTProfileUser

-(id)initWithAttributes:(NSDictionary*)attributes
{
	self = [super init];
	if(self)
	{
		_id			= [attributes objectForKey:@"id"];
		_username	= [attributes objectForKey:@"username"];
		_name		= [attributes objectForKey:@"name"];

		//2012-12-31T13:22:55Z
		//TODO: creating NSDateFormatter is expensive, we should staticify this if at all possible
		NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
		_created_at = [dateFormatter dateFromString:[attributes objectForKey:@"created_at"]];

		_follows_you	= [attributes objectForKey:@"follows_you"];
		_you_follow		= [attributes objectForKey:@"you_follow"];
		_you_muted		= [attributes objectForKey:@"you_muted"];

		NSDictionary * counts = [attributes objectForKey:@"counts"];
		if(counts)
		{
			_follows		= [counts objectForKey:@"follows"];
			_followed_by	= [counts objectForKey:@"followed_by"];
			_post_count		= [counts objectForKey:@"posts"];
		}

		if([attributes objectForKey:@"avatar_image"])
			_avatar_image = [[XTImageObject alloc] initWithAttributes:[attributes objectForKey:@"avatar_image"]];
		
		if([attributes objectForKey:@"cover_image"])
			_cover_image = [[XTImageObject alloc] initWithAttributes:[attributes objectForKey:@"cover_image"]];
	}

	return self;
}


@end
