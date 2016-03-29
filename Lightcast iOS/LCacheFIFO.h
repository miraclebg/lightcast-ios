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
 * @changed $Id: LCacheFIFO.h 128 2011-08-09 06:54:20Z mkovachev $
 * @author $Author: mkovachev $
 * @version $Revision: 128 $
 */

#import <Lightcast/LCacheProtocol.h>

/** Defines the maximum number of cached objects allowed
 *	before the cache manager starts deleting previous entries
 */
#define DEFAULT_MAX_CACHE_OBJECTS 500

/**
 *	@brief An in-memory FIFO caching KEY/VALUE object
 *	Used to store frequently used objects in transit.
 *	Under iPhone it listens for low memory situations and resets its cache.
 *	Conforms to 'CacheProtocol'.
 *	It will store as many as DEFAULT_MAX_CACHE_OBJECTS objects - after which - it will start removing the oldes ones.
 *
 *	@author Martin Kovachev (miracle@nimasystems.com), Nimasystems Ltd
 */
@interface LCacheFIFO : NSObject <LCacheProtocol> {

	NSMutableArray * cacheObjects;
	NSMutableArray * cacheKeys;
	int maximumCacheObjects;
}

@property (readonly) NSInteger cachedObjectsCount;

/** Initialize the cache store with a maximum of 'newMaximumCacheObjects' objects allowed
 *	@param int newMaximumCacheObjects The maximum allowed objects to be stored before auto-removal starts
 *	@return id The live object
 */
- (id)initWithObjectsLimit:(int)newMaximumCacheObjects;

/** Inserts / Replaces a value by a string identifier in the cache
 *	@param NSString identifier The name of the identifier
 *	@param id cachedObject The object to be cached
 *	@return BOOL Returns TRUE on success, FALSE on error
 */
- (BOOL)insertOrReplace:(NSString *)identifier cachedObject:(id)cachedObject;

- (BOOL)has:(NSString *)aIdentifier;
- (BOOL)set:(NSString *)identifier object:(id)aObject;
- (id)get:(NSString *)aIdentifier;
- (BOOL)remove:(NSString *)aIdentifier;

- (void)clear;
- (NSInteger)getCount;

/** Gets a cached value from the store by string identifier and removes it from the cache right away
 *	@param NSString identifier The name of the identifier
 *	@param BOOL removeFromCache Specifies if the value should be removed from the cache after fetching it (TRUE)
 *	@return id Returns the cached value if found. If not - returns NIL
 */
- (id)get:(NSString *)identifier removeFromCache:(BOOL)removeFromCache;

@end
