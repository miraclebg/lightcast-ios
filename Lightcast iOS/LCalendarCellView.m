//
//  LCalendarCellView.h
//  Lightcast
//
//  Created by Martin Kovachev on 7/18/13.
//  Copyright (c) 2013 Nimasystems Ltd. All rights reserved.
//

#import "LCalendarCellView.h"

CGFloat const kLCalendarCellViewLabelHeight = 17.0;

@implementation LCalendarCellView {

    UILabel *_dateLabel;
    NSUInteger _day;
}

@synthesize
selected,
date,
delegate,
cellIndex,
calendar,
isToday,
isDateWithinCurrentMonth,
dateLabel=_dateLabel,
defaultBgColor,
defaultLabelTextColor,
selectedLabelTextColor,
selectedBgColor,
todayBgColor,
todayLabelTextColor,
otherMonthBgColor,
otherMonthLabelTextColor,
otherMonthAlphaValue,
allowsSelection,
allowsSelectionIfOtherMonth,
showsTouchEffect;

#pragma mark - Initialization / Finalization

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.clipsToBounds = YES;
        
        _day = 0;
        self.calendar = [NSCalendar currentCalendar];
        self.selected = NO;
        self.date = [NSDate date];
        
        otherMonthAlphaValue = 0.5;
        
        allowsSelection = YES;
        allowsSelectionIfOtherMonth = NO;
        showsTouchEffect = YES;
        isDateWithinCurrentMonth = YES;
        isToday = NO;
        
        defaultBgColor = [UIColor clearColor];
        defaultLabelTextColor = [UIColor blackColor];
        selectedLabelTextColor = [[UIColor whiteColor] retain];
        selectedBgColor = [[UIColor redColor] retain];
        todayBgColor = [[UIColor purpleColor] retain];
        todayLabelTextColor = [[UIColor whiteColor] retain];
        otherMonthBgColor = [[UIColor grayColor] retain];
        otherMonthLabelTextColor = [[UIColor whiteColor] retain];
        
        self.backgroundColor = defaultBgColor;
        
        //self.layer.borderWidth = 0.5;
        //self.layer.borderColor = [[UIColor grayColor] CGColor];
        
        // UILabel Date
        _dateLabel = [[[UILabel alloc] initWithFrame:self.bounds] autorelease];
        _dateLabel.backgroundColor = [UIColor clearColor];
        _dateLabel.textColor = defaultLabelTextColor;
        [_dateLabel setText:@""];
        [_dateLabel sizeToFit];
        _dateLabel.adjustsFontSizeToFitWidth = YES;
        _dateLabel.textAlignment = UITextAlignmentCenter;
        _dateLabel.font = [UIFont systemFontOfSize:14.0];
        [self addSubview:_dateLabel];
    }
    
    return self;
}

- (void)dealloc
{
    delegate = nil;
    L_RELEASE(date);
    L_RELEASE(calendar);
    
    L_RELEASE(defaultBgColor);
    L_RELEASE(defaultLabelTextColor);
    L_RELEASE(selectedLabelTextColor);
    L_RELEASE(selectedBgColor);
    L_RELEASE(otherMonthBgColor);
    L_RELEASE(otherMonthLabelTextColor);
    L_RELEASE(todayBgColor);
    L_RELEASE(todayLabelTextColor);
    
    [super dealloc];
}

#pragma mark - Touches

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!self.allowsSelection)
    {
        return;
    }
    
    if (!self.isDateWithinCurrentMonth && !self.allowsSelectionIfOtherMonth)
    {
        return;
    }
    
    if (self.showsTouchEffect)
    {
        [self makeViewShine];
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(calendarCellView:selectedDate:)])
    {
        [self.delegate calendarCellView:self selectedDate:self.date];
    }
}

#pragma mark - View Related

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // label
    _dateLabel.frame = self.bounds;
}

- (UIColor*)_cellBackgroundColor
{
    UIColor *color = nil;
    
    if (self.selected)
    {
        color = self.isDateWithinCurrentMonth ? self.selectedBgColor : self.otherMonthBgColor;
    }
    else if (isToday)
    {
        color = self.todayBgColor;
    }
    else
    {
        color = self.isDateWithinCurrentMonth ? self.defaultBgColor : self.otherMonthBgColor;
    }
    
    return color;
}

- (UIColor*)_labelTextColor
{
    UIColor *color = nil;
    
    if (self.selected)
    {
        color = self.isDateWithinCurrentMonth ? self.selectedLabelTextColor : self.otherMonthLabelTextColor;
    }
    else if (isToday)
    {
        color = self.todayLabelTextColor;
    }
    else
    {
        color = self.isDateWithinCurrentMonth ? self.defaultLabelTextColor : self.otherMonthLabelTextColor;
    }
    
    return color;
}

- (CGFloat)_labelAlphaValue
{
    CGFloat val = self.isDateWithinCurrentMonth ? 1.0 : otherMonthAlphaValue;
    return val;
}

-(void)makeViewShine
{
    UIView *view = self;
    
    view.layer.shadowColor = [UIColor yellowColor].CGColor;
    view.layer.shadowRadius = 10.0f;
    view.layer.shadowOpacity = 1.0f;
    view.layer.shadowOffset = CGSizeZero;
    
    [self.superview bringSubviewToFront:self];
    
    [UIView animateWithDuration:0.2f delay:0 options:UIViewAnimationOptionAutoreverse | UIViewAnimationCurveEaseInOut | UIViewAnimationOptionRepeat | UIViewAnimationOptionAllowUserInteraction  animations:^{
        
        [UIView setAnimationRepeatCount:1];
        
        view.transform = CGAffineTransformMakeScale(1.2f, 1.2f);
        
        
    } completion:^(BOOL finished) {
        
        view.layer.shadowRadius = 0.0f;
        view.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
    }];
}

#pragma mark - Getters / Setters

- (void)setSelected:(BOOL)selected_
{
    if (selected != selected_)
    {
        selected = selected_;
        
        // update the bg color of selected cells
        self.backgroundColor = [self _cellBackgroundColor];
        
        // label color
        _dateLabel.textColor = [self _labelTextColor];
        
        // label alpha
        //_dateLabel.alpha = [self _labelAlphaValue];
        self.alpha = [self _labelAlphaValue];
    }
}

- (void)setDate:(NSDate *)date_
{
    if (date != date_)
    {
        L_RELEASE(date);
        date = [date_ copy];
        
        _day = 0;
        
        if (date)
        {
            NSDateComponents *components = [self.calendar components:NSDayCalendarUnit
                                                            fromDate:date];
            _day = components.day;
        }
        
        [_dateLabel setText:(_day ? [NSString stringWithFormat:@"%d", (int)_day] : @"")];
        
        // update the bg color of selected cells
        self.backgroundColor = [self _cellBackgroundColor];
        
        // label color
        _dateLabel.textColor = [self _labelTextColor];
        
        // label alpha
        //_dateLabel.alpha = [self _labelAlphaValue];
        self.alpha = [self _labelAlphaValue];
        
        [self setNeedsLayout];
    }
}

- (void)setSelectedLabelTextColor:(UIColor *)selectedLabelTextColor_
{
    if (selectedLabelTextColor != selectedLabelTextColor_)
    {
        L_RELEASE(selectedLabelTextColor);
        selectedLabelTextColor = [selectedLabelTextColor_ retain];
        
        if (self.selected && self.isDateWithinCurrentMonth)
        {
            _dateLabel.textColor = selectedLabelTextColor;
        }
    }
}

- (void)setSelectedBgColor:(UIColor *)selectedBgColor_
{
    if (selectedBgColor != selectedBgColor_)
    {
        L_RELEASE(selectedBgColor);
        selectedBgColor = [selectedBgColor_ retain];
        
        if (self.selected && self.isDateWithinCurrentMonth)
        {
            self.backgroundColor = selectedBgColor;
        }
    }
}

- (void)setOtherMonthBgColor:(UIColor *)otherMonthBgColor_
{
    if (otherMonthBgColor != otherMonthBgColor_)
    {
        L_RELEASE(otherMonthBgColor);
        otherMonthBgColor = [otherMonthBgColor_ retain];
        
        if (!self.selected && self.isDateWithinCurrentMonth)
        {
            self.backgroundColor = otherMonthBgColor;
        }
    }
}

- (void)setOtherMonthLabelTextColor:(UIColor *)otherMonthLabelTextColor_
{
    if (otherMonthLabelTextColor != otherMonthLabelTextColor_)
    {
        L_RELEASE(otherMonthLabelTextColor);
        otherMonthLabelTextColor = [otherMonthLabelTextColor_ retain];
        
        if (!self.selected && self.isDateWithinCurrentMonth)
        {
            _dateLabel.textColor = otherMonthLabelTextColor;
        }
    }
}

- (void)setDefaultBgColor:(UIColor *)defaultBgColor_
{
    if (defaultBgColor != defaultBgColor_)
    {
        L_RELEASE(defaultBgColor);
        defaultBgColor = [defaultBgColor_ retain];
        
        if (!self.selected && self.isDateWithinCurrentMonth)
        {
            self.backgroundColor = defaultBgColor;
        }
    }
}

- (void)setDefaultLabelTextColor:(UIColor *)defaultLabelTextColor_
{
    if (defaultLabelTextColor != defaultLabelTextColor_)
    {
        L_RELEASE(defaultLabelTextColor);
        defaultLabelTextColor = [defaultLabelTextColor_ retain];
        
        if (!self.selected && self.isDateWithinCurrentMonth)
        {
            _dateLabel.textColor = defaultLabelTextColor;
        }
    }
}

- (void)setTodayBgColor:(UIColor *)todayBgColor_
{
    if (todayBgColor != todayBgColor_)
    {
        L_RELEASE(todayBgColor);
        todayBgColor = [todayBgColor_ retain];
        
        if (isToday)
        {
            // update the bg color of selected cells
            self.backgroundColor = [self _cellBackgroundColor];
            
            // label color
            _dateLabel.textColor = [self _labelTextColor];
            
            // label alpha
            //_dateLabel.alpha = [self _labelAlphaValue];
            self.alpha = [self _labelAlphaValue];
        }
    }
}

- (void)setTodayLabelTextColor:(UIColor *)todayLabelTextColor_
{
    if (todayLabelTextColor != todayLabelTextColor_)
    {
        L_RELEASE(todayLabelTextColor);
        todayLabelTextColor = [todayLabelTextColor_ retain];
        
        if (isToday)
        {
            // update the bg color of selected cells
            self.backgroundColor = [self _cellBackgroundColor];
            
            // label color
            _dateLabel.textColor = [self _labelTextColor];
            
            // label alpha
            //_dateLabel.alpha = [self _labelAlphaValue];
            self.alpha = [self _labelAlphaValue];
            
        }
    }
}

- (void)setOtherMonthAlphaValue:(CGFloat)otherMonthAlphaValue_
{
    if (otherMonthAlphaValue != otherMonthAlphaValue_)
    {
        otherMonthAlphaValue = otherMonthAlphaValue_;
        
        //_dateLabel.alpha = [self _labelAlphaValue];
        self.alpha = [self _labelAlphaValue];
    }
}

- (void)setIsToday:(BOOL)isToday_
{
    if (isToday != isToday_)
    {
        isToday = isToday_;
        
        // update the bg color of selected cells
        self.backgroundColor = [self _cellBackgroundColor];
        
        // label color
        _dateLabel.textColor = [self _labelTextColor];
        
        // label alpha
        //_dateLabel.alpha = [self _labelAlphaValue];
        self.alpha = [self _labelAlphaValue];
    }
}

- (void)setIsDateWithinCurrentMonth:(BOOL)isDateWithinCurrentMonth_
{
    if (isDateWithinCurrentMonth != isDateWithinCurrentMonth_)
    {
        isDateWithinCurrentMonth = isDateWithinCurrentMonth_;
        
        // update the bg color of selected cells
        self.backgroundColor = [self _cellBackgroundColor];
        
        // label color
        _dateLabel.textColor = [self _labelTextColor];
        
        // label alpha
        //_dateLabel.alpha = [self _labelAlphaValue];
        self.alpha = [self _labelAlphaValue];
    }
}

@end
