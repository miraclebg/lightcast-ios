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
 * @changed $Id: LVersionComparator.m 75 2011-07-16 15:47:22Z mkovachev $
 * @author $Author: mkovachev $
 * @version $Revision: 75 $
 */

#import "LVersionComparator.h"

@implementation LVersionComparator

+ (LVersionComparismentResult)compareVersion:(NSString*)version to:(NSString*)versionToCompareTo {
    
    LVersionComparismentResult res = lVersionUnknown;
    
    if (!version || !versionToCompareTo) return res;
    if (![version length] || ![versionToCompareTo length]) return res;
    
    NSInteger f = [LVersionComparator strVerToIntVer:version];
	NSInteger s = [LVersionComparator strVerToIntVer:versionToCompareTo];
	
    if (f > s)
    {
        res = lVersionHigher;
    }
    else
    if (f == s)
    {
        res = lVersionEqual;
    }
    else
    if (f < s)
    {
        res = lVersionLower;
    }
    
	return res;
}

+ (NSInteger)strVerToIntVer:(NSString *)strVer {
    
    NSArray * tmp = [strVer componentsSeparatedByString:@"."];
    
    NSInteger out1 = 0;
    
    for (NSString * tmp2 in tmp)
    {
        out1 += [tmp2 intValue];
    }
    
    return out1;
	//return [[strVer stringByReplacingOccurrencesOfString:@"." withString:@""] intValue];
}
                        
@end
