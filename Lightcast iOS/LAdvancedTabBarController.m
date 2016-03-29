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
 * @changed $Id: LAdvancedTabBarController.m 344 2014-10-03 07:45:12Z mkovachev $
 * @author $Author: mkovachev $
 * @version $Revision: 344 $
 */

#import "LAdvancedTabBarController.h"

@interface LAdvancedTabBarController(Private)

- (void)reloadTabBarItems;
- (CGRect)tabBarFrameForPosition:(LAdvancedTabBarControllerTabPosition)position;
- (CGRect)viewFrameForSelectedViewController;

- (void)repositionTabBarForCurrentPosition;

- (void)setSelectedViewController:(UIViewController *)selectedViewController;

@end

@implementation LAdvancedTabBarController

@synthesize
viewControllers=_viewControllers,
selectedViewController=_selectedViewController,
selectedIndex=_selectedIndex,
tabBarPosition=_position,
delegate=_delegate,
viewControllerFrameInset=_viewControllerFrameInset;

#pragma mark - Initialization / Finalization

- (id)init
{
    self = [super init];
    if (self)
    {
        _tabBar = [[LTabBar alloc] init];
        _tabBar.delegate = self;
        _selectedIndex = 0;
        _selectedViewController = nil;
        _viewControllers = nil;
        _delegate = nil;
        _position = tabPositionBottom; // default
        _viewControllerInset.width = 0.0;
        _viewControllerInset.height = 0.0;
    }
    
    return self;
}

- (void)dealloc {
    L_RELEASE(_tabBar);
    L_RELEASE(_viewControllers);
    _selectedViewController = nil;
    _delegate = nil;
    [super dealloc];
}

#pragma mark - View Related

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    //self.view.backgroundColor = [UIColor whiteColor];
    
    // add the tab bar
    [self.view addSubview:_tabBar];
    [self repositionTabBarForCurrentPosition];
    
    // reinit the tab bar items
    [self reloadTabBarItems];
    
    // if there are view controllers - set the first one visible
    if (_viewControllers)
    {
        [self setSelectedViewController:[_viewControllers objectAtIndex:0]];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    
    // we need to redraw the tab bar to show/hide more/less items when the screen becomes larger/smaller
    
    [_tabBar reloadTabItems];
}

#pragma mark - Getters / Setters

- (void)setViewControllers:(NSArray*)viewControllers {
    if (viewControllers != _viewControllers)
    {
        [_viewControllers release];
        _viewControllers = [viewControllers copy];
        
        _selectedIndex = 0;
        _selectedViewController = nil;
        
        if (self.view)
        {
            // reinit the tab bar items
            [self reloadTabBarItems];
            
            // if there are view controllers - set the first one visible
            if (_viewControllers)
            {
                [self setSelectedViewController:[_viewControllers objectAtIndex:0]];
            }
        }
    }
}

- (void)setTabBarBackgroundColor:(UIColor*)backgroundColor {
    _tabBar.backgroundColor = backgroundColor;
}

- (UIColor*)getTabBarBackgroundColor {
    return _tabBar.backgroundColor;
}

- (LTabBarTabsAlignment)getTabBarTabsAlignment {
    return _tabBar.tabsAlignment;
}

- (void)setTabBarTabsAlignment:(LTabBarTabsAlignment)tabBarTabsAlignment {
    _tabBar.tabsAlignment = tabBarTabsAlignment;
}

- (void)setTabBarPosition:(LAdvancedTabBarControllerTabPosition)tabBarPosition {
    if (_position != tabBarPosition)
    {
        _position = tabBarPosition;
        
        if (self.view)
        {
            [self repositionTabBarForCurrentPosition];
        }
    }
}

- (CGSize)getTabBarItemSize {
    return _tabBar.tabItemSize;
}

- (void)setTabBarItemSize:(CGSize)tabBarItemSize {
    _tabBar.tabItemSize = tabBarItemSize;
    
    if (self.view)
    {
        [self repositionTabBarForCurrentPosition];
    }
}

- (CGFloat)getTabBarItemPadding {
    return _tabBar.tabItemPadding;
}

- (void)setTabBarItemPadding:(CGFloat)tabBarItemPadding {
    _tabBar.tabItemPadding = tabBarItemPadding;
}

- (void)setSelectedViewController:(UIViewController *)selectedViewController {
    
    if (selectedViewController != _selectedViewController)
    {
        // check if valid and obtain index
        NSInteger newIndex = [_viewControllers indexOfObject:selectedViewController];
        
        if (newIndex != NSNotFound)
        {
            // check if the delegate allows us to do this change
            BOOL allowed = YES;
            
            if (_delegate)
            {
                if ([_delegate respondsToSelector:@selector(tabBarController:shouldSelectViewController:)])
                {
                    allowed = [_delegate tabBarController:self shouldSelectViewController:selectedViewController];
                }
            }
            
            // horray - allowed!
            if (allowed)
            {
                // hide the previously selected controller
                if (_selectedViewController)
                {
                    [_selectedViewController viewWillDisappear:NO];
                    [_selectedViewController viewDidDisappear:NO];
                    [_selectedViewController.view removeFromSuperview];
                    _selectedViewController = nil;
                }
                
                _selectedViewController = selectedViewController;
                _selectedIndex = newIndex;
                
                CGRect r = [self viewFrameForSelectedViewController];
                _selectedViewController.view.frame = CGRectInset(r, _viewControllerInset.width, _viewControllerInset.height);
                _selectedViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
                
                [self.view addSubview:_selectedViewController.view];
                
                [_selectedViewController viewWillAppear:NO];
                [_selectedViewController viewDidAppear:NO];
                
                LogDebug(@"LAdvancedTabBarController: active view controller now is: %@", [_selectedViewController class]);
                
                // inform the delegate
                if (_delegate)
                {
                    if ([_delegate respondsToSelector:@selector(tabBarController: didSelectViewController:)])
                    {
                        [_delegate tabBarController:self didSelectViewController:_selectedViewController];
                    }
                }
            }
        }
    }
}

- (void)setViewControllerInset:(CGSize)size {
    
    _viewControllerInset = size;
    
    if (_selectedViewController)
    {
        CGRect frm = [self viewFrameForSelectedViewController];
        _selectedViewController.view.frame = CGRectInset(frm, _viewControllerInset.width, _viewControllerInset.height);
    }
}

#pragma mark - Other

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Private

- (void)reloadTabBarItems {
    
    LogDebug(@"Reloading TabBar items");
    
    // reset the tab bar
    _tabBar.items = nil;
    
    if (!_viewControllers)
    {
        return;
    }
    
    // workout view controllers and create TabBarItems from their prefs
    NSMutableArray *tabItems = [[NSMutableArray alloc] init];
    
    @try 
    {
        for(UIViewController*ctrl in _viewControllers)
        {
            if (![ctrl isKindOfClass:[UIViewController class]])
            {
                LogError(@"LAdvancedTabBarController: invalid object set in viewControllers. Skipping it.");
                continue;
            }
            
            UITabBarItem *itm = ctrl.tabBarItem;
            
            if (!itm) 
            {
                continue;
            }
            
            [tabItems addObject:itm];
        }
        
        LogDebug(@"LAdvancedTabBarController: Got %d tab bar items from view controllers", (int)[tabItems count]);
        
        // check if there are any at all
        if (![tabItems count]) 
        {
            return;
        }
        
        _tabBar.items = [NSArray arrayWithArray:tabItems];
    }
    @finally 
    {
        [tabItems release];
    }
}

- (CGRect)tabBarFrameForPosition:(LAdvancedTabBarControllerTabPosition)position {
    
    CGRect r = CGRectNull;
    
    switch(position)
    {
        case tabPositionBottom:
        {
            r = CGRectMake(self.view.bounds.origin.x, 
                           self.view.bounds.size.height - 
                           _tabBar.tabItemSize.height,
                           self.view.frame.size.width,
                           _tabBar.tabItemSize.height);
            
            break;
        }
        case tabPositionTop:
        {
            r = CGRectMake(self.view.bounds.origin.x, 
                           self.view.bounds.origin.y,
                           self.view.frame.size.width,
                           _tabBar.tabItemSize.height);
            
            break;
        }
    }
    
    return r;
}

- (CGRect)viewFrameForSelectedViewController {
    
    CGRect r = CGRectMake(
                          self.view.bounds.origin.x,
                          ((_position == tabPositionTop) ? self.view.bounds.origin.y + _tabBar.bounds.size.height : self.view.bounds.origin.y),
                          self.view.bounds.size.width,
                          self.view.bounds.size.height - _tabBar.bounds.size.height
                          );
    
    return r;
}

- (void)repositionTabBarForCurrentPosition {
    
    _tabBar.frame = [self tabBarFrameForPosition:_position];
    
    switch(_position)
    {
        case tabPositionBottom:
        {
            _tabBar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
            
            break;
        }
        case tabPositionTop:
        {
            _tabBar.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
            
            break;
        }
    }
}

#pragma mark - LTabBarDelegate methods

- (void)lTabBar:(LTabBar*)tabBar didSelectTabItem:(UITabBarItem*)tabBarItem itemIndex:(NSInteger)index {
    
    [self setSelectedViewController:[_viewControllers objectAtIndex:index]];
}

@end
