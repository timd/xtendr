//
//  XTUserController.h
//  xtendr
//
//  Created by Tony Million on 19/08/2012.
//  Copyright (c) 2012 Tony Million. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XTUserController : NSObject

+(XTUserController*)sharedInstance;

-(void)addUsersFromArray:(NSArray*)userDictArray;
-(void)addUser:(NSDictionary*)userDict;

@end
