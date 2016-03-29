//
//  LCalendarCellView.h
//  Lightcast
//
//  Created by Martin Kovachev on 7/18/13.
//  Copyright (c) 2013 Nimasystems Ltd. All rights reserved.
//

@class LCalendarCellView;

@protocol LCalendarCellViewDelegate <NSObject>

@optional

- (void)calendarCellView:(LCalendarCellView*)calendarCellView selectedDate:(NSDate *)selectedDate;

@end

extern CGFloat const kCXCalendarCellViewLabelHeight;

@interface LCalendarCellView : UIView

@property (nonatomic, assign) id<LCalendarCellViewDelegate> delegate;

@property (nonatomic, assign) BOOL selected;

@property (nonatomic, assign) NSInteger cellIndex;

@property (nonatomic, retain) NSCalendar *calendar;
@property (nonatomic, copy) NSDate *date;
@property (nonatomic, assign) BOOL isToday;
@property (nonatomic, assign) BOOL isDateWithinCurrentMonth;

@property (nonatomic, readonly) UILabel *dateLabel;

@property (nonatomic, assign) BOOL allowsSelection;
@property (nonatomic, assign) BOOL allowsSelectionIfOtherMonth;

@property (nonatomic, retain) UIColor *defaultBgColor;
@property (nonatomic, retain) UIColor *defaultLabelTextColor;
@property (nonatomic, retain) UIColor *selectedLabelTextColor;
@property (nonatomic, retain) UIColor *selectedBgColor;
@property (nonatomic, retain) UIColor *todayBgColor;
@property (nonatomic, retain) UIColor *todayLabelTextColor;
@property (nonatomic, retain) UIColor *otherMonthBgColor;
@property (nonatomic, retain) UIColor *otherMonthLabelTextColor;
@property (nonatomic, assign) CGFloat otherMonthAlphaValue;

@property (nonatomic, assign) BOOL showsTouchEffect;

@end
