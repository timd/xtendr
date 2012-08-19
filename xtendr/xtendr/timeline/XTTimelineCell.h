//
//  XTTimelineCell.h
//  xtendr
//
//  Created by Tony Million on 18/08/2012.
//  Copyright (c) 2012 Tony Million. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XTTimelineCell;

typedef void (^faceTapBlock)(XTTimelineCell  *cell);

@interface XTTimelineCell : UITableViewCell

@property(nonatomic, copy) faceTapBlock		faceTapBlock;
@property(nonatomic, strong) NSDictionary		*post;

+(CGFloat)cellHeightForText:(NSString*)text withUsername:(NSString*)username;

-(void)setPostText:(NSString*)postText username:(NSString*)username pictureURL:(NSString*)picURL;

@end
