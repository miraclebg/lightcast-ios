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
 * @changed $Id: main.m 345 2014-10-07 17:23:27Z mkovachev $
 * @author $Author: mkovachev $
 * @version $Revision: 345 $
 */

#import <Foundation/Foundation.h>

void parseLightcast()
{
    NSString *path = [@"~/sworkspace/lightcast-ios/trunk" stringByExpandingTildeInPath];
    
    LI18nProjectCatalog *catalog = [[LI18nProjectCatalog alloc] initWithBaseDir:path];
    catalog.bundleName = @"Lightcast iOS/lightcast.bundle";
    catalog.skippedItems = [NSArray arrayWithObjects:@"3rdParty/", @"Build/", nil];
    catalog.matchPatterns = [NSArray arrayWithObjects:
                             @"LightcastLocalizedString\\(\\@\"(.+?)\"[\\s\\n]*\\)", nil];
    
    NSArray *langs = [NSArray arrayWithObjects:
                      @"en",
                      @"es",
                      @"bg"
                      , nil];
    [catalog parseAndMergeToBundle:langs error:nil];
}

void parseCocoa()
{
    NSString *path = [@"~/sworkspace/stampii/st-cocoa/trunk" stringByExpandingTildeInPath];
    
    LI18nProjectCatalog *catalog = [[LI18nProjectCatalog alloc] initWithBaseDir:path];
    catalog.bundleName = @"Resources/SharedResources.bundle";
    catalog.skippedItems = [NSArray arrayWithObjects:@"3rdParty/", @"Build/", nil];
    catalog.matchPatterns = [NSArray arrayWithObjects:
                             @"\\[StI18n[\\s]+?localizedString\\:\\@\"(.+?)\"[\\s\\n]*\\]",
                             @"\\[StI18n[\\s]+?localizedStringWithFormat\\:\\@\"(.+?)\"\\,]", nil];

    NSArray *langs = [NSArray arrayWithObjects:
                      @"en",
                      @"es",
                      @"bg"
                      , nil];
    [catalog parseAndMergeToBundle:langs error:nil];
}

void parseStampii()
{
    NSString *path = [@"~/sworkspace/stampii/st-iphone/branches/2.0.0.0" stringByExpandingTildeInPath];
    
    LI18nProjectCatalog *catalog = [[LI18nProjectCatalog alloc] initWithBaseDir:path];
    catalog.bundleName = @"";
    catalog.skippedItems = [NSArray arrayWithObjects:@"3rdParty/", @"Build/", nil];
    catalog.matchPatterns = [NSArray arrayWithObjects:
                             @"\\[LI18n[\\s]+?localizedString\\:\\@\"(.+?)\"[\\s\\n]*\\]",
                             @"\\[LI18n[\\s]+?localizedStringWithFormat\\:\\@\"(.+?)\"\\,", nil];

   NSArray *langs = [NSArray arrayWithObjects:
                      @"en",
                      @"es",
                      @"bg"
                      , nil];
    [catalog parseAndMergeToBundle:langs error:nil];
}

void parseStampiiMac()
{
    NSString *path = [@"~/sworkspace/stampii/st-mac/branches/2.0.0" stringByExpandingTildeInPath];
    
    LI18nProjectCatalog *catalog = [[LI18nProjectCatalog alloc] initWithBaseDir:path];
    catalog.bundleName = @"Resources";
    catalog.skippedItems = [NSArray arrayWithObjects:@"3rdParty/", nil];
    catalog.matchPatterns = [NSArray arrayWithObjects:
                             @"\\[LI18n[\\s]+?localizedString\\:\\@\"(.+?)\"[\\s\\n]*\\]",
                             @"\\[LI18n[\\s]+?localizedStringWithFormat\\:\\@\"(.+?)\"\\,", nil];
    
    NSArray *langs = [NSArray arrayWithObjects:
                      @"en",
                      @"es",
                      @"bg"
                      , nil];
    [catalog parseAndMergeToBundle:langs error:nil];
}

void parseEikaiwa()
{
    NSString *path = [@"/Users/mkovachev/sworkspace/kaiwanow-ios/trunk" stringByExpandingTildeInPath];
    
    LI18nProjectCatalog *catalog = [[LI18nProjectCatalog alloc] initWithBaseDir:path];
    catalog.bundleName = @"";
    catalog.skippedItems = [NSArray arrayWithObjects: @"Build/", nil];
    catalog.matchPatterns = [NSArray arrayWithObjects:
                             @"\\[LI18n[\\s]+?localizedString\\:\\@\"(.+?)\"[\\s\\n]*\\]",
                             @"\\[LI18n[\\s]+?localizedStringWithFormat\\:\\@\"(.+?)\"\\,", nil];
    
    NSArray *langs = [NSArray arrayWithObjects:
                      @"en",
                      @"jp"
                      , nil];
    [catalog parseAndMergeToBundle:langs error:nil];
}

int main (int argc, const char * argv[])
{
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    
    parseEikaiwa();
    
    /*
    parseLightcast();
    parseCocoa();
    parseStampii();
    parseStampiiMac();*/
    
    /*
    
    NSArray *currentBundleItems = [catalog currentBundleLanguages];
    
    LogDebug(@"currentBundleItems: %@", currentBundleItems);
    
   // NSError *err = nil;
    NSDictionary *translations = nil;
    BOOL ret = [catalog parseSourceFiles:&translations error:&err];
    
    LogError(@"err: %@", err);
    LogDebug(@"tRANSLATIONS: %@", translations);
    
    NSString *filename = [@"~/Desktop/OneCollectionViewController.m" stringByExpandingTildeInPath];
    NSData *dta = [NSData dataWithContentsOfFile:filename];
    NSString *sourceString = [[[NSString alloc] initWithData:dta encoding:NSUTF8StringEncoding] autorelease];

    //LogDebug(@"xx: %@", sourceString);
    
    LI18nTranslationSourceParser *parser = [[[LI18nTranslationSourceParser alloc] initWithSourceString:sourceString] autorelease];
    
    NSError *err = nil;
    BOOL parsed = [parser parse:&err];
    
    lassert(parsed);
    LogError(@"err: %@", err);
    */
    
    
    /*
    --parse --configFile [config.plist] --source [dir/file] --recursive --destination [dir/file.plist]
    --deleteLanguage --configFile [config.plist] --destination [dir/file.plist]
    --addLanguage --configFile [config.plist] --destination [dir/file.plist]
    --redist[ribute] --configFile [config.plist] [dir1] [dir2] [dir3]
    */
    
    [pool drain];
    return 0;
}

