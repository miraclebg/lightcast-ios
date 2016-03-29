//
//  LWeakRefObject.m
//  Lightcast
//
//  Created by Martin Kovachev on 27.12.13.
//  Copyright (c) 2013 г. Nimasystems Ltd. All rights reserved.
//

#import "LWeakRefObject.h"

@implementation LWeakRefObject

- (id)initWithObject:(id) object {
    if (self = [super init]) {
        nonretainedObjectValue = originalObjectValue = object;
    }
    return self;
}

+ (LWeakRefObject*)weakReferenceWithObject:(id) object {
    return [[self alloc] initWithObject:object];
}

- (id)nonretainedObjectValue { return nonretainedObjectValue; }
- (void *)originalObjectValue { return (__bridge void *) originalObjectValue; }

// To work appropriately with NSSet
- (BOOL)isEqual:(LWeakRefObject *)object {
    if (![object isKindOfClass:[LWeakRefObject class]]) return NO;
    return object.originalObjectValue == self.originalObjectValue;
}

@end