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
 * @changed $Id: LCacheProtocol.h 75 2011-07-16 15:47:22Z mkovachev $
 * @author $Author: mkovachev $
 * @version $Revision: 75 $
 */

/**
 *	@protocol LCacheProtocol
 *	@brief A protocol defining a cache storage engine
 *
 *	@author Martin Kovachev (miracle@nimasystems.com), Nimasystems Ltd
 */
@protocol LCacheProtocol

/** Sets a new object in the cache with an identifier
 *	@param NSString identifier The identifier name
 *	@param id aObject The object to be cached
 *	@return BOOL Returns TRUE on succes, FALSE on failiure
 */
- (BOOL)set:(NSString *)identifier object:(id)aObject;

/** Gets a cached value from the cache by string identifier
 *	@param NSString aIdentifier The string identifier of the value
 *	@return	id Returns the cached object if available. If not - returns NIL.
 */
- (id)get:(NSString *)aIdentifier;

/** Removes a value from the cache by string identifier
 *	@param NSString aIdentifier The name of the identifier
 *	@return BOOL Returns TRUE on success (object was there and removed) or FALSE (the object was not found or other error occurred)
 */
- (BOOL)remove:(NSString *)aIdentifier;

/** Checks if the cache has cached a value with the string identifier 'aIdentifier'
 *	@param NSString aIdentifier The name of the identifier
 *	@return BOOL Returns TRUE if the object is available in the cache, FALSE - if it is not there
 */
- (BOOL)has:(NSString *)aIdentifier;

/** Reset the cache store and remove all objects
 *	@return void
 */
- (void)clear;

/** Returns the count of all cached objects
 *	@return int Returns the integer count of objects
 */
- (int)getCount;

@end