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
 * @changed $Id: LNotification.m 75 2011-07-16 15:47:22Z mkovachev $
 * @author $Author: mkovachev $
 * @version $Revision: 75 $
 */

#import "LNotification.h"

@interface LNotification(Private) 

- (id)initWithName:(NSString*)aName;
- (id)initWithName:(NSString*)aName object:(id)anObject;

@end

@implementation LNotification

@synthesize
name,
object,
returnValue,
handled;

#pragma mark -
#pragma mark Initialization / Finalization

- (id)init {
    return [self initWithName:nil object:nil];
}

- (id)initWithName:(NSString*)aName {
    return [self initWithName:aName object:nil];
}

- (id)initWithName:(NSString*)aName object:(id)anObject {
    self = [super init];
    if (self)
    {
        name = [aName retain];
        object = [anObject retain];
        returnValue = nil;
    }
    return self;
}

- (void)dealloc {
    
    L_RELEASE(name);
    L_RELEASE(object);
    L_RELEASE(returnValue);
    
    [super dealloc];
}

+ (id)notificationWithName:(NSString*)aName {
    return [[[LNotification alloc] initWithName:aName] autorelease];
}

+ (id)notificationWithName:(NSString*)aName object:(id)anObject {
    return [[[LNotification alloc] initWithName:aName object:anObject] autorelease];
}

@end
