//
//  LCalendarView.h
//  Lightcast
//
//  Created by Martin Kovachev on 7/18/13.
//  Copyright (c) 2013 Nimasystems Ltd. All rights reserved.
//

#import <Lightcast/LCalendarCellView.h>
#import <Lightcast/LCalendarGridView.h>

@class LCalendarView;

@protocol LCalendarViewDataSource <NSObject>

@required

- (LCalendarCellView*)calendarView:(LCalendarView*)calendarView cellFrame:(CGRect)frame cellForDate:(NSDate*)cellDate cellIndex:(NSInteger)cellIndex;

@end

@protocol LCalendarViewDelegate <NSObject>

@optional

- (void)calendarView:(LCalendarView*)calendarView didSelectDate:(NSDate *)selectedDate selectedCell:(LCalendarCellView*)selectedCell;

@end

@interface LCalendarView : UIView <UIGestureRecognizerDelegate, LCalendarCellViewDelegate>

@property(nonatomic, retain, readonly) NSCalendar *calendar;

@property(nonatomic, assign) id<LCalendarViewDelegate> delegate;
@property(nonatomic, assign) id<LCalendarViewDataSource> dataSource;

@property(nonatomic, copy) NSDate *selectedDate;
@property(nonatomic, copy) NSDate *displayedDate;
@property (nonatomic, retain, readonly) LCalendarCellView *selectedCell;

@property (nonatomic, assign) BOOL allowTitleClickToReset;

@property (nonatomic, assign) NSInteger monthNameBarHeight;
@property (nonatomic, assign) NSInteger weekdaysBarHeight;
@property(nonatomic, retain) UIFont *weekdayBarFont;
@property(nonatomic, retain) UIColor *weekdayBarTextColor;

@property (nonatomic, assign) BOOL showsOnlyCurrentMonth;

@property(nonatomic, readonly) NSUInteger displayedYear;
@property(nonatomic, readonly) NSUInteger displayedMonth;

@property(nonatomic, assign, readonly) UIView *monthBar;
@property(nonatomic, assign, readonly) UIButton *monthName;
@property(nonatomic, assign, readonly) UIView *weekdayBar;
@property(nonatomic, assign, readonly) LCalendarGridView *gridView;

- (id)initWithFrame:(CGRect)frame calendar:(NSCalendar*)calendar;

- (id)dequeueReusableCellForDate:(NSInteger)cellIndex;

- (void)monthForward;
- (void)monthBack;

- (void)reset;

- (LCalendarCellView *)cellForDate:(NSDate *)date;

@end