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
 * @changed $Id: UIScreen+Additions.m 360 2015-05-22 08:12:42Z mkovachev $
 * @author $Author: mkovachev $
 * @version $Revision: 360 $
 */

#import "UIScreen+Additions.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIScreen(LAdditions)

- (CGSize)realResolution {
    CGRect screenBounds = self.bounds;
    CGFloat screenScale = self.scale;
    return CGSizeMake(screenBounds.size.width * screenScale, screenBounds.size.height * screenScale);
}

- (UIImage*)screenshot 
{
    // Create a graphics context with the target size
    // On iOS 4 and later, use UIGraphicsBeginImageContextWithOptions to take the scale into consideration
    // On iOS prior to 4, fall back to use UIGraphicsBeginImageContext
    CGSize imageSize = [self bounds].size;
    
    if (NULL != &UIGraphicsBeginImageContextWithOptions)
    {
       UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0); 
    }
    else
    {
        UIGraphicsBeginImageContext(imageSize);
    }
  
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Iterate over every window from back to front
    for (UIWindow *window in [[UIApplication sharedApplication] windows]) 
    {
        if (![window respondsToSelector:@selector(screen)] || [window screen] == [UIScreen mainScreen])
        {
            // -renderInContext: renders in the coordinate space of the layer,
            // so we must first apply the layer's geometry to the graphics context
            CGContextSaveGState(context);
            // Center the context around the window's anchor point
            CGContextTranslateCTM(context, [window center].x, [window center].y);
            // Apply the window's transform about the anchor point
            CGContextConcatCTM(context, [window transform]);
            // Offset by the portion of the bounds left of and above the anchor point
            CGContextTranslateCTM(context,
                                  -[window bounds].size.width * [[window layer] anchorPoint].x,
                                  -[window bounds].size.height * [[window layer] anchorPoint].y);
            
            // Render the layer hierarchy to the current context
            [[window layer] renderInContext:context];
            
            // Restore the context
            CGContextRestoreGState(context);
        }
    }
    
    // Retrieve the screenshot image
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}

+ (BOOL)isRetina
{
    BOOL isRetina = ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] && ([UIScreen mainScreen].scale == 2.0));
    return isRetina;
}

static BOOL _l_isIPhone5Checked, _l_isIPhone5;

+ (BOOL)isIphone5
{
    if (_l_isIPhone5Checked) {
        return _l_isIPhone5;
    }
    _l_isIPhone5 = ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) &&
     ([UIScreen mainScreen].bounds.size.height > 480.0f));
    _l_isIPhone5Checked = YES;
    return _l_isIPhone5;
}

@end
