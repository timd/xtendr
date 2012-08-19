//
//  XTUserController.m
//  xtendr
//
//  Created by Tony Million on 19/08/2012.
//  Copyright (c) 2012 Tony Million. All rights reserved.
//

#import "XTUserController.h"

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
	}

	return self;
}

//everything funnels in here
-(void)internalUserStuff:(NSDictionary*)userDict inContext:(NSManagedObjectContext*)context
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
		user = [User userByID:ID inContext:context createIfNecessary:YES];
	}

	// right now we dont do ANY merging or whatever, we just overwrite with what we have
	user.username	= [userDict objectForKey:@"username"];
	user.name		= [userDict objectForKey:@"name"];

	NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
	user.created_at = [dateFormatter dateFromString:[userDict objectForKey:@"created_at"]];

	user.follows_you	= [userDict objectForKey:@"follows_you"];
	user.you_follow		= [userDict objectForKey:@"you_follow"];
	user.you_muted		= [userDict objectForKey:@"you_muted"];

	NSDictionary * counts = [userDict objectForKey:@"counts"];
	if(counts)
	{
		user.follows		= [counts objectForKey:@"follows"];
		user.followed_by	= [counts objectForKey:@"followed_by"];
		user.postcount		= [counts objectForKey:@"posts"];
	}

	if([userDict objectForKey:@"avatar_image"])
		user.avatar_image_dict = [userDict objectForKey:@"avatar_image"];

	if([userDict objectForKey:@"cover_image"])
		user.cover_image_dict = [userDict objectForKey:@"cover_image"];

	//DO NOT SAVE HERE
}

//stuff to process on a background thread so we dont hang the UI too much
-(void)backgroundAddUserArray:(NSArray*)userArray
{
	NSManagedObjectContext * context = [[NSManagedObjectContext alloc] init];
	[context setPersistentStoreCoordinator:[XTAppDelegate sharedInstance].persistentStoreCoordinator];

	for (NSDictionary * userDict in userArray)
	{
		[self internalUserStuff:userDict inContext:context];
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

	[self internalUserStuff:userDict inContext:context];

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
