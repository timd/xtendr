//
//  XTTimelineViewController.h
//  xtendr
//
//  Created by Tony Million on 18/08/2012.
//  Copyright (c) 2012 Tony Million. All rights reserved.
//

#import <UIKit/UIKit.h>

//TODO: switch to enum pls
#define kMyTimelineMode			(0)
#define kGlobalTimelineMode		(1)
#define kMentionsTimelineMode	(2)

@interface XTTimelineViewController : UIViewController

@property(assign, nonatomic) NSInteger		timelineMode;

@end
