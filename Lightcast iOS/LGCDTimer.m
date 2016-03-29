//
//  LGCDTimer.m
//  Lightcast
//
//  Created by Martin N. Kovachev on 07.01.13.
//  Copyright (c) 2013 г. Nimasystems Ltd. All rights reserved.
//

#import "LGCDTimer.h"

// original source: http://www.fieryrobot.com/blog/2010/07/10/a-watchdog-timer-in-gcd/

@implementation LGCDTimer {
    
    dispatch_queue_t      _queue;
    dispatch_source_t     _timer;
    
    NSTimeInterval _timeout;
}

@synthesize
isRunning,
timerDelegate;

#pragma mark - Initialization / Finalization

- (id)initWithTimeout:(NSTimeInterval)timeout
{
    self = [super init];
    if (self)
    {
        _queue = dispatch_queue_create("com.lightcast.LGCDTimer", DISPATCH_QUEUE_SERIAL);
        
        if (!_queue || !timeout)
        {
            L_RELEASE(self);
            lassert(false);
            return nil;
        }
        
        _timeout = timeout;
        
        isRunning = NO;
    }
    return self;
}

- (id)init
{
    return [self initWithTimeout:1.0];
}

- (void)dealloc
{
    [self stopRelease];
    
    [super dealloc];
}

#pragma mark - Timer methods

- (void)invalidate {
    [self stop];
}

- (void)stop
{
    if (_queue) {
        dispatch_sync(_queue, ^{
            [self stopInternal];
        });
    }
}

- (void)stopRelease
{
    if (_queue) {
        dispatch_sync(_queue, ^{
            [self stopInternal];
        });
        dispatch_release(_queue);
        _queue = nil;
    }
}

- (void)stopInternal {
    if (!isRunning) {
        return;
    }
    
    if (_timer)
    {
        dispatch_source_cancel(_timer);
        dispatch_release(_timer);
        _timer = nil;
    }
    
    isRunning = NO;
}

- (void)start
{
    dispatch_async(_queue, ^{
        [self startInternal];
    });
}

- (void)startInternal {
    if (isRunning)
    {
        return;
    }
    
    lassert(!_timer);
    
    // create our timer source
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, _queue);
    
    if (!_timer)
    {
        lassert(false);
        return;
    }
    
    lassert(_timer);
    
    // set the time to fire (we're only going to fire once,
    // so just fill in the initial time).
    dispatch_source_set_timer(_timer, dispatch_time(DISPATCH_TIME_NOW, _timeout * NSEC_PER_SEC), 0, 0);
    
    dispatch_source_set_event_handler(_timer, ^{
        @try {
            if (isRunning)
            {
                if (timerDelegate && [timerDelegate respondsToSelector:@selector(gcdTimerFired:)])
                {
                    [timerDelegate gcdTimerFired:self];
                }
                
                // someone might have stopped the timer while we reach this point
                if (isRunning) {
                    if (_timer) {
                        dispatch_source_cancel(_timer);
                        dispatch_release(_timer);
                        _timer = nil;
                    }
                    isRunning = NO;
                    
                    [self startInternal];
                }
            }
        }
        @catch (NSException *e) {
            LogError(@"Unhandled exception while running timer: %@", e);
            lassert(false);
        }
    });
    
    isRunning = YES;
    
    // now that our timer is all set to go, start it
    dispatch_resume(_timer);
}

@end
