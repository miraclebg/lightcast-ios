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
 * @changed $Id: LViewController.m 345 2014-10-07 17:23:27Z mkovachev $
 * @author $Author: mkovachev $
 * @version $Revision: 345 $
 */

#import "LViewController.h"
#import "LWebServiceError.h"
#import "LWebServicesValidationError.h"

#ifdef DEBUG
//#define LVIEWCONTROLLER_EXTRA_DEBUG
#endif

@implementation LViewController {
    
#ifdef TARGET_IOS
    BOOL _willUnload;
    BOOL _didUnload;
#endif
}

@synthesize
lc,
frame,
bounds,
viewControllerDelegate;

#ifdef TARGET_IOS
@synthesize
isVisible,
progressColor,
progressBgColor,
progressFont,
activityProgressIsShown;
#endif

#pragma mark -
#pragma mark Initialization / Finalization

- (id)init
{
    self = [super init];
    if (self)
    {
#ifdef TARGET_IOS
        self.activityIndicator = nil;
        self.waitingLabel = nil;
        self.activityHolderView = nil;
        progressFont = [[UIFont fontWithName:@"Helvetica-Bold" size:18.0] retain];
        progressColor = [[UIColor whiteColor] retain];
        progressBgColor = [[UIColor colorWithWhite:0.0 alpha:0.3] retain];
#endif
    }
    return self;
}

- (void)dealloc
{
    viewControllerDelegate = nil;
    
#ifdef TARGET_IOS
    // Only iOS 6 and up
    if (!_willUnload)
    {
        [self viewWillUnload];
    }
    
    // Only iOS 6 and up
    if (!_didUnload)
    {
        [self viewDidUnload];
    }
    
    self.activityHolderView = nil;
    self.activityIndicator = nil;
    self.waitingLabel = nil;
    
    L_RELEASE(_activityHolderView);
    
    L_RELEASE(progressFont);
    L_RELEASE(progressColor);
    L_RELEASE(progressBgColor);
    
#endif
    
    [super dealloc];
}

#pragma mark - View related

#ifdef TARGET_IOS
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (viewControllerDelegate && [viewControllerDelegate respondsToSelector:@selector(viewControllerDidLoad:)])
    {
        [viewControllerDelegate viewControllerDidLoad:self];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (viewControllerDelegate && [viewControllerDelegate respondsToSelector:@selector(viewControllerWillAppear:)])
    {
        [viewControllerDelegate viewControllerWillAppear:self];
    }
    
    isVisible = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (viewControllerDelegate && [viewControllerDelegate respondsToSelector:@selector(viewControllerDidAppear:)])
    {
        [viewControllerDelegate viewControllerDidAppear:self];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (viewControllerDelegate && [viewControllerDelegate respondsToSelector:@selector(viewControllerWillDisappear:)])
    {
        [viewControllerDelegate viewControllerWillDisappear:self];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    isVisible = NO;
    
    if (viewControllerDelegate && [viewControllerDelegate respondsToSelector:@selector(viewControllerDidDisappear:)])
    {
        [viewControllerDelegate viewControllerDidDisappear:self];
    }
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    if (viewControllerDelegate && [viewControllerDelegate respondsToSelector:@selector(viewControllerWillLayoutSubviews:)])
    {
        [viewControllerDelegate viewControllerWillLayoutSubviews:self];
    }
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    if (viewControllerDelegate && [viewControllerDelegate respondsToSelector:@selector(viewControllerDidLayoutSubviews:)])
    {
        [viewControllerDelegate viewControllerDidLayoutSubviews:self];
    }
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Weverything"
- (void)viewWillUnload
{
    /*
     @deprecated
     */
    //[super viewWillUnload];
    
    if (viewControllerDelegate && [viewControllerDelegate respondsToSelector:@selector(viewControllerWillUnLoad:)])
    {
        [viewControllerDelegate viewControllerWillUnLoad:self];
    }
    
    _willUnload = YES;
}
#pragma clang diagnostic pop


#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Weverything"
- (void)viewDidUnload
{
    /*
     @deprecated
     */
    //[super viewDidUnload];
    
    isVisible = NO;
    
    if (viewControllerDelegate && [viewControllerDelegate respondsToSelector:@selector(viewControllerDidUnload:)])
    {
        [viewControllerDelegate viewControllerDidUnload:self];
    }
    
    _didUnload = YES;
}
#pragma clang diagnostic pop

#endif

#pragma mark -
#pragma mark Other

#ifdef TARGET_IOS

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    LogCond(LDFLAG_VIEWCONTROLLERS, @"MEMORY WARNING FOR %@", self);
}

#endif

#pragma mark -
#pragma mark Lightcast Customizations

- (LC*)getLightcast
{
    return [LC sharedLC];
}

- (LDatabaseManager*)getDatabaseManager
{
    return self.lc.db;
}

- (LPluginManager*)getPluginManager
{
    return self.lc.plugins;
}

- (LStorage*)getStorage
{
    return self.lc.storage;
}

- (CGRect)getMainViewFrame
{
    return self.view.frame;
}

- (CGRect)getMainViewBounds
{
    return self.view.bounds;
}

- (void)displayError:(NSError*)error
{
    NSString *errMsg = error && ![NSString isNullOrEmpty:[error localizedDescription]] ? [error localizedDescription] : LightcastLocalizedString(@"Unknown Error");
    
    [self displayAlert:LightcastLocalizedString(@"Error") description:errMsg];
}

- (void)displayError:(NSError*)error description:(NSString*)description
{
    NSString *errDescription = @"";
    
    if (error && [error isKindOfClass:[LWebServiceError class]])
    {
        LWebServiceError *lerr = (LWebServiceError*)error;
      /*
#if DEBUG
        errDescription = [NSString stringWithFormat:@"Web Service Error:\nDomain:%@\nException:%@", lerr.domain, lerr.exceptionName];
#endif*/
        
        NSMutableArray *allVErrs = [[[NSMutableArray alloc] init] autorelease];
        
        if (lerr.validationErrors && [lerr.validationErrors count])
        {
            for(LWebServicesValidationError *err in lerr.validationErrors)
            {
                NSString *field = err.fieldName;
                NSString *msg = ![NSString isNullOrEmpty:err.errorMessage] ? err.errorMessage : @"-";
                
                if (![NSString isNullOrEmpty:field])
                {
                    NSString *combined = [NSString stringWithFormat:@"%@: %@", field, msg];
                    [allVErrs addObject:combined];
                }
            }
            
            if ([allVErrs count])
            {
                errDescription = [NSString stringWithFormat:@"%@\nValidation Errors:\n\n%@", errDescription, [allVErrs componentsJoinedByString:@"\n"]];
            }
        /*
#if DEBUG
            errDescription = [NSString stringWithFormat:@"%@\nTrace:\n%@\n\nExtra data:\n%@", errDescription, lerr.trace, lerr.extraData];
#endif*/
        }
        else
        {
            errDescription = error && ![NSString isNullOrEmpty:[error localizedDescription]] ? [error localizedDescription] : LightcastLocalizedString(@"Unknown Error");
        }
    }
    else
    {
        errDescription = error && ![NSString isNullOrEmpty:[error localizedDescription]] ? [error localizedDescription] : LightcastLocalizedString(@"Unknown Error");
    }
    
    [self displayAlert:description description:errDescription];
}

- (void)displayAlert:(NSString*)title description:(NSString*)description
{
    [GeneralUtils displayMessage:title description:description];
}

#pragma mark - Progress related

#ifdef TARGET_IOS

- (void)displayProgressIndicators
{
    return [self displayProgressIndicators:nil];
}

- (void)displayProgressIndicators:(NSString*)statusText
{
    return [self displayProgressIndicators:statusText indicatorStyle:LViewControllerProgressIndicatorStyleDefault];
}

- (void)displayProgressIndicators:(NSString*)statusText indicatorStyle:(LViewControllerProgressIndicatorStyle)indicatorStyle indicatorSize:(CGSize)indicatorSize
{
    if (indicatorSize.width == 0 && indicatorSize.height == 0)
    {
        return [self displayProgressIndicators:statusText indicatorStyle:indicatorStyle];
    }
    
    lassert([NSThread isMainThread]);
    
    if (activityProgressIsShown)
    {
        return;
    }
    
    activityProgressIsShown = YES;
    
    CGFloat activityW = indicatorSize.width;
    CGFloat activityH = indicatorSize.height;
    CGFloat activityPadding = 20.0;
    CGFloat nextY = activityPadding;
    BOOL onlyIndicatorShown = NO;
    
    UIActivityIndicatorViewStyle iStyle = UIActivityIndicatorViewStyleWhite;
    
    if (indicatorStyle == LViewControllerProgressIndicatorStyleLarge)
    {
        iStyle = UIActivityIndicatorViewStyleWhiteLarge;
        activityH = 100.0;
    }
    
    if ([NSString isNullOrEmpty:statusText]) {
        activityW = activityH;
        onlyIndicatorShown = YES;
    }
    
    _activityHolderView = [[UIView alloc] initWithFrame:CGRectMake(round(self.view.bounds.size.width / 2 - activityW / 2),
                                                                  round(self.view.bounds.size.height / 2 - activityH / 2),
                                                                  activityW,
                                                                  activityH)];
	_activityHolderView.backgroundColor =  self.progressBgColor;
	_activityHolderView.clipsToBounds = YES;
    _activityHolderView.layer.cornerRadius = 10;
    _activityHolderView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;

    // show progress view
    _activityIndicator = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:iStyle] autorelease];
    [_activityIndicator sizeToFit];
	_activityIndicator.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |
	UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
	[_activityIndicator setFrame:CGRectMake(round(_activityHolderView.bounds.size.width / 2 - _activityIndicator.frame.size.width / 2),
                                            (onlyIndicatorShown ? (round(_activityHolderView.bounds.size.height / 2 - _activityIndicator.frame.size.height / 2)) : nextY),
                                            _activityIndicator.frame.size.width,
                                            _activityIndicator.frame.size.height)];
	[_activityHolderView addSubview:_activityIndicator];
	[_activityIndicator startAnimating];
    //[self.view bringSubviewToFront:_activityIndicator];
    
    // show waiting label
    if (statusText)
    {
        nextY += _activityIndicator.size.height + 10.0;
        
        _waitingLabel = [[[UILabel alloc] init] autorelease];
        _waitingLabel.text = statusText;
        _waitingLabel.font = self.progressFont;
        _waitingLabel.textColor = self.progressColor;
        _waitingLabel.textAlignment = UITextAlignmentCenter;
        
        CGSize constraintSize = CGSizeMake(indicatorSize.width, MAXFLOAT);
        CGSize labelSize = [statusText sizeWithFont:self.progressFont constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
        _waitingLabel.numberOfLines = 0;
        
        _waitingLabel.backgroundColor = [UIColor clearColor];
        _waitingLabel.frame = CGRectMake(round(_activityHolderView.bounds.size.width / 2 - labelSize.width / 2),
                                         nextY,
                                         labelSize.width,
                                         labelSize.height);
        _waitingLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |
        UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        [_activityHolderView addSubview:_waitingLabel];
        //[self.view bringSubviewToFront:_waitingLabel];
        
    }
    
    [self.view addSubview:_activityHolderView];
    [self.view bringSubviewToFront:_activityHolderView];
}

- (void)displayProgressIndicators:(NSString*)statusText indicatorStyle:(LViewControllerProgressIndicatorStyle)indicatorStyle
{
    lassert([NSThread isMainThread]);
    
    if (activityProgressIsShown)
    {
        return;
    }
    
    activityProgressIsShown = YES;
    
    CGFloat activityW = 150.0;
    CGFloat activityH = 80.0;
    CGFloat activityPadding = 20.0;
    CGFloat nextY = activityPadding;
    BOOL onlyIndicatorShown = NO;
    
    UIActivityIndicatorViewStyle iStyle = UIActivityIndicatorViewStyleWhite;
    
    if (indicatorStyle == LViewControllerProgressIndicatorStyleLarge)
    {
        iStyle = UIActivityIndicatorViewStyleWhiteLarge;
        activityH = 100.0;
    }
    
    if ([NSString isNullOrEmpty:statusText]) {
        activityW = activityH;
        onlyIndicatorShown = YES;
    }
    
    _activityHolderView = [[UIView alloc]initWithFrame:CGRectMake(round(self.view.bounds.size.width / 2 - activityW / 2),
                                                                  round(self.view.bounds.size.height / 2 - activityH / 2),
                                                                  activityW,
                                                                  activityH)];
	_activityHolderView.backgroundColor =  self.progressBgColor;
	_activityHolderView.clipsToBounds = YES;
    _activityHolderView.layer.cornerRadius = 10;
    _activityHolderView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;

    // show progress view
    _activityIndicator = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:iStyle] autorelease];
    [_activityIndicator sizeToFit];
	_activityIndicator.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |
	UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
	[_activityIndicator setFrame:CGRectMake(round(_activityHolderView.bounds.size.width / 2 - _activityIndicator.frame.size.width / 2),
                                            (onlyIndicatorShown ? (round(_activityHolderView.bounds.size.height / 2 - _activityIndicator.frame.size.height / 2)) : nextY),
                                           _activityIndicator.frame.size.width,
                                            _activityIndicator.frame.size.height)];
	[_activityHolderView addSubview:_activityIndicator];
	[_activityIndicator startAnimating];
    //[self.view bringSubviewToFront:_activityIndicator];
    
    // show waiting label
    if (statusText)
    {
        nextY += _activityIndicator.size.height + 10.0;
        
        _waitingLabel = [[[UILabel alloc] init] autorelease];
        _waitingLabel.text = statusText;
        _waitingLabel.font = self.progressFont;
        _waitingLabel.textColor = self.progressColor;
        [_waitingLabel sizeToFit];
        _waitingLabel.backgroundColor = [UIColor clearColor];
        _waitingLabel.frame = CGRectMake(round(_activityHolderView.bounds.size.width / 2 - _waitingLabel.frame.size.width / 2),
                                         nextY,
                                         _waitingLabel.frame.size.width,
                                         _waitingLabel.frame.size.height);
        _waitingLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |
        UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        [_activityHolderView addSubview:_waitingLabel];
        //[self.view bringSubviewToFront:_waitingLabel];
    }
    
    [self.view addSubview:_activityHolderView];
    [self.view bringSubviewToFront:_activityHolderView];
}

- (void)hideProgressIndicators
{
    lassert([NSThread isMainThread]);
    
    if (!activityProgressIsShown)
    {
        return;
    }
    
    [_activityHolderView removeFromSuperview];
    
    if (_activityIndicator)
    {
        [_activityIndicator stopAnimating];
    }
    
    _activityIndicator = nil;
    _waitingLabel = nil;
    
    L_RELEASE(_activityHolderView);
    
    activityProgressIsShown = NO;
}
#endif

@end
