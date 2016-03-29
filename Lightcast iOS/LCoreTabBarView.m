//
//  LCoreTabBarControllerTBView.m
//  Lightcast
//
//  Created by Martin N. Kovachev on 18.01.13.
//  Copyright (c) 2013 г. Nimasystems Ltd. All rights reserved.
//

#import "LCoreTabBarView.h"
#import "LCoreTabBarBackingLayer.h"
#import "LCoreTabBarContainerView.h"

CGFloat const kLCoreTabBarViewDefaultItemPaddingW = 16.0;
CGFloat const kLCoreTabBarViewDefaultItemPaddingH = 10.0;

@implementation LCoreTabBarView {
    
    LCoreTabBarContainerView *tabContainer;
}

@synthesize
itemPadding,
delegate,
tabItems,
showsTabHighlight,
tabTitleFont,
tabTitlePosition,
fixedTabSize,
badgeOffset;

#pragma mark - Initialization / Finalization

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.badgeOffset = CGSizeMake(5, -9);
        self.showsTabHighlight = YES;
        self.tabTitleFont = [UIFont boldSystemFontOfSize:12.];
        self.tabTitlePosition = LCoreTabBarViewTextPositionRight;
        self.fixedTabSize = CGSizeMake(0,0);
        
        CALayer *backgroundLayer = [[[LCoreTabBarBackingLayer alloc] init] autorelease];
        [self setBackgroundLayer:backgroundLayer];
        
        self.clipsToBounds = YES;
        
        self.backgroundColor = [UIColor clearColor];
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        tabContainer = [[LCoreTabBarContainerView alloc] initWithFrame:self.bounds];
        self.itemPadding = CGSizeMake(kLCoreTabBarViewDefaultItemPaddingW, kLCoreTabBarViewDefaultItemPaddingH);
        [self addSubview:tabContainer];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self setBackgroundLayer:[[[LCoreTabBarBackingLayer alloc] init] autorelease]];
        tabContainer = [[LCoreTabBarContainerView alloc] initWithFrame:self.bounds];
        self.itemPadding = CGSizeMake(kLCoreTabBarViewDefaultItemPaddingW, kLCoreTabBarViewDefaultItemPaddingH);
        [self addSubview:tabContainer];
    }
    return self;
}

- (void)dealloc
{
    self.delegate = nil;
    
    L_RELEASE(tabTitleFont);
    L_RELEASE(tabContainer);
    
    [super dealloc];
}

#pragma mark - View Related

- (void)layoutSubviews
{
    [tabContainer centerInSuperView];
    
    CALayer *oldBackground = [[self.layer sublayers] objectAtIndex:0];
    
    if (oldBackground)
    {
        oldBackground.frame = self.bounds;
    }
}

#pragma mark - Getters / Setters

- (NSArray*)getTabItems
{
    return tabContainer.tabItems;
}

- (void)setTabItems:(NSArray *)tabItems_
{
    tabContainer.tabItems = tabItems_;
    
    for(LCoreTabBarControllerTab *tab in tabItems)
    {
        tab.font = self.tabTitleFont;
        tab.textPosition = self.tabTitlePosition;
        tab.fixedHeight = self.fixedTabSize.height;
        tab.fixedWidth = self.fixedTabSize.width;
        tab.showsHighlight = self.showsTabHighlight;
    }
    
    // pass offset
    [self setBadgeOffset:self.badgeOffset];
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex_
{
    tabContainer.selectedIndex = selectedIndex_;
}

- (NSUInteger)getSelectedIndex
{
    return [tabContainer selectedIndex];
}

- (void)setItemPadding:(CGSize)itemPadding_
{
    itemPadding = itemPadding_;
    
    NSUInteger tabItemIndex, numberOfTabItems = [tabContainer numberOfTabItems];
    
    for (tabItemIndex=0; tabItemIndex<numberOfTabItems; tabItemIndex++)
    {
        LCoreTabBarControllerTab *tabItem = [tabContainer tabItemAtIndex:tabItemIndex];
        
        [tabItem setPadding:itemPadding];
    }
    
    [tabContainer layoutSubviews];
}

- (void)setBadgeOffset:(CGSize)badgeOffset_
{
    badgeOffset = badgeOffset_;
    
    if (tabItems)
    {
        for(LCoreTabBarControllerTab *tab in tabItems)
        {
            tab.badgeOffset = self.badgeOffset;
        }
    }
}

#pragma mark - Delegates

- (BOOL)shouldSelectItemAtIndex:(NSUInteger)itemIndex
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(tabView:shouldSelectTabAtIndex:)])
    {
        return [self.delegate tabView:self shouldSelectTabAtIndex:itemIndex];
    }
    
    return YES;
}

- (void)didSelectItemAtIndex:(NSUInteger)itemIndex
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(tabView:didSelectTabAtIndex:)])
    {
        [self.delegate tabView:self didSelectTabAtIndex:itemIndex];
    }
}

- (void)didTouchItemAtIndex:(NSUInteger)itemIndex
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(tabView:didTouchTabAtIndex:)])
    {
        [self.delegate tabView:self didTouchTabAtIndex:itemIndex];
    }
}

#pragma mark - Other

- (void)setBackgroundLayer:(CALayer *)backgroundLayer
{
    CALayer *oldBackground = [[self.layer sublayers] objectAtIndex:0];
    
    if (oldBackground)
    {
        [self.layer replaceSublayer:oldBackground with:backgroundLayer];
    }
    else
    {
        [self.layer insertSublayer:backgroundLayer atIndex:0];
    }
}

- (void)setMomentary:(BOOL)momentary;
{
    [tabContainer setMomentary:momentary];
}

- (void)addTabItem:(LCoreTabBarControllerTab*)tabItem
{
    tabItem.badgeOffset = self.badgeOffset;
    tabItem.font = self.tabTitleFont;
    tabItem.textPosition = self.tabTitlePosition;
    tabItem.fixedWidth = self.fixedTabSize.width;
    tabItem.fixedHeight = self.fixedTabSize.height;
    tabItem.showsHighlight = self.showsTabHighlight;
    [tabItem setPadding:[self itemPadding]];
    
    [tabContainer addTabItem:tabItem];
}

- (void)addTabItemWithTitle:(NSString*)title icon:(UIImage*)icon
{
    return [self addTabItemWithTitle:title icon:icon selectedIcon:nil];
}

- (void)addTabItemWithTitle:(NSString*)title icon:(UIImage*)icon selectedIcon:(UIImage*)selectedIcon
{
    LCoreTabBarControllerTab *tabItem = [LCoreTabBarControllerTab tabItemWithTitle:title icon:icon selectedIcon:selectedIcon];
    tabItem.font = self.tabTitleFont;
    tabItem.badgeOffset = self.badgeOffset;
    tabItem.textPosition = self.tabTitlePosition;
    tabItem.fixedHeight = self.fixedTabSize.height;
    tabItem.fixedWidth = self.fixedTabSize.width;
    tabItem.showsHighlight = self.showsTabHighlight;
    
    [self addTabItem:tabItem];
}

- (void)removeTabItemAtIndex:(NSUInteger)index
{
    [tabContainer removeTabItem:[tabContainer tabItemAtIndex:index]];
}

- (void)removeAllTabItems
{
    [tabContainer removeAllTabItems];
}

#if NS_BLOCKS_AVAILABLE
- (void)addTabItemWithTitle:(NSString *)title icon:(UIImage *)icon executeBlock:(LCoreTabBarExecutionBlock)executeBlock
{
    return [self addTabItemWithTitle:title icon:icon selectedIcon:nil executeBlock:executeBlock];
}

- (void)addTabItemWithTitle:(NSString*)title icon:(UIImage*)icon selectedIcon:(UIImage*)selectedIcon executeBlock:(LCoreTabBarExecutionBlock)executeBlock
{
    LCoreTabBarControllerTab *tabItem = [LCoreTabBarControllerTab tabItemWithTitle:title icon:icon selectedIcon:selectedIcon executeBlock:executeBlock];
    tabItem.font = self.tabTitleFont;
    tabItem.badgeOffset = self.badgeOffset;
    tabItem.textPosition = self.tabTitlePosition;
    tabItem.fixedWidth = self.fixedTabSize.width;
    tabItem.fixedHeight = self.fixedTabSize.height;
    tabItem.showsHighlight = self.showsTabHighlight;
    
    [self addTabItem:tabItem];
}

#endif

#pragma Mark - Customization

- (void)setSelectionView:(LCoreTabBarSelectionView*)selectionView
{
    [[tabContainer selectionView] removeFromSuperview];
    [tabContainer setSelectionView:selectionView];
    [tabContainer insertSubview:selectionView atIndex:0];
}

- (void)setItemSpacing:(CGFloat)itemSpacing;
{
    [tabContainer setItemSpacing:itemSpacing];
    [tabContainer setNeedsLayout];
}

@end
