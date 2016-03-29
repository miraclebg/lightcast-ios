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
 * @changed $Id: LCalendarMonthView.h 357 2015-04-16 06:29:29Z mkovachev $
 * @author $Author: mkovachev $
 * @version $Revision: 357 $
 */

#import <Foundation/Foundation.h>
#import <Lightcast/LView.h>

typedef enum {
    lcJanuary = 1,
    lcFebruary = 2,
    lcMarch = 3,
    lcApril = 4,
    lcMay = 5,
    lcJune = 6,
    lcJuly = 7,
    lcAugust = 8,
    lcSeptember = 9,
    lcOctober = 10,
    lcNovember = 11,
    lcDecember = 12
} LCalendarMonth;

@interface LCalendarMonthView : LView {
    
    NSInteger day;
    LCalendarMonth month;
    NSInteger year;
    NSDate* currentDate;
    
    
}

@property (nonatomic, readonly) NSInteger day;
@property (nonatomic, readonly) LCalendarMonth month;
@property (nonatomic, readonly) NSInteger year;
@property (nonatomic, retain, readonly) NSDate* currentDate;

- (id)initWithFrame:(CGRect)frame;
- (id)initWithMonth:(LCalendarMonth)aMonth year:(NSInteger)aYear;
- (id)initWithMonth:(LCalendarMonth)aMonth year:(NSInteger)aYear frame:(CGRect)frame;

- (void)pickDay:(NSInteger)aDay;
- (void)pickDate:(NSDate*)aDate;
- (void)pickMonth:(LCalendarMonth)aMonth year:(NSInteger)aYear;

- (void)prevousMonth;
- (void)currentMonth;
- (void)nextMonth;

@end
