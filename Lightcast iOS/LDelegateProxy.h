//
//  LDelegateProxy.h
//  Lightcast
//
//  Created by Martin N. Kovachev on 12.01.13.
//  Copyright (c) 2013 г. Nimasystems Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LDelegateProxy : NSProxy

@property (nonatomic, retain, readonly, getter = getDelegates) NSArray *delegates;
@property (nonatomic, readonly) NSInteger count;

- (id)init;

- (void)attachDelegate:(id)delegate;
- (void)detachDelegate:(id)delegate;

- (void)detachAllDelegates;

@end
