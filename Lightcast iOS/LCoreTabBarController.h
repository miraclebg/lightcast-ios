//
//  LCoreTabBarController.h
//  Lightcast
//
//  Created by Martin N. Kovachev on 18.01.13.
//  Copyright (c) 2013 г. Nimasystems Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Lightcast/LCoreTabBarView.h>
#import <Lightcast/LViewController.h>

extern CGFloat const kLCoreTabBarControllerDefaultTabBarHeight;

@class LCoreTabBarController;

@protocol LCoreTabBarControllerDelegate <NSObject, LCoreTabBarViewDelegate>

@optional

- (BOOL)tabBarController:(LCoreTabBarController*)tabBarController shouldSelectViewController:(UIViewController*)viewController;
- (void)tabBarController:(LCoreTabBarController*)tabBarController didSelectViewController:(UIViewController*)viewController;

- (void)tabBarControllerWillHideBottomBar:(LCoreTabBarController*)tabBarController;
- (void)tabBarControllerDidHideBottomBar:(LCoreTabBarController*)tabBarController;

- (void)tabBarControllerWillShowBottomBar:(LCoreTabBarController*)tabBarController;
- (void)tabBarControllerDidShowBottomBar:(LCoreTabBarController*)tabBarController;

@end

@interface LCoreTabBarController : LViewController <LCoreTabBarViewDelegate>

@property(nonatomic, copy, setter = setViewControllers:) NSArray *viewControllers;

@property(nonatomic, assign, setter = setSelectedViewController:) UIViewController *selectedViewController;
@property(nonatomic, setter = setSelectedIndex:) NSUInteger selectedIndex;

@property(nonatomic, retain) LCoreTabBarView *tabBar;
@property(nonatomic, retain, readonly) UIView *innerView;

@property(nonatomic, assign) id<LCoreTabBarControllerDelegate> controllerDelegate;

- (id)initWithTabBar:(LCoreTabBarView*)tabBar_;

- (LCoreTabBarControllerTab*)tabForViewController:(UIViewController*)viewController;

- (void)hideBottomBar;
- (void)hideBottomBar:(BOOL)animated;

- (void)showBottomBar;
- (void)showBottomBar:(BOOL)animated;

@end