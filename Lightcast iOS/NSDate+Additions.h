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
 * @changed $Id: NSDate+Additions.h 349 2014-10-28 14:03:11Z mkovachev $
 * @author $Author: mkovachev $
 * @version $Revision: 349 $
 */

#import <Foundation/Foundation.h>

extern NSInteger const kSecondsMinute;
extern NSInteger const kSecondsHour;
extern NSInteger const kSecondsDay;
extern NSInteger const kSecondsWeek;
extern NSInteger const kSecondsYear;

@interface NSDate(LAdditions)

/**
 * Returns the current date with the time set to midnight.
 */
+ (NSDate*)dateWithToday:(NSTimeZone*)timezone;

/**
 * Returns the current date with the time set to midnight.
 */
+ (NSDate*)dateWithToday;

/**
 * Returns a copy of the date with the time set to midnight on the same day.
 */
- (NSDate*)dateAtMidnight;

/**
 * Formats the date with 'h:mm a' or the localized equivalent.
 */
- (NSString*)formatTime;

/**
 * Formats the date with 'EEEE, LLLL d, YYYY' or the localized equivalent.
 */
- (NSString*)formatDate;

/** 
 * Formats the date according to the system locale and the specified date style
 */
- (NSString*)formatDateAutomatically:(NSDateFormatterStyle)style;

/**
 * Formats the date according to the system locale
 */
- (NSString*)formatDateAutomatically;

/**
 * Formats the date according to how old it is.
 *
 * For dates less than a day old, the format is 'h:mm a', for less than a week old the
 * format is 'EEEE', and for anything older the format is 'M/d/yy'.
 */
- (NSString*)formatShortTime;

/**
 * Formats the date according to how old it is.
 *
 * For dates less than a day old, the format is 'h:mm a', for less than a week old the
 * format is 'EEE h:mm a', and for anything older the format is 'MMM d h:mm a'.
 */
- (NSString*)formatDateTime;

/**
 * Formats dates within 24 hours like '5 minutes ago', or calls formatDateTime if older.
 */
- (NSString*)formatRelativeTime;

/**
 * Formats dates within 1 week like '5m' or '2d', or calls formatShortTime if older.
 */
- (NSString*)formatShortRelativeTime;

/**
 * Formats the date with 'MMMM d", "Today", or "Yesterday".
 *
 * You must supply date components for today and yesterday because they are relatively expensive
 * to create, so it is best to avoid creating them every time you call this method if you
 * are going to be calling it multiple times in a loop.
 */
- (NSString*)formatDay:(NSDateComponents*)today yesterday:(NSDateComponents*)yesterday;

/**
 * Formats the date with 'MMMM".
 */
- (NSString*)formatMonth;

/**
 * Formats the date with 'yyyy".
 */
- (NSString*)formatYear;

/**
 * Comapres two NSDate objects and returns YES if they are the same day, month and year
 */
- (BOOL)isSameDayAsDate:(NSDate*)secondDate;

- (NSString*)sqlDateWithTimezone:(NSTimeZone*)timezone;
- (NSString*)sqlDate;
- (NSString*)sqlUTCDate;

- (NSUInteger)daysAgo;
- (NSUInteger)daysAgoAgainstMidnight;
- (NSString *)stringDaysAgo;
- (NSString *)stringDaysAgoAgainstMidnight:(BOOL)flag;
- (NSUInteger)weekday;

+ (NSDate *)dateFromString:(NSString *)string;
+ (NSDate *)dateFromString:(NSString *)string withFormat:(NSString *)format;
+ (NSString *)stringFromDate:(NSDate *)date withFormat:(NSString *)string;
+ (NSString *)stringFromDate:(NSDate *)date;
+ (NSString *)stringForDisplayFromDate:(NSDate *)date;
+ (NSString *)stringForDisplayFromDate:(NSDate *)date prefixed:(BOOL)prefixed;
+ (NSString *)stringForDisplayFromDate:(NSDate *)date prefixed:(BOOL)prefixed alwaysDisplayTime:(BOOL)displayTime;

- (NSString *)string;
- (NSString *)stringWithFormat:(NSString *)format;
- (NSString *)stringWithDateStyle:(NSDateFormatterStyle)dateStyle timeStyle:(NSDateFormatterStyle)timeStyle;

- (NSDate *)beginningOfWeek;
- (NSDate *)beginningOfDay;
- (NSDate *)beginningOfDay:(NSTimeZone*)timeZone;
- (NSDate *)endOfWeek;

- (NSDate *)startOfDay;
- (NSDate *)endOfDay;
- (NSDate *)beginningOfMonth;
- (NSDate *)beginningOfYear;
- (NSDate *)endOfMonth;
- (NSDate *)endOfYear;

+ (NSString *)dateFormatString;
+ (NSString *)timeFormatString;
+ (NSString *)timestampFormatString;
+ (NSString *)dbFormatString;

- (BOOL) isEarlierDate: (NSDate *) aDate;
- (BOOL) isLaterDate: (NSDate *) aDate;
- (BOOL) dateBetweenStartDate:(NSDate*)start andEndDate:(NSDate*)end;

- (NSString*)localeFormattedDateString;
- (NSString*)localeFormattedDateStringWithTime;
+ (NSDate *)localeFormatted;
- (NSDate *)dateFormattedLocale;

- (NSString *)formattedStringWithFormat:(NSString *)format;
- (NSDate *)dateWithoutTime;
+ (NSDate *)dateWithoutTime;

- (NSDate *) dateByAddingMinutes:(NSInteger)minutes;
- (NSDate *) dateBySubtractingMinutes:(NSInteger)minutes;
- (NSDate *) dateByAddingHours:(NSInteger)hours;
- (NSDate *) dateBySubtractingHours:(NSInteger)hours;
- (NSDate *) dateByAddingDays:(NSInteger)days;
- (NSDate *) dateBySubtractingDays:(NSInteger)days;
- (NSDate *) dateByAddingMonth:(int)monthes;
- (NSDate *) dateBySubstractingMonth:(int)monthes;

- (NSInteger) seconds;
- (NSInteger) minute;
- (NSInteger) hour;
- (NSInteger) day;
- (NSInteger) month;
- (NSInteger) week;
- (NSInteger) year;
- (NSString*) monthName;
- (NSString*) yearFromDateStr;

+ (NSDate *) dateTomorrow;
+ (NSDate *) dateYesterday;

+ (NSDate *) dateWithDaysFromNow: (NSInteger) days;
+ (NSDate *) dateWithDaysBeforeNow: (NSInteger) days;

// Comparing dates
- (BOOL) isEqualToDateIgnoringTime: (NSDate *) aDate;
- (BOOL) isToday;
- (BOOL) isTomorrow;
- (BOOL) isYesterday;
- (BOOL) isSameWeekAsDate: (NSDate *) aDate;
- (BOOL) isThisWeek;
- (BOOL) isNextWeek;
- (BOOL) isLastWeek;
- (BOOL) isSameMonthAsDate: (NSDate *) aDate;
- (BOOL) isThisMonth;
- (BOOL) isSameYearAsDate: (NSDate *) aDate;
- (BOOL) isThisYear;
- (BOOL) isNextYear;
- (BOOL) isLastYear;
- (BOOL) isEarlierThanDate: (NSDate *) aDate;
- (BOOL) isLaterThanDate: (NSDate *) aDate;
- (BOOL) isInFuture;
- (BOOL) isInPast;

// Date roles
- (BOOL) isTypicallyWorkday;
- (BOOL) isTypicallyWeekend;

+ (NSInteger)hoursFromGMT;

-(NSDate*)toLocalTime;
-(NSDate*)toGlobalTime;

@end
