//
//  XTImageObject.h
//  xtendr
//
//  Created by Tony Million on 19/08/2012.
//  Copyright (c) 2012 Tony Million. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XTImageObject : NSObject

@property(readonly)	NSNumber		*width;
@property(readonly)	NSNumber		*height;

@property(readonly) NSURL			*url;

-(id)initWithAttributes:(NSDictionary*)attributes;

@end
