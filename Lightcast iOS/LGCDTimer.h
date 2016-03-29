//
//  LGCDTimer.h
//  Lightcast
//
//  Created by Martin N. Kovachev on 07.01.13.
//  Copyright (c) 2013 г. Nimasystems Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Lightcast/LGCDTimerDelegate.h>

@interface LGCDTimer : NSObject

@property (readonly) BOOL isRunning;
@property (assign) id<LGCDTimerDelegate> timerDelegate;

- (id)initWithTimeout:(NSTimeInterval)timeout;
- (void)invalidate;

- (void)start;
- (void)stop;

@end
