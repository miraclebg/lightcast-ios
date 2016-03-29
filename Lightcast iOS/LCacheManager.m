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
 * @changed $Id: LCacheManager.m 227 2013-02-12 11:46:14Z mkovachev $
 * @author $Author: mkovachev $
 * @version $Revision: 227 $
 */

#import <Lightcast/LCacheManager.h>

static LCacheManager * cacheManager = nil;
const NSString * cacheManagerDefaultBackend = @"LCacheFIFO";

@implementation LCacheManager

@synthesize cacheBackend, setRequests, getRequests;

#pragma mark Cache Methods

- (BOOL)set:(NSString *)identifier object:(id)aObject {
	setRequests++;
	return [cacheBackend set:identifier object:aObject];
}

- (id)get:(NSString *)aIdentifier {
	getRequests++;
	return [cacheBackend get:aIdentifier];
}

- (BOOL)remove:(NSString *)aIdentifier {
	return [cacheBackend remove:aIdentifier];
}

- (BOOL)has:(NSString *)aIdentifier {
	return [cacheBackend has:aIdentifier];
}

- (void)clear {
	return [cacheBackend clear];
}

- (void)didReceiveMemoryWarning:(NSDictionary*)additionalInformation {
	
	// clear the cached objects
	[cacheBackend clear];
	
	LogWarn(@"CacheManager: Cache cleared due to low memory warning");
}

- (id)initWithCacheBackend:(NSObject<LCacheProtocol> *)aCacheBackend {
	self = [super init];
	if (self != nil)
	{
		cacheBackend = aCacheBackend;
	}
	return self;
}

- (id)init {
	
	id backend;
	
	@try
	{
		backend = [[NSClassFromString((NSString *)cacheManagerDefaultBackend) alloc] init];
	}
	@catch (NSException * e) 
	{
        LogError(@"Cache backend is missing: %@", [e description]);
        
        return nil;
	}
		
	return [self initWithCacheBackend:backend];
}

- (void)dealloc {

	L_RELEASE(cacheBackend);
	[super dealloc];
}

#pragma mark - Singleton Pattern

+ (LCacheManager*)sharedCacheManager {
	@synchronized(self)
    {
        if (cacheManager == nil) 
        {
            cacheManager = [[super alloc] init];
        }
    }
    return cacheManager;
}

+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self)
    {
        if (cacheManager == nil)
        {
            cacheManager = [super allocWithZone:zone];
            return cacheManager;  // assignment and return on first allocation
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
