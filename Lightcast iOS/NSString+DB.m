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
 * @changed $Id: NSString+DB.m 342 2014-10-01 13:16:38Z mkovachev $
 * @author $Author: mkovachev $
 * @version $Revision: 342 $
 */

#import "NSString+DB.h"

@implementation NSString(DB)

/** The string prefix which we should look for when adding slashes 
 *	to make SQL queries safe
 */
#define SQLITE_SLASH_SEARCH @"'"

/**	The string with which we should replace SQLITE_SLASH_SEARCH
 *	in order to make a string safe for SQL execution
 */
#define SQLITE_SLASH_REPLACEMENT @"''"

- (NSString *)addSlashes {
	NSString * res = [self stringByReplacingOccurrencesOfString:SQLITE_SLASH_SEARCH withString:SQLITE_SLASH_REPLACEMENT];
	
	return res;
}

- (NSString *)stripSlashes {
	NSString * res = [self stringByReplacingOccurrencesOfString:SQLITE_SLASH_REPLACEMENT withString:SQLITE_SLASH_SEARCH];
	
	return res;
}

- (NSString *)getStrWithNullValue {
	if (self == (id)[NSNull null])
    {
        return @"NULL";
    }
    else 
    {
        //NSString *str = [self stringByReplacingOccurrencesOfString:@"\r\n" withString:@"\n"];
        //str = [self stringByReplacingOccurrencesOfString:@"\r" withString:@""];
        //str = [str stringByReplacingOccurrencesOfString:@"%d" withString:@""];
        //str = [str stringByReplacingOccurrencesOfString:@"%f" withString:@""];
        //str = [str stringByReplacingOccurrencesOfString:@"%s" withString:@""];
        //str = [str addSlashes];
        return [NSString stringWithFormat:@"'%@'",
                [self addSlashes]];
    }
}

- (NSString *)sqlString {
	return [self getStrWithNullValue];
}

- (int)sqlInt {
	return [self intValue];
}

- (float)sqlFloat {
	return [self floatValue];
}

- (NSString *)sqlDate {
	return [self getStrWithNullValue];
}

@end