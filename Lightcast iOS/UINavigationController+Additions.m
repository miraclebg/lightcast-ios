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
 * @changed $Id: UINavigationController+Additions.m 337 2014-02-10 08:17:18Z mkovachev $
 * @author $Author: mkovachev $
 * @version $Revision: 337 $
 */

#import "UINavigationController+Additions.h"
#import "LNavigationController.h"

@implementation UINavigationController(LAdditions)

- (UIViewController*)topSubcontroller {
    return self.topViewController;
}

- (void)addSubcontroller:(UIViewController*)controller animated:(BOOL)animated
              transition:(UIViewAnimationTransition)transition {
    if (animated && transition) {
        if ([self isKindOfClass:[LNavigationController class]]) {
            [(LNavigationController*)self pushViewController: controller
                                      animatedWithTransition: transition];
        } else {
            [self pushViewController:controller animated:YES];
        }
    } else {
        [self pushViewController:controller animated:animated];
    }
}

- (void)bringControllerToFront:(UIViewController*)controller animated:(BOOL)animated {
    if ([self.viewControllers indexOfObject:controller] != NSNotFound
        && controller != self.topViewController) {
        [self popToViewController:controller animated:animated];
    }
}

- (NSString*)keyForSubcontroller:(UIViewController*)controller {
    NSInteger controllerIndex = [self.viewControllers indexOfObject:controller];
    if (controllerIndex != NSNotFound) {
        return [NSNumber numberWithInteger:controllerIndex].stringValue;
    } else {
        return nil;
    }
}

- (UIViewController*)subcontrollerForKey:(NSString*)key {
    NSInteger controllerIndex = key.intValue;
    if (controllerIndex < self.viewControllers.count) {
        return [self.viewControllers objectAtIndex:controllerIndex];
    } else {
        return nil;
    }
}

@end
