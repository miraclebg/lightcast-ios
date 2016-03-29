//
//  LCoreTabBarContainerView.h
//  Lightcast
//
//  Created by Martin N. Kovachev on 18.01.13.
//  Copyright (c) 2013 г. Nimasystems Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Lightcast/LCoreTabBarControllerTab.h>
#import <Lightcast/LCoreTabBarSelectionView.h>

extern NSString *const kLCoreTabBarContainerViewSelectionAnimation;
extern CGFloat const kLCoreTabBarContainerViewDefaultTabSpacing;
extern CGFloat const kLCoreTabBarContainerViewDefaultSelectionAnimationDuration;

@interface LCoreTabBarContainerView : UIView

@property (nonatomic, retain, setter = setTabItems:) NSArray *tabItems;

@property (nonatomic,retain) LCoreTabBarSelectionView *selectionView;
@property (assign) BOOL momentary;
@property (nonatomic, assign, setter = setSelectedIndex:) NSUInteger selectedIndex;
@property (assign) CGFloat itemSpacing;
@property (assign) CGFloat selectionAnimationDuration;

- (BOOL)isItemSelected:(LCoreTabBarControllerTab*)tabItem;
- (void)itemSelected:(LCoreTabBarControllerTab*)tabItem;
- (void)addTabItem:(LCoreTabBarControllerTab*)tabItem;
- (void)removeTabItem:(LCoreTabBarControllerTab*)tabItem;
- (void)removeAllTabItems;

- (void)animateSelectionToItemAtIndex:(NSUInteger)itemIndex;

- (NSUInteger)numberOfTabItems;
- (LCoreTabBarControllerTab*)tabItemAtIndex:(NSUInteger)index;

@end
