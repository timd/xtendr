//
//  NSAttributedString+heightforrect.m
//  //
//
//  Created by Tony Million on 14/06/2012.
//  Copyright (c) 2012 OmniTyke. All rights reserved.
//

#import "NSAttributedString+heightforrect.h"

#import <CoreText/CoreText.h>

@implementation NSAttributedString (heightforrect)

-(CGFloat)heightForWidth:(CGFloat)width
{
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)self); 
    CGSize suggestedSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, 
                                                                        CFRangeMake(0, 0), 
                                                                        NULL, 
                                                                        CGSizeMake(width, CGFLOAT_MAX), 
                                                                        NULL);
    CFRelease(framesetter);
    return suggestedSize.height;
}

@end
