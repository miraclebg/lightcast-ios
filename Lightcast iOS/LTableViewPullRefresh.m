//
//  LTableViewPullRefresh.m
//  Lightcast
//
//  Created by Martin N. Kovachev on 18.01.13.
//  Copyright (c) 2013 г. Nimasystems Ltd. All rights reserved.
//

#import "LTableViewPullRefresh.h"

NSString *const kLTableViewPullRefreshDefaultArrow = @"blueArrow.png";
CGFloat const kLTableViewPullRefreshFlipAnimationDuration = 0.18f;

@implementation LTableViewPullRefresh {
	
	UILabel *_lastUpdatedLabel;
	UILabel *_statusLabel;
	CALayer *_arrowImage;
	UIActivityIndicatorView *_activityView;
}

@synthesize
tableDelegate,
state;

#pragma mark - Initialization / Finalization

- (id)initWithFrame:(CGRect)frame arrowImageName:(NSString *)arrow textColor:(UIColor *)textColor
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.offset = 60.0f;
        self.offsetNormal = 0.0f;
        self.autoresizesSubviews = YES;
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		self.backgroundColor = [UIColor colorWithRed:226.0/255.0 green:231.0/255.0 blue:237.0/255.0 alpha:1.0];
        
		UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(0.0f, frame.size.height - 30.0f, self.frame.size.width, 20.0f)] autorelease];
		label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		label.font = [UIFont systemFontOfSize:12.0f];
		label.textColor = textColor;
		label.shadowColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
		label.shadowOffset = CGSizeMake(0.0f, 1.0f);
		label.backgroundColor = [UIColor clearColor];
		label.textAlignment = UITextAlignmentCenter;
		[self addSubview:label];
        
		_lastUpdatedLabel = label;
		
		label = [[[UILabel alloc] initWithFrame:CGRectMake(0.0f, frame.size.height - 48.0f, self.frame.size.width, 20.0f)] autorelease];
		label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		label.font = [UIFont boldSystemFontOfSize:13.0f];
		label.textColor = textColor;
		label.shadowColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
		label.shadowOffset = CGSizeMake(0.0f, 1.0f);
		label.backgroundColor = [UIColor clearColor];
		label.textAlignment = UITextAlignmentCenter;
        label.text = LightcastLocalizedString(@"Pull down to refresh...");
		[self addSubview:label];
        
		_statusLabel = label;
		
		CALayer *layer = [CALayer layer];
		layer.frame = CGRectMake(25.0f, frame.size.height - 65.0f, 30.0f, 55.0f);
		layer.contentsGravity = kCAGravityResizeAspect;
		layer.contents = (id)[UIImage imageNamed:arrow].CGImage;
		
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
		if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)])
        {
			layer.contentsScale = [[UIScreen mainScreen] scale];
		}
#endif
		
		[[self layer] addSublayer:layer];
        
		_arrowImage = layer;
		
		UIActivityIndicatorView *view = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];
		view.frame = CGRectMake(25.0f, frame.size.height - 38.0f, 20.0f, 20.0f);
		[self addSubview:view];
        
		_activityView = view;
		
		state = LTableViewPullRefreshStateNormal;
    }
	
    return self;
	
}

- (id)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame arrowImageName:kLTableViewPullRefreshDefaultArrow textColor:[UIColor colorWithRed:87.0/255.0 green:108.0/255.0 blue:137.0/255.0 alpha:1.0]];
}

- (id)init {
    return [self initWithFrame:CGRectNull];
}

- (void)dealloc
{
	tableDelegate = nil;
    
    [super dealloc];
}

#pragma mark - Getters / Setters

- (void)setState:(LTableViewPullRefreshState)aState
{
	if (state != aState)
    {
        switch (aState)
        {
            case LTableViewPullRefreshStatePulling:
                
                _statusLabel.text = LightcastLocalizedString(@"Release to refresh...");
                
                [CATransaction begin];
                [CATransaction setAnimationDuration:kLTableViewPullRefreshFlipAnimationDuration];
                _arrowImage.transform = CATransform3DMakeRotation((M_PI / 180.0) * 180.0f, 0.0f, 0.0f, 1.0f);
                [CATransaction commit];
                
                break;
                
            case LTableViewPullRefreshStateNormal:
                
                if (state == LTableViewPullRefreshStatePulling)
                {
                    [CATransaction begin];
                    [CATransaction setAnimationDuration:kLTableViewPullRefreshFlipAnimationDuration];
                    _arrowImage.transform = CATransform3DIdentity;
                    [CATransaction commit];
                }
                
                _statusLabel.text = LightcastLocalizedString(@"Pull down to refresh...");
                [_activityView stopAnimating];
                
                [CATransaction begin];
                [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
                _arrowImage.hidden = NO;
                _arrowImage.transform = CATransform3DIdentity;
                [CATransaction commit];
                
                [self refreshLastUpdatedDate];
                
                break;
                
            case LTableViewPullRefreshStateLoading:
                
                _statusLabel.text = LightcastLocalizedString(@"Loading...");
                [_activityView startAnimating];
                
                [CATransaction begin];
                [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
                _arrowImage.hidden = YES;
                [CATransaction commit];
                
                break;
                
            default:
                break;
        }
        
        state = aState;
    }
}

#pragma mark - Other

- (void)refreshLastUpdatedDate
{
	if (tableDelegate && [tableDelegate respondsToSelector:@selector(tableViewPullRefreshDataSourceLastUpdated:)])
    {
		NSDate *date = [tableDelegate tableViewPullRefreshDataSourceLastUpdated:self];
		
        if (date)
        {
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateStyle:NSDateFormatterMediumStyle];
            [dateFormat setTimeStyle:NSDateFormatterShortStyle];
            NSString *lastSyncFormattedDate = [dateFormat stringFromDate:date];
            [dateFormat release];
            
            _lastUpdatedLabel.text = [NSString stringWithFormat:LightcastLocalizedString(@"Last Updated: %@"), lastSyncFormattedDate];
        }
        else
        {
            _lastUpdatedLabel.text = LightcastLocalizedString(@"Last Updated: never");
        }
	}
    else
    {
		_lastUpdatedLabel.text = nil;
	}
}

#pragma mark - Scrolling methods

- (void)tableViewPullRefreshDidScroll:(UIScrollView *)scrollView
{
	if (state == LTableViewPullRefreshStateLoading)
    {
		CGFloat offset = MAX(scrollView.contentOffset.y * -1, 0);
		offset = MIN(offset, self.offset);
		scrollView.contentInset = UIEdgeInsetsMake(offset, 0.0f, 0.0f, 0.0f);
	}
    else if (scrollView.isDragging)
    {
		BOOL _loading = NO;
        
		if ([tableDelegate respondsToSelector:@selector(tableViewPullRefreshDataSourceIsLoading:)])
        {
			_loading = [tableDelegate tableViewPullRefreshDataSourceIsLoading:self];
		}
		
		if (state == LTableViewPullRefreshStatePulling && scrollView.contentOffset.y > -(self.offset + 5) && scrollView.contentOffset.y < 0.0f && !_loading)
        {
			[self setState:LTableViewPullRefreshStateNormal];
		}
        else if (state == LTableViewPullRefreshStateNormal && scrollView.contentOffset.y < -(self.offset + 5) && !_loading)
        {
			[self setState:LTableViewPullRefreshStatePulling];
		}
		
		if (scrollView.contentInset.top != 0)
        {
			scrollView.contentInset = UIEdgeInsetsMake(self.offsetNormal, 0.0f, 0.0f, 0.0f);
		}
	}
}

- (void)tableViewPullRefreshDidEndDragging:(UIScrollView *)scrollView
{
	BOOL _loading = NO;
    
	if ([tableDelegate respondsToSelector:@selector(tableViewPullRefreshDataSourceIsLoading:)])
    {
		_loading = [tableDelegate tableViewPullRefreshDataSourceIsLoading:self];
	}
	
	if (scrollView.contentOffset.y <= - (self.offset + 5) && !_loading)
    {
        BOOL should = NO;
        
		if ([tableDelegate respondsToSelector:@selector(tableViewPullRefreshDidTriggerRefresh:)])
        {
			should = [tableDelegate tableViewPullRefreshDidTriggerRefresh:self];
		}
		
        if (should) {
            [self setState:LTableViewPullRefreshStateLoading];
            
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:0.2];
            scrollView.contentInset = UIEdgeInsetsMake(self.offset, 0.0f, 0.0f, 0.0f);
            [UIView commitAnimations];
        }
	}
}

- (void)tableViewPullRefreshDataSourceDidFinishedLoading:(UIScrollView *)scrollView
{
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:.3];
	[scrollView setContentInset:UIEdgeInsetsMake(self.offsetNormal, 0.0f, 0.0f, 0.0f)];
	[UIView commitAnimations];
	
	[self setState:LTableViewPullRefreshStateNormal];
}

- (void)closePullView:(UIScrollView *)scrollView {
    [self tableViewPullRefreshDataSourceDidFinishedLoading:scrollView];
}

@end
