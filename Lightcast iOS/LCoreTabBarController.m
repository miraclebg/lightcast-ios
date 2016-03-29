//
//  LCoreTabBarController.m
//  Lightcast
//
//  Created by Martin N. Kovachev on 18.01.13.
//  Copyright (c) 2013 г. Nimasystems Ltd. All rights reserved.
//

#import "LCoreTabBarController.h"
#import "UIViewController+LCoreTabBarControllerTab.h"

CGFloat const kLCoreTabBarControllerDefaultTabBarHeight = 60.0;

NSString *const kLCoreTabBarControllerBottomBarHideAnimation = @"bottomBarHideAnimation";
NSString *const kLCoreTabBarControllerBottomBarShowAnimation = @"bottomBarShowAnimation";
CGFloat const kLCoreTabBarControllerBottomBarShowHideAnimationDuration = 0.5;

@interface LCoreTabBarController(Private)

- (BOOL)isVCIndexValid:(NSInteger)index_;
- (void)reloadViewControllers_;

- (void)runBottomBarShowHideAnimation:(BOOL)shouldHide;
- (void)bottomBarShowHideAnimationCompleted:(id)sender;

@end

@implementation LCoreTabBarController {
    
    UIView *_innerView;
}

@synthesize
viewControllers,
selectedViewController,
selectedIndex,
tabBar,
innerView=_innerView,
controllerDelegate;

#pragma mark - Initialization / Finalization

- (id)initWithTabBar:(LCoreTabBarView*)tabBar_
{
    self = [super init];
    if (self)
    {
        selectedViewController = nil;
        tabBar = [tabBar_ retain];
        _innerView = [[[UIView alloc] init] autorelease];
    }
    return self;
}

- (id)init
{
    return [self initWithTabBar:[[[LCoreTabBarView alloc] init] autorelease]];
}

- (void)dealloc
{
    controllerDelegate = nil;
    selectedViewController = nil;
    
    L_RELEASE(tabBar);
    L_RELEASE(_innerView);
    L_RELEASE(viewControllers);
    
    [super dealloc];
}

#pragma mark - View Related

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGRect tabBarFrame = CGRectMake(0,
                                    self.view.bounds.size.height - kLCoreTabBarControllerDefaultTabBarHeight,
                                    self.view.bounds.size.width,
                                    kLCoreTabBarControllerDefaultTabBarHeight
                                    );
    tabBar.frame = tabBarFrame;
    
    tabBar.delegate = self;
    
    [self.view addSubview:tabBar];
    
    CGRect innerViewFrame = CGRectMake(0, 0,
                                       self.view.bounds.size.width,
                                       self.view.bounds.size.height - tabBar.frame.size.height);
    
    _innerView.frame = innerViewFrame;

    [self.view addSubview:_innerView];
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

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    if (tabBar.hidden)
    {
        _innerView.frame = self.view.bounds;
    }
    else
    {
        CGRect tabBarFrame = CGRectMake(0,
                                        self.view.bounds.size.height - tabBar.frame.size.height,
                                        self.view.bounds.size.width,
                                        tabBar.frame.size.height
                                        );
        
        tabBar.frame = tabBarFrame;
        
        CGRect innerViewFrame = CGRectMake(0, 0,
                                           self.view.bounds.size.width,
                                           self.view.bounds.size.height - tabBar.frame.size.height);
        _innerView.frame = innerViewFrame;
    }
    
    if (viewControllers)
    {
        for(UIViewController *vc in viewControllers)
        {
            vc.view.frame = _innerView.bounds;
            [vc.view setNeedsLayout];
        }
    }
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
    [self.view setNeedsLayout];
}

#pragma mark - Misc

- (LCoreTabBarControllerTab*)tabForViewController:(UIViewController*)viewController
{
    if (!viewController)
    {
        lassert(false);
        return nil;
    }
    
    LCoreTabBarControllerTab *tab = nil;
    
    if (viewControllers)
    {
        NSInteger idx = [viewControllers indexOfObject:viewController];
        
        if (idx == NSNotFound)
        {
            return nil;
        }
        
        tab = [tabBar.tabItems objectAtIndex:idx];
    }
    
    return tab;
}

#pragma mark - Bottom bar hiding / showing

- (void)hideBottomBar
{
    return [self hideBottomBar:YES];
}

- (void)hideBottomBar:(BOOL)animated
{
    if (tabBar.isHidden)
    {
        return;
    }
    
    if (animated)
    {
        [self runBottomBarShowHideAnimation:YES];
    }
    else
    {
        tabBar.hidden = YES;
        [self.view setNeedsLayout];
    }
}

- (void)showBottomBar
{
    return [self showBottomBar:YES];
}

- (void)showBottomBar:(BOOL)animated
{
    if (!tabBar.isHidden)
    {
        return;
    }
    
    if (animated)
    {
        [self runBottomBarShowHideAnimation:NO];
    }
    else
    {
        tabBar.hidden = NO;
        [self.view setNeedsLayout];
    }
}

- (void)runBottomBarShowHideAnimation:(BOOL)shouldHide
{
    if (!shouldHide)
    {
        // move it if not in position first
        tabBar.frame = CGRectMake(0, self.view.bounds.size.height, tabBar.frame.size.width, tabBar.frame.size.height);
        tabBar.hidden = NO;
    }
    
    NSString *anim = shouldHide ? kLCoreTabBarControllerBottomBarHideAnimation : kLCoreTabBarControllerBottomBarShowAnimation;
    [UIView beginAnimations:anim context:self.view];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(bottomBarShowHideAnimationCompleted:)];
    [UIView setAnimationDuration:kLCoreTabBarControllerBottomBarShowHideAnimationDuration];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    
    CGRect frHide;
    //CGRect subviewFrm;
    
    if (shouldHide)
    {
       // subviewFrm = self.view.bounds;
        frHide = CGRectMake(0, self.view.bounds.size.height, tabBar.frame.size.width, tabBar.frame.size.height);
    }
    else
    {
        frHide = CGRectMake(0,
                            self.view.bounds.size.height - tabBar.frame.size.height,
                            self.view.bounds.size.width,
                            tabBar.frame.size.height
                            );
        
      /*  subviewFrm = CGRectMake(0, 0,
                                           self.view.bounds.size.width,
                                           self.view.bounds.size.height - tabBar.frame.size.height);*/
    }

    tabBar.frame = frHide;
    //_innerView.frame = subviewFrm;
    
    [UIView commitAnimations];
}

- (void)bottomBarShowHideAnimationCompleted:(id)sender
{
    BOOL animHide = ([sender isEqualToString:kLCoreTabBarControllerBottomBarHideAnimation]);
    
    if (animHide)
    {
        tabBar.hidden = YES;
    }
    else
    {
        tabBar.hidden = NO;
    }
    
    [self.view setNeedsLayout];
}

#pragma mark - Getters / Setters

- (void)setSelectedIndex:(NSUInteger)selectedIndex_
{
    if (selectedIndex != selectedIndex_)
    {
        if ([self isVCIndexValid:selectedIndex_])
        {
            [self setSelectedViewController:[viewControllers objectAtIndex:selectedIndex_]];
        }
    }
}

- (void)setSelectedViewController:(UIViewController*)selectedViewController_
{
    if (!viewControllers || ![viewControllers count])
    {
        return;
    }
    
    if (selectedViewController_ != selectedViewController)
    {
        NSInteger newIndex = 0;
        
        // select the first available controller if this is nil
        if (!selectedViewController_)
        {
            newIndex = 0;
        }
        else
        {
            NSInteger idx = [viewControllers indexOfObject:selectedViewController_];
            
            if (idx != NSNotFound)
            {
                newIndex = idx;
            }
        }
        
        // check the delegate
        BOOL shouldChange = YES;
        
        if (selectedViewController_)
        {
            if (controllerDelegate && [controllerDelegate respondsToSelector:@selector(tabBarController:shouldSelectViewController:)])
            {
                shouldChange = [controllerDelegate tabBarController:self shouldSelectViewController:selectedViewController_];
            }
        }
        
        if (!shouldChange)
        {
            return;
        }
        
        // pass to tab bar - we will switch the actual VC on its delegate return
        [tabBar setSelectedIndex:newIndex];
    }
}

- (void)setViewControllers:(NSArray*)viewControllers_
{
    if (viewControllers != viewControllers_)
    {
        if (viewControllers)
        {
            [_innerView removeAllSubviews];
            L_RELEASE(viewControllers);
        }
        
        viewControllers = [viewControllers_ copy];
        
        selectedViewController = viewControllers && viewControllers.count ? [viewControllers objectAtIndex:0] : nil;
        selectedIndex = 0;
        
        [self reloadViewControllers_];
    }
}

#pragma mark - LCoreTabBarView delegate

- (void)tabView:(LCoreTabBarView*)tabView didTouchTabAtIndex:(NSUInteger)itemIndex
{
    if (tabView == tabBar)
    {
        // reset the main navigation controller of the current VC
        if (itemIndex == selectedIndex && selectedViewController)
        {
            if ([selectedViewController isKindOfClass:[UINavigationController class]])
            {
                [((UINavigationController*)selectedViewController) popToRootViewControllerAnimated:YES];
            }
        }
    }
}

- (void)tabView:(LCoreTabBarView*)tabView didSelectTabAtIndex:(NSUInteger)itemIndex
{
    if (tabView == tabBar)
    {
        // select the proper view controller
        lassert(itemIndex >= 0 && itemIndex <= [viewControllers count] - 1);
        
        // remove the previous view
        if (selectedViewController)
        {
            [selectedViewController.view removeFromSuperview];
            selectedViewController = nil;
        }
        
        selectedViewController = viewControllers ? [viewControllers objectAtIndex:itemIndex] : nil;
        selectedIndex = itemIndex;
        
        // inform the delegate
        if (selectedViewController)
        {
            if (controllerDelegate && [controllerDelegate respondsToSelector:@selector(tabBarController:didSelectViewController:)])
            {
                [controllerDelegate tabBarController:self didSelectViewController:selectedViewController];
            }
        }
        
        // update the frame size of the controller - in case something has overriden it
        selectedViewController.view.frame = _innerView.bounds;
        
        // add the new view
        if (selectedViewController) {
            [_innerView addSubview:selectedViewController.view];
        }
    }
}

- (BOOL)tabView:(LCoreTabBarView*)tabView shouldSelectTabAtIndex:(NSUInteger)itemIndex
{
    BOOL shouldChange = YES;
    
    UIViewController *ctrl = viewControllers ? [viewControllers objectAtIndex:itemIndex] : nil;
    
    if (controllerDelegate && [controllerDelegate respondsToSelector:@selector(tabBarController:shouldSelectViewController:)])
    {
        shouldChange = [controllerDelegate tabBarController:self shouldSelectViewController:ctrl];
    }
    
    return shouldChange;
}

#pragma mark - Private methods

- (BOOL)isVCIndexValid:(NSInteger)index_
{
    BOOL isValid = (viewControllers && index_ >= 0 && index_ <= [viewControllers count] - 1);
    return isValid;
}

- (void)reloadViewControllers_
{
    [_innerView removeAllSubviews];
    
    // remove all tabs
    [tabBar removeAllTabItems];
    
    // create tabs for all controllers
    if (viewControllers)
    {
        for(UIViewController *vc in viewControllers)
        {
            // check for a custom tab - or - create a new one
            LCoreTabBarControllerTab *tab = vc.customCoreTabBarItem;
            
            if (!tab)
            {
                UITabBarItem *itm = vc.tabBarItem;
                
                NSString *title = (itm && ![NSString isNullOrEmpty:itm.title]) ? itm.title : @"";
                UIImage *img = itm ? itm.image : nil;
                
                UIImage *selectedImg = nil;
                
                if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
                    selectedImg = itm ? itm.finishedSelectedImage : nil;
                    selectedImg = selectedImg ? selectedImg : itm.selectedImage;
                } else {
                    selectedImg = itm ? itm.finishedSelectedImage : nil;
                }
                
                tab = [[[LCoreTabBarControllerTab alloc] initWithTitle:title icon:img selectedIcon:selectedImg] autorelease];
            }
            
            // add the tab
            [tabBar addTabItem:tab];
        }
        
        // add the first view
        if (selectedViewController) {
            [_innerView addSubview:selectedViewController.view];
        }
        
        if (viewControllers && [viewControllers count])
        {
            [tabBar setSelectedIndex:selectedIndex];
        }
    }
    
    [self.view setNeedsLayout];
}

@end
