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
 * @changed $Id: NSImage+Additions.h 227 2013-02-12 11:46:14Z mkovachev $
 * @author $Author: mkovachev $
 * @version $Revision: 227 $
 */

@interface NSImage(Additions)

// Deprecated in favor of newCGImage to prevent LLDB warnings
- (CGImageRef)CGImage __deprecated;

- (CGImageRef)newCGImage;

+ (NSImage *)reflectedImage:(NSImage *)sourceImage amountReflected:(float)fraction;

@end
