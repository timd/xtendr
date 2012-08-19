//
//  XTNewPostCell.m
//  xtendr
//
//  Created by Tony Million on 19/08/2012.
//  Copyright (c) 2012 Tony Million. All rights reserved.
//

#import "XTNewPostCell.h"

@interface XTNewPostCell ()

@property(weak) IBOutlet UIImageView	*userPictureImageView;
@property(weak) IBOutlet UIImageView	*textBackgroundImageView;



@end

@implementation XTNewPostCell

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

	UIImage * image = [UIImage imageNamed:@"post-thoughtbubble"];

	image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(23, 20, 20, 8)];

    self.textBackgroundImageView.image = image;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
