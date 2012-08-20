//
//  Post+coolstuff.m
//  xtendr
//
//  Created by Tony Million on 19/08/2012.
//  Copyright (c) 2012 Tony Million. All rights reserved.
//

#import "Post+coolstuff.h"

@implementation Post (coolstuff)

+(Post*)postByID:(NSString*)id inContext:(NSManagedObjectContext*)context
{
	NSFetchRequest *request= [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Post"
											  inManagedObjectContext:context];
	[request setEntity:entity];

	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id = %@", id];
	[request setPredicate:predicate];
	[request setFetchLimit:1];

	NSError *error;
	//so if the object isn't in core data it returns a 0 length array
	// at which point lastObject returns nil
	// yay
	Post * entry = [[context executeFetchRequest:request
										   error:&error] lastObject];

	return entry;
}

+(Post*)postByID:(NSString*)ID inContext:(NSManagedObjectContext*)context createIfNecessary:(BOOL)create
{
	Post * temp = [Post postByID:ID inContext:context];

	if(!temp && create)
	{
		//TODO: create object and assign ID
		temp = [NSEntityDescription insertNewObjectForEntityForName:@"Post"
											 inManagedObjectContext:context];
		temp.id		= ID;
		temp.intid	= [NSNumber numberWithLongLong:[ID longLongValue]];

	}

	return temp;
}

@end
