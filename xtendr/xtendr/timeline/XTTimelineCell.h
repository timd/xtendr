//
//  XTTimelineCell.h
//  xtendr
//
//  Created by Tony Million on 18/08/2012.
//  Copyright (c) 2012 Tony Million. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XTTimelineCell : UITableViewCell


+(CGFloat)cellHeightForText:(NSString*)text withUsername:(NSString*)username;

-(void)setPostText:(NSString*)postText username:(NSString*)username;

@end
