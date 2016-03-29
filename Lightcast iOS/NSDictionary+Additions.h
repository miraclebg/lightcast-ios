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
 * @changed $Id: NSDictionary+Additions.h 349 2014-10-28 14:03:11Z mkovachev $
 * @author $Author: mkovachev $
 * @version $Revision: 349 $
 */

#import <Foundation/Foundation.h>


@interface NSDictionary(LAdditions)

- (id)nilifiedObjectForKey:(NSString*)key;

- (NSInteger)intForKey:(NSString*)key;
- (BOOL)boolForKey:(NSString*)key;
- (double)doubleForKey:(NSString*)key;
- (NSDate*)dateForKey:(NSString*)key format:(NSString*)dateFormat fromTimezone:(NSTimeZone*)fromTimezone;
- (NSDate*)dateForKey:(NSString*)key format:(NSString*)dateFormat;

+ (NSDictionary *)dictionaryWithFormEncodedString:(NSString *)encodedString;
- (NSString *)stringWithFormEncodedComponents;

/** Returns a valid SQL value string (escaped) or 'NULL' string if the string is empty or NIL
 *	@param id aKey The input string
 *	@return NSString Returns the escaped string
 */
- (NSString *)getStrWithNullValue:(id)aKey;

- (NSString *)sqlString:(id)aKey;

/** Returns the integer representation of the 'aKey' object
 *	@param id aKey An object
 *	@return int Returns the integer value of the object
 */
- (int)sqlInt:(id)aKey;

/** Returns the float representation of the 'aKey' object
 *	@param id aKey An object
 *	@return int Returns the float value of the object
 */
- (float)sqlFloat:(id)aKey;

/** Returns a properly escaped date string
 *	@param id aKey The date, datetime string
 *	@return NSString Returns the properly escaped datetime string
 */
- (NSString *)sqlDate:(id)aKey;

- (int)intFromSql:(id)aKey;
- (float)floatFromSql:(id)aKey;
- (NSString*)stringFromSql:(id)aKey;

@end
