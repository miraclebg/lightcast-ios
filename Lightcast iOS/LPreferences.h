//
//  LPreferences.h
//  Lightcast
//
//  Created by Martin N. Kovachev on 05.01.13.
//  Copyright (c) 2013 г. Nimasystems Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Lightcast/LPreference.h>

@interface LPreferences : NSObject

- (LPreference*)preferenceForKey:(NSString*)key;
- (LPreference*)preferenceForKeyAndCategory:(NSString*)key category:(NSString*)category;

- (LPreference*)preferenceForUniqueId:(NSString*)key uniqueId:(NSInteger)uniqueId;
- (LPreference*)preferenceForUniqueIdAndCategory:(NSString*)key uniqueId:(NSInteger)uniqueId category:(NSString*)category;

- (NSArray*)allPreferences;

- (BOOL)removePreference:(NSString*)key error:(NSError**)error;
- (BOOL)removePreference:(NSString*)key category:(NSString*)category error:(NSError**)error;
- (BOOL)removePreference:(NSString*)key category:(NSString*)category uniqueId:(NSInteger)uniqueId error:(NSError**)error;

- (BOOL)removePreferences:(NSError**)error;
- (BOOL)removePreferences:(NSString*)category error:(NSError**)error;
- (BOOL)removePreferences:(NSString*)category uniqueId:(NSInteger)uniqueId error:(NSError**)error;

- (BOOL)setPreference:(LPreference*)preference;
- (BOOL)setPreference:(LPreference*)preference error:(NSError**)error;
- (BOOL)setPreferences:(NSArray*)preferences error:(NSError**)error;

@end
