//
//  LPreferences.m
//  Lightcast
//
//  Created by Martin N. Kovachev on 05.01.13.
//  Copyright (c) 2013 г. Nimasystems Ltd. All rights reserved.
//

#import "LPreferences.h"

@implementation LPreferences

#pragma mark - Abstract methods

- (LPreference*)preferenceForUniqueIdAndCategory:(NSString*)key uniqueId:(NSInteger)uniqueId category:(NSString*)category
{
    lassert(false);
    return nil;
}

- (BOOL)setPreference:(LPreference*)preference
{
    return [self setPreference:preference error:nil];
}

- (BOOL)setPreference:(LPreference*)preference error:(NSError**)error
{
    lassert(false);
    return NO;
}

- (NSArray*)allPreferences
{
    lassert(false);
    return nil;
}

- (BOOL)removePreference:(NSString*)key category:(NSString*)category uniqueId:(NSInteger)uniqueId error:(NSError**)error;
{
    lassert(false);
    return NO;
}

- (BOOL)removePreferences:(NSString*)category uniqueId:(NSInteger)uniqueId error:(NSError**)error;
{
    lassert(false);
    return NO;
}

#pragma mark - Preferences

- (BOOL)removePreference:(NSString*)key error:(NSError**)error;
{
    return [self removePreference:key category:kLPreferenceDefaultCategory uniqueId:0 error:error];
}

- (BOOL)removePreference:(NSString*)key category:(NSString*)category error:(NSError**)error;
{
    return [self removePreference:key category:category uniqueId:0 error:error];
}


- (BOOL)removePreferences:(NSError**)error;
{
    return [self removePreferences:kLPreferenceDefaultCategory uniqueId:0 error:error];
}

- (BOOL)removePreferences:(NSString*)category error:(NSError**)error;
{
    return [self removePreferences:category uniqueId:0 error:error];
}

- (LPreference*)preferenceForKey:(NSString*)key
{
    return [self preferenceForUniqueIdAndCategory:key uniqueId:0 category:kLPreferenceDefaultCategory];
}

- (LPreference*)preferenceForKeyAndCategory:(NSString*)key category:(NSString*)category
{
    return [self preferenceForUniqueIdAndCategory:key uniqueId:0 category:category];
}

- (LPreference*)preferenceForUniqueId:(NSString*)key uniqueId:(NSInteger)uniqueId
{
    return [self preferenceForUniqueIdAndCategory:key uniqueId:uniqueId category:kLPreferenceDefaultCategory];
}

#pragma mark - Helpers

- (BOOL)setPreferences:(NSArray*)preferences error:(NSError**)error
{
    if (error != NULL)
    {
        *error = nil;
    }
    
    if (!preferences || [preferences count])
    {
        lassert(false);
        return NO;
    }
    
    BOOL ret = NO;
    
    for(LPreference *preference in preferences)
    {
        if (![preference isKindOfClass:[LPreference class]])
        {
            lassert(false);
            continue;
        }
        
        ret = [self setPreference:preference error:error];
        
        if (!ret)
        {
            lassert(false);
            return NO;
        }
    }
    
    return YES;
}

@end
