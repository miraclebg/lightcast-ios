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
 * @changed $Id: LStorageAdapter.m 78 2011-07-18 16:50:17Z mkovachev $
 * @author $Author: mkovachev $
 * @version $Revision: 78 $
 */

#import "LStorageAdapter.h"
#import "LStorageAdapterBehaviour.h"

@implementation LStorageAdapter

@synthesize
adapterName;

#pragma mark - 
#pragma mark Initialization / Finalization

- (id)init {
    self = [super init];
    if (self)
    {
        // abstract class protection
        if (![self conformsToProtocol:@protocol(LStorageAdapterBehaviour)])
        {
            [self doesNotRecognizeSelector:_cmd];
            L_RELEASE(self);
            return nil;
        }
        
        // init
        NSString * clName = NSStringFromClass([self class]);
        clName = [clName substringWithRange:NSMakeRange(1, 
                                                        [clName length]-14
                                                        )];
        adapterName = [clName retain];
        
        LogInfo(@"Storage adapter: %@ initialized", adapterName);
    }
    return self;
}

- (void)dealloc {
    [self sync];
    L_RELEASE(adapterName);
    [super dealloc];
}

#pragma mark -
#pragma mark Derived

- (void)set:(id)value forKey:(NSString*)key {
    return;
}

- (id)get:(NSString*)key {
    return nil;
}

- (void)sync {
    return;
}

#pragma mark - 
#pragma mark Class Factory

+ (BOOL)storageAdapterExists:(NSString*)storageAdapterName {
    
    if (!storageAdapterName) return NO;
    
    NSString * className = [NSString stringWithFormat:@"L%@StorageAdapter", storageAdapterName];
    
    Class class = NSClassFromString(className);
    
    if (![class isSubclassOfClass:[LStorageAdapter class]])
    {
        return NO;
    }
    
    return YES;
}

+ (LStorageAdapter*)classFactory:(NSString*)objectName {
    
    // storage name consists of 'L[plugin_name]StorageAdapter'
    // what should be passed to this method is only: [storage_name]
    
    if (![LStorageAdapter storageAdapterExists:objectName])
    {
        LogError(@"classFactory: storage adapter not found: %@", objectName);
        return nil;
    }
    
    NSString * className = [NSString stringWithFormat:@"L%@StorageAdapter", objectName];
    Class class = NSClassFromString(className);
    LStorageAdapter<LStorageAdapterBehaviour> * instance = [[class alloc] init];
    
    return [instance autorelease];
}

@end
