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
 * @changed $Id: LTabBar.h 357 2015-04-16 06:29:29Z mkovachev $
 * @author $Author: mkovachev $
 * @version $Revision: 357 $
 */

#import <Lightcast/LView.h>
#import <Lightcast/LTabBarDelegate.h>

typedef enum 
{
    tabsAlignmentCenter = 0,
    tabsAlignmentLeft = 1,
    tabsAlignmentRight = 2,
    tabsAlignmentAuto = 3
} LTabBarTabsAlignment;

@interface LTabBar : LView {
    
    
    NSArray *_items;
    LTabBarTabsAlignment _tabsAlignment;
    UIView *_innerView;
    CGSize _tabItemSize;
    CGFloat _tabItemPadding;

    
}

@property (nonatomic, retain, setter=setItems:) NSArray *items; // an array of LTabBarItem
@property (nonatomic, assign, setter=setTabsAlignment:) LTabBarTabsAlignment tabsAlignment;

@property (nonatomic, assign, setter=setTabItemSize:) CGSize tabItemSize;
@property (nonatomic, assign, setter=setTabItemPadding:) CGFloat tabItemPadding;

@property (nonatomic, assign) id<LTabBarDelegate> delegate;

- (void)reloadTabItems;

@end
