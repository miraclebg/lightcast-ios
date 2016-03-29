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
 * @changed $Id: LApplicationUtils.m 360 2015-05-22 08:12:42Z mkovachev $
 * @author $Author: mkovachev $
 * @version $Revision: 360 $
 */

#import "LApplicationUtils.h"
#import "NSUserDefaults+Additions.h"
#import "LDeviceSystemInfo.h"

@interface LApplicationUtils(Private)

+ (NSString*)formattedDeviceInfoString;

@end

@implementation LApplicationUtils

+ (BOOL)resetFolder:(NSString*)folderName error:(NSError**)error {
	
    if (error != NULL)
    {
        *error = nil;
    }
    
	NSFileManager *fm = [NSFileManager defaultManager];

    BOOL res = NO;
    
    if ([NSString isNullOrEmpty:folderName])
    {
        lassert(false);
        return NO;
    }
    
    if (![fm folderExists:folderName])
    {
        return YES;
    }
	
    LogInfo(@"resetDocumentsFolder start: %@", folderName);
    
    @try
    {
        res = [fm removeFolderRecursively:folderName emptyTopFolder:YES error:error];
    }
    @catch (NSException *e) 
    {
        res = NO;
        LogError(@"Error while running resetDocumentsFolder: %@", e);
        
        if (error != NULL)
        {
            *error = nil;
        }
    }
    
    LogInfo(@"resetDocumentsFolder end");
    
    return res;
}

+ (BOOL)resetDocumentsFolder:(NSError**)error
{
    if (error != NULL)
    {
        *error = nil;
    }
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *documentsFolder = [fm documentsPath];
    
    return [LApplicationUtils resetFolder:documentsFolder error:error];
}

+ (BOOL)resetTemporaryFolder:(NSError**)error {
	
    if (error != NULL)
    {
        *error = nil;
    }
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *documentsFolder = [fm temporaryPath];
    
    return [LApplicationUtils resetFolder:documentsFolder error:error];
}

+ (void)resetUserDefaults:(NSUserDefaults*)userDefaults preserveKeys:(NSArray*)preservedKeys
{
    NSArray *keys = [userDefaults allSavedKeys];
	
	if (!keys || ![keys count]) return;
	
	NSInteger count = [keys count];
	
	LogInfo(@"resetUserDefaults: %d", (int)count);
	
	for (NSString *key in keys)
	{
        if (preservedKeys && [preservedKeys containsObject:key])
        {
            continue;
        }
        
		[userDefaults removeObjectForKey:key];
	}
    
    [userDefaults synchronize];
}

+ (void)resetUserDefaults:(NSUserDefaults*)userDefaults
{
	[self resetUserDefaults:userDefaults preserveKeys:nil];
}

+ (NSString*)currentLocale
{
    // obtain locale from OS
	NSLocale * currentUsersLocale = [NSLocale currentLocale];
	NSString * currentLocale = [currentUsersLocale localeIdentifier];
	
	return currentLocale;
}

+ (NSString*)bundleVersion
{
    // bundle version
    NSString * bv = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString * rev = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    NSString *bundleVersion = (![NSString isNullOrEmpty:bv] && ![NSString isNullOrEmpty:rev]) ?
    [NSString stringWithFormat:@"%@.%@", bv, rev] :
    @"0";
    
    return bundleVersion;
}

+ (NSString*)bundleIdentifier
{
    NSBundle *bundle = [NSBundle mainBundle];
    NSDictionary *info = [bundle infoDictionary];
    NSString *bundleIdentifier = ![NSString isNullOrEmpty:[info objectForKey:@"CFBundleIdentifier"]] ? [info objectForKey:@"CFBundleIdentifier"] : @"";
    return bundleIdentifier;
}

+ (NSString*)formattedUserAgentStringForLocale:(NSString*)productName
{
    return [LApplicationUtils formattedUserAgentStringForLocale:productName
                                                        version:[LApplicationUtils bundleVersion]
                                                         locale:[LApplicationUtils currentLocale]
                                              deviceDescription:[LApplicationUtils formattedDeviceInfoString]];
}

+ (NSString*)formattedUserAgentStringForLocale:(NSString*)productName userDetails:(NSDictionary*)userDetails
{
    return [self formattedUserAgentStringForLocale:productName
                                           version:[LApplicationUtils bundleVersion]
                                            locale:[LApplicationUtils currentLocale]
                                 deviceDescription:[LApplicationUtils formattedDeviceInfoString]
                                       userDetails:userDetails];
}

+ (NSString*)formattedUserAgentStringForLocale:(NSString*)productName locale:(NSString*)locale
{
    NSString *deviceDescription = [LApplicationUtils formattedDeviceInfoString];
    
    lassert(deviceDescription);
    
    return [LApplicationUtils formattedUserAgentStringForLocale:productName
                                                        version:[LApplicationUtils bundleVersion]
                                                         locale:locale
                                              deviceDescription:deviceDescription];
}

+ (NSString*)formattedUserAgentStringForLocale:(NSString*)productName version:(NSString*)version locale:(NSString*)locale deviceDescription:(NSString*)deviceDescription
{
    return [self formattedUserAgentStringForLocale:productName version:version locale:locale deviceDescription:deviceDescription userDetails:nil];
}

+ (NSString*)formattedUserAgentStringForLocale:(NSString*)productName version:(NSString*)version locale:(NSString*)locale deviceDescription:(NSString*)deviceDescription userDetails:(NSDictionary*)userDetails
{
    if ([NSString isNullOrEmpty:productName] || [NSString isNullOrEmpty:locale] || [NSString isNullOrEmpty:version] || [NSString isNullOrEmpty:deviceDescription])
    {
        lassert(false);
        return nil;
    }
    
    NSString *screenSize = nil;
    BOOL isRetina = NO;
    
#ifdef TARGET_IOS
    CGRect scrRect = [UIScreen mainScreen].applicationFrame;
    screenSize = [NSString stringWithFormat:@"%ldx%ld", (long)scrRect.size.width, (long)scrRect.size.height];
    isRetina = [UIScreen isRetina];
#else 
    NSRect e = [[NSScreen mainScreen] frame];
    screenSize = [NSString stringWithFormat:@"%ldx%ld", (long)e.size.width, (long)e.size.height];
    
    float displayScale = 1;
    
    if ([[NSScreen mainScreen] respondsToSelector:@selector(backingScaleFactor)]) {
        NSArray *screens = [NSScreen screens];
        for (int i = 0; i < [screens count]; i++) {
            float s = [[screens objectAtIndex:i] backingScaleFactor];
            if (s > displayScale)
                displayScale = s;
        }
    }
    
    isRetina = (displayScale > 1);
#endif
    
    NSMutableArray *items = [[[NSMutableArray alloc] init] autorelease];
    
    [items addObject:deviceDescription];
    [items addObject:[NSString stringWithFormat:@"lightcast:%@", LC_VER]];
    [items addObject:[NSString stringWithFormat:@"locale:%@",locale]];
    [items addObject:[NSString stringWithFormat:@"display:%@%@",
                      screenSize,
                      (isRetina ? @",retina" : @"")
                      ]];
    
    if (userDetails && [userDetails count])
    {
        for(NSString *key in userDetails)
        {
            NSString *tmp = [NSString stringWithFormat:@"%@:%@",
                             key,
                             [userDetails objectForKey:key]
                             ];
            [items addObject:tmp];
        }
    }
    
	NSString * tmp = [NSString stringWithFormat:@"%@/%@ (%@)",
                      productName,
					  version,
					  [items componentsJoinedByString:@"; "]
					  ];
    
    return tmp;
}

#pragma mark - Private methods

+ (NSString*)formattedDeviceInfoString
{
    // TODO: Find a way to obtain this once statically
    LDeviceSystemInfo *sysInfo = [[[LDeviceSystemInfo alloc] init] autorelease];
    
    lassert(![NSString isNullOrEmpty:sysInfo.model]);
    lassert(![NSString isNullOrEmpty:sysInfo.systemName]);
    lassert(![NSString isNullOrEmpty:sysInfo.systemVersion]);
    
    NSString *formattedInfo = [NSString stringWithFormat:@"%@; %@/%@",
                               sysInfo.model,
                               sysInfo.systemName,
                               sysInfo.systemVersion
                               ];
    
    return formattedInfo;
}

@end
