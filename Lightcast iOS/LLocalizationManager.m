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
 * @changed $Id: LLocalizationManager.m 234 2013-03-15 05:30:35Z mkovachev $
 * @author $Author: mkovachev $
 * @version $Revision: 234 $
 */

#import "LLocalizationManager.h"

static LLocalizationManager *defaultLocalizationManager = nil;

@implementation LLocalizationManager

@synthesize
bundle;

#pragma mark - Initialization / Finalization

- (id)initWithBundle:(NSBundle*)aBundle
{
    self = [super init];
    if (self)
    {
        bundle = [aBundle retain];
    }
    return self;
}

- (id)init
{
    return [self initWithBundle:nil];
}

- (void)dealloc
{
    L_RELEASE(bundle);
    
    [super dealloc];
}

#pragma mark - Localization

- (NSString*)localizedString:(NSString*)key
{
    lassert(![NSString isNullOrEmpty:key]);
    
    if (!bundle)
    {
        return key;
    }
    
    NSString *lString = [bundle localizedStringForKey:key value:key table:nil];
	
	if ([NSString isNullOrEmpty:lString])
	{
		return key;
	}
	
	return lString;
}

- (NSString*)localizedStringWithFormat:(NSString*)format, ... NS_FORMAT_FUNCTION(1,2)
{
    NSString *translatedStr = [self localizedString:format];
    
    va_list argumentList;
    
    va_start(argumentList, format);
    translatedStr = [[[NSString alloc] initWithFormat:translatedStr arguments:argumentList] autorelease];
    va_end(argumentList);
    
    return translatedStr;
}

#pragma mark - Default localization manager static methods

+ (NSString*)localizedString:(NSString*)key
{
    return [[LLocalizationManager defaultLocalizationManager] localizedString:key];
}

+ (NSString*)localizedStringWithFormat:(NSString*)format, ... NS_FORMAT_FUNCTION(1,2)
{
    NSString *translatedStr = [[LLocalizationManager defaultLocalizationManager] localizedString:format];
    
    va_list argumentList;
    
    va_start(argumentList, format);
    translatedStr = [[[NSString alloc] initWithFormat:translatedStr arguments:argumentList] autorelease];
    va_end(argumentList);
    
    return translatedStr;
}

+ (LLocalizationManager*)defaultLocalizationManager {
	@synchronized(self)
    {
        if (defaultLocalizationManager == nil)
        {
            NSBundle *mainBundle = [NSBundle mainBundle];
            defaultLocalizationManager = [[super alloc] initWithBundle:mainBundle];
            lassert(defaultLocalizationManager);
        }
    }
    return defaultLocalizationManager;
}

@end

@implementation LI18n

@end