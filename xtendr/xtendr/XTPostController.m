//
//  XTPostController.m
//  xtendr
//
//  Created by Tony Million on 19/08/2012.
//  Copyright (c) 2012 Tony Million. All rights reserved.
//

#import "XTPostController.h"

#import "Post.h"
#import "Post+coolstuff.h"

@interface XTPostController ()

@property(strong) NSDateFormatter		*ISO8601Formatter;

@end

@implementation XTPostController
{
	dispatch_queue_t	_addQueue;
}

+(XTPostController*)sharedInstance
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
		_addQueue = dispatch_queue_create("com.tonymillion.postaddqueue", DISPATCH_QUEUE_SERIAL);
		self.ISO8601Formatter = [[NSDateFormatter alloc] init];
		[self.ISO8601Formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
	}

	return self;
}

//everything funnels in here
-(void)internalPostStuff:(NSDictionary*)postDict
			   inContext:(NSManagedObjectContext*)context
			   isMention:(BOOL)isMention
			  ifMyStream:(BOOL)isMyStream
{
	NSString * ID = [postDict valueForKey:@"id"];

	Post * post = [Post postByID:ID inContext:context];
	if(post)
	{
		//merge user
		DLog(@"Merge post");
	}
	else
	{
		//create user
		DLog(@"Create post");
		post = [Post postByID:ID inContext:context createIfNecessary:YES];
	}

	//right now we dont do ANY merging or whatever, we just overwrite with what we have
	//TODO: extract user object and link!

	post.created_at		= [self.ISO8601Formatter dateFromString:[postDict objectForKey:@"created_at"]];

	post.text			= [postDict objectForKey:@"text"];
	post.html			= [postDict objectForKey:@"html"];

	post.reply_to		= [postDict objectForKey:@"reply_to"];
	post.thread_id		= [postDict objectForKey:@"thread_id"];
	post.num_replies	= [postDict objectForKey:@"num_replies"];
	post.is_deleted		= [postDict objectForKey:@"is_deleted"];


	post.annotations	= [postDict objectForKey:@"annotations"];
	post.entities		= [postDict objectForKey:@"entities"];

	NSDictionary * source = [postDict objectForKey:@"source"];
	post.source_link	= [source objectForKey:@"link"];
	post.source_name	= [source objectForKey:@"name"];

	if(isMention)
	{
		post.is_mention = [NSNumber numberWithBool:YES];
	}

	if(isMyStream)
	{
		post.is_mystream = [NSNumber numberWithBool:YES];
	}


	//DO NOT SAVE HERE
}

-(void)backgroundAddPostArray:(NSArray*)postArray
{
	NSManagedObjectContext * context = [[NSManagedObjectContext alloc] init];
	[context setPersistentStoreCoordinator:[XTAppDelegate sharedInstance].persistentStoreCoordinator];

	for (NSDictionary * postDict in postArray)
	{
		[self internalPostStuff:postDict inContext:context isMention:NO ifMyStream:NO];
	}

	NSError * error;
	if([context hasChanges] && ![context save:&error])
	{
		DLog(@"user save error: %@", error);
	}
	context = nil;
}

-(void)backgroundAddPost:(NSDictionary*)postDict
{
	NSManagedObjectContext * context = [[NSManagedObjectContext alloc] init];
	[context setPersistentStoreCoordinator:[XTAppDelegate sharedInstance].persistentStoreCoordinator];

	[self internalPostStuff:postDict inContext:context isMention:NO ifMyStream:NO];

	NSError * error;
	if([context hasChanges] && ![context save:&error])
	{
		DLog(@"user save error: %@", error);
	}
	context = nil;
}

-(void)addPostArray:(NSArray*)postArray
{
	if(postArray.count == 0)
		return;

	dispatch_async(_addQueue, ^{
		[self backgroundAddPostArray:postArray];
	});
}

-(void)addPost:(NSDictionary*)postDict
{
	dispatch_async(_addQueue, ^{
		[self backgroundAddPost:postDict];
	});
}

@end
