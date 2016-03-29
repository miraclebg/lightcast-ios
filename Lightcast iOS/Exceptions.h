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
 * @changed $Id: Exceptions.h 255 2013-03-31 04:57:52Z mkovachev $
 * @author $Author: mkovachev $
 * @version $Revision: 255 $
 */

#import <Foundation/Foundation.h>

#define LE_PARAM_EXCEPTION @"eParameterError"
#define LE_DB_EXCEPTION @"eDatabaseError"

#define LExcept(value,message) [NSException raise:[NSString stringWithFormat:@"%d", (value)] format:(message),nil]

NSError* LERR(int code, NSDictionary * userInfo);

extern NSString *const lightcastNetworkErrorDomain;


#if DEBUG

#ifndef Debugger
#define Debugger() { }
#endif

#if __ppc64__ || __ppc__
#define DebugBreak() \
if([DebuggerTools isDebuggerAvailable]) \
{ \
Debugger(); \ /*
__asm__("li r0, 20\nsc\nnop\nli r0, 37\nli r4, 2\nsc\nnop\n" \
: : : "memory","r0","r3","r4" ); \*/
}
#else
#define DebugBreak() { if([DebuggerTools isDebuggerAvailable]) {__asm__("int $3\n" : : );} } // if([DebuggerTools isDebuggerAvailable]) {__asm__("int $3\n" : : );}
#endif

#else
#define DebugBreak()
#endif

#if DEBUG

#ifdef TARGET_IOS

// We leave the __asm__ in this macro so that when a break occurs, we don't have to step out of
// a "breakInDebugger" function.
#if TARGET_IPHONE_SIMULATOR
#define lassert(xx) { if(!(xx)) { Log(@"lassert failed: %s", #xx); \
__asm__("int $3\n" : : );  } \
} ((void)0)
#else
#define lassert(xx) { if(!(xx)) { Log(@"lassert failed: %s", #xx); \
 } \
} ((void)0)
#endif

#else// TODO: Fix this

// We leave the __asm__ in this macro so that when a break occurs, we don't have to step out of
// a "breakInDebugger" function.
#define lassert(xx) { if(!(xx)) { Log(@"lassert failed: %s", #xx); \
DebugBreak() } \
} ((void)0)
#endif // #if TARGET_OSX

#else
#define lassert(xx) ((void)0)
#endif // #ifdef DEBUG

#if DEBUG
@interface DebuggerTools : NSObject

#ifdef TARGET_OSX
+ (BOOL)isDebuggerAvailable;
#endif

@end
#endif