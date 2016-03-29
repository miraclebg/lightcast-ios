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
 * @changed $Id: LNavigationController.m 75 2011-07-16 15:47:22Z mkovachev $
 * @author $Author: mkovachev $
 * @version $Revision: 75 $
 */

#import "LNavigationController.h"

@implementation LNavigationController

- (UIViewAnimationTransition)invertTransition:(UIViewAnimationTransition)transition {
    switch (transition) {
        case UIViewAnimationTransitionCurlUp:
            return UIViewAnimationTransitionCurlDown;
        case UIViewAnimationTransitionCurlDown:
            return UIViewAnimationTransitionCurlUp;
        case UIViewAnimationTransitionFlipFromLeft:
            return UIViewAnimationTransitionFlipFromRight;
        case UIViewAnimationTransitionFlipFromRight:
            return UIViewAnimationTransitionFlipFromLeft;
        default:
            return UIViewAnimationTransitionNone;
    }
}

- (void)pushAnimationDidStop {
}

#pragma mark -
#pragma mark Public

- (void)pushViewController: (UIViewController*)controller
    animatedWithTransition: (UIViewAnimationTransition)transition {
    [self pushViewController:controller animated:NO];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:lkDefaultFlipTransitionDuration];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(pushAnimationDidStop)];
    [UIView setAnimationTransition:transition forView:self.view cache:YES];
    [UIView commitAnimations];
}

- (UIViewController*)popViewControllerAnimatedWithTransition:(UIViewAnimationTransition)transition {
    UIViewController* poppedController = [self popViewControllerAnimated:NO];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:lkDefaultFlipTransitionDuration];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(pushAnimationDidStop)];
    [UIView setAnimationTransition:transition forView:self.view cache:NO];
    [UIView commitAnimations];
    
    return poppedController;
}

@end
