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
 * @changed $Id: LNotificationDispatcher.h 75 2011-07-16 15:47:22Z mkovachev $
 * @author $Author: mkovachev $
 * @version $Revision: 75 $
 */

#import <Foundation/Foundation.h>
#import <Lightcast/LNotification.h>

@interface LNotificationDispatcher : NSObject {
    
    NSNotificationCenter* nd;
    
}

+ (LNotificationDispatcher *)sharedND;

- (void)addObserver:(id)observer selector:(SEL)aSelector name:(NSString *)aName object:(id)anObject;

- (void)postNotification:(LNotification *)notification;

- (void)removeObserver:(id)observer;
- (void)removeObserver:(id)observer name:(NSString *)aName object:(id)anObject;

@end

/*
 [[NSNotificationCenter defaultCenter] addObserver:self
 selector:@selector(applicationDidReceiveMemoryWarning:)
 name:@"StampiiAppDelegate::applicationDidReceiveMemoryWarning"
 object:nil];
 
 
 NSNotification* notification = [NSNotification notificationWithName:kStCommunicatorNotifyForOperation object:notifDict];
 NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
 [nc postNotification:notification];
 */