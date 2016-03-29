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
 * @changed $Id: i18n.h 235 2013-03-15 14:08:45Z mkovachev $
 * @author $Author: mkovachev $
 * @version $Revision: 235 $
 */

#import <Lightcast/LLocalizationManager.h>
#import <Lightcast/LI18nTranslationSourceParser.h>
#import <Lightcast/LI18nLocalizedStringsFile.h>
#import <Lightcast/LI18nProjectCatalog.h>

#ifndef lc_i18n
#define lc_i18n

extern NSString *const kLCI18nErrorDomain;

/**
 * Gets the current system locale chosen by the user.
 *
 * This is necessary because [NSLocale currentLocale] always returns en_US.
 */
NSLocale *LCurrentLocale(void);

/**
 * @return A localized string from the lightcast bundle.
 */
NSString *LightcastLocalizedString(NSString *key);

/**
 * @return A localized string from the main bundle.
 */
NSString *LLocalizedString(NSString *key);

/**
 * @return A localized string from the a specified bundle.
 */
NSString *LLocalizedStringInBundle(NSString *key, NSBundle *bundle);

/**
 * @return The given number formatted as XX,XXX,XXX.XX
 *
 */
NSString *LFormatInteger(NSInteger num);

#endif
