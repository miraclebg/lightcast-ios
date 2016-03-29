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
 * @changed $Id: LLocalizationManager.h 233 2013-03-15 05:24:57Z mkovachev $
 * @author $Author: mkovachev $
 * @version $Revision: 233 $
 */

@interface LLocalizationManager : NSObject

@property (nonatomic, retain, readonly) NSBundle *bundle;

- (id)initWithBundle:(NSBundle*)aBundle;

- (NSString*)localizedString:(NSString*)key;
- (NSString*)localizedStringWithFormat:(NSString*)format, ... NS_FORMAT_FUNCTION(1,2);

+ (LLocalizationManager*)defaultLocalizationManager;
+ (NSString*)localizedString:(NSString*)key;
+ (NSString*)localizedStringWithFormat:(NSString*)format, ... NS_FORMAT_FUNCTION(1,2);

@end

@interface LI18n : LLocalizationManager

@end
