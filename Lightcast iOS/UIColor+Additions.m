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
 * @changed $Id: UIColor+Additions.m 282 2013-08-05 12:04:40Z mkovachev $
 * @author $Author: mkovachev $
 * @version $Revision: 282 $
 */

#import "UIColor+Additions.h"
#import "Primitives.h"

@implementation UIColor(Additions)

- (NSDictionary*)rgbComponents
{
    CGFloat r,g,b,a = 0.0;
    
    // < iOS 5
    const CGFloat *components = CGColorGetComponents(self.CGColor);
    r = components[0];
    g = components[1];
    b = components[2];
    a = components[3];
    
    NSDictionary *ret = [NSDictionary dictionaryWithObjectsAndKeys:
                       [NSNumber numberWithFloat:r], @"red",
                       [NSNumber numberWithFloat:g], @"green",
                       [NSNumber numberWithFloat:b], @"blue",
                       [NSNumber numberWithFloat:a], @"alpha",
                       nil];
    
    return ret;
}

/*
 *  Returns a random UIColor
 *  @return UIColor The randomized color
 */
+ (UIColor*)randomColor
{
    
    float red = LRandomFloatBetween( 0.0, 255.0 ) / 255.0;
    float green = LRandomFloatBetween( 0.0, 255.0 ) / 255.0;
    float blue = LRandomFloatBetween( 0.0, 255.0 ) / 255.0;
    
    UIColor *myColor = [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
    
    return myColor;
}

+ (UIColor*)colorWithHex:(long)hexColor
{
    return [UIColor colorWithHex:hexColor alpha:1.];
}

+ (UIColor *)colorWithHex:(long)hexColor alpha:(float)opacity
{
    float red = ((float)((hexColor & 0xFF0000) >> 16))/255.0;
    float green = ((float)((hexColor & 0xFF00) >> 8))/255.0;
    float blue = ((float)(hexColor & 0xFF))/255.0;
    return [UIColor colorWithRed:red green:green blue:blue alpha:opacity];
}

@end