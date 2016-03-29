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
 * @changed $Id: Primitives.h 128 2011-08-09 06:54:20Z mkovachev $
 * @author $Author: mkovachev $
 * @version $Revision: 128 $
 */

#ifndef Lightcast_Primitives_h
#define Lightcast_Primitives_h

static __inline__ int LRandomIntBetween(int a, int b)
{
    srand ( (unsigned)time(NULL) );
    int range = b - a < 0 ? b - a - 1 : b - a + 1;
    int value = (int)(range * ((float) random() / (float) RAND_MAX));
    return value == range ? a : a + value;
}

static __inline__ CGFloat LRandomFloatBetween(CGFloat a, CGFloat b)
{
    float diff = b - a;
    return (((float) (arc4random() % ((unsigned)RAND_MAX + 1)) / RAND_MAX) * diff) + a;
}

static __inline__ CGPoint LRandomPointForSizeWithinRect(CGSize size, CGRect rect)
{
    return CGPointMake(
                        LRandomFloatBetween(rect.origin.x, (rect.origin.x + rect.size.width - size.width)), 
                        LRandomFloatBetween(rect.origin.y, (rect.origin.y + rect.size.height - size.height)));
}

static __inline__ CGRect LCenteredRectInRect(CGRect innerRect, CGRect outerRect)
{
#if CGFLOAT_IS_DOUBLE
    innerRect.origin.x = floor((outerRect.size.width - innerRect.size.width) / (CGFloat) 2.0);
    innerRect.origin.y = floor((outerRect.size.height - innerRect.size.height) / (CGFloat) 2.0);
#else
    innerRect.origin.x = floorf((outerRect.size.width - innerRect.size.width) / (CGFloat) 2.0);
    innerRect.origin.y = floorf((outerRect.size.height - innerRect.size.height) / (CGFloat) 2.0);
#endif
    return innerRect;
}

#endif
