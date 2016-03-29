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
 * @changed $Id: NSDate+Additions.m 357 2015-04-16 06:29:29Z mkovachev $
 * @author $Author: mkovachev $
 * @version $Revision: 357 $
 */

#import "NSDate+Additions.h"

NSInteger const kSecondsMinute   =   60;
NSInteger const kSecondsHour     =   3600;
NSInteger const kSecondsDay      =   86400;
NSInteger const kSecondsWeek     =   604800;
NSInteger const kSecondsYear     =   31556926;

#define kCurrentCalendar [NSCalendar currentCalendar]

#define kDateComponents (NSYearCalendarUnit| NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekCalendarUnit |  NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit | NSWeekdayCalendarUnit | NSWeekdayOrdinalCalendarUnit)

@implementation NSDate(LAdditions)

#pragma mark -
#pragma mark Class public

+ (NSDate*)dateWithToday:(NSTimeZone*)timezone {
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-d-M";
	
	if (timezone)
	{
		formatter.timeZone = timezone;
	}
	
    NSString* formattedTime = [formatter stringFromDate:[NSDate date]];
    NSDate* date = [formatter dateFromString:formattedTime];
    L_RELEASE(formatter);
    
    return date;
}

+ (NSDate*)dateWithToday {
    return [self dateWithToday:nil];
}

#pragma mark -
#pragma mark Public

- (NSDate*)dateAtMidnight {
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-d-M";
    
    NSString* formattedTime = [formatter stringFromDate:self];
    NSDate* date = [formatter dateFromString:formattedTime];
    L_RELEASE(formatter);
    
    return date;
}

- (NSString*)formatDateAutomatically:(NSDateFormatterStyle)style {
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateStyle:style];
	NSString *dateFormatted = [dateFormat stringFromDate:self];
	[dateFormat release];
	
	return dateFormatted;
}

- (NSString*)formatDateAutomatically {
	
	return [self formatDateAutomatically:NSDateFormatterShortStyle];
}

- (NSString*)formatTime {
    static NSDateFormatter* formatter = nil;
    if (!formatter) {
        formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = LightcastLocalizedString(@"h:mm a");
        formatter.locale = LCurrentLocale();
    }
    return [formatter stringFromDate:self];
}

- (NSString*)formatDate {
    static NSDateFormatter* formatter = nil;
    if (!formatter) {
        formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat =
        LightcastLocalizedString(@"EEEE, LLLL d, YYYY");
        formatter.locale = LCurrentLocale();
    }
    return [formatter stringFromDate:self];
}

- (NSString*)formatShortTime {
    NSTimeInterval diff = fabs([self timeIntervalSinceNow]);
    
    if (diff < L_DAY) {
        return [self formatTime];
        
    } else if (diff < L_WEEK) {
        static NSDateFormatter* formatter = nil;
        if (!formatter) {
            formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = LightcastLocalizedString(@"EEEE");
            formatter.locale = LCurrentLocale();
        }
        return [formatter stringFromDate:self];
        
    } else {
        static NSDateFormatter* formatter = nil;
        if (!formatter) {
            formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = LightcastLocalizedString(@"M/d/yy");
            formatter.locale = LCurrentLocale();
        }
        return [formatter stringFromDate:self];
    }
}

- (NSString*)formatDateTime {
    NSTimeInterval diff = fabs([self timeIntervalSinceNow]);
    if (diff < L_DAY) {
        return [self formatTime];
        
    } else if (diff < L_WEEK) {
        static NSDateFormatter* formatter = nil;
        if (!formatter) {
            formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = LightcastLocalizedString(@"EEE h:mm a");
            formatter.locale = LCurrentLocale();
        }
        return [formatter stringFromDate:self];
        
    } else {
        static NSDateFormatter* formatter = nil;
        if (!formatter) {
            formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = LightcastLocalizedString(@"MMM d h:mm a");
            formatter.locale = LCurrentLocale();
        }
        return [formatter stringFromDate:self];
    }
}

- (NSString*)formatRelativeTime {
    NSTimeInterval elapsed = fabs([self timeIntervalSinceNow]);
    if (elapsed <= 1) {
        return LightcastLocalizedString(@"just a moment ago");
        
    } else if (elapsed < L_MINUTE) {
        int seconds = (int)(elapsed);
        return [NSString stringWithFormat:LightcastLocalizedString(@"%d seconds ago"), seconds];
        
    } else if (elapsed < 2*L_MINUTE) {
        return LightcastLocalizedString(@"about a minute ago");
        
    } else if (elapsed < L_HOUR) {
        int mins = (int)(elapsed/L_MINUTE);
        return [NSString stringWithFormat:LightcastLocalizedString(@"%d minutes ago"), mins];
        
    } else if (elapsed < L_HOUR*1.5) {
        return LightcastLocalizedString(@"about an hour ago");
        
    } else if (elapsed < L_DAY) {
        int hours = (int)((elapsed+L_HOUR/2)/L_HOUR);
        return [NSString stringWithFormat:LightcastLocalizedString(@"%d hours ago"), hours];
        
    } else {
        return [self formatDateTime];
    }
}

- (NSString*)formatShortRelativeTime {
    NSTimeInterval elapsed = fabs([self timeIntervalSinceNow]);
    
    if (elapsed < L_MINUTE) {
        return LightcastLocalizedString(@"<1m");
        
    } else if (elapsed < L_HOUR) {
        int mins = (int)(elapsed / L_MINUTE);
        return [NSString stringWithFormat:LightcastLocalizedString(@"%dm"), mins];
        
    } else if (elapsed < L_DAY) {
        int hours = (int)((elapsed + L_HOUR / 2) / L_HOUR);
        return [NSString stringWithFormat:LightcastLocalizedString(@"%dh"), hours];
        
    } else if (elapsed < L_WEEK) {
        int day = (int)((elapsed + L_DAY / 2) / L_DAY);
        return [NSString stringWithFormat:LightcastLocalizedString(@"%dd"), day];
        
    } else {
        return [self formatShortTime];
    }
}

- (NSString*)formatDay:(NSDateComponents*)today yesterday:(NSDateComponents*)yesterday {
    static NSDateFormatter* formatter = nil;
    if (!formatter) {
        formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = LightcastLocalizedString(@"MMMM d");
        formatter.locale = LCurrentLocale();
    }
    
    NSCalendar* cal = [NSCalendar currentCalendar];
    NSDateComponents* day = [cal components:NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit
                                   fromDate:self];
    
    if (day.day == today.day && day.month == today.month && day.year == today.year) {
        return LightcastLocalizedString(@"Today");
    } else if (day.day == yesterday.day && day.month == yesterday.month
               && day.year == yesterday.year) {
        return LightcastLocalizedString(@"Yesterday");
    } else {
        return [formatter stringFromDate:self];
    }
}

- (NSString*)formatMonth {
    static NSDateFormatter* formatter = nil;
    if (!formatter) {
        formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = LightcastLocalizedString(@"MMMM");
        formatter.locale = LCurrentLocale();
    }
    return [formatter stringFromDate:self];
}

- (NSString*)formatYear {
    static NSDateFormatter* formatter = nil;
    if (!formatter) {
        formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = LightcastLocalizedString(@"yyyy");
        formatter.locale = LCurrentLocale();
    }
    return [formatter stringFromDate:self];
}

- (BOOL)isSameDayAsDate:(NSDate*)date {
    NSCalendar * calendar = [NSCalendar currentCalendar];
    
    unsigned unitFlags = NSYearCalendarUnit
                       | NSMonthCalendarUnit
                       | NSDayCalendarUnit;

    NSDateComponents * comp1 = [calendar components:unitFlags fromDate:self];
    NSDateComponents * comp2 = [calendar components:unitFlags fromDate:date];
    
    return [comp1 day] == [comp2 day] &&
           [comp1 month] == [comp2 month] &&
           [comp1 year]  == [comp2 year];
}

- (NSString*)sqlDateWithTimezone:(NSTimeZone*)timezone {
    
    NSString *formattedDateStringTime = nil;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    @try
    {
        [formatter setDateFormat:SQL_DATETIME_FORMAT]; //this is the sqlite's format
        formatter.timeZone = timezone;
        formattedDateStringTime = [formatter stringFromDate:self];
    }
    @finally
    {
        [formatter release];
    }
    
    formattedDateStringTime = (formattedDateStringTime && formattedDateStringTime != NULL) ?
    [NSString stringWithFormat:@"'%@'", [formattedDateStringTime addSlashes]] : @"NULL";
    
    return formattedDateStringTime;
}

- (NSString*)sqlDate {
    return [self sqlDateWithTimezone:nil];
}

- (NSString*)sqlUTCDate {
    return [self sqlDateWithTimezone:[NSTimeZone timeZoneWithName:@"UTC"]];
}

/*
 * This guy can be a little unreliable and produce unexpected results,
 * you're better off using daysAgoAgainstMidnight
 */
- (NSUInteger)daysAgo {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSDayCalendarUnit)
											   fromDate:self
												 toDate:[NSDate date]
												options:0];
	return [components day];
}

- (NSUInteger)daysAgoAgainstMidnight {
	// get a midnight version of ourself:
	NSDateFormatter *mdf = [[NSDateFormatter alloc] init];
	[mdf setDateFormat:@"yyyy-MM-dd"];
	NSDate *midnight = [mdf dateFromString:[mdf stringFromDate:self]];
	[mdf release];
    
	return (int)[midnight timeIntervalSinceNow] / (60*60*24) *-1;
}

- (NSString *)stringDaysAgo {
	return [self stringDaysAgoAgainstMidnight:YES];
}

- (NSString *)stringDaysAgoAgainstMidnight:(BOOL)flag {
	NSUInteger daysAgo = (flag) ? [self daysAgoAgainstMidnight] : [self daysAgo];
	NSString *text = nil;
	switch (daysAgo) {
		case 0:
			text = @"Today";
			break;
		case 1:
			text = @"Yesterday";
			break;
		default:
			text = [NSString stringWithFormat:@"%lu days ago", (unsigned long)daysAgo];
	}
	return text;
}

- (NSUInteger)weekday {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *weekdayComponents = [calendar components:(NSWeekdayCalendarUnit) fromDate:self];
	return [weekdayComponents weekday];
}

+ (NSDate *)dateFromString:(NSString *)string {
	return [NSDate dateFromString:string withFormat:[NSDate dbFormatString]];
}

+ (NSDate *)dateFromString:(NSString *)string withFormat:(NSString *)format {
	NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
	[inputFormatter setDateFormat:format];
	NSDate *date = [inputFormatter dateFromString:string];
	[inputFormatter release];
	return date;
}

+ (NSString *)stringFromDate:(NSDate *)date withFormat:(NSString *)format {
	return [date stringWithFormat:format];
}

+ (NSString *)stringFromDate:(NSDate *)date {
	return [date string];
}

+ (NSString *)stringForDisplayFromDate:(NSDate *)date prefixed:(BOOL)prefixed alwaysDisplayTime:(BOOL)displayTime {
    /*
	 * if the date is in today, display 12-hour time with meridian,
	 * if it is within the last 7 days, display weekday name (Friday)
	 * if within the calendar year, display as Jan 23
	 * else display as Nov 11, 2008
	 */
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateFormatter *displayFormatter = [[NSDateFormatter alloc] init];
    
	NSDate *today = [NSDate date];
    NSDateComponents *offsetComponents = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit)
													 fromDate:today];
    
	NSDate *midnight = [calendar dateFromComponents:offsetComponents];
	NSString *displayString = nil;
    
	// comparing against midnight
    NSComparisonResult midnight_result = [date compare:midnight];
	if (midnight_result == NSOrderedDescending) {
		if (prefixed) {
			[displayFormatter setDateFormat:@"'at' h:mm a"]; // at 11:30 am
		} else {
			[displayFormatter setDateFormat:@"h:mm a"]; // 11:30 am
		}
	} else {
		// check if date is within last 7 days
		NSDateComponents *componentsToSubtract = [[NSDateComponents alloc] init];
		[componentsToSubtract setDay:-7];
		NSDate *lastweek = [calendar dateByAddingComponents:componentsToSubtract toDate:today options:0];
		[componentsToSubtract release];
        NSComparisonResult lastweek_result = [date compare:lastweek];
		if (lastweek_result == NSOrderedDescending) {
            if (displayTime) {
                [displayFormatter setDateFormat:@"EEEE h:mm a"];
            } else {
                [displayFormatter setDateFormat:@"EEEE"]; // Tuesday
            }
		} else {
			// check if same calendar year
			NSInteger thisYear = [offsetComponents year];
            
			NSDateComponents *dateComponents = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit)
														   fromDate:date];
			NSInteger thatYear = [dateComponents year];
			if (thatYear >= thisYear) {
                if (displayTime) {
                    [displayFormatter setDateFormat:@"MMM d h:mm a"];
                }
                else {
                    [displayFormatter setDateFormat:@"MMM d"];
                }
			} else {
                if (displayTime) {
                    [displayFormatter setDateFormat:@"MMM d, yyyy h:mm a"];
                }
                else {
                    [displayFormatter setDateFormat:@"MMM d, yyyy"];
                }
			}
		}
		if (prefixed) {
			NSString *dateFormat = [displayFormatter dateFormat];
			NSString *prefix = @"'on' ";
			[displayFormatter setDateFormat:[prefix stringByAppendingString:dateFormat]];
		}
	}
    
	// use display formatter to return formatted date string
	displayString = [displayFormatter stringFromDate:date];
    
    [displayFormatter release];
    
	return displayString;
}

+ (NSString *)stringForDisplayFromDate:(NSDate *)date prefixed:(BOOL)prefixed {
	return [[self class] stringForDisplayFromDate:date prefixed:prefixed alwaysDisplayTime:NO];
}

+ (NSString *)stringForDisplayFromDate:(NSDate *)date {
	return [self stringForDisplayFromDate:date prefixed:NO];
}

- (NSString *)stringWithFormat:(NSString *)format {
	NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
	[outputFormatter setDateFormat:format];
	NSString *timestamp_str = [outputFormatter stringFromDate:self];
	[outputFormatter release];
	return timestamp_str;
}

- (NSString *)string {
	return [self stringWithFormat:[NSDate dbFormatString]];
}

- (NSString *)stringWithDateStyle:(NSDateFormatterStyle)dateStyle timeStyle:(NSDateFormatterStyle)timeStyle {
	NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
	[outputFormatter setDateStyle:dateStyle];
	[outputFormatter setTimeStyle:timeStyle];
	NSString *outputString = [outputFormatter stringFromDate:self];
	[outputFormatter release];
	return outputString;
}

- (NSDate *)beginningOfWeek {
	// largely borrowed from "Date and Time Programming Guide for Cocoa"
	// we'll use the default calendar and hope for the best
	NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *beginningOfWeek = nil;
	BOOL ok = [calendar rangeOfUnit:NSWeekCalendarUnit startDate:&beginningOfWeek
						   interval:NULL forDate:self];
	if (ok) {
		return beginningOfWeek;
	}
    
	// couldn't calc via range, so try to grab Sunday, assuming gregorian style
	// Get the weekday component of the current date
	NSDateComponents *weekdayComponents = [calendar components:NSWeekdayCalendarUnit fromDate:self];
    
	/*
	 Create a date components to represent the number of days to subtract from the current date.
	 The weekday value for Sunday in the Gregorian calendar is 1, so subtract 1 from the number of days to subtract from the date in question.  (If today's Sunday, subtract 0 days.)
	 */
	NSDateComponents *componentsToSubtract = [[NSDateComponents alloc] init];
	[componentsToSubtract setDay: 0 - ([weekdayComponents weekday] - 1)];
	beginningOfWeek = nil;
	beginningOfWeek = [calendar dateByAddingComponents:componentsToSubtract toDate:self options:0];
	[componentsToSubtract release];
    
	//normalize to midnight, extract the year, month, and day components and create a new date from those components.
	NSDateComponents *components = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit)
											   fromDate:beginningOfWeek];
	return [calendar dateFromComponents:components];
}

- (NSDate *)beginningOfDay {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    // Get the weekday component of the current date
	NSDateComponents *components = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit)
											   fromDate:self];
	return [calendar dateFromComponents:components];
}

- (NSDate *)beginningOfDay:(NSTimeZone*)timeZone {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:self];
    NSTimeZone* destinationTimeZone = timeZone;
    int timeZoneOffset = (int)[destinationTimeZone secondsFromGMTForDate:self] / 3600;
    [components setHour:timeZoneOffset];
    [components setMinute:0];
    [components setSecond:0];
    NSDate *morningStart = [calendar dateFromComponents:components];
    return morningStart;
}

- (NSDate *)endOfWeek {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    // Get the weekday component of the current date
	NSDateComponents *weekdayComponents = [calendar components:NSWeekdayCalendarUnit fromDate:self];
	NSDateComponents *componentsToAdd = [[NSDateComponents alloc] init];
	// to get the end of week for a particular date, add (7 - weekday) days
	[componentsToAdd setDay:(7 - [weekdayComponents weekday])];
	NSDate *endOfWeek = [calendar dateByAddingComponents:componentsToAdd toDate:self options:0];
	[componentsToAdd release];
    
	return endOfWeek;
}

+ (NSString *)dateFormatString {
	return @"yyyy-MM-dd";
}

+ (NSString *)timeFormatString {
	return @"HH:mm:ss";
}

+ (NSString *)timestampFormatString {
	return @"yyyy-MM-dd HH:mm:ss";
}

// preserving for compatibility
+ (NSString *)dbFormatString {
	return [NSDate timestampFormatString];
}

#pragma mark -
#pragma mark Comparing dates

- (BOOL) isEarlierDate: (NSDate *) aDate
{
	return ([[self earlierDate:aDate] isEqualToDate:self]);
}

- (BOOL) isLaterDate: (NSDate *) aDate
{
	return ([[self laterDate:aDate] isEqualToDate:self]);
}

- (BOOL) dateBetweenStartDate:(NSDate*)start andEndDate:(NSDate*)end {
    
    BOOL isEarlier = [self isLaterDate:start];
    BOOL isLater = [self isEarlierDate:end];
    
    if (isLater && isEarlier) {
        return YES;
    } else
        return NO;
}

#pragma mark -
#pragma mark Date formatting

- (NSString*)localeFormattedDateString {
    
    NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
    [formatter setLocale:[NSLocale currentLocale]];
    [formatter setDateStyle:NSDateFormatterLongStyle];
    [formatter setTimeStyle:NSDateFormatterNoStyle];
    
    NSString *ret = [formatter stringFromDate:self];
    
    return ret;
}

- (NSString*)localeFormattedDateStringWithTime {
    
    NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
    [formatter setDateFormat:@"MMM dd, yyyy HH:mm"];
    [formatter setLocale:[NSLocale currentLocale]];
    //   [formatter setDateStyle:NSDateFormatterShortStyle];
    NSString *ret = [formatter stringFromDate:self];
    return ret;
}

+ (NSDate *)localeFormatted {
    
    return [[NSDate date] dateFormattedLocale];
}

- (NSDate *)dateFormattedLocale {
    
    NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
    [formatter setLocale:[NSLocale currentLocale]];
    [formatter setTimeStyle:NSDateFormatterNoStyle];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    
    NSString *ret = [formatter stringFromDate:self];
    
    return [formatter dateFromString:ret];
}


- (NSString *)formattedStringWithFormat:(NSString *)format
{
    NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
    [formatter setDateFormat:format];
    NSString *ret = [formatter stringFromDate:self];
    
    return ret;
}

- (NSDate *)dateWithoutTime
{
    
    NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    NSString *ret = [formatter stringFromDate:self];
    
    return [formatter dateFromString:ret];
}

+ (NSDate *)dateWithoutTime
{
    return [[NSDate date] dateWithoutTime];
}


#pragma mark -
#pragma mark SQLite formatting

- (NSDate *) dateForSqlite {
    NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
    [formatter setLocale:[NSLocale currentLocale]];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSString *ret = [formatter stringFromDate:self];
    
    NSDate *date = [formatter dateFromString:ret];
    
    return date;
}

+ (NSDate*) dateFromSQLString:(NSString*)dateStr {
    
    NSDateFormatter *dateForm = [[[NSDateFormatter alloc] init] autorelease];
    [dateForm setDateFormat:@"yyyy-MM-dd HH:mm:ss ZZZ"];
    NSDate *date = [dateForm dateFromString:dateStr];
    return date;
}


#pragma mark -
#pragma mark Beginning and end of date components

- (NSDate *) startOfDay
{
    
    
	NSDateComponents *components = [kCurrentCalendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit)
                                                fromDate:self];    [components setHour: 0];
    [components setMinute: 0];
    [components setSecond: 0];
    
    return [kCurrentCalendar dateFromComponents:components];
}

- (NSDate *) endOfDay
{
    NSDateComponents *components = [kCurrentCalendar components: NSUIntegerMax fromDate: self];
    [components setHour: 23];
    [components setMinute: 59];
    [components setSecond: 59];
    
    return [kCurrentCalendar dateFromComponents:components];
}

- (NSDate *)beginningOfMonth {
    
    NSDateComponents *comps = [kCurrentCalendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:self];
    [comps setDay:1];
    
    return [kCurrentCalendar dateFromComponents:comps];
    
}

- (NSDate *)beginningOfYear {
    
    NSDateComponents *comps = [kCurrentCalendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:self];
    [comps setDay:1];
    [comps setMonth:1];
    
    return [kCurrentCalendar dateFromComponents:comps];
    
}

- (NSDate *)endOfMonth {
    
    NSRange daysRange = [kCurrentCalendar rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:self];
    
    NSDateComponents *components = [kCurrentCalendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:self];
    [components setDay:daysRange.length];
    
    return [kCurrentCalendar dateFromComponents:components];
}

- (NSDate *)endOfYear {
    
    NSUInteger days = 0;
    NSDateComponents *components = [kCurrentCalendar components:NSYearCalendarUnit fromDate:self];
    NSUInteger months = [kCurrentCalendar rangeOfUnit:NSMonthCalendarUnit
                                        inUnit:NSYearCalendarUnit
                                       forDate:self].length;
    for (int i = 1; i <= months; i++) {
        components.month = i;
        NSDate *month = [kCurrentCalendar dateFromComponents:components];
        days += [kCurrentCalendar rangeOfUnit:NSDayCalendarUnit
                                inUnit:NSMonthCalendarUnit
                               forDate:month].length;
    }
    
    NSDateComponents *comps = [kCurrentCalendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:self];;
    
    [comps setMonth:12];
    
    return [[kCurrentCalendar dateFromComponents:comps] endOfMonth];
}

#pragma mark -
#pragma mark Date math

- (NSDate *) dateByAddingDays:(NSInteger)days
{
    NSDate *date = [self dateByAddingTimeInterval:(days * kSecondsDay)];
	return date;
}

- (NSDate *) dateBySubtractingDays:(NSInteger)days
{
    
    NSDate *date = [self dateByAddingTimeInterval:(-days * kSecondsDay)];
	return date;
}

- (NSDate *) dateByAddingHours:(NSInteger)hours
{
    NSDate *date = [self dateByAddingTimeInterval:(hours * kSecondsHour)];
	return date;
}

- (NSDate *) dateBySubtractingHours:(NSInteger)hours
{
    NSDate *date = [self dateByAddingTimeInterval:(-hours * kSecondsHour)];
    return date;
}

- (NSDate *) dateByAddingMinutes:(NSInteger)minutes
{
    NSDate *date = [self dateByAddingTimeInterval:(minutes * kSecondsMinute)];
	return date;
}

- (NSDate *) dateBySubtractingMinutes:(NSInteger)minutes
{
    NSDate *date = [self dateByAddingTimeInterval:(-minutes * kSecondsMinute)];
	return date;
}


- (NSDate*) dateByAddingMonth:(int)monthes
{
    NSDateComponents *components = [kCurrentCalendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:self];
    components.month += monthes;
    
    return [kCurrentCalendar dateFromComponents:components];
}

- (NSDate*) dateBySubstractingMonth:(int)monthes
{
    NSDateComponents *components = [kCurrentCalendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:self];
    components.month -= monthes;
    
    return [kCurrentCalendar dateFromComponents:components];
}

- (BOOL) isEqualToDateIgnoringTime: (NSDate *) aDate
{
	NSDateComponents *components1 = [kCurrentCalendar components:kDateComponents fromDate:self];
	NSDateComponents *components2 = [kCurrentCalendar components:kDateComponents fromDate:aDate];
	return ((components1.year == components2.year) &&
			(components1.month == components2.month) &&
			(components1.day == components2.day));
}

#pragma mark Date components

- (NSInteger) hour
{
	NSDateComponents *components = [kCurrentCalendar components:kDateComponents fromDate:self];
	return [components hour];
}

- (NSInteger) minute
{
	NSDateComponents *components = [kCurrentCalendar components:kDateComponents fromDate:self];
	return [components minute];
}

- (NSInteger) seconds
{
	NSDateComponents *components = [kCurrentCalendar components:kDateComponents fromDate:self];
	return [components second];
}

- (NSInteger) day
{
	NSDateComponents *components = [kCurrentCalendar components:kDateComponents fromDate:self];
	return [components day];
}

- (NSInteger) month
{
	NSDateComponents *components = [kCurrentCalendar components:kDateComponents fromDate:self];
	return [components month];
}

- (NSInteger) week
{
	NSDateComponents *components = [kCurrentCalendar components:kDateComponents fromDate:self];
	return [components week];
}

- (NSInteger) nthWeekday // e.g. 2nd Tuesday of the month is 2
{
	NSDateComponents *components = [kCurrentCalendar components:kDateComponents fromDate:self];
	return [components weekdayOrdinal];
}
- (NSInteger) year
{
	NSDateComponents *components = [kCurrentCalendar components:kDateComponents fromDate:self];
	return [components year];
}


- (NSString*) monthName {
    
    NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
    [formatter setDateFormat:@"MMMM"];
    [formatter setLocale:[NSLocale currentLocale]];
    
    NSString *stringFromDate = [formatter stringFromDate:self];
    
    return stringFromDate;
}

- (NSString*) yearFromDateStr {
    
    NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
    [formatter setDateFormat:@"YYYY"];
    [formatter setLocale:[NSLocale currentLocale]];
    
    NSString *stringFromDate = [formatter stringFromDate:self];
    
    return stringFromDate;
}

+ (NSDate *) dateWithDaysFromNow: (NSInteger) days
{
    // Thanks, Jim Morrison
	return [[NSDate date] dateByAddingDays:days];
}

+ (NSDate *) dateWithDaysBeforeNow: (NSInteger) days
{
    // Thanks, Jim Morrison
	return [[NSDate date] dateBySubtractingDays:days];
}

+ (NSDate *) dateTomorrow
{
	return [NSDate dateWithDaysFromNow:1];
}

+ (NSDate *) dateYesterday
{
	return [NSDate dateWithDaysBeforeNow:1];
}

- (BOOL) isToday
{
	return [self isEqualToDateIgnoringTime:[NSDate date]];
}

- (BOOL) isTomorrow
{
	return [self isEqualToDateIgnoringTime:[NSDate dateTomorrow]];
}

- (BOOL) isYesterday
{
	return [self isEqualToDateIgnoringTime:[NSDate dateYesterday]];
}

// This hard codes the assumption that a week is 7 days
- (BOOL) isSameWeekAsDate: (NSDate *) aDate
{
	NSDateComponents *components1 = [kCurrentCalendar components:kDateComponents fromDate:self];
	NSDateComponents *components2 = [kCurrentCalendar components:kDateComponents fromDate:aDate];
    
	// Must be same week. 12/31 and 1/1 will both be week "1" if they are in the same week
	if (components1.week != components2.week) return NO;
    
	// Must have a time interval under 1 week. Thanks @aclark
	return (fabs([self timeIntervalSinceDate:aDate]) < kSecondsWeek);
}

- (BOOL) isThisWeek
{
	return [self isSameWeekAsDate:[NSDate date]];
}

- (BOOL) isNextWeek
{
	NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] + kSecondsWeek;
	NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
	return [self isSameWeekAsDate:newDate];
}

- (BOOL) isLastWeek
{
	NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] - kSecondsWeek;
	NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
	return [self isSameWeekAsDate:newDate];
}

// Thanks, mspasov
- (BOOL) isSameMonthAsDate: (NSDate *) aDate
{
    NSDateComponents *components1 = [kCurrentCalendar components:NSYearCalendarUnit | NSMonthCalendarUnit fromDate:self];
    NSDateComponents *components2 = [kCurrentCalendar components:NSYearCalendarUnit | NSMonthCalendarUnit fromDate:aDate];
    return ((components1.month == components2.month) &&
            (components1.year == components2.year));
}

- (BOOL) isThisMonth
{
    return [self isSameMonthAsDate:[NSDate date]];
}

- (BOOL) isSameYearAsDate: (NSDate *) aDate
{
	NSDateComponents *components1 = [kCurrentCalendar components:NSYearCalendarUnit fromDate:self];
	NSDateComponents *components2 = [kCurrentCalendar components:NSYearCalendarUnit fromDate:aDate];
	return (components1.year == components2.year);
}

- (BOOL) isThisYear
{
    // Thanks, baspellis
	return [self isSameYearAsDate:[NSDate date]];
}

- (BOOL) isNextYear
{
	NSDateComponents *components1 = [kCurrentCalendar components:NSYearCalendarUnit fromDate:self];
	NSDateComponents *components2 = [kCurrentCalendar components:NSYearCalendarUnit fromDate:[NSDate date]];
    
	return (components1.year == (components2.year + 1));
}

- (BOOL) isLastYear
{
	NSDateComponents *components1 = [kCurrentCalendar components:NSYearCalendarUnit fromDate:self];
	NSDateComponents *components2 = [kCurrentCalendar components:NSYearCalendarUnit fromDate:[NSDate date]];
    
	return (components1.year == (components2.year - 1));
}

- (BOOL) isEarlierThanDate: (NSDate *) aDate
{
	return ([self compare:aDate] == NSOrderedAscending);
}

- (BOOL) isLaterThanDate: (NSDate *) aDate
{
	return ([self compare:aDate] == NSOrderedDescending);
}

// Thanks, markrickert
- (BOOL) isInFuture
{
    return ([self isLaterThanDate:[NSDate date]]);
}

// Thanks, markrickert
- (BOOL) isInPast
{
    return ([self isEarlierThanDate:[NSDate date]]);
}

#pragma mark Roles
- (BOOL) isTypicallyWeekend
{
    NSDateComponents *components = [kCurrentCalendar components:NSWeekdayCalendarUnit fromDate:self];
    if ((components.weekday == 1) ||
        (components.weekday == 7))
        return YES;
    return NO;
}

- (BOOL) isTypicallyWorkday
{
    return ![self isTypicallyWeekend];
}

+ (NSInteger)hoursFromGMT {
    return [[NSTimeZone localTimeZone] secondsFromGMT] / 3600;
}

-(NSDate*)toLocalTime {
    NSTimeZone *tz = [NSTimeZone defaultTimeZone];
    NSInteger seconds = [tz secondsFromGMTForDate: self];
    return [NSDate dateWithTimeInterval: seconds sinceDate: self];
}

-(NSDate*)toGlobalTime {
    NSTimeZone *tz = [NSTimeZone defaultTimeZone];
    NSInteger seconds = -[tz secondsFromGMTForDate: self];
    return [NSDate dateWithTimeInterval: seconds sinceDate: self];
}

@end
