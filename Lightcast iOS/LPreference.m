//
//  LPreference.m
//  Lightcast
//
//  Created by Martin N. Kovachev on 05.01.13.
//  Copyright (c) 2013 г. Nimasystems Ltd. All rights reserved.
//

#import "LPreference.h"

NSString *const kLPreferenceDefaultCategory = @"global";

NSString *const kLPreferenceCategoryKey = @"Category";
NSString *const kLPreferenceUniqueIdKey = @"UniqueID";
NSString *const kLPreferenceKeyKey = @"Key";
NSString *const kLPreferenceValueKey = @"Value";

@implementation LPreference

@synthesize
category,
uniqueId,
key,
value;

#pragma mark - Initialization / Finalization

- (id)initWithKey:(NSString*)aKey value:(id)aValue
{
    return [self initWithCategoryAndUniqueId:kLPreferenceDefaultCategory uniqueId:0 key:aKey value:aValue];
}

- (id)initWithCategory:(NSString*)aCategory key:(NSString*)aKey value:(id)aValue
{
    return [self initWithCategoryAndUniqueId:aCategory uniqueId:0 key:aKey value:aValue];
}

- (id)initWithCategoryAndUniqueId:(NSString*)aCategory uniqueId:(NSInteger)aUniqueId key:(NSString*)aKey value:(id)aValue
{
    self = [super init];
    if (self)
    {
        if ([NSString isNullOrEmpty:aCategory] || [NSString isNullOrEmpty:aKey])
        {
            L_RELEASE(self);
            lassert(false);
            return nil;
        }
        
        category = [aCategory copy];
        uniqueId = aUniqueId;
        key = [aKey copy];
        value = [aValue copy];
    }
    return self;
}

- (id)init
{
    return [self initWithCategoryAndUniqueId:nil uniqueId:0 key:nil value:nil];
}

- (void)dealloc
{
    L_RELEASE(category);
    L_RELEASE(key);
    L_RELEASE(value);
    
    [super dealloc];
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    LPreference *pref = [[LPreference allocWithZone:zone] initWithKey:self.key value:self.value];
    
    if (!pref)
    {
        return nil;
    }
    
    pref.category = self.category;
    pref.uniqueId = self.uniqueId;
    pref.key = self.key;
    pref.value = self.value;
    
    return pref;
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:category forKey:kLPreferenceCategoryKey];
    [aCoder encodeObject:key forKey:kLPreferenceKeyKey];
    [aCoder encodeInteger:uniqueId forKey:kLPreferenceUniqueIdKey];
    [aCoder encodeObject:value forKey:kLPreferenceValueKey];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self)
    {
        category = [aDecoder decodeObjectForKey:kLPreferenceCategoryKey];
        key = [aDecoder decodeObjectForKey:kLPreferenceKeyKey];
        uniqueId = [aDecoder decodeIntegerForKey:kLPreferenceUniqueIdKey];
        value = [aDecoder decodeObjectForKey:kLPreferenceValueKey];
    }
    return self;
}

#pragma mark - Helpers

- (NSString*)description
{
    NSString *description = [NSString stringWithFormat:@"%@ (%ld) :: %@: %@",
                             category,
                             (long)uniqueId,
                             key,
                             value
                             ];
    return description;
}

#pragma mark - Converters

- (NSNumber*)convertedFromPossibleNumericalValueToNumericalValue:(id)value_
{
    if (!value_)
    {
        return nil;
    }
    
    NSNumber *ret = nil;
    
    if ([value_ isKindOfClass:[NSString class]])
    {
        ret = [NSNumber numberWithInt:[((NSString*)value_) intValue]];
    }
    else if ([value_ isKindOfClass:[NSNumber class]])
    {
        return value_;
    }
    else
    {
        lassert(false);
    }
    
    return ret;
}

- (BOOL)boolValue
{
    NSNumber *n = [self convertedFromPossibleNumericalValueToNumericalValue:value];
    
    BOOL v = n ? [n boolValue] : NO;
    
    return v;
}

- (NSInteger)intValue
{
    NSNumber *n = [self convertedFromPossibleNumericalValueToNumericalValue:value];
    
    NSInteger v = n ? [n intValue] : 0;
    
    return v;
}

- (double)doubleValue
{
    NSNumber *n = [self convertedFromPossibleNumericalValueToNumericalValue:value];
    
    double v = n ? [n doubleValue] : 0;
    
    return v;
}

- (float)floatValue
{
    NSNumber *n = [self convertedFromPossibleNumericalValueToNumericalValue:value];
    
    double v = n ? [n floatValue] : 0;
    
    return v;
}

- (long long)longLongValue
{
    NSNumber *n = [self convertedFromPossibleNumericalValueToNumericalValue:value];
    
    long long v = n ? [n longLongValue] : 0;
    
    return v;
}

- (NSString*)stringValue
{
    return value;
}

- (NSDate*)dateValue
{
    NSDate *ret = [value isKindOfClass:[NSDate class]] ? value : [LDateTimeUtils dateFromString:value dateFormat:SQL_DATETIME_FORMAT];
    return ret;
}

@end
