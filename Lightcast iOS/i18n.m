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
 * @changed $Id: i18n.m 271 2013-06-19 16:52:15Z mkovachev $
 * @author $Author: mkovachev $
 * @version $Revision: 271 $
 */

#import "i18n.h"

NSString *const kLCI18nErrorDomain = @"com.nimasystems.lightcast.i18n";

NSLocale *LCurrentLocale(void)
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSArray* languages = [defaults objectForKey:@"AppleLanguages"];
    
    if (languages.count > 0)
    {
        NSString* currentLanguage = [languages objectAtIndex:0];
        return [[[NSLocale alloc] initWithLocaleIdentifier:currentLanguage] autorelease];
    }
    else
    {
        return [NSLocale currentLocale];
    }
}

NSString *LLocalizedString(NSString *key)
{
    return LLocalizedStringInBundle(key, [NSBundle mainBundle]);
}

NSString *LLocalizedStringInBundle(NSString *key, NSBundle *bundle)
{
    return [bundle localizedStringForKey:key value:key table:nil];
}

NSString *LFormatInteger(NSInteger num)
{
    NSNumber* number = [NSNumber numberWithInt:(int)num];
    NSNumberFormatter* formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [formatter setGroupingSeparator:@","];
    NSString* formatted = [formatter stringForObjectValue:number];
    [formatter release];
    return formatted;
}
