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


@interface XTTimelineCell () <TTTAttributedLabelDelegate>

@property(weak) IBOutlet UIImageView			*userPhoto;
@property(weak) IBOutlet UIImageView			*thoughtBubbleBackImageView;
@property(weak) IBOutlet TTTAttributedLabel		*thoughtLabel;

@property(assign) CGFloat						labelHeight;

@end

@implementation XTTimelineCell

+(NSAttributedString*)boldString:(NSString*)string
{
    CTFontRef font      = CTFontCreateWithName(CFSTR("HelveticaNeue-Medium"), 17.0, NULL);

    NSMutableAttributedString * returnString = [[NSMutableAttributedString alloc] initWithString:string];
    [returnString addAttribute:(id)kCTFontAttributeName
                         value:(__bridge id)font
                         range:NSMakeRange(0, string.length)];

    CFRelease(font);

    return returnString;
}

+(NSAttributedString*)normalString:(NSString*)string
{
    CTFontRef font      = CTFontCreateWithName(CFSTR("HelveticaNeue"), 16.0, NULL);

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

	self.thoughtLabel.dataDetectorTypes = UIDataDetectorTypeLink;
    self.thoughtLabel.delegate = self;

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

	self.thoughtBubbleBackImageView.frame = CGRectMake(45, 5, 263, self.labelHeight+15);
	self.thoughtLabel.frame = CGRectMake(60, 10, 240, self.labelHeight);

}

-(void)setPostText:(NSString*)postText username:(NSString*)username pictureURL:(NSString*)picURL
{
	NSAttributedString* attrText = [XTTimelineCell attributedStringForPost:postText andUsername:username];
	self.thoughtLabel.text = attrText;

	self.labelHeight = [attrText heightForWidth:240];

	[self.userPhoto loadFromURL:[NSURL URLWithString:picURL]
			   placeholderImage:[UIImage imageNamed:@"unknown"]
					  fromCache:[XTAppDelegate sharedInstance].userProfilePicCache];
}


-(IBAction)userPhotoTapped:(id)sender
{
	DLog(@"USER PHOTO TAPPED!");
	if(self.faceTapBlock)
	{
		self.faceTapBlock(self);
	}
}

-(void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url
{
    DLog(@"URL TAPPED: %@", url);

	//TODO: googlechrome://www.google.com

    [[UIApplication sharedApplication] openURL:url];
}

@end
