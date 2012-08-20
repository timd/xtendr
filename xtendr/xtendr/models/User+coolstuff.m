//
//  User+coolstuff.m
//  xtendr
//
//  Created by Tony Million on 19/08/2012.
//  Copyright (c) 2012 Tony Million. All rights reserved.
//

#import "User+coolstuff.h"
#import "XTImageObject.h"
@implementation User (coolstuff)

+(User*)userByID:(NSString*)id inContext:(NSManagedObjectContext*)context
{
	NSFetchRequest *request= [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"User"
											  inManagedObjectContext:context];
	[request setEntity:entity];

	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id = %@", id];
	[request setPredicate:predicate];
	[request setFetchLimit:1];

	NSError *error = nil;
	//so if the object isn't in core data it returns a 0 length array
	// at which point lastObject returns nil
	// yay
	User * entry = [[context executeFetchRequest:request
										   error:&error] lastObject];

	if(error)
	{
		DLog(@"fetch Error: %@", error);
	}

	return entry;
}

+(User*)userByID:(NSString*)ID inContext:(NSManagedObjectContext*)context createIfNecessary:(BOOL)create
{
	User * temp = [User userByID:ID inContext:context];

	if(!temp && create)
	{
		//TODO: create object and assign ID
		temp = [NSEntityDescription insertNewObjectForEntityForName:@"User"
											 inManagedObjectContext:context];
		temp.id = ID;
		temp.intid	= [NSNumber numberWithLongLong:[ID longLongValue]];
	}

	return temp;
}

-(XTImageObject*)avatar
{
	XTImageObject *image;

	if(self.avatar_image_dict)
	{
		image = [[XTImageObject alloc] initWithAttributes:self.avatar_image_dict];
	}

	return image;
}

-(XTImageObject*)cover
{
	XTImageObject *image;

	if(self.cover_image_dict)
	{
		image = [[XTImageObject alloc] initWithAttributes:self.cover_image_dict];
	}

	return image;

}


@end
