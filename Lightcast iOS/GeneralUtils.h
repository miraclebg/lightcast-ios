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
 * @changed $Id: GeneralUtils.h 235 2013-03-15 14:08:45Z mkovachev $
 * @author $Author: mkovachev $
 * @version $Revision: 235 $
 */

@interface GeneralUtils : NSObject {

}

/** A general usage for sha1 hashing of a given string
 * @param NSString str The input string to be hashed.
 * @return NSString The sha1 hashed string.
 * @deprecated To be used from [NSString sha1Hash]
 */
+ (NSString *)sha1:(NSString *)str __LDEPRECATED_METHOD;

#ifdef TARGET_IOS	// iOS Target

/** General method to display an alert box with button and a specific title
 *	@param NSString title The title of the alert
 *	@param NSString description The additional description below the title
 *	@param NSString buttonTitle The title of the action button
 *	@param id delegate The object which should receive the button click event
 *	@return void
 */
+ (void)displayMessage:(NSString *)title description:(NSString *)description buttonTitle:(NSString *)buttonTitle delegate:(id)delegate;

/** General method to display an alert box
 *	@param NSString title The title of the alert
 *	@param NSString description The additional description below the title
 *	@param id delegate The object which should receive the button click event
 *	@return void
 */
+ (void)displayMessage:(NSString *)title description:(NSString *)description delegate:(id)delegate;

+ (BOOL)isSimulator;

+ (BOOL)isIPad;

+ (BOOL)isIPhone;

#endif // end of iOS Target

/** General method to display an alert box
 *	@param NSString title The title of the alert
 *	@param NSString description The additional description below the title
 *	@return void
 */
+ (void)displayMessage:(NSString *)title description:(NSString *)description;

#ifdef TARGET_OSX // MAC-OSX Target

#ifdef HAS_APPKIT
+ (void)displayMessage:(NSString *)title description:(NSString *)description style:(NSAlertStyle)alertStyle;
#endif

+ (void)displayError:(NSError*)error;

#endif

@end
