//
//  XTPostController.h
//  xtendr
//
//  Created by Tony Million on 19/08/2012.
//  Copyright (c) 2012 Tony Million. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XTPostController : NSObject

+(XTPostController*)sharedInstance;

-(void)addPostArray:(NSArray*)postArray;
-(void)addPost:(NSDictionary*)post;

@end
