//
//  LCoreTabBarContainerView.m
//  Lightcast
//
//  Created by Martin N. Kovachev on 18.01.13.
//  Copyright (c) 2013 г. Nimasystems Ltd. All rights reserved.
//

#import "LCoreTabBarContainerView.h"
#import "LCoreTabBarView.h"

NSString *const kLCoreTabBarContainerViewSelectionAnimation = @"kSelectionAnimation";
CGFloat const kLCoreTabBarContainerViewDefaultTabSpacing = 10.0;
CGFloat const kLCoreTabBarContainerViewDefaultSelectionAnimationDuration = 0.3;

@interface LCoreTabBarContainerView(Private)

@end

@implementation LCoreTabBarContainerView {
    CGSize containerSize_;
    
    NSMutableArray *tabItems;
}

@synthesize
tabItems,
selectionView,
selectedIndex,
momentary,
itemSpacing,
selectionAnimationDuration;

#pragma mark - Initialization / Finalization

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        tabItems = [[NSMutableArray array] retain];
        self.selectionView = [[[LCoreTabBarSelectionView alloc] initWithFrame:CGRectZero] autorelease];
        self.itemSpacing = kLCoreTabBarContainerViewDefaultTabSpacing;
        [self addSubview:self.selectionView];
        
        selectionAnimationDuration = kLCoreTabBarContainerViewDefaultSelectionAnimationDuration;
    }
    return self;
}

- (void)dealloc
{
    self.selectionView = nil;
    
    L_RELEASE(tabItems);
    
    [super dealloc];
}

#pragma mark - Getters / Setters

- (void)setTabItems:(NSArray*)tabItems_
{
    // clear them out
    if (tabItems)
    {
        for(UIView *v in tabItems)
        {
            [v removeFromSuperview];
        }
    }
    
    [tabItems removeAllObjects];
    
    if (tabItems_)
    {
        for(LCoreTabBarControllerTab *v in tabItems_)
        {
            [self addTabItem:v];
        }
        
        // set the first tabs frame as the selected one
        self.selectionView.frame = ((LCoreTabBarControllerTab*)[tabItems objectAtIndex:0]).frame;
    }
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex_
{
    if (tabItems && selectedIndex_ <= [tabItems count] - 1)
    {
        LCoreTabBarControllerTab *tab = [tabItems objectAtIndex:selectedIndex_];
        
        [self itemSelected:tab];
    }
}

#pragma mark - View Related

- (void)layoutSubviews
{
    CGFloat xOffset = 0.;
    CGFloat yOffset = 0.;
    CGFloat itemHeight = 0.;
    
    for (LCoreTabBarControllerTab *item in self.tabItems)
    {
        [item sizeToFit];
        [item setFrame:CGRectMake(xOffset, yOffset, item.frame.size.width, item.frame.size.height)];
        
        xOffset += item.frame.size.width;
        
        if (item != [self.tabItems lastObject])
        {
            xOffset += self.itemSpacing;
        }
        
        itemHeight = item.frame.size.height;
    }
    
    containerSize_.width = xOffset;
    containerSize_.height = itemHeight;
    
    [self sizeToFit];
    [self centerInSuperView];
    
    if (tabItems && [tabItems count])
    {
        CGRect r = ((LCoreTabBarControllerTab*)[tabItems objectAtIndex:self.selectedIndex]).frame;
        self.selectionView.frame = r;
    }
}

- (CGSize)sizeThatFits:(CGSize)size
{
    return containerSize_;
}

- (void)addTabItem:(LCoreTabBarControllerTab*)tabItem
{
    [tabItems addObject:tabItem];
    [self addSubview:tabItem];
    [self setNeedsLayout];
    
    if (tabItems && [tabItems count] == 1)
    {
        // set the first tabs frame as the selected one
        CGRect r = ((LCoreTabBarControllerTab*)[tabItems objectAtIndex:0]).frame;
        self.selectionView.frame = r;
    }
}

- (void)removeTabItem:(LCoreTabBarControllerTab*)tabItem
{
    [tabItems removeObject:tabItem];
    [tabItem removeFromSuperview];
    [self setNeedsLayout];
}

- (void)removeAllTabItems
{
    for (LCoreTabBarControllerTab *tabItem in self.tabItems)
    {
        [tabItem removeFromSuperview];
    }
    
    [tabItems removeAllObjects];
    [self setNeedsLayout];
}

- (BOOL)isItemSelected:(LCoreTabBarControllerTab*)tabItem
{
    return ([self.tabItems indexOfObject:tabItem] == self.selectedIndex);
}

- (void)itemSelected:(LCoreTabBarControllerTab*)tabItem
{
    LCoreTabBarView * tabView = (LCoreTabBarView*)[self superview];
    
    NSInteger newIndex = [self.tabItems indexOfObject:tabItem];
    
    [tabView didTouchItemAtIndex:newIndex];
    
    if (newIndex != self.selectedIndex)
    {
        // check parent tabView
        BOOL shouldSelect = [tabView shouldSelectItemAtIndex:newIndex];
        
        if (!shouldSelect)
        {
            return;
        }
        
        selectedIndex = newIndex;
        
        if (!self.momentary)
        {
            [self animateSelectionToItemAtIndex:self.selectedIndex];
        }
        
        for (LCoreTabBarControllerTab *item in self.tabItems)
        {
            [item setNeedsDisplay];
        }
        
        [self animateSelectionToItemAtIndex:newIndex];
        
        // notify parent tabView
        [tabView didSelectItemAtIndex:self.selectedIndex];
    }
}

- (void)animateSelectionToItemAtIndex:(NSUInteger)itemIndex
{
    LCoreTabBarControllerTab *tabItem = [self.tabItems objectAtIndex:itemIndex];
    
    [UIView beginAnimations:kLCoreTabBarContainerViewSelectionAnimation context:self.selectionView];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:(CGRectIsEmpty(self.selectionView.frame) ? 0. : selectionAnimationDuration)];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    
    self.selectionView.frame = tabItem.frame;
    
    [UIView commitAnimations];
}

- (NSUInteger)numberOfTabItems
{
    return [self.tabItems count];
}

#pragma mark - Tab Item Accessors

- (LCoreTabBarControllerTab*)tabItemAtIndex:(NSUInteger)index
{
    return [self.tabItems objectAtIndex:index];
}

@end
