//
//  LPreference.h
//  Lightcast
//
//  Created by Martin N. Kovachev on 05.01.13.
//  Copyright (c) 2013 г. Nimasystems Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const kLPreferenceDefaultCategory;

@interface LPreference : NSObject <NSCoding, NSCopying>

@property (copy) NSString *category;
@property NSInteger uniqueId;
@property (copy) NSString *key;
@property (copy) id value;

- (id)initWithKey:(NSString*)aKey value:(id)aValue;
- (id)initWithCategory:(NSString*)aCategory key:(NSString*)aKey value:(id)aValue;
- (id)initWithCategoryAndUniqueId:(NSString*)aCategory uniqueId:(NSInteger)aUniqueId key:(NSString*)aKey value:(id)aValue;

- (NSInteger)intValue;
- (BOOL)boolValue;
- (double)doubleValue;
- (float)floatValue;
- (long long)longLongValue;
- (NSDate*)dateValue;

@end
