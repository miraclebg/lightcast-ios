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
 * @changed $Id: LCacheManager.h 357 2015-04-16 06:29:29Z mkovachev $
 * @author $Author: mkovachev $
 * @version $Revision: 357 $
 */

#import <Lightcast/LCacheProtocol.h>

/**
 *	@brief The main caching engine used in the application
 *	Can use cache backends conforming to 'CacheProtocol' (like CacheFIFO, which is the default backend)
 *	
 *	@author Martin Kovachev (miracle@nimasystems.com), Nimasystems Ltd
 */
@interface LCacheManager : NSObject {

	NSObject<LCacheProtocol> * cacheBackend;
	
	int setRequests;
	int getRequests;
}

@property (nonatomic, retain, readonly) NSObject <LCacheProtocol> * cacheBackend;
@property int setRequests;
@property int getRequests;

/** Initializes the cache manager with a cache backend store - conforming to 'CacheProtocol'
 *	@param NSObject<CacheProtocol> aCacheBackend The initialized cache backend object
 *	@return id The live object
 */
- (id)initWithCacheBackend:(NSObject<LCacheProtocol> *)aCacheBackend;

/** Obtain the singleton pointer to the CacheManager object
 *	@return CacheManager Returns the object
 */
+ (LCacheManager *)sharedCacheManager;

- (BOOL)set:(NSString *)identifier object:(id)aObject;

- (id)get:(NSString *)aIdentifier;

- (BOOL)remove:(NSString *)aIdentifier;

- (BOOL)has:(NSString *)aIdentifier;

- (void)clear;

@end
