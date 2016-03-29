//
//  LBadgeView.m
//  Lightcast
//
//  Created by Martin N. Kovachev on 23.01.13.
//  Copyright (c) 2013 г. Nimasystems Ltd. All rights reserved.
//

#import "LBadgeView.h"

CGFloat const kLBadgeViewDefaultCornerRadius = 9.0;
CGFloat const kLBadgeViewDefaultTextPadding = 2.0;
CGFloat const kLBadgeViewDefaultBorderWidth = 2.0;
CGFloat const kLBadgeViewDefaultBorderWidthIOS7 = 1.0;
NSString *const kLBadgeViewDefaultFontName = @"Helvetica-Bold";
CGFloat const kLBadgeViewDefaultFontSize = 12.0;
CGFloat const kLBadgeViewDefaultShadowOffset = 4.0;

@implementation LBadgeView {
    
    CGColorRef _ccbackgroundColor;
    CGColorRef _ccBorderColor;
    CGColorRef _ccTextColor;
}

@synthesize
value,
font,
backgroundColor,
borderColor,
textColor,
borderWidth,
cornerRadius,
delegate,
textPaddingX,
textPaddingY;

#pragma mark - Initialization / Finalization

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        super.backgroundColor = [UIColor clearColor];

        cornerRadius = kLBadgeViewDefaultCornerRadius;
        
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
          borderWidth = kLBadgeViewDefaultBorderWidth;
        } else {
            borderWidth = kLBadgeViewDefaultBorderWidthIOS7;
        }
        
        textPaddingX = kLBadgeViewDefaultTextPadding;
        textPaddingY = kLBadgeViewDefaultTextPadding - 1;
        
        self.userInteractionEnabled = YES;
        
        self.backgroundColor = [UIColor redColor];
        self.borderColor = [UIColor whiteColor];
        self.textColor = [UIColor whiteColor];
        self.font = [UIFont fontWithName:kLBadgeViewDefaultFontName size:kLBadgeViewDefaultFontSize];
    }
    return self;
}

- (void)dealloc
{
    delegate = nil;
    
    L_RELEASE(value);
    L_RELEASE(backgroundColor);
    L_RELEASE(borderColor);
    L_RELEASE(font);
    
    if (_ccbackgroundColor != NULL)
    {
        CGColorRelease(_ccbackgroundColor);
    }
    
    if (_ccBorderColor != NULL)
    {
        CGColorRelease(_ccBorderColor);
    }
    
    if (_ccTextColor != NULL)
    {
        CGColorRelease(_ccTextColor);
    }
    
    [super dealloc];
}

#pragma mark - Getters / Setters

- (void)setValue:(NSString *)value_
{
    if (value != value_)
    {
        L_RELEASE(value);
        value = [value_ copy];
        
        [self setNeedsDisplay];
    }
}

- (void)setBackgroundColor:(UIColor *)backgroundColor_
{
    if (backgroundColor != backgroundColor_)
    {
        L_RELEASE(backgroundColor);
        backgroundColor = [backgroundColor_ retain];
        
        CGColorRelease(_ccbackgroundColor);
        _ccbackgroundColor = CGColorRetain([backgroundColor CGColor]);
        
        [self setNeedsDisplay];
    }
}

- (void)setBorderWidth:(CGFloat)borderWidth_
{
    if (borderWidth != borderWidth_)
    {
        borderWidth = borderWidth_;
        
        [self setNeedsDisplay];
    }
}

- (void)setBorderColor:(UIColor *)borderColor_
{
    if (borderColor != borderColor_)
    {
        L_RELEASE(borderColor);
        borderColor = [borderColor_ retain];
        
        CGColorRelease(_ccBorderColor);
        _ccBorderColor = CGColorRetain([borderColor CGColor]);
        
        [self setNeedsDisplay];
    }
}

- (void)setTextColor:(UIColor *)textColor_
{
    if (textColor != textColor_)
    {
        L_RELEASE(textColor);
        textColor = [textColor_ retain];
        
        CGColorRelease(_ccTextColor);
        _ccTextColor = CGColorRetain([textColor CGColor]);
        
        [self setNeedsDisplay];
    }
}

- (void)setCornerRadius:(CGFloat)cornerRadius_
{
    if (cornerRadius != cornerRadius_)
    {
        cornerRadius = cornerRadius_;
        
        [self setNeedsDisplay];
    }
}

- (void)setFont:(UIFont *)font_
{
    if (font != font_)
    {
        L_RELEASE(font);
        font = [font_ retain];
    }
}

#pragma mark - View related

- (void)sizeToFit
{
    if ([NSString isNullOrEmpty:value])
    {
        [super sizeToFit];
        return;
    }
    
    CGFloat highPadd = textPaddingX > textPaddingY ? textPaddingX : textPaddingY;
    
    CGSize necessarySize = [value sizeWithFont:self.font];
    CGRect r = CGRectMake(0, 0,
                          necessarySize.width + self.borderWidth + highPadd + kLBadgeViewDefaultShadowOffset + 8,
                          necessarySize.height + self.borderWidth + highPadd + kLBadgeViewDefaultShadowOffset
    );
    
    self.size = r.size;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // reset the contents of the text rect first
    CGContextClearRect(context, self.bounds);
    
    [self drawBackground:context];
    [self drawText:context];
}

- (void)drawText:(CGContextRef)context
{
    CGFloat padX = textPaddingX + self.borderWidth;
    CGFloat padY = textPaddingY + self.borderWidth;
    
    CGRect rrect = CGRectInset(self.bounds, padX, padY);
    
    if ([NSString isNullOrEmpty:value])
    {
        return;
    }
    
    [textColor set];
    
    [value drawInRect:rrect withFont:self.font lineBreakMode:NSLineBreakByClipping alignment:NSTextAlignmentCenter];
}

- (void)drawBackground:(CGContextRef)context
{
    // draw the shadow first
    CGFloat pad = 4.0f;
    //CGFloat shadowOffset = kLBadgeViewShadowOffset;
    //CGRect rrect = CGRectInset(self.bounds, 4.0f, 6.0f);
  
    //CGFloat minx = CGRectGetMinX(rrect), midx = CGRectGetMidX(rrect), maxx = CGRectGetMaxX(rrect);
    //CGFloat miny = CGRectGetMinY(rrect), midy = CGRectGetMidY(rrect), maxy = CGRectGetMaxY(rrect);
    
    /*CGContextSaveGState(context);
    
    CGColorRef shadowColor = [[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.6f] CGColor];
    //CGContextSaveGState(context);
    CGContextSetShadowWithColor(context, CGSizeMake(0.0f, shadowOffset), 8.0f, shadowColor);
    
    CGContextSetFillColorWithColor(context, shadowColor);
    
    CGContextMoveToPoint(context, minx, midy);
    CGContextAddArcToPoint(context, minx, miny, midx, miny, self.cornerRadius);
    CGContextAddArcToPoint(context, maxx, miny, maxx, midy, self.cornerRadius);
    CGContextAddArcToPoint(context, maxx, maxy, midx, maxy, self.cornerRadius);
    CGContextAddArcToPoint(context, minx, maxy, minx, midy, self.cornerRadius);
    
    CGContextClosePath(context);
    
    CGContextDrawPath(context, kCGPathFillStroke);
    
    CGContextRestoreGState(context);*/
    
    CGContextSaveGState(context);
    
    // draw the rounded stroked path
    pad = self.borderWidth;
    CGRect rrect = CGRectInset(self.bounds, pad, pad);
    
    CGFloat minx = CGRectGetMinX(rrect), midx = CGRectGetMidX(rrect), maxx = CGRectGetMaxX(rrect);
    CGFloat miny = CGRectGetMinY(rrect), midy = CGRectGetMidY(rrect), maxy = CGRectGetMaxY(rrect);
    
    CGContextSetLineJoin(context, kCGLineJoinRound);
    CGContextSetLineWidth(context, borderWidth);
    CGContextSetStrokeColorWithColor(context, _ccBorderColor);
    CGContextSetFillColorWithColor(context, _ccbackgroundColor);
    
    CGContextMoveToPoint(context, minx, midy);
    CGContextAddArcToPoint(context, minx, miny, midx, miny, self.cornerRadius);
    CGContextAddArcToPoint(context, maxx, miny, maxx, midy, self.cornerRadius);
    CGContextAddArcToPoint(context, maxx, maxy, midx, maxy, self.cornerRadius);
    CGContextAddArcToPoint(context, minx, maxy, minx, midy, self.cornerRadius);

    CGContextClosePath(context);
    
    CGContextDrawPath(context, kCGPathFillStroke);
    
    CGContextRestoreGState(context);
    
    // for iOS6 and lower - we draw a curved gloss
    if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
        [self drawCurvedGloss:context rect:rrect radius:60.0f];
    }
}

#pragma mark - Misc

- (NSString*)description
{
    return value;
}

#pragma mark - Touches

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (delegate && [delegate respondsToSelector:@selector(viewTouched:)])
    {
        [delegate viewTouched:self];
    }
}

@end
