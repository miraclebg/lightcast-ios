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
 * @changed $Id: LC.h 357 2015-04-16 06:29:29Z mkovachev $
 * @author $Author: mkovachev $
 * @version $Revision: 357 $
 */

#import <Foundation/Foundation.h>
#import <Lightcast/LCAppConfiguration.h>
#import <Lightcast/LSystemObject.h>
#import <Lightcast/LPluginManager.h>
#import <Lightcast/LDatabaseManager.h>
#import <Lightcast/LStorage.h>
#import <Lightcast/LNotificationDispatcher.h>
#import <Lightcast/LAppUpgrades.h>
#import <Lightcast/LLocalizationManager.h>
#import <Lightcast/LCompressingLogFileManager.h>

#define LIGHTCAST_NAME @"Lightcast"

extern NSString *const lnLightcastAppUpgradesNSUserDefaultsSaveKey;
extern NSString *const lnLightcastStatusChangeCaptionKey;

// notification strings

extern NSString *const lnLightcastInitialized;

#ifdef TARGET_IOS
extern NSString *const lnLightcastApplicationDidReceiveMemoryWarning;
extern NSString *const lnLightcastApplicationDidFinishLaunchingWithOptions;
extern NSString *const lnLightcastApplicationWillResignActive;
extern NSString *const lnLightcastApplicationDidEnterBackground;
extern NSString *const lnLightcastApplicationWillEnterForeground;
extern NSString *const lnLightcastApplicationDidBecomeActive;
extern NSString *const lnLightcastApplicationWillTerminate;
extern NSString *const lnLightcastApplicationDidRegisterForRemoteNotifications;
extern NSString *const lnLightcastApplicationDidReceiveRemoteNotification;
extern NSString *const lnLightcastApplicationDidFailToRegisterRemoteNotifications;
#endif

extern NSInteger const kLightcastDefaultLogMaxSize;
extern NSInteger const kLightcastDefaultLogMaxRotatedFiles;

typedef enum
{
    LCInitializationStageBase = 0,
    LCInitializationStageSystemObjects = 1,
    LCInitializationStageAppUpgrades = 2,
    
    LCInitializationStageDone = 100
    
} LCInitializationStage;

/**
 * @return A localized string from the lightcast bundle.
 */
NSString *LightcastLocalizedString(NSString *key);

@class LC;

@protocol LightcastDelegate <NSObject> 

@optional

- (void)willBeginInitialization:(LC*)lightcast;
- (void)didFinishInitializing:(LC*)lightcast;
- (void)initializationStageChange:(LC*)lightcast currentStage:(LCInitializationStage)stage statusInfo:(NSDictionary*)statusInfo;

- (void)willRunAppUpgrades:(LC*)lightcast appUpgrader:(LAppUpgrades*)appUpgrader fromVersion:(NSInteger)fromVersion;
- (void)didFailRunningAppUpgrades:(LC*)lightcast appUpgrader:(LAppUpgrades*)appUpgrader fromVersion:(NSInteger)fromVersion reachedVersion:(NSInteger)reachedVersion error:(NSError*)error shouldCancelInitialization:(BOOL*)shouldCancelInitialization;
- (void)didFinishRunningAppUpgrades:(LC*)lightcast appUpgrader:(LAppUpgrades*)appUpgrader fromVersion:(NSInteger)fromVersion reachedVersion:(NSInteger)reachedVersion;

@end

@interface LC : NSObject {
    
    LCAppConfiguration * configuration;
    LNotificationDispatcher* nd;
    
    NSMutableDictionary * systemObjects;
	
    BOOL hasInitialized;
    BOOL firstInstall;
    
    id<LightcastDelegate> delegate;
	
	LPluginManager *plugins; // only a stub - to compile in 32-bit mode
	LDatabaseManager *db; // only a stub - to compile in 32-bit mode
	LStorage *storage; // only a stub - to compile in 32-bit mode
    
    LAppUpgrades *appUpgrader;
}

@property (nonatomic, assign) id<LightcastDelegate> delegate;
@property (nonatomic, retain, readonly) LCAppConfiguration * config;
@property (nonatomic, retain) LAppUpgrades *appUpgrader;
@property (nonatomic, retain, readonly, getter = getEventDispatcher) LNotificationDispatcher *eventDispatcher;
@property (nonatomic, retain, readonly, getter = getPluginManager_) LPluginManager * plugins;
@property (nonatomic, retain, readonly, getter = getDatabaseManager_) LDatabaseManager * db;
@property (nonatomic, retain, readonly, getter = getStorage_) LStorage * storage;
@property (nonatomic, retain, retain) LLocalizationManager *localizationManager;
@property (nonatomic, assign) BOOL firstInstall;

@property (nonatomic, retain, readonly) LCompressingLogFileManager *logFileManager;

@property (nonatomic, retain) NSBundle *lightcastBundle;

// these are here only for compatibility with previous versions!
@property (nonatomic, retain, getter = getResourcesPath) NSString *resourcesPath;
@property (nonatomic, retain, getter = getDocumentsPath) NSString *documentsPath;
@property (nonatomic, retain, getter = getTemporaryPath) NSString *temporaryPath;

+ (LC*)sharedLC;

- (void)initialize;
- (void)initialize:(LCAppConfiguration*)aConfiguration;
- (void)initialize:(LCAppConfiguration*)aConfiguration notificationDispatcher:(LNotificationDispatcher*)dispatcher;

- (BOOL)initFileLogger:(NSString*)logsDirectory error:(NSError**)error;
- (BOOL)initFileLogger:(NSString*)logsDirectory compressLogs:(BOOL)compressLogs error:(NSError**)error;
- (void)addConsoleLoggers;

+ (BOOL)resetAppData:(NSError**)error configuration:(LCAppConfiguration*)aConfiguration;

+ (NSArray*)systemReservedNSKeys;

+ (LCAppConfiguration*)defaultConfiguration;
- (LCAppConfiguration*)defaultConfiguration;

#ifdef TARGET_IOS
- (void)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;
- (void)applicationWillResignActive:(UIApplication *)application;
- (void)applicationDidEnterBackground:(UIApplication *)application;
- (void)applicationWillEnterForeground:(UIApplication *)application;
- (void)applicationDidBecomeActive:(UIApplication *)application;
- (void)applicationWillTerminate:(UIApplication *)application;

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken;
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo;
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error;

#endif

// TODO: Move this to another file!
- (NSString *)getLogFilesContentWithMaxSize:(NSInteger)maxSize;
+ (NSString*)defaultPathForLogs;

@end
