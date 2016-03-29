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
 * @changed $Id: NSColor+Additions.m 275 2013-07-24 20:33:22Z mkovachev $
 * @author $Author: mkovachev $
 * @version $Revision: 275 $
 */

#import "NSColor+Additions.h"

@implementation NSColor(Additions)

// need to override the warning shown by LLVM here as it's not really an error (intended)
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"
+ (NSArray *)controlAlternatingRowBackgroundColors {
	NSColor *colorForControlTint = [[NSColor colorForControlTint:[NSColor currentControlTint]] highlightWithLevel:2.60];
	return [NSArray arrayWithObjects:colorForControlTint, [NSColor colorWithCalibratedRed:230.0/255.0 
																					green:242.0/255.0 
																					 blue:250.0/255.0 
																					alpha:1.0], nil];
}
#pragma clang diagnostic pop

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"
// this method is already included on 10.8
- (CGColorRef)CGColor
{
    const NSInteger numberOfComponents = [self numberOfComponents];
    CGFloat components[numberOfComponents];
    CGColorSpaceRef colorSpace = [[self colorSpace] CGColorSpace];
	
    [self getComponents:(CGFloat *)&components];
	
    return (CGColorRef)[(id)CGColorCreate(colorSpace, components) autorelease];
}
#pragma clang diagnostic pop

+ (NSColor*)randomColor {

	float red = LRandomFloatBetween( 0.0, 255.0 ) / 255.0;
    float green = LRandomFloatBetween( 0.0, 255.0 ) / 255.0;
    float blue = LRandomFloatBetween( 0.0, 255.0 ) / 255.0;
    
    NSColor *myColor = [NSColor colorWithCalibratedRed:red green:green blue:blue alpha:1.0];
    
    return myColor;
}

@end
