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
 * @changed $Id: LTabBar.m 311 2013-11-30 10:44:13Z mkovachev $
 * @author $Author: mkovachev $
 * @version $Revision: 311 $
 */

#import "LTabBar.h"
#import "LTabBarItem.h"

@interface LTabBar(Private)

- (NSInteger)maxVisibleTabsForWidth:(CGFloat)itemWidth;

- (CGRect)innerViewFrameForAlignment:(LTabBarTabsAlignment)alignment itemSize:(CGSize)itemSize numberOfItems:(NSInteger)numberOfItems;

@end

@implementation LTabBar

static CGFloat kLTabBarDefaultTabItemSideHeight = 49.0;
static CGFloat kLTabBarDefaultTabItemSideWidth = 76.0;
static CGFloat kLTabBarDefaultTabItemPadding = 10.0;

@synthesize
items=_items,
tabsAlignment=_tabsAlignment,
tabItemSize=_tabItemSize,
tabItemPadding=_tabItemPadding,
delegate=_delegate;

#pragma mark - Initialization / Finalization

- (id)init
{
    return [self initWithFrame:CGRectNull];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) 
    {
        _items = nil;
        _delegate = nil;
        _tabItemPadding = kLTabBarDefaultTabItemPadding;
        _tabItemSize = CGSizeMake(kLTabBarDefaultTabItemSideWidth, kLTabBarDefaultTabItemSideHeight);
        _tabsAlignment = tabsAlignmentCenter; // default - centered
        self.backgroundColor = [UIColor blackColor];    // the default color
        _innerView = [[UIView alloc] init];
        [self addSubview:_innerView];
    }
    return self;
}

- (void)dealloc {
    
    L_RELEASE(_items);
    L_RELEASE(_innerView);
    _delegate = nil;
    
    [super dealloc];
}

#pragma mark - Setters / Getters

- (void)setItems:(NSArray *)items {
    if (_items != items)
    {
        [_items release];
        _items = [items retain]; // copy ?
        
        [self reloadTabItems];
    }
}

- (void)setTabsAlignment:(LTabBarTabsAlignment)tabsAlignment {
    if (tabsAlignment != _tabsAlignment)
    {
        _tabsAlignment = tabsAlignment;
        
        [self reloadTabItems];
    }
}

- (void)setTabItemSize:(CGSize)tabItemSize {
    if (_tabItemSize.height != tabItemSize.height || _tabItemSize.width != tabItemSize.width)
    {
        _tabItemSize = tabItemSize;
        
        [self reloadTabItems];
    }
}

- (void)setTabItemPadding:(CGFloat)tabItemPadding {
    if (_tabItemPadding != tabItemPadding)
    {
        _tabItemPadding = tabItemPadding;
        
        [self reloadTabItems];
    }
}

#pragma mark - Private

- (void)reloadTabItems {
    
    LogDebug(@"LTabBar: reloadTabItems");
    
    [_innerView removeAllSubviews];
    
    if (!_items) return;
    
    CGFloat itemWidth = (_tabItemSize.width);

    NSInteger visibleItems = [self maxVisibleTabsForWidth:itemWidth];
    
    // set the alignment
    switch (_tabsAlignment) 
    {
        case tabsAlignmentCenter:
        {
            _innerView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
            
            break;
        }
        case tabsAlignmentLeft:
        {
            _innerView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
            
            break;
        }
        case tabsAlignmentRight:
        {
            _innerView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
            
            break;
        }
        case tabsAlignmentAuto:
        {
            _innerView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
            
            break;
        }
    }
    
    for(int i=0;i<visibleItems;i++)
    {
        UIView *view = [[[UIView alloc] init] autorelease];
        view.tag = i;
        
        UITabBarItem *itm = [_items objectAtIndex:i];
        
        // create the button which will receive the touch events
        UIButton *itemButton = [[[UIButton alloc] init] autorelease];
        itemButton.backgroundColor = [UIColor clearColor];
        itemButton.titleLabel.textColor = [UIColor blackColor];
        itemButton.tag = i;
        
        [itemButton addTarget:self action:@selector(itemTabClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        if (itm.image)
        {
            [itemButton setImage:itm.image forState:UIControlStateNormal];
        }
        
        if (itm.title)
        {
            [itemButton setTitle:itm.title forState:UIControlStateNormal];
        }
        
        [view addSubview:itemButton];
        [_innerView addSubview:view];
    }
    
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self layoutTabs];
}

- (void)layoutTabs {

    CGFloat itemWidth = (_tabItemSize.width);
    CGFloat tHeight = _tabItemSize.height > self.bounds.size.height ? self.bounds.size.height : _tabItemSize.height;
    
    NSInteger visibleItems = [self maxVisibleTabsForWidth:itemWidth];
    
    // set the frame
    CGRect r = [self innerViewFrameForAlignment:_tabsAlignment itemSize:_tabItemSize numberOfItems:visibleItems];
    _innerView.frame = r;
    
    CGFloat padding = 0.0;
    
    // calculate the padding between the tab items automatically when in mode tabsAlignmentAuto
    
    if (_tabsAlignment == tabsAlignmentAuto)
    {
        padding = (self.bounds.size.width - (itemWidth*visibleItems)) / visibleItems;
    }
    else
    {
        padding = _tabItemPadding;
    }
    
    CGFloat lastX = round(padding / 2);
    
    for(int i=0;i<visibleItems;i++)
    {
        UIView *view = [_innerView subviewWithTag:i];
        
        view.frame = CGRectMake(lastX,
                                round(self.bounds.size.height / 2 - tHeight / 2),
                                itemWidth,
                                tHeight);
        
        UIButton *itemButton = (UIButton*)[view subviewWithTag:i];
        itemButton.frame = view.bounds;
        
        lastX += (itemWidth + padding);
    }
}

- (CGRect)innerViewFrameForAlignment:(LTabBarTabsAlignment)alignment itemSize:(CGSize)itemSize numberOfItems:(NSInteger)numberOfItems {
    
    if (!itemSize.width || !itemSize.height || !numberOfItems)
    {
        return CGRectNull;
    }
    
    CGRect r = CGRectNull;
    
    CGFloat tWidth = numberOfItems*(itemSize.width+(alignment == tabsAlignmentAuto ? 0.0 : _tabItemPadding));
    CGFloat tHeight = itemSize.height > self.bounds.size.height ? self.bounds.size.height : itemSize.height;
    
    switch (alignment) 
    {
        case tabsAlignmentCenter:
        {
            r = CGRectMake(round(self.bounds.size.width / 2 - tWidth / 2),
             0,
             tWidth,
             tHeight);
            
            break;
        }
        case tabsAlignmentAuto:
        {
            r = CGRectMake(0,
                           0,
                           self.bounds.size.width,
                           tHeight);
            
            break;
        }
        case tabsAlignmentLeft:
        {
            r = CGRectMake(0,
                           0,
                           tWidth,
                           tHeight);
            
            break;
        }
        case tabsAlignmentRight:
        {
            
            r = CGRectMake(self.bounds.size.width - tWidth,
                           0,
                           tWidth,
                           tHeight);
            
            break;
        }
    }
    
    return r;
}

- (NSInteger)maxVisibleTabsForWidth:(CGFloat)itemWidth {
    
    if (!_items) return 0;
    
    NSInteger numberOfItems = [_items count];
    
    return numberOfItems;
    
    //NSInteger maxItems = floor(self.bounds.size.width / itemWidth);
    //NSInteger itemsCount = (numberOfItems > maxItems) ? maxItems : numberOfItems;
    
    //return itemsCount;
}

#pragma mark - Events

- (void)itemTabClicked:(id)sender {
    
    if (![sender isKindOfClass:[UIButton class]]) return;
    
    UIButton *btn = (UIButton*)sender;
    NSInteger selectedItemIndex = btn.tag;
    UITabBarItem *selectedItem = [_items objectAtIndex:selectedItemIndex];
    
    //LogDebug(@"LTabBar: clicked on tab: %d", btn.tag);
    
    if (_delegate != nil)
    {
        if ([_delegate respondsToSelector:@selector(lTabBar: didSelectTabItem: itemIndex:)])
        {
            [_delegate lTabBar:self didSelectTabItem:selectedItem itemIndex:selectedItemIndex];
        }
    }
}

@end
