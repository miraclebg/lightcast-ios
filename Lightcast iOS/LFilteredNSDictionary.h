//
//  LFilteredNSDictionary.h
//  Lightcast
//
//  Created by Martin N. Kovachev on 10.01.13.
//  Copyright (c) 2013 г. Nimasystems Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef BOOL (^LFilteredNSDictionaryExecuteFilterBlock)(id key, id value);

@class LFilteredNSDictionary;

@protocol LFilteredNSDictionaryDelegate <NSObject>

@optional

- (void)filteredNSDictionaryDidSetFilter:(LFilteredNSDictionary*)dictinary;
- (void)filteredNSDictionaryDidResetFilter:(LFilteredNSDictionary*)dictinary;

@end

@interface LFilteredNSDictionary : NSDictionary

@property (nonatomic, readonly, getter = getIsFiltered) BOOL isFiltered;
@property (nonatomic, assign) id<LFilteredNSDictionaryDelegate> filterDelegate;
@property (nonatomic, retain, readonly) NSDictionary *unfilteredDictionary;

- (void)setFilter:(LFilteredNSDictionaryExecuteFilterBlock)block;
- (void)resetFilter;

- (void)setObject:(id)object forKey:(id<NSCopying>)key;

@end