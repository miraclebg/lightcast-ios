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
 * @changed $Id: LViewController.h 341 2014-08-28 05:21:47Z mkovachev $
 * @author $Author: mkovachev $
 * @version $Revision: 341 $
 */

#import <Lightcast/LC.h>
#import <Lightcast/LDatabaseManager.h>
#import <Lightcast/LPluginManager.h>
#import <Lightcast/LStorage.h>

@class LViewController;

@protocol LViewControllerDelegate <NSObject>

@optional

#ifdef TARGET_IOS
- (void)viewControllerWillAppear:(LViewController*)viewController;
- (void)viewControllerDidAppear:(LViewController*)viewController;

- (void)viewControllerWillDisappear:(LViewController*)viewController;
- (void)viewControllerDidDisappear:(LViewController*)viewController;

- (void)viewControllerWillLayoutSubviews:(LViewController*)viewController;
- (void)viewControllerDidLayoutSubviews:(LViewController*)viewController;

- (void)viewControllerDidLoad:(LViewController*)viewController;

- (void)viewControllerWillUnLoad:(LViewController*)viewController;
- (void)viewControllerDidUnload:(LViewController*)viewController;
#endif

@end

#ifdef TARGET_IOS

typedef enum
{
    LViewControllerProgressIndicatorStyleDefault = 0,
    LViewControllerProgressIndicatorStyleLarge = 1
    
} LViewControllerProgressIndicatorStyle;


@interface LViewController : UIViewController
#else
@interface LViewController : NSViewController
#endif

@property (nonatomic, readonly, getter = getLightcast) LC* lc;
@property (nonatomic, readonly, getter = getDatabaseManager) LDatabaseManager* db;
@property (nonatomic, readonly, getter = getPluginManager) LPluginManager* plugins;
@property (nonatomic, readonly, getter = getStorage) LStorage* storage;
@property (nonatomic, readonly, getter = getMainViewFrame) CGRect frame;
@property (nonatomic, readonly, getter = getMainViewBounds) CGRect bounds;

#ifdef TARGET_IOS
@property (readonly) BOOL isVisible;
@property (nonatomic, retain) UIFont *progressFont;
@property (nonatomic, retain) UIColor *progressColor;
@property (nonatomic, retain) UIColor *progressBgColor;
@property (nonatomic, assign, readonly) BOOL activityProgressIsShown;
@property (nonatomic, retain) UIView *activityHolderView;
@property (nonatomic, retain) UIActivityIndicatorView* activityIndicator;
@property (nonatomic, retain) UILabel* waitingLabel;
#endif

@property (assign) id<LViewControllerDelegate> viewControllerDelegate;

- (void)displayError:(NSError*)error;
- (void)displayError:(NSError*)error description:(NSString*)description;

- (void)displayAlert:(NSString*)title description:(NSString*)description;

#ifdef TARGET_IOS

- (void)displayProgressIndicators;
- (void)displayProgressIndicators:(NSString*)statusText;
- (void)displayProgressIndicators:(NSString*)statusText indicatorStyle:(LViewControllerProgressIndicatorStyle)indicatorStyle;
- (void)displayProgressIndicators:(NSString*)statusText indicatorStyle:(LViewControllerProgressIndicatorStyle)indicatorStyle indicatorSize:(CGSize)indicatorSize;

- (void)hideProgressIndicators;

- (void)viewDidLoad;

- (void)viewWillAppear:(BOOL)animated;
- (void)viewDidAppear:(BOOL)animated;

- (void)viewWillDisappear:(BOOL)animated;
- (void)viewDidDisappear:(BOOL)animated;

- (void)viewWillLayoutSubviews;
- (void)viewDidLayoutSubviews;

- (void)viewWillUnload;
- (void)viewDidUnload;
#endif

@end
