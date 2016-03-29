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
 * @changed $Id: NSString+Additions.h 354 2015-02-05 07:34:56Z mkovachev $
 * @author $Author: mkovachev $
 * @version $Revision: 354 $
 */

@interface NSString(LAdditions)

+ (NSString*)nilify;
+ (BOOL)isNullOrEmpty:(NSString*)string;
+ (NSString*)randomString:(NSInteger)length;

- (NSString *)stringByUnescapingFromURLQuery;
- (NSString *)stringByEscapingForURLQuery;

- (NSString *)stringTrimmed;
- (NSString *)trim;
- (NSString *)trimmedString;

/**
 * Determines if the string contains only whitespace and newlines.
 */
- (BOOL)isWhitespaceAndNewlines;

/**
 * Determines if the string is empty or contains only whitespace.
 */
- (BOOL)isEmptyOrWhitespace;

- (BOOL)startsWith:(NSString*)string;
- (BOOL)endsWith:(NSString*)string;

/**
 * Compares two strings expressing software versions.
 *
 * The comparison is (except for the development version provisions noted below) lexicographic
 * string comparison. So as long as the strings being compared use consistent version formats,
 * a variety of schemes are supported. For example "3.02" < "3.03" and "3.0.2" < "3.0.3". If you
 * mix such schemes, like trying to compare "3.02" and "3.0.3", the result may not be what you
 * expect.
 *
 * Development versions are also supported by adding an "a" character and more version info after
 * it. For example "3.0a1" or "3.01a4". The way these are handled is as follows: if the parts
 * before the "a" are different, the parts after the "a" are ignored. If the parts before the "a"
 * are identical, the result of the comparison is the result of NUMERICALLY comparing the parts
 * after the "a". If the part after the "a" is empty, it is treated as if it were "0". If one
 * string has an "a" and the other does not (e.g. "3.0" and "3.0a1") the one without the "a"
 * is newer.
 *
 * Examples (?? means undefined):
 *   "3.0" = "3.0"
 *   "3.0a2" = "3.0a2"
 *   "3.0" > "2.5"
 *   "3.1" > "3.0"
 *   "3.0a1" < "3.0"
 *   "3.0a1" < "3.0a4"
 *   "3.0a2" < "3.0a19"  <-- numeric, not lexicographic
 *   "3.0a" < "3.0a1"
 *   "3.02" < "3.03"
 *   "3.0.2" < "3.0.3"
 *   "3.00" ?? "3.0"
 *   "3.02" ?? "3.0.3"
 *   "3.02" ?? "3.0.2"
 */
- (NSComparisonResult)versionStringCompare:(NSString *)other;

/** Checks and removes any other than alphanumberical characters from the current string
 *	@return NSString Returns the sanitized string
 */
- (NSString *)sanitizeToAlphaNumericalString;

- (NSString*)stringByAppendingPathComponentIfMissing;

/** Searches in the current string for the occurence of a substring and replaces it with another one
 *	@param NSString substring The string being looked up
 *	@param NSString replaceString The string with which the 'substring' should be replaced with
 *	@return NSString Returns the replaced string
 */
- (NSString *)stringByReplacingSubstring:(NSString *)substring
							  withString:(NSString *)replaceString;

/**
 *
 */
- (NSString*)stringByDeletingLastPathComponent:(NSString*)inputString;

/**
 * On strings containing file paths or names this can be applied to strip the extension
 *
 * @return file name or path without extension (if any)
 */
- (NSString*)removedFileExtension;

/**
 * Applied to file extensions or full path to file returns the extension
 *
 * @return The extension of the file name/path
 */
- (NSString*)fileExtension;

- (BOOL)containsString:(NSString*)searchFor;

/**
 * Calculate the md5 hash of this string using CC_MD5.
 *
 * @return md5 hash of this string
 */
@property (nonatomic, readonly, getter = md5Hash) NSString *md5Hash;

/**
 * Calculate the sha1 hash of this string using CC_SHA1.
 *
 * @return sha1 hash of this string
 */
@property (nonatomic, readonly, getter = sha1Hash) NSString *sha1Hash;

@property (nonatomic, readonly, getter = base64EncodedString) NSString *base64EncodedString;

@end
