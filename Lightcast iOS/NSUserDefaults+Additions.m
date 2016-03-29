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
 * @changed $Id: NSUserDefaults+Additions.m 294 2013-09-10 05:10:48Z mkovachev $
 * @author $Author: mkovachev $
 * @version $Revision: 294 $
 */

#import "NSUserDefaults+Additions.h"

@implementation NSUserDefaults(Additions)

- (NSArray*)allSavedKeys
{
	return [[self dictionaryRepresentation] allKeys];
}

- (void)setMainBundleSettingsDefaults
{
    [self setBundleSettingsDefaults:[NSBundle mainBundle]];
}

- (void)setBundleSettingsDefaults:(NSBundle*)bundle
{
    if (!bundle)
    {
        lassert(false);
        return;
    }
    
    NSString *bundlePath = [bundle bundlePath];
    NSString *settingsBundlePath = [bundlePath stringByAppendingPathComponent:@"Settings.bundle"];
    NSBundle *settingsBundle = [NSBundle bundleWithPath:settingsBundlePath];
    NSString *settingsPath = [settingsBundle pathForResource:@"Root" ofType:@"plist"];
    
    NSDictionary *settingsDict = [NSDictionary dictionaryWithContentsOfFile:settingsPath];
    
    if (!settingsDict)
    {
        return;
    }
    
    NSArray *prefSpecifierArray = [settingsDict objectForKey:@"PreferenceSpecifiers"];
    
    NSMutableDictionary *appDefaults = [[NSMutableDictionary alloc] init];
    
    for (NSDictionary *prefItem in prefSpecifierArray)
    {
        NSString *key = [prefItem objectForKey:@"Key"];
        
        if (key != nil)
        {
            id defaultValue = [prefItem objectForKey:@"DefaultValue"];
            
            if (defaultValue)
            {
                [appDefaults setObject:defaultValue forKey:key];
            }
        }
    }
    
    // set them in the standard user defaults
    [[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
    
    L_RELEASE(appDefaults);
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
