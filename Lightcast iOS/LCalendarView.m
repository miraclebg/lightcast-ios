//
//  LCalendarView.m
//  Lightcast
//
//  Created by Martin Kovachev on 7/18/13.
//  Copyright (c) 2013 Nimasystems Ltd. All rights reserved.
//

#import "LCalendarView.h"
#import <QuartzCore/QuartzCore.h>

CGFloat const kLCalendarViewMonthBarHeight = 37.0;
CGFloat const kLCalendarViewWeekBarHeight = 32.0;

@implementation LCalendarView {

    UIView *_monthBar;
    UIButton *_monthName;
    UIView *_weekdayBar;
    LCalendarGridView *_gridView;
    
    NSMutableDictionary *_reusableCells;
    
    NSDateFormatter *_dateFormatter;
    
    CGSize _lastCellSize;
    
    NSUInteger _selectedDateDay;
    NSUInteger _selectedDateMonth;
    NSUInteger _selectedDateYear;
}

@synthesize
delegate,
dataSource,
calendar,
selectedDate,
displayedDate,
allowTitleClickToReset,
selectedCell,
monthNameBarHeight,
weekdaysBarHeight,
weekdayBarFont,
weekdayBarTextColor,
showsOnlyCurrentMonth;

#pragma mark - Initialization / Finalization

- (id)initWithFrame:(CGRect)frame calendar:(NSCalendar*)calendar_
{
    self = [super initWithFrame:frame];
    if (self)
    {
        selectedCell = nil;
        
        allowTitleClickToReset = YES;
        
        calendar = [calendar_ retain];
        _lastCellSize = [self preferredCellSize];
        
        _reusableCells = [[NSMutableDictionary alloc] init];
        
        monthNameBarHeight = kLCalendarViewMonthBarHeight;
        weekdaysBarHeight = kLCalendarViewWeekBarHeight;
        weekdayBarFont = [[UIFont systemFontOfSize:14.0] retain];
        weekdayBarTextColor = [[UIColor whiteColor] retain];
        
        self.backgroundColor = [UIColor whiteColor];
        
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.locale = [NSLocale autoupdatingCurrentLocale];
        
        // init month bar
        CGRect r = CGRectMake(0, 0, self.bounds.size.width, kLCalendarViewMonthBarHeight + kLCalendarViewWeekBarHeight);
        _monthBar = [[[UIView alloc] initWithFrame:r] autorelease];
        _monthBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _monthBar.backgroundColor = [UIColor clearColor];
        [self addSubview:_monthBar];
        
        // init month label
        //r = CGRectMake(0, 0, _monthBar.bounds.size.width, kLCalendarViewMonthBarHeight);
        _monthName = [UIButton buttonWithType:UIButtonTypeCustom];
        _monthName.titleLabel.font = [UIFont systemFontOfSize:18.0];
        _monthName.titleLabel.textColor = [UIColor whiteColor];
        _monthName.titleLabel.textAlignment = UITextAlignmentCenter;
        _monthName.titleLabel.adjustsFontSizeToFitWidth = YES;
        _monthName.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _monthName.showsTouchWhenHighlighted = self.allowTitleClickToReset;
        _monthName.backgroundColor = [UIColor blueColor];
        [_monthName setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_monthName addTarget:self action:@selector(titleClickReset) forControlEvents:UIControlEventTouchUpInside];
        [self.monthBar addSubview: _monthName];
        
        // weekday bar
        r = CGRectMake(0,
                       _monthName.frame.origin.y + _monthName.frame.size.height,
                       self.bounds.size.width,
                       weekdaysBarHeight);
        _weekdayBar = [[[UIView alloc] initWithFrame:r] autorelease];
        _weekdayBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _weekdayBar.backgroundColor = [UIColor purpleColor];
        
        // weekday name labels
        for (NSUInteger i = self.calendar.firstWeekday; i < self.calendar.firstWeekday + 7; ++i)
        {
            NSUInteger index = (i - 1) < 7 ? (i - 1) : ((i - 1) - 7);
            
            r = CGRectMake((self.weekdayBar.bounds.size.width / 7) * (i % 7), 0,
                           self.weekdayBar.bounds.size.width / 7, self.weekdayBar.bounds.size.height);
            UILabel *label = [[[UILabel alloc] initWithFrame:r] autorelease];
            label.tag = i;
            label.font = weekdayBarFont;
            label.textAlignment = UITextAlignmentCenter;
            label.adjustsFontSizeToFitWidth = YES;
            label.text = [[_dateFormatter shortWeekdaySymbols] objectAtIndex: index];
            label.backgroundColor = [UIColor clearColor];
            label.textColor = weekdayBarTextColor;
            
            [_weekdayBar addSubview:label];
        }
        
        [self.monthBar addSubview:_weekdayBar];

        // gridview
//        r = CGRectMake(0, _monthBar.frame.origin.y + _monthBar.frame.size.height,
//                       self.bounds.size.width,
//                       self.bounds.size.height - _monthBar.frame.size.height);
        
        r = CGRectMake(0, _monthBar.frame.origin.y + _monthBar.frame.size.height,
                       self.bounds.size.width,
                       self.bounds.size.height);
        
        _gridView = [[[LCalendarGridView alloc] initWithFrame:r] autorelease];
        _gridView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _gridView.backgroundColor = [UIColor clearColor];
        _gridView.cellSize = _lastCellSize;
        [self addSubview: _gridView];
        
        // init with default date
        //self.displayedDate = [NSDate date];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame calendar:[NSCalendar currentCalendar]];
}

- (void)dealloc
{
    dataSource = nil;
    delegate = nil;
    
    L_RELEASE(calendar);
    L_RELEASE(selectedDate);
    L_RELEASE(displayedDate);
    L_RELEASE(_dateFormatter);
    L_RELEASE(selectedCell);
    L_RELEASE(weekdayBarFont);
    L_RELEASE(weekdayBarTextColor);
    L_RELEASE(_reusableCells);
    
    [super dealloc];
}

#pragma mark - View Related

- (CGSize)preferredCellSize
{
    CGSize s = CGSizeMake(_gridView.frame.size.width / 7,
                          _gridView.frame.size.height / 6
                          );
    return s;
}

- (void)sizeToFit
{
    CGSize s = CGSizeMake(
                          self.bounds.size.width,
                          _monthBar.frame.size.height + _gridView.frame.size.height
                          );
    [self setSize:s];
}

/*
- (void)didMoveToSuperview
{
    // initialize the cells here
    if (!self.gridView.cells)
    {
        [self initInternalViews];
    }
}*/

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // MONTH HEADER
    
    // month / weekday container
    CGRect r = CGRectMake(0, 0, self.bounds.size.width, monthNameBarHeight + weekdaysBarHeight);
    _monthBar.frame = r;
    
    // month label
    r = CGRectMake(0, 2, self.bounds.size.width, monthNameBarHeight);
    _monthName.frame = r;
    
    // weekday bar
    r = CGRectMake(0,
                   _monthName.frame.origin.y + _monthName.frame.size.height - 2,
                   self.bounds.size.width,
                   weekdaysBarHeight);
    _weekdayBar.frame = r;
    
    // weekday name labels
    NSInteger i = 0;
    
    for (UIView *v in _weekdayBar.subviews)
    {
        r = CGRectMake((self.weekdayBar.bounds.size.width / 7) * (i % 7),
                       0,
                       self.weekdayBar.bounds.size.width / 7,
                       self.weekdayBar.bounds.size.height);
        v.frame = r;
        i++;
    }
    
    // gridview
    r = CGRectMake(0, _monthBar.frame.origin.y + _monthBar.frame.size.height,
                   self.bounds.size.width,
                   self.bounds.size.height - _monthBar.frame.size.height);
    _gridView.frame = r;
    
    // CELLS
    
    if (self.gridView.cells)
    {
        // Calculate shift
        NSInteger shift = 0;
        
        if (self.showsOnlyCurrentMonth)
        {
            NSDateComponents *components = [self.calendar components: NSWeekdayCalendarUnit
                                                            fromDate: [self displayedMonthStartDate]];
            shift = components.weekday - self.calendar.firstWeekday;
            
            if (shift < 0)
            {
                shift = 7 + shift;
            }
        }
        
        CGSize cellSize = [self preferredCellSize];
        
        if (cellSize.width != _lastCellSize.width || cellSize.height != _lastCellSize.height)
        {
            _lastCellSize = cellSize;
            
            // mark grid view to update
            self.gridView.cellSize = _lastCellSize;
        }
        
        LogDebug(@"LAYOUTED");
        
        CGRect rectCellView;
        
        NSInteger indexGridViewHeight = 1;
        
        CGFloat borderPadding = self.gridView.cellBorderWidth;
        
        for (NSUInteger i = 0; i < [self.gridView.cells count]; ++i)
        {
            LCalendarCellView *cellView = [self.gridView.cells objectAtIndex:i];
            
            rectCellView = CGRectMake(cellSize.width * ((shift + i) % 7) + borderPadding ,
                                      cellSize.height * ((shift + i) / 7) + borderPadding,
                                      cellSize.width - (borderPadding*2),
                                      cellSize.height - (borderPadding*2));
            cellView.frame = rectCellView;
            
            if ((cellSize.width * ((shift + i) % 7)) == 0 && i != 0)
            {
                indexGridViewHeight++;
            }
        }
        
        self.gridView.frame = CGRectMake(0, self.monthBar.bounds.size.height,
                                         self.bounds.size.width ,
                                         cellSize.height * indexGridViewHeight);
    }
}

#pragma mark - Cells Initialization

- (id)dequeueReusableCellForDate:(NSInteger)cellIndex
{
    id cell = [_reusableCells objectForKey:[NSNumber numberWithInteger:cellIndex]];
    return cell;
}

- (void)initInternalViews
{
    lassert(displayedDate);
    lassert(calendar);

    L_RELEASE(selectedCell);
    _gridView.cells = nil;
    
    if (!self.dataSource)
    {
        return;
    }
    
    NSDate *date = nil;
    
    NSDateComponents *componentsToday = [self.calendar components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:[NSDate date]];
    NSInteger todayYear = componentsToday.year;
    NSInteger todayMonth = componentsToday.month;
    NSInteger todayDay = componentsToday.day;
    
    NSDateComponents *components = [self.calendar components:NSMonthCalendarUnit | NSYearCalendarUnit fromDate:self.displayedDate];
    NSInteger year = components.year;
    NSInteger month = components.month;
    //NSInteger day = components.day;
    
    NSCalendar* cal = self.calendar;
    NSDateComponents* comps = [[[NSDateComponents alloc] init] autorelease];
    
    [comps setMonth:month];
    [comps setYear:year];
    
    // Calculate shift
    [comps setDay:1];
    NSDate *firstDate = [cal dateFromComponents:comps];

    NSDateComponents *componentsW = [self.calendar components:NSWeekdayCalendarUnit
                                                     fromDate:firstDate];
    NSInteger shift = componentsW.weekday - cal.firstWeekday;
    
    if (shift < 0)
    {
        shift = 7 + shift;
    }
    
    // current month days
    NSRange range = [cal rangeOfUnit:NSDayCalendarUnit
                              inUnit:NSMonthCalendarUnit
                             forDate:[cal dateFromComponents:comps]];
    NSInteger days = range.length;
    
    // previous month days
    [comps setMonth:(month-1 < 1 ? 12 : month-1)];
    [comps setYear:(month-1 < 1 ? year-1 : year)];
    NSRange rangePrev = [cal rangeOfUnit:NSDayCalendarUnit
                              inUnit:NSMonthCalendarUnit
                             forDate:[cal dateFromComponents:comps]];
    NSInteger daysPrev = rangePrev.length;
    
    // reset
    [comps setMonth:month];
    [comps setYear:year];
    
    NSMutableArray *cells = [NSMutableArray array];

    CGSize preferredCellSize = [self preferredCellSize];
    CGRect rectCellView = CGRectMake(0, 0, preferredCellSize.width, preferredCellSize.height);
    
    LCalendarCellView *cell = nil;
    
    NSInteger matrixSize = (shift + days > 35) ? 42 : 35;
    
    NSInteger start = self.showsOnlyCurrentMonth ? 1 : (1 - shift);
    //NSInteger max = self.showsOnlyCurrentMonth ? days : matrixSize - (shift > 0 ? abs(start) -1 : 0);
    NSInteger max = days + (matrixSize - (shift + days));
    NSInteger nextD = 0;
    NSInteger i = 0;

    NSInteger cellIndex = 0;
    
    for(i=start;i<=max;i++)
    {
        // make the new date
        NSInteger m = (i < 1 ? (month-1 < 1 ? 12 : month-1) : (i > days ? (month+1 > 12 ? 1 : month+1) : month));
        NSInteger d = (i < 1 ? daysPrev - abs((int)i) : (i > days ? 1+nextD : i));
        NSInteger y = (i < 1 ? (month-1 < 1 ? year-1 : year) : (i > days ? (month+1 > 12 ? year+1 : year) : year));
        
        //LogDebug(@"Cal date: %d.%d.%d", d, m, y);
        
        [comps setMonth:m];
        [comps setDay:d];
        [comps setYear:y];
        date = [cal dateFromComponents:comps];
        
        if (i > days)
        {
            nextD++;
        }
        
        // fetch from data source
        cell = [self.dataSource calendarView:self cellFrame:rectCellView cellForDate:date cellIndex:cellIndex];

        if (cell)
        {
            cell.cellIndex = cellIndex;
            cell.calendar = self.calendar;
            cell.date = date;
            cell.delegate = self;
            cell.isToday = (d == todayDay && m == todayMonth && y == todayYear);
            cell.selected = (d == _selectedDateDay && m == _selectedDateMonth && y == _selectedDateYear);
            cell.isDateWithinCurrentMonth = (m == month && y == year);
            
            // add for reusing
            [_reusableCells setObject:cell forKey:[NSNumber numberWithInteger:cellIndex]];
            
            [cells addObject:cell];
        }
        
        cellIndex++;
    }
    
    //LogDebug(@"MONTH: %d, DAYS: %d, SHIFT: %d, START: %d, MAX: %d, TOTAL CELLS: %d", month, days, shift, start, max, [cells count]);
    
    self.gridView.cells = cells;
    
    NSString *monthName = [[_dateFormatter standaloneMonthSymbols] objectAtIndex: self.displayedMonth - 1];
    NSString *textMonth = [NSString stringWithFormat: @"%@ %d", monthName, (int)self.displayedYear];
    textMonth = [textMonth capitalizedString];
    [self.monthName setTitle:textMonth forState:UIControlStateNormal];
    
    [self setNeedsLayout];
}

#pragma mark - Getters / Setters

- (void)setAllowTitleClickToReset:(BOOL)allowTitleClickToReset_ {
    if (allowTitleClickToReset_ != allowTitleClickToReset) {
        allowTitleClickToReset = allowTitleClickToReset_;
        _monthName.showsTouchWhenHighlighted = self.allowTitleClickToReset;
    }
}

- (void)setSelectedDate:(NSDate *)selectedDate_
{
    if (![selectedDate isEqual:selectedDate_])
    {
        L_RELEASE(selectedDate);
        selectedDate = [selectedDate_ copy];
        
        // keep a cached copy of the components
        if (selectedDate) {
            NSDateComponents *components = [self.calendar components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:self.selectedDate];
            _selectedDateYear = components.year;
            _selectedDateMonth = components.month;
            _selectedDateDay = components.day;
        }
        
        LCalendarCellView *selectedCell_ = nil;
        
        for (LCalendarCellView *cellView in self.gridView.cells)
        {
            if ([self.selectedDate isEqualToDateIgnoringTime:cellView.date])
            {
                cellView.selected = YES;
                selectedCell_ = cellView;
            }
            else
            {
                cellView.selected = NO;
            }
        }
        
        if (selectedCell_ != selectedCell)
        {
            L_RELEASE(selectedCell);
            selectedCell = [selectedCell_ retain];
        }
        
        if (selectedDate)
        {
            if ([self.delegate respondsToSelector:@selector(calendarView:didSelectDate:selectedCell:)])
            {
                [self.delegate calendarView:self didSelectDate:selectedDate selectedCell:selectedCell];
            }
        }
    }
}

- (void)setDisplayedDate:(NSDate *)displayedDate_
{
    if (displayedDate_ == nil || ![self.displayedDate isSameMonthAsDate:displayedDate_])
    {
        self.displayedDate = displayedDate_;
        
        if (self.gridView.cells)
        {
            id view = [self cellForDate:displayedDate];
            
            if (!view)
            {
                // if already attached to superview - reset right away
                [self initInternalViews];
            }
        }
        else
        {
            // if already attached to superview - reset right away
            [self initInternalViews];
        }
        
        // update the selected date
        self.selectedDate = displayedDate;
    }
}

- (void)setDelegate:(id<LCalendarViewDelegate>)delegate_
{
    if (delegate != delegate_)
    {
        delegate = delegate_;
        
        [self setNeedsLayout];
    }
}

- (LCalendarCellView *)cellForDate:(NSDate*)date
{
    if (!date)
    {
        return nil;
    }
    
    for(LCalendarCellView *view in self.gridView.cells)
    {
        if ([view.date isEqualToDateIgnoringTime:date] && view.isDateWithinCurrentMonth)
        {
            return view;
        }
    }
    
    return nil;
}

- (void)setWeekdayBarFont:(UIFont *)weekdayBarFont_
{
    if (weekdayBarFont != weekdayBarFont_)
    {
        L_RELEASE(weekdayBarFont);
        weekdayBarFont = [weekdayBarFont_ retain];
        
        // weekday name labels
        for (UILabel *v in _weekdayBar.subviews)
        {
            v.font = weekdayBarFont;
        }
        
        [self setNeedsLayout];
    }
}

- (void)setWeekdayBarTextColor:(UIColor *)weekdayBarTextColor_
{
    if (weekdayBarTextColor != weekdayBarTextColor_)
    {
        L_RELEASE(weekdayBarTextColor);
        weekdayBarTextColor = [weekdayBarTextColor_ retain];
        
        // weekday name labels
        for (UILabel *v in _weekdayBar.subviews)
        {
            v.textColor = weekdayBarTextColor;
        }
    }
}

- (void)setMonthNameBarHeight:(NSInteger)monthNameBarHeight_
{
    if (monthNameBarHeight != monthNameBarHeight_)
    {
        monthNameBarHeight = monthNameBarHeight_;
        
        [self setNeedsLayout];
    }
}

- (void)setWeekdaysBarHeight:(NSInteger)weekdaysBarHeight_
{
    if (weekdaysBarHeight != weekdaysBarHeight_)
    {
        weekdaysBarHeight = weekdaysBarHeight_;
        
        [self setNeedsLayout];
    }
}

- (void)setShowsOnlyCurrentMonth:(BOOL)showsOnlyCurrentMonth_
{
    if (showsOnlyCurrentMonth != showsOnlyCurrentMonth_)
    {
        showsOnlyCurrentMonth = showsOnlyCurrentMonth_;
        
        // reset the cells as the month may have changed
        L_RELEASE(selectedCell);
        self.gridView.cells = nil;
        self.selectedDate = nil;
        
        [self setNeedsLayout];
        
        self.displayedDate = self.displayedDate ? self.displayedDate : [NSDate date];
    }
}

- (NSUInteger)displayedYear
{
    NSDateComponents *components = [self.calendar components: NSYearCalendarUnit
                                                    fromDate: self.displayedDate];
    return components.year;
}

- (NSUInteger)displayedMonth
{
    NSDateComponents *components = [self.calendar components: NSMonthCalendarUnit
                                                    fromDate: self.displayedDate];
    return components.month;
}

- (NSDate*)displayedMonthStartDate
{
    NSDateComponents *components = [self.calendar components: NSMonthCalendarUnit|NSYearCalendarUnit
                                                    fromDate: self.displayedDate];
    components.day = 1;
    return [self.calendar dateFromComponents: components];
}

- (UIView*)monthBar
{
    return _monthBar;
}

- (UIButton*)monthName
{
    return _monthName;
}

- (UIView*)weekdayBar
{
    return _weekdayBar;
}

- (UIView*)gridView
{
    return _gridView;
}

#pragma mark - Date Navigation

- (void)monthForward
{
    NSDateComponents *monthStep = [[[NSDateComponents alloc] init] autorelease];
    monthStep.month = 1;
    NSDate *newDate = [self.calendar dateByAddingComponents: monthStep toDate: self.displayedDate options: 0];
    
    self.displayedDate = newDate;
}

- (void)monthBack
{
    NSDateComponents *monthStep = [[NSDateComponents new] autorelease];
    monthStep.month = -1;
    NSDate *newDate = [self.calendar dateByAddingComponents: monthStep toDate: self.displayedDate options: 0];
    
    self.displayedDate = newDate;
}

- (void)titleClickReset {
    if (self.allowTitleClickToReset) {
        [self reset];
    }
}

- (void)reset
{
    // reset and show the current date
    self.displayedDate = [NSDate date];
}

#pragma mark - LCalendarCellViewDelegate

- (void)calendarCellView:(LCalendarCellView*)calendarCellView selectedDate:(NSDate *)selectedDate_
{
    self.selectedDate = selectedDate_;
}


@end
