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
 * @changed $Id: Logging.h 356 2015-02-16 10:31:14Z mkovachev $
 * @author $Author: mkovachev $
 * @version $Revision: 356 $
 */

/**
 *	Logging - Logging Methods
 *
 *	Methods simplifying application and runtime logging
 *	Levels:
 *	0 - OFF
 *	1 - ERROR
 *	2 - WARNING
 *	3 - INFO
 *	4 - DEBUG
 *
 */

/** if debugging - set to highest level of logging
 * these are the DEFAULT logging types if the app has not specified otherwise
 */

#define DD_LEGACY_MACROS 0

//#import </usr/include/libgen.h>
#import <Lightcast/CocoaLumberjack.h>

extern NSInteger const kMaxSystemLogFileSize;

void openSystemLog(NSInteger maxLogFileSize, NSString *path); // in MB

#ifndef DEBUG_LEVEL

#ifdef DEBUG
	#define DEBUG_LEVEL 4
    #import "debug.h"
#else
	#define DEBUG_LEVEL 3
#endif

#endif

/** logging functions and defines
 */
#define DEBUG_ERROR   (DEBUG_LEVEL >= 1) /** ERROR level */
#define DEBUG_WARN    (DEBUG_LEVEL >= 2) /** WARNING level */
#define DEBUG_INFO    (DEBUG_LEVEL >= 3) /** INFO level */

#ifdef DEBUG
#define DEBUG_DEBUG (DEBUG_LEVEL >= 4) /** DEBUG level */
#endif

// if defined - no logging will be performed
//#define LOGGER_DISABLED 0

/** DDLog
 */
#ifndef LOGGER_DISABLED
#if DEBUG_DEBUG
static const DDLogLevel ddLogLevel = DDLogLevelVerbose;
#else
#if DEBUG_INFO
static const DDLogLevel ddLogLevel = DDLogLevelInfo;
#else
#if DEBUG_WARN
static const DDLogLevel ddLogLevel = DDLogLevelWarning;
#else
#if DEBUG_ERROR
static const DDLogLevel ddLogLevel = DDLogLevelError;
#endif
#endif
#endif
#endif
#else
static const DDLogLevel ddLogLevel = DDLogLevelOff;
#endif

/** methods for logging different levels of messages
 */
#ifndef LOGGER_DISABLED
#define LogError(format, ...)   if(DEBUG_ERROR) DDLogError(@"ERROR: %@", [NSString stringWithFormat:(format), ##__VA_ARGS__]) /** Method for logging ERRORS */
#define LogWarn(format, ...)    if(DEBUG_WARN)  DDLogWarn(@"WARNING: %@", [NSString stringWithFormat:(format), ##__VA_ARGS__]) /** Method for logging WARNING */
#define LogInfo(format, ...)    if(DEBUG_INFO)  DDLogInfo(@"%@", [NSString stringWithFormat:(format), ##__VA_ARGS__]) /** Method for logging INFO MESSAGES */

#define LogCError(format, ...)   if(DEBUG_ERROR) DDLogError(@"ERROR: %@", [NSString stringWithFormat:(format), ##__VA_ARGS__]) /** Method for logging ERRORS */
#define LogCWarn(format, ...)    if(DEBUG_WARN)  DDLogWarn(@"WARNING: %@", [NSString stringWithFormat:(format), ##__VA_ARGS__]) /** Method for logging WARNING */
#define LogCInfo(format, ...)    if(DEBUG_INFO)  DDLogInfo(@"%@", [NSString stringWithFormat:(format), ##__VA_ARGS__]) /** Method for logging INFO MESSAGES */

#ifdef DEBUG
#define LogDebug(format, ...)   if(DEBUG_DEBUG) DDLogVerbose(@"DEBUG: %@ (%s:%d)", [NSString stringWithFormat:(format), ##__VA_ARGS__], __FILE__, __LINE__) /** Method for logging DEBUGGING INFO */
#define LogCDebug(format, ...)   if(DEBUG_DEBUG) DDLogVerbose(@"DEBUG: %@ (%s:%d)", [NSString stringWithFormat:(format), ##__VA_ARGS__], __FILE__, __LINE__) /** Method for logging DEBUGGING INFO */
#else
#define LogDebug(format, ...) ;
#define LogCDebug(format, ...) ;
#endif

#else
#define LogError(format, ...)   if(DEBUG_ERROR) ; /** Method for logging ERRORS */
#define LogWarn(format, ...)    if(DEBUG_WARN)  ; /** Method for logging WARNING */
#define LogInfo(format, ...)    if(DEBUG_INFO)  ; /** Method for logging INFO MESSAGES */
#define LogDebug(format, ...)   if(DEBUG_DEBUG) ; /** Method for logging DEBUGGING INFO */

#define LogCError(format, ...)   if(DEBUG_ERROR) ; /** Method for logging ERRORS */
#define LogCWarn(format, ...)    if(DEBUG_WARN)  ; /** Method for logging WARNING */
#define LogCInfo(format, ...)    if(DEBUG_INFO)  ; /** Method for logging INFO MESSAGES */
#define LogCDebug(format, ...)   if(DEBUG_DEBUG) ; /** Method for logging DEBUGGING INFO */
#endif

/** methods for logging RECT / POINT
 */
#define LogRect(RECT) DDLogInfo(@"%s: (%0.0f, %0.0f) %0.0f x %0.0f",#RECT, RECT.origin.x, RECT.origin.y, RECT.size.width, RECT.size.height) /** Logs a NSRect to the console */
#define LogPoint(POINT) DDLogInfo(@"%s: (%0.0f, %0.0f)",#POINT POINT.x, POINT.y); /** Logs a NSPoint to the console */

/** logging views and subviews
 */
#define LogViews(_VIEW) \
{ for (UIView* view = _VIEW; view; view = view.superview) { LogInfo(@"%@", view); } }

#define LogNSViews(_VIEW) \
{ for (NSView* view = _VIEW; view; view = view.superview) { LogInfo(@"%@", view); } }

/** methods for logging function + line
*/
#define Log(xx, ...)    if(DEBUG_DEBUG) DDLogVerbose(@"%s(%d): " xx, __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#define LogMethod()     if(DEBUG_DEBUG) DDLogVerbose(@"%s", __PRETTY_FUNCTION__)

#import <TargetConditionals.h>

/** conditional logging
*/
#ifdef DEBUG
#define LogCond(condition, xx, ...) { if ((condition)) { \
Log(xx, ##__VA_ARGS__); \
} \
} ((void)0)
#else
#define LogCond(condition, xx, ...) ((void)0)
#endif // #ifdef DEBUG