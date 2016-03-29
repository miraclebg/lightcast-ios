//
//  LCoreTabBarView.h
//  Lightcast
//
//  Created by Martin N. Kovachev on 18.01.13.
//  Copyright (c) 2013 г. Nimasystems Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Lightcast/LCoreTabBarControllerTab.h>
#import <Lightcast/LCoreTabBarSelectionView.h>

extern CGFloat const kLCoreTabBarViewDefaultItemPaddingW;
extern CGFloat const kLCoreTabBarViewDefaultItemPaddingH;

@class LCoreTabBarView;

@protocol LCoreTabBarViewDelegate <NSObject>

@optional

- (BOOL)tabView:(LCoreTabBarView*)tabView shouldSelectTabAtIndex:(NSUInteger)itemIndex;
- (void)tabView:(LCoreTabBarView*)tabView didSelectTabAtIndex:(NSUInteger)itemIndex;
- (void)tabView:(LCoreTabBarView*)tabView didTouchTabAtIndex:(NSUInteger)itemIndex;

@end

@interface LCoreTabBarView : UIView

@property (nonatomic, getter = getSelectedIndex, setter = setSelectedIndex:) NSUInteger selectedIndex;
@property (nonatomic, setter = setItemPadding:) CGSize itemPadding;
@property (nonatomic, setter = setItemMargin:) CGFloat itemMargin;

@property (nonatomic, retain, setter = setTabItems:, getter = getTabItems) NSArray *tabItems;

@property (nonatomic, assign) id<LCoreTabBarViewDelegate> delegate;

@property (nonatomic, assign, setter = setBadgeOffset:) CGSize badgeOffset;

@property (nonatomic, assign) BOOL showsTabHighlight;
@property (nonatomic, retain) UIFont *tabTitleFont;
@property (nonatomic, assign) LCoreTabBarViewTextPosition tabTitlePosition;
@property (nonatomic, assign) CGSize fixedTabSize;

- (void)setMomentary:(BOOL)momentary;

- (BOOL)shouldSelectItemAtIndex:(NSUInteger)itemIndex;
- (void)didSelectItemAtIndex:(NSUInteger)itemIndex;
- (void)didTouchItemAtIndex:(NSUInteger)itemIndex;

- (void)addTabItem:(LCoreTabBarControllerTab*)tabItem;
- (void)addTabItemWithTitle:(NSString*)title icon:(UIImage*)icon;
- (void)addTabItemWithTitle:(NSString*)title icon:(UIImage*)icon selectedIcon:(UIImage*)selectedIcon;

- (void)removeTabItemAtIndex:(NSUInteger)index;
- (void)removeAllTabItems;

#if NS_BLOCKS_AVAILABLE
- (void)addTabItemWithTitle:(NSString*)title icon:(UIImage*)icon executeBlock:(LCoreTabBarExecutionBlock)executeBlock;
- (void)addTabItemWithTitle:(NSString*)title icon:(UIImage*)icon selectedIcon:(UIImage*)selectedIcon executeBlock:(LCoreTabBarExecutionBlock)executeBlock;
#endif

- (void)setSelectionView:(LCoreTabBarSelectionView*)selectionView;
- (void)setItemSpacing:(CGFloat)itemSpacing;
- (void)setBackgroundLayer:(CALayer*)backgroundLayer;

@end
