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
 * @changed $Id: LAdvancedTabBarController.h 357 2015-04-16 06:29:29Z mkovachev $
 * @author $Author: mkovachev $
 * @version $Revision: 357 $
 */

#import <Lightcast/LViewController.h>
#import <Lightcast/LNavigationController.h>
#import <Lightcast/LAdvancedTabBarControllerDelegate.h>
#import <Lightcast/LTabBar.h>

typedef enum 
{
    tabPositionBottom = 0,
    tabPositionTop = 1
} LAdvancedTabBarControllerTabPosition;

@interface LAdvancedTabBarController : LViewController <LTabBarDelegate> {
    
    
    LTabBar *_tabBar;
    
    CGSize _viewControllerInset;
    NSArray *_viewControllers;
    UIViewController *_selectedViewController;
    NSInteger _selectedIndex;
    id<LAdvancedTabBarControllerDelegate>_delegate;
    LAdvancedTabBarControllerTabPosition _position;
}

@property(nonatomic,retain,setter = setViewControllers:) NSArray *viewControllers;

@property(nonatomic,assign) UIViewController *selectedViewController;
@property(nonatomic) NSInteger selectedIndex;
@property(nonatomic, setter = setViewControllerInset:) CGSize viewControllerFrameInset;
@property(nonatomic, setter = setTabBarPosition:) LAdvancedTabBarControllerTabPosition tabBarPosition;
@property(nonatomic,assign,getter = getTabBarTabsAlignment, setter = setTabBarTabsAlignment:) LTabBarTabsAlignment tabBarTabsAlignment;
@property(nonatomic,assign,getter = getTabBarItemSize, setter = setTabBarItemSize:) CGSize tabBarItemSize;
@property(nonatomic,assign,getter = getTabBarItemPadding, setter = setTabBarItemPadding:) CGFloat tabBarItemPadding;

@property(nonatomic,assign,setter = setTabBarBackgroundColor:,getter = getTabBarBackgroundColor) UIColor *tabBarBackgroundColor;

@property(nonatomic,assign) id<LAdvancedTabBarControllerDelegate> delegate;

@end
