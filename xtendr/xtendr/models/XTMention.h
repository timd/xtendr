//
//  XTMention.h
//  xtendr
//
//  Created by Tony Million on 20/08/2012.
//  Copyright (c) 2012 Tony Million. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XTMention : NSObject

@property(readonly) NSString	*name;
@property(readonly) NSString	*id;
@property(readonly) NSRange		range;

-(id)initWithAttributes:(NSDictionary*)attributes;

@end
