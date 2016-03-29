//
//  LI18nParsedString.m
//  Lightcast
//
//  Created by Martin N. Kovachev on 15.03.13.
//  Copyright (c) 2013 г. Nimasystems Ltd. All rights reserved.
//

#import "LI18nParsedString.h"

@implementation LI18nParsedString

@synthesize
comment,
key,
value;

#pragma mark - Initialization / Finalization

- (void)dealloc
{
    L_RELEASE(key);
    L_RELEASE(value);
    L_RELEASE(comment);
    
    [super dealloc];
}

#pragma mark - Helpers

- (NSString*)description
{
    NSString *description = [NSString stringWithFormat:@"%@=%@", key, value];
    return description;
}

@end
