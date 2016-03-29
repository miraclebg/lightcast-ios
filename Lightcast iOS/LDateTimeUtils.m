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
 * @changed $Id: LDateTimeUtils.m 349 2014-10-28 14:03:11Z mkovachev $
 * @author $Author: mkovachev $
 * @version $Revision: 349 $
 */

#import "LDateTimeUtils.h"

@implementation LDateTimeUtils

static NSDateFormatter *LDateTimeUtilsSharedDateFormatter;
static dispatch_once_t LDateTimeUtilsSharedDateFormatterOnceToken = 0;

+ (NSDate*)dateFromString:(NSString*)string dateFormat:(NSString*)format {
    return [self dateFromString:string dateFormat:format fromTimezone:nil];
}

+ (NSDate*)dateFromString:(NSString*)string dateFormat:(NSString*)format fromTimezone:(NSTimeZone*)fromTimezone {
    
    dispatch_once(&LDateTimeUtilsSharedDateFormatterOnceToken, ^{
        LDateTimeUtilsSharedDateFormatter = [[NSDateFormatter alloc] init];
    });
    
    @synchronized(LDateTimeUtilsSharedDateFormatter)
    {
        if (!string || ![string isKindOfClass:[NSString class]] || [NSString isNullOrEmpty:format] || [NSString isNullOrEmpty:string])
        {
            return nil;
        }
        
        //NSString *str = [[string copy] autorelease];
        [string retain];
        
        [LDateTimeUtilsSharedDateFormatter setDateFormat:format];
        
        //if (fromTimezone) {
            //NSInteger seconds = -[fromTimezone secondsFromGMTForDate:date];
            //date = [NSDate dateWithTimeInterval:seconds sinceDate: date];
        //}
        
        NSTimeZone *tz = [NSTimeZone timeZoneWithName:@"UTC"];
        [LDateTimeUtilsSharedDateFormatter setTimeZone:(fromTimezone ? fromTimezone : tz)];
        
        NSDate *date = [LDateTimeUtilsSharedDateFormatter dateFromString:string];
        
        [string release];
        
        return date;
    }
}

+ (NSInteger)daysBetween:(NSDate *)dt1 andDate:(NSDate *)dt2
{
    if (!dt1 || !dt2 || [dt1 isEqualToDate:dt2])
    {
        return 0;
    }
    
    NSUInteger unitFlags = NSDayCalendarUnit;
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:unitFlags fromDate:dt1 toDate:dt2 options:0];
    NSInteger daysBetween = abs((int)[components day]);
    return daysBetween+1;
}

@end