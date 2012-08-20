//
//  XTTimelineCell.h
//  xtendr
//
//  Created by Tony Million on 18/08/2012.
//  Copyright (c) 2012 Tony Million. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Post.h"

typedef void (^faceTapBlock)(Post  *post);

@interface XTTimelineCell : UITableViewCell

@property(nonatomic, copy) faceTapBlock		faceTapBlock;
@property(nonatomic, strong) Post			*post;

+(CGFloat)cellHeightForText:(NSString*)text withUsername:(NSString*)username;
-(void)setPostText:(NSString*)postText username:(NSString*)username pictureURL:(NSURL*)picURL;

+(CGFloat)cellHeightForPost:(Post*)post;
-(void)setPost:(Post*)post;


@end
