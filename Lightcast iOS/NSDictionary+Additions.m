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
 * @changed $Id: NSDictionary+Additions.m 349 2014-10-28 14:03:11Z mkovachev $
 * @author $Author: mkovachev $
 * @version $Revision: 349 $
 */

#import "NSDictionary+Additions.h"


@implementation NSDictionary(LAdditions)

- (id)nilifiedObjectForKey:(NSString*)key
{
    id obj = [LVars nilify:[self objectForKey:key]];
    return obj;
}

- (NSInteger)intForKey:(NSString*)key
{
    id obj = [self nilifiedObjectForKey:key];
    
    if (!obj || (![obj isKindOfClass:[NSNumber class]] && ![obj isKindOfClass:[NSString class]]))
    {
        return 0;
    }
    
    return [obj intValue];
}

- (BOOL)boolForKey:(NSString*)key
{
    id obj = [self nilifiedObjectForKey:key];
    
    if (!obj || (![obj isKindOfClass:[NSNumber class]] && ![obj isKindOfClass:[NSString class]]))
    {
        return NO;
    }
    
    return [obj boolValue];
}

- (double)doubleForKey:(NSString*)key
{
    id obj = [self nilifiedObjectForKey:key];
    
    if (!obj || (![obj isKindOfClass:[NSNumber class]] && ![obj isKindOfClass:[NSString class]]))
    {
        return 0.0;
    }
    
    return [obj doubleValue];
}

- (NSDate*)dateForKey:(NSString*)key format:(NSString*)dateFormat fromTimezone:(NSTimeZone*)fromTimezone {
    id obj = [self nilifiedObjectForKey:key];
    
    if (!obj || ![obj isKindOfClass:[NSString class]])
    {
        return nil;
    }
    
    NSDate *d = [LDateTimeUtils dateFromString:obj dateFormat:dateFormat fromTimezone:fromTimezone];
    
    return d;
}

- (NSDate*)dateForKey:(NSString*)key format:(NSString*)dateFormat
{
    return [self dateForKey:key format:dateFormat fromTimezone:nil];
}

- (NSString *)getStrWithNullValue:(id)aKey {
	id obj = [self objectForKey:aKey];
    
	if (obj == NULL || !obj) return @"NULL"; else return [NSString stringWithFormat:@"'%@'",
                                                          [(NSString *)obj addSlashes]];
}

- (NSString *)sqlString:(id)aKey {
	return [self getStrWithNullValue: aKey];
}

- (int)sqlInt:(id)aKey {
	return (![[self objectForKey: aKey] isEqual:[NSNull null]] || ![[self objectForKey: aKey] isKindOfClass:[NSNumber class]]) ? [[self objectForKey: aKey] intValue] : 0;
}

- (float)sqlFloat:(id)aKey {
	return (![[self objectForKey: aKey] isEqual:[NSNull null]] || ![[self objectForKey: aKey] isKindOfClass:[NSNumber class]]) ? [[self objectForKey: aKey] floatValue] : 0.0;
}

- (NSString *)sqlDate:(id)aKey {
	return [self getStrWithNullValue: aKey];
}

- (int)intFromSql:(id)aKey {
    return (![[self objectForKey: aKey] isEqual:[NSNull null]] || ![[self objectForKey: aKey] isKindOfClass:[NSNumber class]]) ? [[self objectForKey:aKey] intValue] : 0;
}

- (float)floatFromSql:(id)aKey {
    return (![[self objectForKey: aKey] isEqual:[NSNull null]] || ![[self objectForKey: aKey] isKindOfClass:[NSNumber class]]) ? [[self objectForKey:aKey] floatValue] : 0.0;
}

- (NSString*)stringFromSql:(id)aKey {
    return (![[self objectForKey: aKey] isEqual:[NSNull null]]) ? [((NSString*)[self objectForKey:aKey]) stripSlashes] : @"";
}

+ (NSDictionary *)dictionaryWithFormEncodedString:(NSString *)encodedString
{
	if (!encodedString)
    {
		return nil;
	}
    
	NSMutableDictionary *result = [NSMutableDictionary dictionary];
	NSArray *pairs = [encodedString componentsSeparatedByString:@"&"];
    
	for (NSString *kvp in pairs)
    {
		if ([kvp length] == 0)
        {
			continue;
		}
        
		NSRange pos = [kvp rangeOfString:@"="];
		NSString *key;
		NSString *val;
        
		if (pos.location == NSNotFound)
        {
			key = [kvp stringByUnescapingFromURLQuery];
			val = @"";
		}
        else
        {
			key = [[kvp substringToIndex:pos.location] stringByUnescapingFromURLQuery];
			val = [[kvp substringFromIndex:pos.location + pos.length] stringByUnescapingFromURLQuery];
		}
        
		if (!key || !val)
        {
			continue; // I'm sure this will bite my arse one day
		}
        
		[result setObject:val forKey:key];
	}
    
	return result;
}


- (NSString *)stringWithFormEncodedComponents
{
	NSMutableArray *arguments = [NSMutableArray arrayWithCapacity:[self count]];
    
	[self enumerateKeysAndObjectsUsingBlock:^(id key, id object, BOOL *stop)
    {
		[arguments addObject:[NSString stringWithFormat:@"%@=%@",
							  [key stringByEscapingForURLQuery],
							  [[object description] stringByEscapingForURLQuery]]];
	}];
    
	return [arguments componentsJoinedByString:@"&"];
}

@end
