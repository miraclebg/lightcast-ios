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
 * @changed $Id: Utilities.h 348 2014-10-18 20:59:25Z mkovachev $
 * @author $Author: mkovachev $
 * @version $Revision: 348 $
 */

#import <Lightcast/Primitives.h>
#import <Lightcast/NSString+WebEntities.h>
#import <Lightcast/NSString+Additions.h>
#import <Lightcast/NSString+DB.h>
#import <Lightcast/NSNull+Additions.h>
#import <Lightcast/NSArray+Additions.h>
#import <Lightcast/NSMutableArray+Additions.h>
#import <Lightcast/NSDictionary+Additions.h>
#import <Lightcast/NSDate+Additions.h>
#import <Lightcast/NSData+Additions.h>
#import <Lightcast/NSData+Compression.h>
#import <Lightcast/NSData+CommonCrypto.h>
#import <Lightcast/LVars.h>
#import <Lightcast/NSFileManager+Additions.h>
#import <Lightcast/LDateTimeUtils.h>
#import <Lightcast/LNumbers.h>
#import <Lightcast/NSURLRequest+SSLChecks.h>
#import <Lightcast/GeneralUtils.h>
#import <Lightcast/LApplicationUtils.h>
#import <Lightcast/NSError+Additions.h>
#import <Lightcast/NSUserDefaults+Additions.h>

#ifdef TARGET_IOS	// iOS Target

#import <Lightcast/UIViewController+Additions.h>
#import <Lightcast/UINavigationController+Additions.h>
#import <Lightcast/UIView+Additions.h>
#import <Lightcast/UIView+Explode.h>
#import <Lightcast/UITableView+Additons.h>
#import <Lightcast/UIWindow+Additions.h>
#import <Lightcast/UIImage+Additions.h>
#import <Lightcast/UIColor+Additions.h>
#import <Lightcast/UIScreen+Additions.h>

#import <Lightcast/NGAParallaxMotion.h>

#else	// Mac OSX Target

#ifdef HAS_APPKIT
#import <Lightcast/NSColor+Additions.h>
#import <Lightcast/NSWindow+Additions.h>
#import <Lightcast/CALayer+Additions.h>
#import <Lightcast/NSView+Additions.h>
#import <Lightcast/NSImage+Additions.h>
#import <Lightcast/CTGradient.h>
#import <Lightcast/NSBezierPath+RoundedRect.h>
#endif

#import <Lightcast/NSBundle+Additions.h>

#endif

// third party

#import <Lightcast/Base64.h>

