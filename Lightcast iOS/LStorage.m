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
 * @changed $Id: LStorage.m 189 2012-12-21 10:37:46Z mkovachev $
 * @author $Author: mkovachev $
 * @version $Revision: 189 $
 */

#import "LStorage.h"

NSString *const lnStorageInitialized = @"notifications.StorageInitialized";

@implementation LStorage

#pragma mark - 
#pragma mark Initialization / Finalization

- (id)init {
    return [self initWithAdapter:nil];
}

- (id)initWithAdapter:(LStorageAdapter<LStorageAdapterBehaviour>*)anAdapter {
    self = [super init];
    if (self)
    {
        adapter = [anAdapter retain];
    }
    return self;
}

- (BOOL)initializeAdapter:(LStorageAdapter<LStorageAdapterBehaviour>*)anAdapter connectionString:(NSString*)connectionString error:(NSError **)err {
    
    return NO;
}

- (void)dealloc {
    L_RELEASE(adapter);
    [super dealloc];
}

#pragma mark - 
#pragma mark LSystemObject derived

- (BOOL)initialize:(LCAppConfiguration*)aConfiguration notificationDispatcher:(LNotificationDispatcher*)aDispatcher error:(NSError**)error {
    
    if (![super initialize:aConfiguration notificationDispatcher:aDispatcher error:error]) return NO;
    
    // notify everyone
    [nd postNotification:[LNotification notificationWithName:lnStorageInitialized object:self]];
    
    return YES;
}

#pragma mark -
#pragma mark Values


- (void)set:(id)value forKey:(NSString*)key {
    [adapter set:value forKey:key];
}

- (id)get:(NSString*)key {
    return [adapter get:key];
}

#pragma mark -
#pragma mark Adapter methods

- (void)sync {
    [adapter sync];
}

@end
