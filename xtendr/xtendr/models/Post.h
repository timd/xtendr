//
//  Post.h
//  xtendr
//
//  Created by Tony Million on 20/08/2012.
//  Copyright (c) 2012 Tony Million. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class User;

@interface Post : NSManagedObject

@property (nonatomic, retain) id annotations_dict;
@property (nonatomic, retain) NSDate * created_at;
@property (nonatomic, retain) id entities_dict;
@property (nonatomic, retain) NSString * html;
@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSNumber * intid;
@property (nonatomic, retain) NSNumber * is_deleted;
@property (nonatomic, retain) NSNumber * is_mention;
@property (nonatomic, retain) NSNumber * is_mystream;
@property (nonatomic, retain) NSNumber * num_replies;
@property (nonatomic, retain) NSString * reply_to;
@property (nonatomic, retain) NSString * source_link;
@property (nonatomic, retain) NSString * source_name;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSString * thread_id;
@property (nonatomic, retain) NSString * userid;
@property (nonatomic, retain) User *user;

@end
