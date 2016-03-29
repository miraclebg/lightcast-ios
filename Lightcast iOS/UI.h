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
 * @changed $Id: UI.h 348 2014-10-18 20:59:25Z mkovachev $
 * @author $Author: mkovachev $
 * @version $Revision: 348 $
 */

/*
 Core Elements:
 
 Carrier Status bar - 320x20
 UIView - 320x460
 UINavigationBar - 320x44
 UITabBar - 320x49
 UISearchBar - 320x44
 UIToolBar - 320x44
 
 Data Input:
 
 UIPickerView - 320x216
 UIDatePicker - 320x216
 UIKeyboard - 320x216
 
 Buttons:
 
 UISegmentedControl - 320x44
 UIButton xx37
 
 Fields:
 
 UITextField - xx37
 UISwitch 94x27
 UISlider - xx23
 
 Indicators:
 
 UIProgressView -xx9
 UIActivityIndicatorView - 37x37
 UIPageControl - 38x36
 */

// Views header includes

#ifdef TARGET_IOS	// iOS Target

#import <Lightcast/UI-General.h>

#import <Lightcast/LView.h>
#import <Lightcast/LImageView.h>
#import <Lightcast/LScrollView.h>
#import <Lightcast/LWebView.h>

// Alerts
#import <Lightcast/LAlertPrompt.h>

// View Controllers
#import <Lightcast/LViewController.h>
#import <Lightcast/LNavigationController.h>
#import <Lightcast/LTabBarController.h>
#import <Lightcast/LTableViewController.h>

// Labels
#import <Lightcast/LLabel.h>

#else

// View Controllers
#if HAS_APPKIT || TARGET_IOS
#import <Lightcast/LViewController.h>
#endif

#endif