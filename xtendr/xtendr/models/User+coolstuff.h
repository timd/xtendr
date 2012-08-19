//
//  User+coolstuff.h
//  xtendr
//
//  Created by Tony Million on 19/08/2012.
//  Copyright (c) 2012 Tony Million. All rights reserved.
//

#import "User.h"
#import	"XTImageObject.h"

@interface User (coolstuff)

+(User*)userByID:(NSString*)id inContext:(NSManagedObjectContext*)context;
+(User*)userByID:(NSString*)id inContext:(NSManagedObjectContext*)context createIfNecessary:(BOOL)create;

-(XTImageObject*)avatar;
-(XTImageObject*)cover;

@end
