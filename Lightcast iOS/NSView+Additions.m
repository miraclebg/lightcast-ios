//
//  NSView+Additions.m
//  Lightcast
//
//  Created by Martin N. Kovachev on 09.02.13.
//  Copyright (c) 2013 г. Nimasystems Ltd. All rights reserved.
//

#import "NSView+Additions.h"

@implementation NSView(Additions)

- (CGFloat)left {
	return self.frame.origin.x;
}

- (void)setLeft:(CGFloat)x {
	CGRect frame = self.frame;
	frame.origin.x = x;
	self.frame = frame;
}

- (CGFloat)top {
	return self.frame.origin.y;
}

- (void)setTop:(CGFloat)y {
	CGRect frame = self.frame;
	frame.origin.y = y;
	self.frame = frame;
}

- (CGFloat)right {
	return self.frame.origin.x + self.frame.size.width;
}

- (void)setRight:(CGFloat)right {
	CGRect frame = self.frame;
	frame.origin.x = right - frame.size.width;
	self.frame = frame;
}

- (CGFloat)bottom {
	return self.frame.origin.y + self.frame.size.height;
}

- (void)setBottom:(CGFloat)bottom {
	CGRect frame = self.frame;
	frame.origin.y = bottom - frame.size.height;
	self.frame = frame;
}

- (CGFloat)centerX {
	return self.center.x;
}

- (void)setCenterX:(CGFloat)centerX {
	self.center = CGPointMake(centerX, self.center.y);
}

- (CGFloat)centerY {
	return self.center.y;
}

- (void)setCenterY:(CGFloat)centerY {
	self.center = CGPointMake(self.center.x, centerY);
}

- (CGFloat)width {
	return self.frame.size.width;
}

- (void)setWidth:(CGFloat)width {
	CGRect frame = self.frame;
	frame.size.width = width;
	self.frame = frame;
}

- (CGFloat)height {
	return self.frame.size.height;
}

- (void)setHeight:(CGFloat)height {
	CGRect frame = self.frame;
	frame.size.height = height;
	self.frame = frame;
}

- (CGPoint)origin {
	return self.frame.origin;
}

- (void)setOrigin:(CGPoint)origin {
	CGRect frame = self.frame;
	frame.origin = origin;
	self.frame = frame;
}

- (CGSize)size {
	return self.frame.size;
}

- (void)setSize:(CGSize)size {
	CGRect frame = self.frame;
	frame.size = size;
	self.frame = frame;
}

- (NSView*)descendantOrSelfWithClass:(Class)cls {
	if ([self isKindOfClass:cls])
		return self;
	
	for (NSView* child in self.subviews) {
		NSView* it = [child descendantOrSelfWithClass:cls];
		if (it)
			return it;
	}
	
	return nil;
}

- (CGPoint)center {
    CGPoint p = CGPointMake((self.frame.origin.x + (self.frame.size.width / 2)),
                            (self.frame.origin.y + (self.frame.size.height / 2)));
    return p;
}

- (void)setCenter:(CGPoint)center {
    // TODO
}

- (NSView*)ancestorOrSelfWithClass:(Class)cls {
	if ([self isKindOfClass:cls]) {
		return self;
	} else if (self.superview) {
		return [self.superview ancestorOrSelfWithClass:cls];
	} else {
		return nil;
	}
}

- (void)removeAllSubviews {
	while (self.subviews.count) {
		NSView* child = self.subviews.lastObject;
		[child removeFromSuperview];
	}
}

- (void)removeAllSubviewsWithoutView:(NSView*)_view {
	for (id obj in [self subviews])
    {
        if (obj != _view)
        {
            [obj removeFromSuperview];
        }
    }
}

- (CGPoint)offsetFromView:(NSView*)otherView {
	CGFloat x = 0, y = 0;
	for (NSView* view = self; view && view != otherView; view = view.superview) {
		x += view.left;
		y += view.top;
	}
	return CGPointMake(x, y);
}

#pragma mark - Positioning

- (void)centerInRect:(CGRect)rect;
{
    [self setCenter:CGPointMake(floorf(CGRectGetMidX(rect)) + ((int)floorf([self width]) % 2 ? .5 : 0) , floorf(CGRectGetMidY(rect)) + ((int)floorf([self height]) % 2 ? .5 : 0))];
}

- (void)centerVerticallyInRect:(CGRect)rect;
{
    [self setCenter:CGPointMake([self center].x, floorf(CGRectGetMidY(rect)) + ((int)floorf([self height]) % 2 ? .5 : 0))];
}

- (void)centerHorizontallyInRect:(CGRect)rect;
{
    [self setCenter:CGPointMake(floorf(CGRectGetMidX(rect)) + ((int)floorf([self width]) % 2 ? .5 : 0), [self center].y)];
}

- (void)centerInSuperView;
{
    [self centerInRect:[[self superview] bounds]];
}
- (void)centerVerticallyInSuperView;
{
    [self centerVerticallyInRect:[[self superview] bounds]];
}
- (void)centerHorizontallyInSuperView;
{
    [self centerHorizontallyInRect:[[self superview] bounds]];
}

- (void)centerHorizontallyBelow:(NSView *)view padding:(CGFloat)padding;
{
    // for now, could use screen relative positions.
    NSAssert([self superview] == [view superview], @"views must have the same parent");
    
    [self setCenter:CGPointMake([view center].x,
                                floorf(padding + CGRectGetMaxY([view frame]) + ([self height] / 2)))];
}

- (void)centerHorizontallyBelow:(NSView *)view;
{
    [self centerHorizontallyBelow:view padding:0];
}

#pragma mark - Other

- (NSViewController*)viewController {
	for (NSView* next = [self superview]; next; next = next.superview) {
		NSResponder* nextResponder = [next nextResponder];
		if ([nextResponder isKindOfClass:[NSViewController class]]) {
			return (NSViewController*)nextResponder;
		}
	}
	return nil;
}

- (void)applyGradientWithColors:(NSArray*)colors atPoints:(NSArray*)points {
    
    if (!colors || !points)
    {
        LogDebug(@"Could not apply gradient without both points and colors.");
        return;
    }
    
    if ([colors count] != [points count])
    {
        LogDebug(@"The number of points must match the number of colors.");
        return;
    }
    
    // create a CAGradientLayer to draw the gradient on
    CAGradientLayer *layer = [CAGradientLayer layer];
    
    // create the colors for our gradient based on the color passed in
    layer.colors = colors;
    // create the color stops for our gradient
    layer.locations = points;
    
    layer.frame = self.bounds;
    [self.layer insertSublayer:layer atIndex:0];
}

#pragma mark - Inner View Shadow

// sourced from http://stackoverflow.com/questions/4431292/inner-shadow-effect-on-uiview-layer

- (void)drawInnerShadowInRect:(CGRect)rect radius:(CGFloat)radius fillColor:(NSColor *)fillColor
{
    CGRect bounds = [self bounds];
    CGContextRef context =  (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort];
    CGFloat outsideOffset = 20.f;
    
    CGMutablePathRef visiblePath = CGPathCreateMutable();
    CGPathMoveToPoint(visiblePath, NULL, bounds.size.width-radius, bounds.size.height);
    CGPathAddArc(visiblePath, NULL, bounds.size.width-radius, radius, radius, 0.5f*M_PI, 1.5f*M_PI, YES);
    CGPathAddLineToPoint(visiblePath, NULL, radius, 0.f);
    CGPathAddArc(visiblePath, NULL, radius, radius, radius, 1.5f*M_PI, 0.5f*M_PI, YES);
    CGPathAddLineToPoint(visiblePath, NULL, bounds.size.width-radius, bounds.size.height);
    CGPathCloseSubpath(visiblePath);
    
    [fillColor setFill];
    CGContextAddPath(context, visiblePath);
    CGContextFillPath(context);
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, -outsideOffset, -outsideOffset);
    CGPathAddLineToPoint(path, NULL, bounds.size.width+outsideOffset, -outsideOffset);
    CGPathAddLineToPoint(path, NULL, bounds.size.width+outsideOffset, bounds.size.height+outsideOffset);
    CGPathAddLineToPoint(path, NULL, -outsideOffset, bounds.size.height+outsideOffset);
    
    CGPathAddPath(path, NULL, visiblePath);
    CGPathCloseSubpath(path);
    
    CGContextAddPath(context, visiblePath);
    CGContextClip(context);

    NSColor * shadowColor = [NSColor colorWithCalibratedRed:0.0f green:0.0f blue:0.0f alpha:0.6f];
    CGContextSaveGState(context);
    CGContextSetShadowWithColor(context, CGSizeMake(0.0f, 4.0f), 8.0f, [shadowColor CGColor]);
    [shadowColor setFill];
    
    CGContextSaveGState(context);
    CGContextAddPath(context, path);
    CGContextFillPath(context);
    
    CGPathRelease(path);
    CGPathRelease(visiblePath);
    CGContextRestoreGState(context);
}

- (void)drawInnerShadowInRect:(CGRect)rect fillColor:(NSColor *)fillColor
{
    [self drawInnerShadowInRect:rect radius:(0.5f * CGRectGetHeight(rect)) fillColor:fillColor];
}

- (void)drawRoundedRectToPath:(CGContextRef)context rect:(CGRect)rect ovalWidth:(CGFloat)ovalWidth ovalHeight:(CGFloat)ovalHeight
{
    float fw, fh;
    
    if (ovalWidth == 0 || ovalHeight == 0)
    {
        CGContextAddRect(context, rect);
        return;
    }
    
    CGContextSaveGState(context);
    CGContextTranslateCTM (context, CGRectGetMinX(rect), CGRectGetMinY(rect));
    CGContextScaleCTM (context, ovalWidth, ovalHeight);
    fw = CGRectGetWidth (rect) / ovalWidth;
    fh = CGRectGetHeight (rect) / ovalHeight;
    CGContextMoveToPoint(context, fw, fh/2);
    CGContextAddArcToPoint(context, fw, fh, fw/2, fh, 1);
    CGContextAddArcToPoint(context, 0, fh, 0, fh/2, 1);
    CGContextAddArcToPoint(context, 0, 0, fw/2, 0, 1);
    CGContextAddArcToPoint(context, fw, 0, fw, fh/2, 1);
    CGContextClosePath(context);
    CGContextRestoreGState(context);
}

- (void)drawGlossyPath:(CGContextRef)context rect:(CGRect)rect
{
    CGFloat quarterHeight = CGRectGetMidY(rect) / 2;
    CGContextSaveGState(context);
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, -20, 0);
    
    CGContextAddLineToPoint(context, -20, quarterHeight);
    CGContextAddQuadCurveToPoint(context, CGRectGetMidX(rect), quarterHeight * 3, CGRectGetMaxX(rect) + 20, quarterHeight);
    CGContextAddLineToPoint(context, CGRectGetMaxX(rect) + 20, 0);
    
    CGContextClosePath(context);
    CGContextRestoreGState(context);
}

- (void)drawLinearGradient:(CGContextRef)context rect:(CGRect)rect startColor:(CGColorRef)startColor endColor:(CGColorRef)endColor
{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGFloat locations[] = { 0.0, 1.0 };
    
    NSArray *colors = [NSArray arrayWithObjects:(id)startColor, (id)endColor, nil];
    
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef) colors, locations);
    
    CGPoint startPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect));
    CGPoint endPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));
    
    CGContextSaveGState(context);
    CGContextAddRect(context, rect);
    CGContextClip(context);
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
    CGContextRestoreGState(context);
    
    CGColorSpaceRelease(colorSpace);
    CGGradientRelease(gradient);
}

- (void)drawLinearGloss:(CGContextRef)context rect:(CGRect)rect reverse:(BOOL)reverse
{
	CGColorRef highlightStart = [[NSColor colorWithCalibratedRed:1.0 green:1.0 blue:1.0 alpha:0.35] CGColor];
	CGColorRef highlightEnd = [[NSColor colorWithCalibratedRed:1.0 green:1.0 blue:1.0 alpha:0.1] CGColor];
    
    if (reverse)
    {
		CGRect half = CGRectMake(rect.origin.x, rect.origin.y+rect.size.height/2, rect.size.width, rect.size.height/2);
        [self drawLinearGradient:context rect:half startColor:highlightEnd endColor:highlightStart];
	}
	else
    {
		CGRect half = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height/2);
        [self drawLinearGradient:context rect:half startColor:highlightStart endColor:highlightEnd];
	}
}

- (void)drawCurvedGloss:(CGContextRef)context rect:(CGRect)rect radius:(CGFloat)radius
{
	CGColorRef glossStart = [[NSColor colorWithCalibratedRed:1.0 green:1.0 blue:1.0 alpha:0.6] CGColor];
	CGColorRef glossEnd = [[NSColor colorWithCalibratedRed:1.0 green:1.0 blue:1.0 alpha:0.1] CGColor];
    
	//CGFloat radius = 60.0f; //radius of gloss
    
	CGMutablePathRef glossPath = CGPathCreateMutable();
    
	CGContextSaveGState(context);
    CGPathMoveToPoint(glossPath, NULL, CGRectGetMidX(rect), CGRectGetMinY(rect)-radius+rect.size.height/2);
	CGPathAddArc(glossPath, NULL, CGRectGetMidX(rect), CGRectGetMinY(rect)-radius+rect.size.height/2, radius, 0.75f*M_PI, 0.25f*M_PI, YES);
	CGPathCloseSubpath(glossPath);
	CGContextAddPath(context, glossPath);
	CGContextClip(context);
    
	CGMutablePathRef buttonPath = [self newRoundedRectForRect:rect radius:6.0f];
    
	CGContextAddPath(context, buttonPath);
    CGPathRelease(buttonPath);
    
	CGContextClip(context);
    
	CGRect half = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height/2);
    
    [self drawLinearGradient:context rect:half startColor:glossStart endColor:glossEnd];
	CGContextRestoreGState(context);
    
	CGPathRelease(glossPath);
}

- (CGMutablePathRef)newRoundedRectForRect:(CGRect)rect radius:(CGFloat)radius
{
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, CGRectGetMidX(rect), CGRectGetMinY(rect));
    CGPathAddArcToPoint(path, NULL, CGRectGetMaxX(rect), CGRectGetMinY(rect), CGRectGetMaxX(rect), CGRectGetMaxY(rect), radius);
    CGPathAddArcToPoint(path, NULL, CGRectGetMaxX(rect), CGRectGetMaxY(rect), CGRectGetMinX(rect), CGRectGetMaxY(rect), radius);
    CGPathAddArcToPoint(path, NULL, CGRectGetMinX(rect), CGRectGetMaxY(rect), CGRectGetMinX(rect), CGRectGetMinY(rect), radius);
    CGPathAddArcToPoint(path, NULL, CGRectGetMinX(rect), CGRectGetMinY(rect), CGRectGetMaxX(rect), CGRectGetMinY(rect), radius);
    CGPathCloseSubpath(path);
    
    return path;
}

- (CGMutablePathRef)newRoundedRectForRectCCW:(CGRect)rect radius:(CGFloat)radius
{
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, CGRectGetMidX(rect), CGRectGetMinY(rect));
    CGPathAddArcToPoint(path, NULL, CGRectGetMinX(rect), CGRectGetMinY(rect), CGRectGetMinX(rect), CGRectGetMaxY(rect), radius);
    CGPathAddArcToPoint(path, NULL, CGRectGetMinX(rect), CGRectGetMaxY(rect), CGRectGetMaxX(rect), CGRectGetMaxY(rect), radius);
    CGPathAddArcToPoint(path, NULL, CGRectGetMaxX(rect), CGRectGetMaxY(rect), CGRectGetMaxX(rect), CGRectGetMinY(rect), radius);
    CGPathAddArcToPoint(path, NULL, CGRectGetMaxX(rect), CGRectGetMinY(rect), CGRectGetMinX(rect), CGRectGetMinY(rect), radius);
    CGPathCloseSubpath(path);
    
    return path;
}

- (NSNumberFormatter*)standardNumberFormatter
{
    NSNumberFormatter *formatter = [[[NSNumberFormatter alloc] init] autorelease];
    [formatter setMaximumSignificantDigits:3];
	[formatter setUsesSignificantDigits:YES];
    return formatter;
}

- (NSImage*)imageSnapshot
{
    NSImage *img = [[[NSImage alloc] initWithData:[self dataWithPDFInsideRect:[self bounds]]] autorelease];
    return img;
}

@end
