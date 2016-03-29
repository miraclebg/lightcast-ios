//
//  NSBundle+Additions.m
//  Lightcast
//
//  Created by Martin N. Kovachev on 12.02.13.
//  Copyright (c) 2013 г. Nimasystems Ltd. All rights reserved.
//

#import "NSBundle+Additions.h"

@implementation NSBundle(Additions)

- (BOOL)loadNibNamedL:(NSString *)nibName owner:(id)owner topLevelObjects:(NSArray **)topLevelObjects
{
    if (topLevelObjects != NULL)
    {
        *topLevelObjects = nil;
    }
    
    if ([self respondsToSelector:@selector(loadNibNamed:owner:topLevelObjects:)])
    {
        return [self loadNibNamed:nibName owner:owner topLevelObjects:topLevelObjects];
    }
    else
    {
        return [NSBundle loadNibNamed:nibName owner:owner];
    }
}

@end
