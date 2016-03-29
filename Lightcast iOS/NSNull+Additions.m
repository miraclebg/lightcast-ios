//
//  NSNull+Additions.m
//  Lightcast
//
//  Created by Martin N. Kovachev on 21.05.13.
//  Copyright (c) 2013 г. Nimasystems Ltd. All rights reserved.
//

#import "NSNull+Additions.h"

@implementation NSNull(Additions)

- (NSString *)getStrWithNullValue:(id)aKey
{
    return @"NULL";
}

- (NSString *)sqlString:(id)aKey
{
    return @"NULL";
}

- (int)sqlInt:(id)aKey
{
    return 0;
}

- (float)sqlFloat:(id)aKey
{
    return 0.0;
}

- (NSString *)sqlDate:(id)aKey
{
    return @"NULL";
}

- (int)intFromSql:(id)aKey
{
    return 0;
}

- (float)floatFromSql:(id)aKey
{
    return 0.0;
}

- (NSString*)stringFromSql:(id)aKey
{
    return @"";
}

- (id)nilifiedObjectForKey:(NSString*)key
{
    return nil;
}

- (NSInteger)intForKey:(NSString*)key
{
    return 0;
}

- (BOOL)boolForKey:(NSString*)key
{
    return NO;
}

- (double)doubleForKey:(NSString*)key
{
    return 0.0;
}

- (NSDate*)dateForKey:(NSString*)key format:(NSString*)dateFormat
{
    return nil;
}

- (NSString *)addSlashes
{
    return @"''";
}

- (NSString *)stripSlashes
{
    return @"";
}

- (NSString *)getStrWithNullValue
{
    return @"NULL";
}

- (NSString *)sqlString
{
    return [self addSlashes];
}

- (int)sqlInt
{
    return 0;
}

- (float)sqlFloat
{
    return 0.0;
}

- (NSString *)sqlDate
{
    return nil;
}

@end
