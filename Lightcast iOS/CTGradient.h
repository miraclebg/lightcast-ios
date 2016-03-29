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
 * @changed $Id: CTGradient.h 134 2011-08-10 17:18:53Z mkovachev $
 * @author $Author: mkovachev $
 * @version $Revision: 134 $
 */

typedef struct _CTGradientElement 
{
	CGFloat red, green, blue, alpha;
	CGFloat position;
	
	struct _CTGradientElement *nextElement;
	
} CTGradientElement;

typedef enum  _CTBlendingMode
{
	CTLinearBlendingMode,
	CTChromaticBlendingMode,
	CTInverseChromaticBlendingMode
	
} CTGradientBlendingMode;

/**
 *	@brief [INFO]
 *
 *	@author Martin Kovachev (miracle@nimasystems.com), Nimasystems Ltd
 */
@interface CTGradient : NSObject <NSCopying, NSCoding>
{
	CTGradientElement *elementList;
	CTGradientBlendingMode blendingMode;
	
	CGFunctionRef gradientFunction;
}

+ (id)gradientWithBeginningColor:(NSColor *)begin endingColor:(NSColor *)end;

+ (id)aquaSelectedGradient;
+ (id)aquaNormalGradient;
+ (id)aquaPressedGradient;

+ (id)unifiedSelectedGradient;
+ (id)unifiedNormalGradient;
+ (id)unifiedPressedGradient;
+ (id)unifiedDarkGradient;

+ (id)sourceListSelectedGradient;
+ (id)sourceListUnselectedGradient;

- (CTGradient *)gradientWithAlphaComponent:(float)alpha;

//positions given relative to [0,1]
- (CTGradient *)addColorStop:(NSColor *)color atPosition:(float)position;	

- (CTGradient *)removeColorStopAtIndex:(unsigned)index;
- (CTGradient *)removeColorStopAtPosition:(float)position;
- (CTGradientBlendingMode)blendingMode;
- (NSColor *)colorStopAtIndex:(unsigned)index;
- (NSColor *)colorAtPosition:(float)position;
- (void)drawSwatchInRect:(NSRect)rect;
- (void)fillRect:(NSRect)rect angle:(float)angle;					

//fills rect with radial gradient
//  gradient from center outwards

- (void)radialFillRect:(NSRect)rect;								

@end
