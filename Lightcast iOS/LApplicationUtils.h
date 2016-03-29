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
 * @changed $Id: LApplicationUtils.h 360 2015-05-22 08:12:42Z mkovachev $
 * @author $Author: mkovachev $
 * @version $Revision: 360 $
 */

#import <Foundation/Foundation.h>

@interface LApplicationUtils : NSObject

+ (BOOL)resetDocumentsFolder:(NSError**)error;
+ (BOOL)resetTemporaryFolder:(NSError**)error;
+ (void)resetUserDefaults:(NSUserDefaults*)userDefaults;
+ (void)resetUserDefaults:(NSUserDefaults*)userDefaults preserveKeys:(NSArray*)preservedKeys;
+ (BOOL)resetFolder:(NSString*)folderName error:(NSError**)error;

+ (NSString*)currentLocale;
+ (NSString*)bundleVersion;
+ (NSString*)bundleIdentifier;

+ (NSString*)formattedUserAgentStringForLocale:(NSString*)productName;
+ (NSString*)formattedUserAgentStringForLocale:(NSString*)productName userDetails:(NSDictionary*)userDetails;
+ (NSString*)formattedUserAgentStringForLocale:(NSString*)productName locale:(NSString*)locale;
+ (NSString*)formattedUserAgentStringForLocale:(NSString*)productName version:(NSString*)version locale:(NSString*)locale deviceDescription:(NSString*)deviceDescription;
+ (NSString*)formattedUserAgentStringForLocale:(NSString*)productName version:(NSString*)version locale:(NSString*)locale deviceDescription:(NSString*)deviceDescription userDetails:(NSDictionary*)userDetails;

@end
