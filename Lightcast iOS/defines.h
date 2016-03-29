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
 * @changed $Id: defines.h 272 2013-06-21 10:46:41Z mkovachev $
 * @author $Author: mkovachev $
 * @version $Revision: 272 $
 */

// lightcast version
#define LC_VER @"1.0.0.0"

/* disable all types of debugging if we are in RELEASE
 */
#ifndef DEBUG
#ifndef NS_BLOCK_ASSERTIONS 
#define NS_BLOCK_ASSERTIONS 
#endif
#ifndef NDEBUG 
#define NDEBUG 
#endif
#endif

/** autodetected options
 */
#ifdef CORETELEPHONY_EXTERN_CLASS
#define OPT_TELEPHONY
#endif

// custom imports
#ifndef __MAC_OS_X_VERSION_MAX_ALLOWED
#import <Lightcast/defines-iOS.h>
#else
#import <Lightcast/defines-MacOSX.h>
#endif

#ifdef APPKIT_EXTERN
#define HAS_APPKIT 1
#endif

/**
 * Borrowed from Apple's AvailabiltyInternal.h header. There's no reason why we shouldn't be
 * able to use this macro, as it's a gcc-supported flag.
 * Here's what we based it off of.
 * __AVAILABILITY_INTERNAL_DEPRECATED         __attribute__((deprecated))
 */
#define __LDEPRECATED_METHOD __attribute__((deprecated))

// Time

#define L_MINUTE 60
#define L_HOUR   (60 * L_MINUTE)
#define L_DAY    (24 * L_HOUR)
#define L_WEEK   (7 * L_DAY)
#define L_MONTH  (30.5 * L_DAY)
#define L_YEAR   (365 * L_DAY)

#define L_DOMAIN    @"lightcast-ios.nimasystems.com"

// Safe releases
#define L_RELEASE(__POINTER) { [__POINTER release]; __POINTER = nil; }
#define L_INVALIDATE_TIMER(__TIMER) { [__TIMER invalidate]; __TIMER = nil; }

// Release a CoreFoundation object safely.
#define CF_RELEASE(__REF) { if (nil != (__REF)) { CFRelease(__REF); __REF = nil; } }

// Check if a variable has content (check both if nil or NULL)
#define L_VALID_VAR(var) { return (var && ![var isEqual:[NSNull null]]) ? YES : NO; }

#define CONCAT(format, ...) { return [NSString stringWithFormat:(format), ##__VA_ARGS__]; }

#if __LP64__ || (TARGET_OS_EMBEDDED && !TARGET_OS_IPHONE) || TARGET_OS_WIN32 || NS_BUILD_32_LIKE_64
#define NSINT "ld"
#define NSUINT "lu"
#else
#define NSINT "d"
#define NSUINT "u"
#endif

