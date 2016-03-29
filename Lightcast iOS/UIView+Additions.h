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
 * @changed $Id: UIView+Additions.h 289 2013-08-25 14:30:09Z mkovachev $
 * @author $Author: mkovachev $
 * @version $Revision: 289 $
 */

#define degreesToRadian(x) (M_PI * (x) / 180.0)

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 *	@category UIView(Additions)
 *	@brief Useful helper methods for UIView
 *
 *	@author Martin Kovachev (miracle@nimasystems.com), Nimasystems Ltd
 */
@interface UIView(LAdditions)

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
 * Return the x coordinate on the screen, taking into account scroll views.
 */
@property (nonatomic, readonly) CGFloat screenViewX;

/**
 * Return the y coordinate on the screen, taking into account scroll views.
 */
@property (nonatomic, readonly) CGFloat screenViewY;

/**
 * Return the view frame on the screen, taking into account scroll views.
 */
@property (nonatomic, readonly) CGRect screenFrame;

/**
 * Shortcut for frame.origin
 */
@property (nonatomic) CGPoint origin;

/**
 * Shortcut for frame.size
 */
@property (nonatomic) CGSize size;

/**
 * Return the width in portrait or the height in landscape.
 */
@property (nonatomic, readonly) CGFloat orientationWidth;

/**
 * Return the height in portrait or the width in landscape.
 */
@property (nonatomic, readonly) CGFloat orientationHeight;

/**
 * Finds the first descendant view (including this view) that is a member of a particular class.
 */
- (UIView*)descendantOrSelfWithClass:(Class)cls;

/**
 * Finds the first ancestor view (including this view) that is a member of a particular class.
 */
- (UIView*)ancestorOrSelfWithClass:(Class)cls;

/**
 * Removes all subviews.
 */
- (void)removeAllSubviews;

- (void)removeAllSubviewsWithoutView:(UIView*)_view;

/**
 * Calculates the offset of this view from another view in screen coordinates.
 *
 * otherView should be a parent view of this view.
 */
- (CGPoint)offsetFromView:(UIView*)otherView;

/**
 * Shows the view in a window at the bottom of the screen.
 *
 * This will send a notification pretending that a keyboard is about to appear so that
 * observers who adjust their layout for the keyboard will also adjust for this view.
 */
- (void)presentAsKeyboardInView:(UIView*)containingView;

/**
 * Hides a view that was showing in a window at the bottom of the screen (via presentAsKeyboard).
 *
 * This will send a notification pretending that a keyboard is about to disappear so that
 * observers who adjust their layout for the keyboard will also adjust for this view.
 */
- (void)dismissAsKeyboard:(BOOL)animated;

/**
 * The view controller whose view contains this view.
 */
- (UIViewController*)viewController;

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

- (void)centerHorizontallyBelow:(UIView *)view padding:(CGFloat)padding;
- (void)centerHorizontallyBelow:(UIView *)view;

- (void)drawInnerShadowInRect:(CGRect)rect radius:(CGFloat)radius fillColor:(UIColor *)fillColor;
- (void)drawInnerShadowInRect:(CGRect)rect fillColor:(UIColor *)fillColor;

- (void)drawInnerShadowInRect2:(CGContextRef)context rect:(CGRect)rect radius:(CGFloat)radius fillColor:(UIColor*)fillColor shadowColor:(UIColor*)shadowColor;

- (void)drawRoundedRectToPath:(CGContextRef)context rect:(CGRect)rect ovalWidth:(CGFloat)ovalWidth ovalHeight:(CGFloat)ovalHeight;
- (void)drawGlossyPath:(CGContextRef)context rect:(CGRect)rect;

- (CGMutablePathRef)newRoundedRectForRectCCW:(CGRect)rect radius:(CGFloat)radius;
- (CGMutablePathRef)newRoundedRectForRect:(CGRect)rect radius:(CGFloat)radius;
- (void)drawCurvedGloss:(CGContextRef)context rect:(CGRect)rect radius:(CGFloat)radius;
- (void)drawLinearGloss:(CGContextRef)context rect:(CGRect)rect reverse:(BOOL)reverse;
- (void)drawLinearGradient:(CGContextRef)context rect:(CGRect)rect startColor:(CGColorRef)startColor endColor:(CGColorRef)endColor;

- (UIImage*)imageFromView;

- (UIView*)subviewWithTag:(NSInteger)tag;

@end
