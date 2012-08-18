//
//  ZZLeftPanelCell.m
//  //
//
//  Created by Tony Million on 17/06/2012.
//  Copyright (c) 2012 OmniTyke. All rights reserved.
//

#import "XTLeftPanelCell.h"

@implementation XTLeftPanelCell

@synthesize textLabel;
@synthesize badge;
@synthesize chevron;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)awakeFromNib
{
    [super awakeFromNib];

    self.selectedBackgroundView = [[UIView alloc] init];
    self.selectedBackgroundView.backgroundColor = [UIColor colorWithWhite:0 
                                                                    alpha:0.4];
    
    
    [self.badge setStyle:BadgeLabelStyleMail];
    self.badge.backgroundColor = [UIColor redColor];

}

@end
