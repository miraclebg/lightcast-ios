//
//  LNSUserDefaultsPreferences.m
//  Lightcast
//
//  Created by Martin N. Kovachev on 05.01.13.
//  Copyright (c) 2013 г. Nimasystems Ltd. All rights reserved.
//

#import "LNSUserDefaultsPreferences.h"

NSString *const kLNSUserDefaultsPreferencesPrefix = @"lc:";
NSString *const kLNSUserDefaultsPreferencesEncodingSeparator = @":";
NSString *const kLNSUserDefaultsPreferencesEncodingSeparatorSlashed = @"::";

@interface LNSUserDefaultsPreferences(Private)

- (NSString*)encodedKeyForPreference:(LPreference*)preference;
- (NSString*)encodedKeyParams:(NSString*)category uniqueId:(NSInteger)uniqueId key:(NSString*)key;

- (LPreference*)preferenceForUDKey:(NSString*)udKey;

@end

@implementation LNSUserDefaultsPreferences {
    
    NSUserDefaults *_ud;
}

#pragma mark - Initialization / Finalization

- (id)initWithUserDefaults:(NSUserDefaults*)userDefaults
{
    self = [super init];
    if (self)
    {
        if (!userDefaults)
        {
            L_RELEASE(self);
            lassert(false);
            return nil;
        }
        
        _ud = [userDefaults retain];
        [_ud synchronize];
    }
    return self;
}

- (id)init
{
    return [self initWithUserDefaults:[NSUserDefaults standardUserDefaults]];
}

- (void)dealloc
{
    if (_ud)
    {
        [_ud synchronize];
    }
    
    L_RELEASE(_ud);
    
    [super dealloc];
}

#pragma mark - Abstract methods

- (LPreference*)preferenceForUniqueIdAndCategory:(NSString*)key uniqueId:(NSInteger)uniqueId category:(NSString*)category
{
    if ([NSString isNullOrEmpty:key] || [NSString isNullOrEmpty:category])
    {
        lassert(false);
        return nil;
    }
    
    NSString *udKey = [self encodedKeyParams:category uniqueId:uniqueId key:key];
    
    if (!udKey)
    {
        lassert(false);
        return nil;
    }
    
    return [self preferenceForUDKey:udKey];
}

- (BOOL)setPreference:(LPreference*)preference error:(NSError**)error
{
    if (error != NULL)
    {
        *error = nil;
    }
    
    if (!preference)
    {
        lassert(false);
        return NO;
    }
    
    NSString *udKey = [self encodedKeyForPreference:preference];
    
    if (!udKey)
    {
        lassert(false);
        return NO;
    }
    
    [_ud setObject:preference.value forKey:udKey];
    
    return YES;
}

- (NSArray*)allPreferences
{
    NSArray *udKeys = [_ud allSavedKeys];
    
    if (!udKeys)
    {
        return nil;
    }
    
    NSMutableArray *results = [[[NSMutableArray alloc] init] autorelease];
    
    for(NSString *key in udKeys)
    {
        if ([key startsWith:kLNSUserDefaultsPreferencesPrefix])
        {
            LPreference *preference = [self preferenceForUDKey:key];
            
            if (!preference)
            {
                lassert(false);
                continue;
            }
            
            [results addObject:preference];
        }
    }
    
    return results;
}

- (BOOL)removePreference:(NSString*)key category:(NSString*)category uniqueId:(NSInteger)uniqueId error:(NSError**)error;
{
    if (error != NULL)
    {
        *error = nil;
    }
    
    if ([NSString isNullOrEmpty:key] || [NSString isNullOrEmpty:category])
    {
        lassert(false);
        return NO;
    }
    
    NSString *udKey = [self encodedKeyParams:category uniqueId:uniqueId key:key];
    
    if (!udKey)
    {
        lassert(false);
        return NO;
    }
    
    return YES;
}

- (BOOL)removePreferences:(NSString*)category uniqueId:(NSInteger)uniqueId error:(NSError**)error;
{
    if (error != NULL)
    {
        *error = nil;
    }
    
    if ([NSString isNullOrEmpty:category])
    {
        lassert(false);
        return NO;
    }
    
    lassert(false);
    
    // TODO: Complete this
    
    return NO;
}

#pragma mark - Helpers

- (NSString*)encodedKeyForPreference:(LPreference*)preference
{
    if (!preference || !preference.category || !preference.key)
    {
        lassert(false);
        return nil;
    }
    
    return [self encodedKeyParams:preference.category uniqueId:preference.uniqueId key:preference.key];
}


- (NSString*)encodedKeyParams:(NSString*)category uniqueId:(NSInteger)uniqueId key:(NSString*)key
{
    if ([NSString isNullOrEmpty:category] || [NSString isNullOrEmpty:key])
    {
        lassert(false);
        return nil;
    }
    
    NSString *category_ = [category stringByReplacingOccurrencesOfString:kLNSUserDefaultsPreferencesEncodingSeparator
                                                                        withString:kLNSUserDefaultsPreferencesEncodingSeparatorSlashed];
    
    NSString *key_ = [key stringByReplacingOccurrencesOfString:kLNSUserDefaultsPreferencesEncodingSeparator
                                                              withString:kLNSUserDefaultsPreferencesEncodingSeparatorSlashed];
    
    NSString *fullKey = [NSString stringWithFormat:@"%@%@%ld%@%@",
                         category_,
                         kLNSUserDefaultsPreferencesEncodingSeparator,
                         (long)uniqueId,
                         kLNSUserDefaultsPreferencesEncodingSeparator,
                         key_
                         ];
    
    return fullKey;
}

- (LPreference*)preferenceForUDKey:(NSString*)udKey
{
    lassert(udKey);

    // parse the key
    NSArray *parsedKey = [udKey componentsSeparatedByString:kLNSUserDefaultsPreferencesEncodingSeparatorSlashed];
    
    if (!parsedKey || [parsedKey count] != 4)
    {
        return nil;
    }

    id value = [_ud objectForKey:udKey];
    
    LPreference *preference = [[[LPreference alloc] init] autorelease];
    preference.category = [parsedKey objectAtIndex:1];
    preference.uniqueId = [((NSNumber*)[parsedKey objectAtIndex:2]) intValue];
    preference.key = [parsedKey objectAtIndex:3];
    preference.value = value;

    return preference;
}

@end
