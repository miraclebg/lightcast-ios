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
 * @changed $Id: UI-General.h 75 2011-07-16 15:47:22Z mkovachev $
 * @author $Author: mkovachev $
 * @version $Revision: 75 $
 */

/**
 * @return the current runtime version of the iPhone OS.
 */
float LOSVersion(void);

/**
 * Checks if the link-time version of the OS is at least a certain version.
 */
BOOL LOSVersionIsAtLeast(float version);

/**
 * @return TRUE if the keyboard is visible.
 */
BOOL LIsKeyboardVisible(void);

/**
 * @return TRUE if the device has phone capabilities.
 */
BOOL LIsPhoneSupported(void);

/**
 * @return TRUE if the device is iPad.
 */
BOOL LIsPad(void);

/**
 * @return the current device orientation.
 */
UIDeviceOrientation LDeviceOrientation(void);

UIInterfaceOrientation LInterfaceOrientation(void);

CGRect LScreenBounds(void);

CGRect LNavigationFrame(void);

CGRect LToolbarNavigationFrame(void);

CGFloat LStatusHeight(void);

CGFloat LBarsHeight(void);

CGFloat LToolbarHeight(void);

CGFloat LKeyboardHeight(void);

/**
 * On iPhone/iPod touch
 * Checks if the orientation is portrait, landscape left, or landscape right.
 * This helps to ignore upside down and flat orientations.
 * 
 * On iPad:
 * Always returns Yes.
 */
BOOL LIsSupportedOrientation(UIInterfaceOrientation orientation);

/**
 * @return the rotation transform for a given orientation.
 */
CGAffineTransform LRotateTransformForOrientation(UIInterfaceOrientation orientation);

/**
 * @return the application frame with no offset.
 *
 * From the Apple docs:
 * Frame of application screen area in points (i.e. entire screen minus status bar if visible)
 */
CGRect LApplicationFrame(void);

/**
 * @return the toolbar height for a given orientation.
 *
 * The toolbar is slightly shorter in landscape.
 */
CGFloat LToolbarHeightForOrientation(UIInterfaceOrientation orientation);

/**
 * @return the height of the keyboard for a given orientation.
 */
CGFloat LKeyboardHeightForOrientation(UIInterfaceOrientation orientation);

/**
 * A convenient way to show a UIAlertView with a message.
 */
void LAlert(NSString* message);

///////////////////////////////////////////////////////////////////////////////////////////////////
// Dimensions of common iPhone OS Views

/**
 * The standard height of a row in a table view controller.
 * @const 44 pixels
 */
extern const CGFloat lkDefaultRowHeight;

/**
 * The standard height of a toolbar in portrait orientation.
 * @const 44 pixels
 */
extern const CGFloat lkDefaultPortraitToolbarHeight;

/**
 * The standard height of a toolbar in landscape orientation.
 * @const 33 pixels
 */
extern const CGFloat lkDefaultLandscapeToolbarHeight;

/**
 * The standard height of the keyboard in portrait orientation.
 * @const 216 pixels
 */
extern const CGFloat lkDefaultPortraitKeyboardHeight;

/**
 * The standard height of the keyboard in landscape orientation.
 * @const 160 pixels
 */
extern const CGFloat lkDefaultLandscapeKeyboardHeight;

/**
 * The space between the edge of the screen and the cell edge in grouped table views.
 * @const 10 pixels
 */
extern const CGFloat lkGroupedTableCellInset;

///////////////////////////////////////////////////////////////////////////////////////////////////
// Animation

/**
 * The standard duration length for a transition.
 * @const 0.3 seconds
 */
extern const CGFloat lkDefaultTransitionDuration;

/**
 * The standard duration length for a fast transition.
 * @const 0.2 seconds
 */
extern const CGFloat lkDefaultFastTransitionDuration;

/**
 * The standard duration length for a flip transition.
 * @const 0.7 seconds
 */
extern const CGFloat lkDefaultFlipTransitionDuration;
