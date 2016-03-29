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
 * @changed $Id: NSString+WebEntities.m 178 2012-05-18 11:34:29Z mkovachev $
 * @author $Author: mkovachev $
 * @version $Revision: 178 $
 */

#import "NSString+WebEntities.h"

@implementation NSString(WebEntities)

- (NSString*)urlEncode {
	return [self urlEncoded];
}

- (NSString*)urlDecode {
	return [self urlDecoded];
}

- (NSString*)urlEncoded {
	
	if (!self || ![self length] || [self isEqual:[NSNull null]]) return nil;
	
	NSString *encodedStr = nil;
	CFStringRef encoded = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)self, NULL, CFSTR("!$&'()*+,-./:;=?@_~"), kCFStringEncodingUTF8);
	NSString *outs = nil;
	
	@try 
	{
		encodedStr = (NSString*)encoded;
		outs = [[NSString alloc] initWithString:(NSString*)encoded];
	}
	@finally 
	{
		CFRelease(encoded);
	}
	
	return [outs autorelease];
}

- (NSString*)urlDecoded {
	
	if (!self || ![self length] || [self isEqual:[NSNull null]]) return nil;
	
	NSString *decodedStr = nil;
	CFStringRef decoded = CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault, (CFStringRef)self, CFSTR("!$&'()*+,-./:;=?@_~"), kCFStringEncodingUTF8);
	NSString *outs = nil;
	
	@try 
	{
		decodedStr = (NSString*)decoded;
		outs = [[NSString alloc] initWithString:(NSString*)decoded];
	}
	@finally 
	{
		CFRelease(decoded);
	}
	
	return [outs autorelease];
}

@end
