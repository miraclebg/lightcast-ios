//
//  LTableViewPullRefresh.h
//  Lightcast
//
//  Created by Martin N. Kovachev on 18.01.13.
//  Copyright (c) 2013 г. Nimasystems Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

typedef enum
{
	LTableViewPullRefreshStatePulling = 0,
	LTableViewPullRefreshStateNormal,
	LTableViewPullRefreshStateLoading,
    
} LTableViewPullRefreshState;

@class LTableViewPullRefresh;

@protocol LTableViewPullRefreshDelegate <NSObject>

- (BOOL)tableViewPullRefreshDidTriggerRefresh:(LTableViewPullRefresh*)tableView;
- (BOOL)tableViewPullRefreshDataSourceIsLoading:(LTableViewPullRefresh*)tableView;

@optional

- (NSDate*)tableViewPullRefreshDataSourceLastUpdated:(LTableViewPullRefresh*)view;

@end

@interface LTableViewPullRefresh : UIView

@property(nonatomic,assign) id <LTableViewPullRefreshDelegate> tableDelegate;
@property (nonatomic, setter = setState:) LTableViewPullRefreshState state;
@property (nonatomic, assign) NSInteger offset;
@property (nonatomic, assign) NSInteger offsetNormal;

- (id)initWithFrame:(CGRect)frame arrowImageName:(NSString*)arrow textColor:(UIColor*)textColor;

- (void)refreshLastUpdatedDate;

- (void)tableViewPullRefreshDidScroll:(UIScrollView*)scrollView;
- (void)tableViewPullRefreshDidEndDragging:(UIScrollView*)scrollView;
- (void)tableViewPullRefreshDataSourceDidFinishedLoading:(UIScrollView*)scrollView;

- (void)closePullView:(UIScrollView *)scrollView;

@end

