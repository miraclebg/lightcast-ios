//
//  LDelegateProxy.m
//  Lightcast
//
//  Created by Martin N. Kovachev on 12.01.13.
//  Copyright (c) 2013 г. Nimasystems Ltd. All rights reserved.
//

#import "LDelegateProxy.h"

@implementation LDelegateProxy {
    
    id _delegatesLock;
    
    NSMutableArray *_delegates;
}

@synthesize
delegates=_delegates,
count;

#pragma mark - Initialization / Finalization

- (id)init
{
    _delegates = [[NSMutableArray alloc] init];
    _delegatesLock = [[NSObject alloc] init];
    
    return self;
}

- (void)dealloc
{
    [self detachAllDelegates];
    
    L_RELEASE(_delegates);
    L_RELEASE(_delegatesLock);
    
    [super dealloc];
}

#pragma mark - Delegate setting / unsetting methods

- (void)attachDelegate:(id)delegate
{
    @synchronized(_delegatesLock)
    {
        NSValue *nonRetainedValue = [NSValue valueWithNonretainedObject:delegate];
        
        BOOL shouldAdd = YES;
        
        for(NSValue *value in self.delegates)
        {
            if ([value isEqual:delegate])
            {
                shouldAdd = NO;
                break;
            }
        }
        
        if (!shouldAdd)
        {
            return;
        }
        
        [_delegates addObject:nonRetainedValue];
        
        count++;
    }
}

- (void)detachDelegate:(id)delegate
{
    @synchronized(_delegatesLock)
    {
        NSValue *nonRetainedValue = [NSValue valueWithNonretainedObject:delegate];
        
        BOOL shouldRemove = NO;
        
        for(NSValue *value in self.delegates)
        {
            if ([value isEqual:delegate])
            {
                shouldRemove = YES;
                break;
            }
        }
        
        if (!shouldRemove)
        {
            return;
        }
        
        [_delegates removeObject:nonRetainedValue];
        
        count--;
    }
}

- (void)detachAllDelegates
{
    @synchronized(_delegatesLock)
    {
        [_delegates removeAllObjects];
        
        count = 0;
    }
}

#pragma mark - Getters / Setters

- (NSArray*)getDelegates
{
    @synchronized(_delegatesLock)
    {
        NSMutableArray *delegatesBuilder = [NSMutableArray arrayWithCapacity:[_delegates count]];
        
        for (NSValue *delegateValue in _delegates)
        {
            [delegatesBuilder addObject:[delegateValue nonretainedObjectValue]];
        }
        
        return [NSArray arrayWithArray:delegatesBuilder];
    }
}

#pragma mark - NSProxy inherited methods

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector
{
    @synchronized(_delegatesLock)
    {
        NSMethodSignature *signature = nil;
        
        for (id delegate in self.delegates)
        {
            signature = [[delegate class] instanceMethodSignatureForSelector:selector];
            
            if (signature)
            {
                /*#ifdef DEBUG
                 LogDebug(@"LDelegateProxy: found selector: %@:%s", [delegate class], sel_getName(selector));
                 #endif*/
                break;
            }
        }
        return signature;
    }
}

- (void)forwardInvocation:(NSInvocation *)invocation
{
    NSString *returnType = [NSString stringWithCString:invocation.methodSignature.methodReturnType encoding:NSUTF8StringEncoding];
    BOOL voidReturnType = [returnType isEqualToString:@"v"];
    
    @synchronized(_delegatesLock)
    {
        for (id delegate in self.delegates)
        {
            if ([delegate respondsToSelector:invocation.selector])
            {
                /*#ifdef DEBUG
                 LogDebug(@"LDelegateProxy: forwarding invocation (%@%@) to: %@", invocation, (voidReturnType ? @" :void" : @""), delegate);
                 #endif*/
                [invocation invokeWithTarget:delegate];
                
                if (!voidReturnType)
                {
                    return;
                }
            }
        }
    }
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
    @synchronized(_delegatesLock)
    {
        for (id delegate in self.delegates)
        {
            if ([delegate respondsToSelector:aSelector])
            {
                return YES;
            }
        }
        return NO;
    }
}

@end
