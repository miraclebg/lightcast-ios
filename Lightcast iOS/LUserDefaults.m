//
//  LUserDefaults.m
//  Lightcast
//
//  Created by Martin N. Kovachev on 19.01.13.
//  Copyright (c) 2013 г. Nimasystems Ltd. All rights reserved.
//

#import "LUserDefaults.h"

@implementation LUserDefaults

@synthesize
syncOnWrite;

- (void)setObject:(id)value forKey:(NSString *)defaultName
{
    /*if (!value || !defaultName)
    {
        LogError(@"Attempted to set a NIL value for UD key: %@", defaultName);
    }*/
    
    [super setObject:value forKey:defaultName];
    
    if (syncOnWrite)
    {
        [self synchronize];
    }
}

- (void)removeObjectForKey:(NSString *)defaultName
{
    if (!defaultName)
    {
        LogError(@"Attempted to pass a NIL UD key: %@", defaultName);
        lassert(false);
        return;
    }
    
    [super removeObjectForKey:defaultName];
    
    if (syncOnWrite)
    {
        [self synchronize];
    }
}

@end
