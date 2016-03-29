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
 * @changed $Id: LPluginManager.h 271 2013-06-19 16:52:15Z mkovachev $
 * @author $Author: mkovachev $
 * @version $Revision: 271 $
 */

#import <Foundation/Foundation.h>
#import <Lightcast/LPlugin.h>
#import <Lightcast/LSystemObject.h>
#import <Lightcast/LDatabaseManager.h>

@protocol LPluginManagerDelegate <NSObject>

@optional

- (void)pluginLoaded:(LPlugin*)plugin;
- (void)pluginInitialized:(LPlugin*)plugin;
- (void)errorLoadingPlugin:(NSString*)pluginName error:(NSError*)error;

@end

@interface LPluginManager : LSystemObject

@property (nonatomic, retain, readonly) NSDictionary * plugins;
@property (nonatomic, readonly, getter = getPluginsCount) NSInteger count;
@property (nonatomic, assign) id<LPluginManagerDelegate> delegate;

- (BOOL)loadPlugins:(NSArray*)pluginNames errors:(NSArray **)errors;
- (BOOL)loadPlugin:(NSString*)pluginName configuration:(LConfiguration*)aConfiguration error:(NSError **)error; // was ..configuration:(LConfiguration*)configuration
- (BOOL)loadPlugin:(NSString*)pluginName error:(NSError **)error;
- (BOOL)pluginExists:(NSString*)pluginName;
- (BOOL)isPluginLoaded:(NSString*)pluginName;

- (LPlugin*)plugin:(NSString *)pluginName;

- (BOOL)pluginMeetsRequirements:(LPlugin*)plugin error:(NSError**)error;

@end

extern NSString *const lnPluginManagerInitialized;