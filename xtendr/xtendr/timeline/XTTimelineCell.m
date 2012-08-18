//
//  XTTimelineCell.m
//  xtendr
//
//  Created by Tony Million on 18/08/2012.
//  Copyright (c) 2012 Tony Million. All rights reserved.
//

#import "XTTimelineCell.h"
#import <QuartzCore/QuartzCore.h>

#import "TTTAttributedLabel.h"

#import "NSAttributedString+heightforrect.h"

#import "UIImageView+NetworkLoad.h"

#import "XTAppDelegate.h"


@interface XTTimelineCell ()

@property(weak) IBOutlet UIImageView			*userPhoto;
@property(weak) IBOutlet UIImageView			*thoughtBubbleBackImageView;
@property(weak) IBOutlet TTTAttributedLabel		*thoughtLabel;

@end

@implementation XTTimelineCell

+(NSAttributedString*)boldString:(NSString*)string
{
    CTFontRef font      = CTFontCreateWithName(CFSTR("HelveticaNeue-Medium"), 15.0, NULL);

    NSMutableAttributedString * returnString = [[NSMutableAttributedString alloc] initWithString:string];
    [returnString addAttribute:(id)kCTFontAttributeName
                         value:(__bridge id)font
                         range:NSMakeRange(0, string.length)];

    CFRelease(font);

    return returnString;
}

+(NSAttributedString*)normalString:(NSString*)string
{
    CTFontRef font      = CTFontCreateWithName(CFSTR("HelveticaNeue"), 14.0, NULL);

    NSMutableAttributedString * returnString = [[NSMutableAttributedString alloc] initWithString:string];
    [returnString addAttribute:(id)kCTFontAttributeName
                         value:(__bridge id)font
                         range:NSMakeRange(0, string.length)];

    CFRelease(font);

    return returnString;
}

+(NSAttributedString*)attributedStringForPost:(NSString*)text andUsername:(NSString*)username
{
    NSMutableAttributedString * returnString = [[NSMutableAttributedString alloc] init];

	[returnString appendAttributedString:[XTTimelineCell boldString:username]];
	[returnString appendAttributedString:[XTTimelineCell normalString:@" "]];
	[returnString appendAttributedString:[XTTimelineCell normalString:text]];

    return returnString;
}

+(CGFloat)cellHeightForText:(NSString*)text withUsername:(NSString*)username
{
	CGFloat height = [[XTTimelineCell attributedStringForPost:text andUsername:username] heightForWidth:240.0];
	return MAX(10+height+3+16+10, 60);
}

-(void)awakeFromNib
{
	[super awakeFromNib];

	CALayer * l = self.userPhoto.layer;

    l.masksToBounds = YES;
    l.cornerRadius  = 3;
    l.borderWidth   = 1;
    l.borderColor   = [UIColor darkGrayColor].CGColor;

    UITapGestureRecognizer *_recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                  action:@selector(userPhotoTapped:)];

    [self.userPhoto addGestureRecognizer:_recognizer];
    self.userPhoto.userInteractionEnabled = YES;


	UIImage * image = [UIImage imageNamed:@"post-thoughtbubble"];

	image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(23, 20, 20, 8)];

    self.thoughtBubbleBackImageView.image = image;
}

-(void)layoutSubviews
{
    [super layoutSubviews];

    CGRect oldFrame = self.thoughtBubbleBackImageView.frame;
    oldFrame.size.height = self.frame.size.height - 8;
    self.thoughtBubbleBackImageView.frame = oldFrame;

    oldFrame = self.thoughtLabel.frame;
    oldFrame.size.height = self.frame.size.height - 20;
    self.thoughtLabel.frame = oldFrame;
}

-(void)setPostText:(NSString*)postText username:(NSString*)username pictureURL:(NSString*)picURL
{
	self.thoughtLabel.text = [XTTimelineCell attributedStringForPost:postText andUsername:username];

	[self.userPhoto loadFromURL:[NSURL URLWithString:picURL]
			   placeholderImage:[UIImage imageNamed:@"unknown"]
					  fromCache:[XTAppDelegate sharedInstance].userProfilePicCache];
}


-(IBAction)userPhotoTapped:(id)sender
{
	
}

@end
