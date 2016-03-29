//
//  LGDCTimerDelegate.h
//  Lightcast
//
//  Created by Martin N. Kovachev on 07.01.13.
//  Copyright (c) 2013 г. Nimasystems Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LGCDTimer;

@protocol LGCDTimerDelegate <NSObject>

@optional

- (void)gcdTimerFired:(LGCDTimer*)timer;

@end
