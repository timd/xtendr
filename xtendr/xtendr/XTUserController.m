//
//  XTUserController.m
//  xtendr
//
//  Created by Tony Million on 19/08/2012.
//  Copyright (c) 2012 Tony Million. All rights reserved.
//

#import "XTUserController.h"

@interface XTUserController ()

@property(strong) NSDateFormatter		*ISO8601Formatter;

@end

@implementation XTUserController
{
	dispatch_queue_t	_addQueue;
}

+(XTUserController*)sharedInstance
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
		_addQueue = dispatch_queue_create("com.tonymillion.useraddqueue", DISPATCH_QUEUE_SERIAL);

		self.ISO8601Formatter = [[NSDateFormatter alloc] init];
		[self.ISO8601Formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
		[self.ISO8601Formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];

	}

	return self;
}

//everything funnels in here
-(User*)insertUser:(NSDictionary*)userDict inContext:(NSManagedObjectContext*)context
{
	NSString * ID = [userDict valueForKey:@"id"];

	User * user = [User userByID:ID inContext:context];
	if(user)
	{
		//merge user
		DLog(@"Merge User");
	}
	else
	{
		//create user
		DLog(@"Create User");
		user = [User userByID:ID
					inContext:context
			createIfNecessary:YES];

		//TODO: can a user change their user name?
		if([userDict objectForKey:@"username"])
			user.username	= [userDict objectForKey:@"username"];

		if([userDict objectForKey:@"name"])
			user.name		= [userDict objectForKey:@"name"];

		if(!user.created_at)
		{
			user.created_at = [self.ISO8601Formatter  dateFromString:[userDict objectForKey:@"created_at"]];
		}
	}

	// this can merge
	if(user.follows_you)
	{
		if(![user.follows_you isEqual:[userDict objectForKey:@"follows_you"]])
			user.follows_you	= [userDict objectForKey:@"follows_you"];
	}
	else
	{
		user.follows_you	= [userDict objectForKey:@"follows_you"];
	}

	if(user.you_follow)
	{
		if(![user.you_follow isEqual:[userDict objectForKey:@"you_follow"]])
			user.you_follow		= [userDict objectForKey:@"you_follow"];
	}
	else
	{
		user.you_follow		= [userDict objectForKey:@"you_follow"];
	}

	if(user.you_muted)
	{
		if(![user.you_follow isEqual:[userDict objectForKey:@"you_muted"]])
			user.you_muted		= [userDict objectForKey:@"you_muted"];
	}
	else
	{
		user.you_muted		= [userDict objectForKey:@"you_muted"];
	}


	NSDictionary * counts = [userDict objectForKey:@"counts"];
	if(counts)
	{
		if(user.follows)
		{
			if([user.follows isEqual:[counts objectForKey:@"follows"]])
				user.follows		= [counts objectForKey:@"follows"];
		}
		else
		{
			user.follows		= [counts objectForKey:@"follows"];
		}

		if(user.followed_by)
		{
			if([user.followed_by isEqual:[counts objectForKey:@"followed_by"]])
				user.followed_by		= [counts objectForKey:@"followed_by"];
		}
		else
		{
			user.followed_by		= [counts objectForKey:@"followed_by"];
		}

		if(user.postcount)
		{
			if([user.postcount isEqual:[counts objectForKey:@"posts"]])
				user.postcount		= [counts objectForKey:@"posts"];
		}
		else
		{
			user.postcount		= [counts objectForKey:@"posts"];
		}
	}

	if([userDict objectForKey:@"avatar_image"])
	{
		// we only care if the key is included eh
		if(user.avatar_image_dict)
		{
			if(![user.avatar_image_dict isEqualToDictionary:[userDict objectForKey:@"avatar_image"]])
				user.avatar_image_dict = [userDict objectForKey:@"avatar_image"];
		}
		else
		{
			user.avatar_image_dict = [userDict objectForKey:@"avatar_image"];
		}
	}
	
	if([userDict objectForKey:@"cover_image"])
	{
		// we only care if the key is included eh
		if(user.cover_image_dict)
		{
			if(![user.cover_image_dict isEqualToDictionary:[userDict objectForKey:@"cover_image"]])
				user.cover_image_dict = [userDict objectForKey:@"cover_image"];
		}
		else
		{
			user.cover_image_dict = [userDict objectForKey:@"cover_image"];
		}
	}

	//DO NOT SAVE HERE
	return user;
}

//stuff to process on a background thread so we dont hang the UI too much
-(void)backgroundAddUserArray:(NSArray*)userArray
{
	NSManagedObjectContext * context = [[NSManagedObjectContext alloc] init];
	[context setPersistentStoreCoordinator:[XTAppDelegate sharedInstance].persistentStoreCoordinator];

	for (NSDictionary * userDict in userArray)
	{
		[self insertUser:userDict inContext:context];
	}

	NSError * error;
	if([context hasChanges] && ![context save:&error])
	{
		DLog(@"user save error: %@", error);
	}
	context = nil;
}

-(void)backgroundAddUser:(NSDictionary*)userDict
{
	NSManagedObjectContext * context = [[NSManagedObjectContext alloc] init];
	[context setPersistentStoreCoordinator:[XTAppDelegate sharedInstance].persistentStoreCoordinator];

	[self insertUser:userDict inContext:context];

	NSError * error;
	if([context hasChanges] && ![context save:&error])
	{
		DLog(@"user save error: %@", error);
	}
	context = nil;
}

//publically accessable functions
-(void)addUsersFromArray:(NSArray*)userDictArray
{
	if(userDictArray.count == 0)
		return;

	dispatch_async(_addQueue, ^{
		[self backgroundAddUserArray:userDictArray];
	});
}

-(void)addUser:(NSDictionary*)userDict
{
	dispatch_async(_addQueue, ^{
		[self backgroundAddUser:userDict];
	});
}

@end
