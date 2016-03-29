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
 * @changed $Id: NSString+Additions.m 354 2015-02-05 07:34:56Z mkovachev $
 * @author $Author: mkovachev $
 * @version $Revision: 354 $
 */

#import <Security/Security.h>
#import "NSData+Additions.h"
#import <CommonCrypto/CommonDigest.h>
#import "Base64.h"
#import "NSString+Additions.h"

@implementation NSString(LAdditions)

+ (NSString*)nilify
{
    NSString *r = (NSString*)[LVars nilify:self];
    return r;
}

+ (BOOL)isNullOrEmpty:(NSString*)string
{
    BOOL isValid = (string && [string isKindOfClass:[NSString class]] && ![string isEqual:[NSNull null]] && ![string isEqualToString:@""]);
    
    return !isValid;
}

- (BOOL)startsWith:(NSString*)string
{
    BOOL ret =([self hasPrefix:string]);
    return ret;
}

- (BOOL)endsWith:(NSString*)string
{
    BOOL ret =([self hasSuffix:string]);
    return ret;
}

+ (NSString*)randomString:(NSInteger)length
{
    length = length > 0 ? length : 40;
    
    NSString *alphabet  = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXZY0123456789";
    NSMutableString *s = [NSMutableString stringWithCapacity:length];
    NSInteger alen = [alphabet length];
    
    for (NSUInteger i = 0U; i < length; i++)
    {
        u_int32_t r = arc4random() % alen;
        unichar c = [alphabet characterAtIndex:r];
        [s appendFormat:@"%C", c];
    }
    
    return s;
}

- (NSString*)stringByAppendingPathComponentIfMissing
{
    NSString *str = [NSString string];
    
    if (![self length])
    {
        return str;
    }
    
    if (![[self substringFromIndex:[self length]-1] isEqualToString:@"/"])
    {
        str = [NSString stringWithFormat:@"%@/", self];
    }
    else
    {
        str = self;
    }
    
    return str;
}

- (NSString *)stringByUnescapingFromURLQuery
{
	NSString *deplussed = [self stringByReplacingOccurrencesOfString:@"+" withString:@" "];
    return [deplussed stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

- (NSString *)stringByEscapingForURLQuery
{
	NSString *result = self;
    
	static CFStringRef leaveAlone = CFSTR(" ");
	static CFStringRef toEscape = CFSTR("\n\r:/=,!$&'()*+;[]@#?%");
    
	CFStringRef escapedStr = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)self, leaveAlone,
																	 toEscape, kCFStringEncodingUTF8);
    
	if (escapedStr)
    {
		NSMutableString *mutable = [NSMutableString stringWithString:(NSString *)escapedStr];
		CFRelease(escapedStr);
        
		[mutable replaceOccurrencesOfString:@" " withString:@"+" options:0 range:NSMakeRange(0, [mutable length])];
		result = mutable;
	}
    
	return result;  
}

- (NSString *)stringTrimmed {

	NSString *trimmed = [self stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
	
	return trimmed;
}

- (NSString *)trim {
    return [self stringTrimmed];
}

- (NSString *)trimmedString {
    return [self stringTrimmed];
}

- (BOOL)isWhitespaceAndNewlines {
    NSCharacterSet* whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    for (NSInteger i = 0; i < self.length; ++i) {
        unichar c = [self characterAtIndex:i];
        if (![whitespace characterIsMember:c]) {
            return NO;
        }
    }
    return YES;
}

- (BOOL)isEmptyOrWhitespace {
    return !self.length ||
    ![self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length;
}

- (NSComparisonResult)versionStringCompare:(NSString *)other {
    NSArray *oneComponents = [self componentsSeparatedByString:@"a"];
    NSArray *twoComponents = [other componentsSeparatedByString:@"a"];
    
    // The parts before the "a"
    NSString *oneMain = [oneComponents objectAtIndex:0];
    NSString *twoMain = [twoComponents objectAtIndex:0];
    
    // If main parts are different, return that result, regardless of alpha part
    NSComparisonResult mainDiff;
    if ((mainDiff = [oneMain compare:twoMain]) != NSOrderedSame) {
        return mainDiff;
    }
    
    // At this point the main parts are the same; just deal with alpha stuff
    // If one has an alpha part and the other doesn't, the one without is newer
    if ([oneComponents count] < [twoComponents count]) {
        return NSOrderedDescending;
    } else if ([oneComponents count] > [twoComponents count]) {
        return NSOrderedAscending;
    } else if ([oneComponents count] == 1) {
        // Neither has an alpha part, and we know the main parts are the same
        return NSOrderedSame;
    }
    
    // At this point the main parts are the same and both have alpha parts. Compare the alpha parts
    // numerically. If it's not a valid number (including empty string) it's treated as zero.
    NSNumber *oneAlpha = [NSNumber numberWithInt:[[oneComponents objectAtIndex:1] intValue]];
    NSNumber *twoAlpha = [NSNumber numberWithInt:[[twoComponents objectAtIndex:1] intValue]];
    return [oneAlpha compare:twoAlpha];
}

- (NSString*)md5Hash {
    return [[self dataUsingEncoding:NSUTF8StringEncoding] md5Hash];
}

- (NSString *)sha1Hash {
	
	unsigned char hashedChars[20];
	
	CC_SHA1([self UTF8String],
            (int)[self lengthOfBytesUsingEncoding:NSUTF8StringEncoding], 
            hashedChars);
	
	NSData * hashedData = [NSData dataWithBytes:hashedChars length:20];
	
	// may be a more optimized way to do this?
	NSMutableString * tmp = [[NSMutableString stringWithFormat:@"%@", [hashedData description]] retain];
	[tmp replaceOccurrencesOfString:@" " withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [tmp length])];
	[tmp deleteCharactersInRange:NSMakeRange([tmp length]-1, 1)];
	[tmp deleteCharactersInRange:NSMakeRange(0, 1)];
	
	return [tmp autorelease];
}

- (NSString*)base64EncodedString {
	return [self base64EncodedString];
}

- (NSString*)base64DecodedString {
	return [self base64DecodedString];
}

// allow a-z, A-Z, 0-9 characters only
- (NSString *)sanitizeToAlphaNumericalString {
	
	const unichar * buff[400];
	
	int y = 0;
	
	if ([self length] <= 400)
	{
		for (int i=0;i<[self length];i++)
		{
			unichar ch = [self characterAtIndex:i];
			int myChar = (int)ch;
			
			if (!((myChar < 48) || (myChar > 122) || ((myChar > 57) && (myChar < 65)) || ((myChar > 90) && (myChar < 97))))
			{
				buff[y] = &ch;
                
				y++;
			}
		}
	}
	
	NSString * tmp = [[NSString alloc] initWithCharacters:(const unichar *)buff length:y];
	
	return [tmp autorelease];
}

- (NSString *)stringByReplacingSubstring:(NSString *)substring
							  withString:(NSString *)replaceString
{
	NSMutableString * string = [NSMutableString stringWithString:self];
	NSRange range;
	
	if (!replaceString || !substring) 
	{ 
		return self; 
	}
	
	range = [string rangeOfString:substring];
	
	while (range.length)
	{
		[string replaceCharactersInRange:range withString:replaceString];
		//range.location = range.location + range.length;
		range.location = range.location + 1;
		range.length = [string length] - range.location;
		range = [string rangeOfString:substring options:0 range:range];
	}
	
	return string;
}

- (NSString*)stringByDeletingLastPathComponent:(NSString*)inputString {
    
    NSArray* components = [inputString pathComponents];
    
    if (!components) return inputString;
    
    NSArray *startOfPath = [components subarrayWithRange:NSMakeRange(0, [components count]-1)];
    
    if (!startOfPath) return inputString;
    
    NSString* str = [NSString pathWithComponents:startOfPath];
    
    return str;
}

- (NSString*)removedFileExtension {

    NSString * result = self;
    NSInteger length = [self length];
    NSInteger index = 0;
    
    if (length == 0)
    {
        return self;
    }
    
    for (index = length - 1 ; index >= 0 ; index--)
    {
        if ([self characterAtIndex:index] == '.')
        {
            return [self substringToIndex:index];
        }
    }
    
    return result;
}

- (NSString*)fileExtension {
    
    NSString * result = @"";
    NSInteger length = [self length];
    NSInteger index = 0;
    
    if (length == 0)
    {
        return self;
    }
    
    for (index = length - 1 ; index >= 0 ; index--)
    {
        if ([self characterAtIndex:index] == '.')
        {
            return [self substringFromIndex:index+1];
        }
    }
    
    return result;
}

- (BOOL)containsString:(NSString*)searchFor {
	
	if (!searchFor || ![searchFor length]) return NO;
	
	NSRange range = [self rangeOfString:searchFor options:NSCaseInsensitiveSearch];
	
	return (range.location != NSNotFound) ? YES : NO;
}

@end
