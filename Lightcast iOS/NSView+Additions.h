//
//  NSView+Additions.h
//  Lightcast
//
//  Created by Martin N. Kovachev on 09.02.13.
//  Copyright (c) 2013 г. Nimasystems Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSView(Additions)

/**
 * Shortcut for frame.origin.x.
 *
 * Sets frame.origin.x = left
 */
@property (nonatomic) CGFloat left;

/**
 * Shortcut for frame.origin.y
 *
 * Sets frame.origin.y = top
 */
@property (nonatomic) CGFloat top;

/**
 * Shortcut for frame.origin.x + frame.size.width
 *
 * Sets frame.origin.x = right - frame.size.width
 */
@property (nonatomic) CGFloat right;

/**
 * Shortcut for frame.origin.y + frame.size.height
 *
 * Sets frame.origin.y = bottom - frame.size.height
 */
@property (nonatomic) CGFloat bottom;

/**
 * Shortcut for frame.size.width
 *
 * Sets frame.size.width = width
 */
@property (nonatomic) CGFloat width;

/**
 * Shortcut for frame.size.height
 *
 * Sets frame.size.height = height
 */
@property (nonatomic) CGFloat height;

@property (nonatomic) CGPoint center;

/**
 * Shortcut for center.x
 *
 * Sets center.x = centerX
 */
@property (nonatomic) CGFloat centerX;

/**
 * Shortcut for center.y
 *
 * Sets center.y = centerY
 */
@property (nonatomic) CGFloat centerY;

/**
 * Shortcut for frame.origin
 */
@property (nonatomic) CGPoint origin;

/**
 * Shortcut for frame.size
 */
@property (nonatomic) CGSize size;

/**
 * Finds the first descendant view (including this view) that is a member of a particular class.
 */
- (NSView*)descendantOrSelfWithClass:(Class)cls;

/**
 * Finds the first ancestor view (including this view) that is a member of a particular class.
 */
- (NSView*)ancestorOrSelfWithClass:(Class)cls;

/**
 * Removes all subviews.
 */
- (void)removeAllSubviews;

- (void)removeAllSubviewsWithoutView:(NSView*)_view;

/**
 * Calculates the offset of this view from another view in screen coordinates.
 *
 * otherView should be a parent view of this view.
 */
- (CGPoint)offsetFromView:(NSView*)otherView;

/**
 * The view controller whose view contains this view.
 */
- (NSViewController*)viewController;

/**
 * This method applies a gradient to a view by specifying an array of colors and an array of points for those colors
 * @param colors Array of colors for gradient
 * @param points Array of points for gradient
 */
- (void)applyGradientWithColors:(NSArray*)colors atPoints:(NSArray*)points;

- (void)centerInRect:(CGRect)rect;
- (void)centerVerticallyInRect:(CGRect)rect;
- (void)centerHorizontallyInRect:(CGRect)rect;

- (void)centerInSuperView;
- (void)centerVerticallyInSuperView;
- (void)centerHorizontallyInSuperView;

- (void)centerHorizontallyBelow:(NSView *)view padding:(CGFloat)padding;
- (void)centerHorizontallyBelow:(NSView *)view;

- (void)drawInnerShadowInRect:(CGRect)rect radius:(CGFloat)radius fillColor:(NSColor *)fillColor;
- (void)drawInnerShadowInRect:(CGRect)rect fillColor:(NSColor *)fillColor;

- (void)drawRoundedRectToPath:(CGContextRef)context rect:(CGRect)rect ovalWidth:(CGFloat)ovalWidth ovalHeight:(CGFloat)ovalHeight;
- (void)drawGlossyPath:(CGContextRef)context rect:(CGRect)rect;

- (CGMutablePathRef)newRoundedRectForRectCCW:(CGRect)rect radius:(CGFloat)radius;
- (CGMutablePathRef)newRoundedRectForRect:(CGRect)rect radius:(CGFloat)radius;
- (void)drawCurvedGloss:(CGContextRef)context rect:(CGRect)rect radius:(CGFloat)radius;
- (void)drawLinearGloss:(CGContextRef)context rect:(CGRect)rect reverse:(BOOL)reverse;
- (void)drawLinearGradient:(CGContextRef)context rect:(CGRect)rect startColor:(CGColorRef)startColor endColor:(CGColorRef)endColor;

- (NSImage*)imageSnapshot;

@end
