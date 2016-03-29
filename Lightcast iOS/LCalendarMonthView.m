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
 * @changed $Id: LCalendarMonthView.m 341 2014-08-28 05:21:47Z mkovachev $
 * @author $Author: mkovachev $
 * @version $Revision: 341 $
 */

#import "LCalendarMonthView.h"

@interface LCalendarMonthView(Private)

- (void)validateAndSetCurrentDate:(NSInteger)aDay month:(LCalendarMonth)aMonth year:(NSInteger)aYear;

@end

@implementation LCalendarMonthView

@synthesize
day,
month,
year,
currentDate;

#pragma mark -
#pragma mark Initialization / Finalization

- (id)init {
    return [self initWithMonth:0 year:0 frame:CGRectNull];
}

- (id)initWithFrame:(CGRect)frame {
    return [self initWithMonth:0 year:0 frame:frame];
}

- (id)initWithMonth:(LCalendarMonth)aMonth year:(NSInteger)aYear {
    return [self initWithMonth:aMonth year:aYear frame:CGRectNull];
}

- (id)initWithMonth:(LCalendarMonth)aMonth year:(NSInteger)aYear frame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self)
    {
        currentDate = nil;
        
        [self validateAndSetCurrentDate:0 month:aMonth year:aYear];
    }
    return self;
}

- (void)dealloc {
    L_RELEASE(currentDate);
    [super dealloc];
}

#pragma mark -
#pragma mark Date / Month picking

- (void)pickDay:(NSInteger)aDay {
    
}

- (void)pickDate:(NSDate*)aDate {
    
}

- (void)pickMonth:(LCalendarMonth)aMonth year:(NSInteger)aYear {
    
}

- (void)prevousMonth {
    
}

- (void)currentMonth {
    
}

- (void)nextMonth {
    
}

#pragma mark -
#pragma mark Private

- (void)validateAndSetCurrentDate:(NSInteger)aDay month:(LCalendarMonth)aMonth year:(NSInteger)aYear {
    
    L_RELEASE(currentDate);
    day = 0;
    month = 0;
    year = 0;
    
    NSDate* now = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    ///////
    NSString* dstr = [NSString stringWithFormat:@"%ld-%ld-%ld", (long)aDay, (long)aMonth, (long)aYear];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    
    @try 
    {
        [df setDateFormat:@"dd-MM-yyyy"];
        NSDate* d = [df dateFromString:dstr];
        
        ///////
        
        NSDateComponents* components = nil;
        NSDate* dd = nil;
        
        if (d)
        {
            dd = d;
            components = [calendar components:NSHourCalendarUnit fromDate:d];
        }
        else
        {
            dd = now;
            components = [calendar components:NSHourCalendarUnit fromDate:now];
        }
        
        day = [components day];
        month = (int)[components month];
        year = [components year];
        
        currentDate = [dd retain];
    }
    @finally 
    {
        [df release];
    }
}

@end
