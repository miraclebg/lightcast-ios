//
//  ViewController.m
//  LightcastTestApp
//
//  Created by Martin N. Kovachev on 23.01.13.
//  Copyright (c) 2013 г. Nimasystems Ltd. All rights reserved.
//

#import "ViewController.h"
#import "LBadgeView.h"
#import "LCoreTabBarView.h"

@interface ViewController(Private)

@end

@implementation ViewController {
    
    LBadgeView *_badgeView;
    LCoreTabBarView *_tabBarView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    CGRect frm = CGRectMake(0, 10, self.view.bounds.size.width, 40);
    
    _tabBarView = [[[LCoreTabBarView alloc] initWithFrame:frm] autorelease];
    _tabBarView.clipsToBounds = YES;
    [self.view addSubview:_tabBarView];
    
    [_tabBarView addTabItemWithTitle:@"test 1" icon:nil];
    [_tabBarView addTabItemWithTitle:@"test 2" icon:nil];
    [_tabBarView addTabItemWithTitle:@"test 3" icon:nil];
    
    ((LCoreTabBarControllerTab*)[_tabBarView.tabItems objectAtIndex:0]).badgeValue = @"222";
    
    return;
    
    CGRect frame = CGRectMake(
    100,100,30,30
    );
    _badgeView = [[[LBadgeView alloc] initWithFrame:frame] autorelease];
    _badgeView.font = [UIFont fontWithName:@"Helvetica-Bold" size:12.0];
    _badgeView.value = @"1234 4321";
    [_badgeView sizeToFit];
    
    [self.view addSubview:_badgeView];
    
}

@end
