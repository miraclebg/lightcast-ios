/*
 * Lightcast for iOS Framework
 * Copyright (C) 2007-2011 Nimasystems Ltd
 *
 * This program is NOT free software; you cannot redistribute and/or modify
 * it's sources under any circumstances without the explicit knowledge and
 * agreement of the rightful owner of the software - Nimasystems Ltd.
 *
 * This program is distributed WITHOUT ANY WARRANTY; without even the
 * implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
 * PURPOSE.  See the LICENSE.txt file for more information.
 *
 * You should have received a copy of LICENSE.txt file along with this
 * program; if not, write to:
 * NIMASYSTEMS LTD 
 * Plovdiv, Bulgaria
 * ZIP Code: 4000
 * Address: 95 "Kapitan Raycho" Str., 6th Floor
 * General E-Mail: info@nimasystems.com
 * Tel./Fax: +359 32 395 282
 * Mobile: +359 896 610 876
 */

/**
 * File Description
 * @package File Category
 * @subpackage File Subcategory
 * @changed $Id: LNotificationDispatcher.m 227 2013-02-12 11:46:14Z mkovachev $
 * @author $Author: mkovachev $
 * @version $Revision: 227 $
 */

#import "LNotificationDispatcher.h"

static LNotificationDispatcher * sharedND = nil;

@implementation LNotificationDispatcher

#pragma mark -
#pragma mark Initialization / Finalization

- (id)init {
    self = [super init];
    if (self)
    {
        nd = [[NSNotificationCenter defaultCenter] retain];
    }
    return self;
}

- (void)dealloc {
    L_RELEASE(nd);
    [super dealloc];
}

#pragma mark -
#pragma mark Notifications

- (void)addObserver:(id)observer selector:(SEL)aSelector name:(NSString *)aName object:(id)anObject {
    
    LogDebug(@"ND: addObserver: %@ (%@)", observer, aName);
    
    [nd addObserver:observer selector:aSelector name:aName object:anObject];
}

- (void)postNotification:(LNotification *)notification {
    
    LogDebug(@"ND: postNotification: %@", notification.name);
    
    [nd postNotificationName:notification.name object:notification];
}

- (void)removeObserver:(id)observer {
    [nd removeObserver:observer];
}

- (void)removeObserver:(id)observer name:(NSString *)aName object:(id)anObject {
    [nd removeObserver:observer name:aName object:anObject];
}

#pragma mark -
#pragma mark Singleton

+ (LNotificationDispatcher*)sharedND {
	@synchronized(self)
    {
        if (sharedND == nil) 
        {
            sharedND = [[super alloc] init];
        }
    }
    return sharedND;
}

+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self)
    {
        if (sharedND == nil)
        {
            sharedND = [super allocWithZone:zone];
            return sharedND;  // assignment and return on first allocation
        }
    }
    return nil; //on subsequent allocation attempts return nil
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (id)retain {
    return self;
}

- (NSUInteger)retainCount {
    return NSUIntegerMax;
}

- (oneway void)release {
    //do nothing
}

- (id)autorelease {
    return self;
}

@end
