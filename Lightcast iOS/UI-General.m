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
 * @changed $Id: UI-General.m 312 2013-12-09 07:21:51Z mkovachev $
 * @author $Author: mkovachev $
 * @version $Revision: 312 $
 */

#include "UI-General.h"

const CGFloat lkDefaultRowHeight = 44;

const CGFloat lkDefaultPortraitToolbarHeight   = 44;
const CGFloat lkDefaultLandscapeToolbarHeight  = 33;

const CGFloat lkDefaultPortraitKeyboardHeight  = 216;
const CGFloat lkDefaultLandscapeKeyboardHeight = 160;

const CGFloat lkGroupedTableCellInset = 10.0;

const CGFloat lkDefaultTransitionDuration      = 0.3;
const CGFloat lkDefaultFastTransitionDuration  = 0.2;
const CGFloat lkDefaultFlipTransitionDuration  = 0.7;

///////////////////////////////////////////////////////////////////////////////////////////////////
float LOSVersion(void) {
    return [[[UIDevice currentDevice] systemVersion] floatValue];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
BOOL LOSVersionIsAtLeast(float version) {
    // Floating-point comparison is pretty bad, so let's cut it some slack with an epsilon.
    static const CGFloat kEpsilon = 0.0000001;
    
#ifdef __IPHONE_4_0
    return 4.0 - version >= -kEpsilon;
#endif
#ifdef __IPHONE_3_2
    return 3.2 - version >= -kEpsilon;
#endif
#ifdef __IPHONE_3_1
    return 3.1 - version >= -kEpsilon;
#endif
#ifdef __IPHONE_3_0
    return 3.0 - version >= -kEpsilon;
#endif
#ifdef __IPHONE_2_2
    return 2.2 - version >= -kEpsilon;
#endif
#ifdef __IPHONE_2_1
    return 2.1 - version >= -kEpsilon;
#endif
#ifdef __IPHONE_2_0
    return 2.0 - version >= -kEpsilon;
#endif
    return NO;
}

BOOL LIsKeyboardVisible(void) {
    // Operates on the assumption that the keyboard is visible if and only if there is a first
    // responder; i.e. a control responding to key events
    UIWindow* window = [UIApplication sharedApplication].keyWindow;
    return !![window findFirstResponder];
}

BOOL LIsPhoneSupported(void) {
    NSString* deviceType = [UIDevice currentDevice].model;
    return [deviceType isEqualToString:@"iPhone"];
}

static BOOL _l_isIpadChecked, _l_isIpad;

BOOL LIsPad(void) {
    if (_l_isIpadChecked) {
        return _l_isIpad;
    }
#if __IPHONE_3_2 && __IPHONE_3_2 <= __IPHONE_OS_VERSION_MAX_ALLOWED
    _l_isIpad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
#else
    _l_isIpad = NO;
#endif
    _l_isIpadChecked = YES;
    
    return _l_isIpad;
}

UIDeviceOrientation LDeviceOrientation(void) {
    UIDeviceOrientation orient = [UIDevice currentDevice].orientation;
    if (UIDeviceOrientationUnknown == orient) {
        return UIDeviceOrientationPortrait;
    } else {
        return orient;
    }
}

UIInterfaceOrientation LInterfaceOrientation(void) {
    UIInterfaceOrientation orient = [UIApplication sharedApplication].statusBarOrientation;
    return orient;
}

CGRect LScreenBounds(void) {
    CGRect bounds = [UIScreen mainScreen].bounds;
    if (UIInterfaceOrientationIsLandscape(LInterfaceOrientation())) {
        CGFloat width = bounds.size.width;
        bounds.size.width = bounds.size.height;
        bounds.size.height = width;
    }
    return bounds;
}

CGRect LNavigationFrame(void) {
    CGRect frame = [UIScreen mainScreen].applicationFrame;
    return CGRectMake(0, 0, frame.size.width, frame.size.height - LToolbarHeight());
}

CGRect LToolbarNavigationFrame(void) {
    CGRect frame = [UIScreen mainScreen].applicationFrame;
    return CGRectMake(0, 0, frame.size.width, frame.size.height - LToolbarHeight()*2);
}

CGFloat LStatusHeight(void) {
    UIInterfaceOrientation orientation = LInterfaceOrientation();
    if (orientation == UIInterfaceOrientationLandscapeLeft) {
        return [UIScreen mainScreen].applicationFrame.origin.x;
    } else if (orientation == UIInterfaceOrientationLandscapeRight) {
        return -[UIScreen mainScreen].applicationFrame.origin.x;
    } else {
        return [UIScreen mainScreen].applicationFrame.origin.y;
    }
}

CGFloat LBarsHeight(void) {
    CGRect frame = [UIApplication sharedApplication].statusBarFrame;
    if (UIInterfaceOrientationIsPortrait(LInterfaceOrientation())) {
        return frame.size.height + lkDefaultRowHeight;
    } else {
        return frame.size.width + lkDefaultLandscapeToolbarHeight;
    }
}

CGFloat LToolbarHeight(void) {
    return LToolbarHeightForOrientation(LInterfaceOrientation());
}

CGFloat LKeyboardHeight(void) {
    return LKeyboardHeightForOrientation(LInterfaceOrientation());
}

BOOL LIsSupportedOrientation(UIInterfaceOrientation orientation) {
    if (LIsPad()) {
        return YES;
    } else {
        switch (orientation) {
            case UIInterfaceOrientationPortrait:
            case UIInterfaceOrientationLandscapeLeft:
            case UIInterfaceOrientationLandscapeRight:
                return YES;
            default:
                return NO;
        }
    }
}

CGAffineTransform LRotateTransformForOrientation(UIInterfaceOrientation orientation) {
    if (orientation == UIInterfaceOrientationLandscapeLeft) {
        return CGAffineTransformMakeRotation(M_PI*1.5);
    } else if (orientation == UIInterfaceOrientationLandscapeRight) {
        return CGAffineTransformMakeRotation(M_PI/2);
    } else if (orientation == UIInterfaceOrientationPortraitUpsideDown) {
        return CGAffineTransformMakeRotation(-M_PI);
    } else {
        return CGAffineTransformIdentity;
    }
}

CGRect LApplicationFrame(void) {
    CGRect frame = [UIScreen mainScreen].applicationFrame;
    return CGRectMake(0, 0, frame.size.width, frame.size.height);
}

CGFloat LToolbarHeightForOrientation(UIInterfaceOrientation orientation) {
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        return lkDefaultRowHeight;
    } else {
        return lkDefaultLandscapeToolbarHeight;
    }
}

CGFloat LKeyboardHeightForOrientation(UIInterfaceOrientation orientation) {
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        return lkDefaultPortraitKeyboardHeight;
    } else {
        return lkDefaultLandscapeKeyboardHeight;
    }
}

void LAlert(NSString* message) {
    
    UIAlertView* alert = [[[UIAlertView alloc] initWithTitle:LightcastLocalizedString(@"Alert")
                                                     message:message delegate:nil
                                           cancelButtonTitle:LightcastLocalizedString(@"OK")
                                           otherButtonTitles:nil] autorelease];
    [alert show];
}