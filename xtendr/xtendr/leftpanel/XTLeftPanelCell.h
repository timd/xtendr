//
//  ZZLeftPanelCell.h
//  //
//
//  Created by Tony Million on 17/06/2012.
//  Copyright (c) 2012 OmniTyke. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BadgeLabel.h"

@interface XTLeftPanelCell : UITableViewCell

@property(weak, nonatomic) IBOutlet UILabel     *textLabel;
@property(weak, nonatomic) IBOutlet BadgeLabel  *badge;
@property(weak, nonatomic) IBOutlet UIImageView *chevron;

@end
