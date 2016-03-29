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
 * @changed $Id: LC.m 342 2014-10-01 13:16:38Z mkovachev $
 * @author $Author: mkovachev $
 * @version $Revision: 342 $
 */

#import "LC.h"
#import "LSQLiteDatabaseAdapter.h"
#import "LPluginManager.h"
#import "LSystemObject.h"
#import "DDASLLogger.h"
#import "DDTTYLogger.h"

static LC *sharedLC = nil;

NSString *const kLightcastI18NBundleName = @"lightcast.bundle";

NSString *const lnLightcastInitialized = @"lightcast:lightcastInitialized";
NSString *const lnLightcastAppUpgradesNSUserDefaultsSaveKey = @"lightcast:app_upgrades_current_build_version";

NSString *const lnLightcastStatusChangeCaptionKey = @"caption";

#ifdef TARGET_IOS
NSString *const lnLightcastApplicationDidReceiveMemoryWarning = @"lightcast:applicationDidReceiveMemoryWarning";
NSString *const lnLightcastApplicationDidFinishLaunchingWithOptions = @"lightcast:applicationDidFinishLaunchingWithOptions";
NSString *const lnLightcastApplicationWillResignActive = @"lightcast:applicationWillResignActive";
NSString *const lnLightcastApplicationDidEnterBackground = @"lightcast:applicationDidEnterBackground";
NSString *const lnLightcastApplicationWillEnterForeground = @"lightcast:applicationWillEnterForeground";
NSString *const lnLightcastApplicationDidBecomeActive = @"lightcast:applicationDidBecomeActive";
NSString *const lnLightcastApplicationWillTerminate = @"lightcast:applicationWillTerminate";
NSString *const lnLightcastApplicationDidRegisterForRemoteNotifications = @"lightcast:didRegisterForRemoteNotifications";
NSString *const lnLightcastApplicationDidReceiveRemoteNotification = @"lightcast:didReceiveRemoteNotification";
NSString *const lnLightcastApplicationDidFailToRegisterRemoteNotifications = @"lightcast:didFailToRegisterForRemoteNotifications";
#endif

NSInteger const kLightcastDefaultLogMaxSize = 4194304; // 4MB
NSInteger const kLightcastDefaultLogMaxRotatedFiles = 4;
NSInteger const kLightcastDefaultLogRollingFrequency = 120; // 120 mins

#define LC_DEFAULT_STORAGE_ADAPTER @"Default"

#define LC_LOADER_NAME_DATABASE_MANAGER @"database_manager"
#define LC_LOADER_NAME_PLUGIN_MANAGER @"plugin_manager"
#define LC_LOADER_NAME_STORAGE @"storage"

NSString *LightcastLocalizedString(NSString *key)
{
	return [[LC sharedLC].localizationManager localizedString:key];
}

// private class methods
@interface LC(Private) 

- (void)initSystemObjects;
- (void)initSystemObject:(NSString*)className type:(NSString*)type;
- (void)informDelegateOfInitializationStageChange:(LCInitializationStage)stage statusMessage:(NSString*)statusMessage;
- (BOOL)runAppUpgrades;

@end;

// public class methods
@implementation LC {
    
    LCompressingLogFileManager *_logFileManager;
    DDFileLogger *_fileLogger;
    
    BOOL _consoleLoggersAdded;
}

@synthesize
delegate,
config=configuration,
firstInstall,
localizationManager,
lightcastBundle,
plugins,
db,
storage,
appUpgrader,
documentsPath,
resourcesPath,
temporaryPath,
eventDispatcher=nd,
logFileManager=_logFileManager;

#pragma mark -
#pragma mark Initialization / Finalization

- (id)init {
    self = [super init];
    if (self)
    {
        hasInitialized = NO;
        configuration = nil;
        systemObjects = nil;
        delegate = nil;
        
        // by default we mark firstInstall to YES
        // callers must override it before initialization if it's not a first install
        firstInstall = YES;

        // init the default localization manager and lc bundle
        NSString *bundlePath = [NSFileManager combinePaths:[[NSBundle mainBundle] resourcePath], kLightcastI18NBundleName, nil];
        lassert(bundlePath);
        lightcastBundle = [[NSBundle bundleWithPath:bundlePath] retain];
        lassert(lightcastBundle);
        
        localizationManager = [[LLocalizationManager alloc] initWithBundle:lightcastBundle];
        lassert(localizationManager);
        
        /*if (!lightcastBundle || !localizationManager)
        {
            lassert(false);
            L_RELEASE(self);
            return nil;
        }*/
        
        // attach console logger
#if DEBUG || TESTING
        [self addConsoleLoggers];
#endif
        
        _logFileManager = nil;
        _fileLogger = nil;
        
#ifdef TARGET_IOS
		// listen for low memory notifications
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(applicationDidReceiveMemoryWarning:)
													 name:UIApplicationDidReceiveMemoryWarningNotification
												   object:nil];
#endif
        
#ifdef DEBUG
        LogWarn(@"---------------- WARNING: DEBUG MODE ENABLED! ----------------");
#endif
        
#if TARGET_IPHONE_SIMULATOR
        // where are you?
        LogInfo(@"Documents Directory: %@", [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject]);
#endif
    }
    return self;
}

- (void)dealloc {
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];	
	
    L_RELEASE(configuration);
    L_RELEASE(nd);
    L_RELEASE(systemObjects);
    L_RELEASE(appUpgrader);
    L_RELEASE(localizationManager);
    L_RELEASE(lightcastBundle);
    L_RELEASE(_fileLogger);
    L_RELEASE(_logFileManager);
    
    [super dealloc];
}

- (void)initialize {
    [self initialize:nil];
}

- (void)initialize:(LCAppConfiguration*)aConfiguration {
    [self initialize:aConfiguration notificationDispatcher:[LNotificationDispatcher sharedND]];
}

- (void)initialize:(LCAppConfiguration*)aConfiguration notificationDispatcher:(LNotificationDispatcher*)dispatcher {
    
	if (hasInitialized) return;
    
    // init config
    if (aConfiguration != configuration && aConfiguration)
    {
        L_RELEASE(configuration);
        configuration = [aConfiguration retain];
    }
    
    if (!configuration)
    {
        configuration = [[self defaultConfiguration] retain];
    }
    
    // set dispatcher
    if (dispatcher != nd)
    {
        L_RELEASE(nd);
        nd = [dispatcher retain];
    }
    
    // initialize environment paths
    NSError *err = nil;
    BOOL ret = [self initEnvPaths:&err];
    
    if (!ret)
    {
        lassert(false);
        LogError(@"Could not initialize environment paths: %@", err);
        
        // do not take any action here!
    }
    
    // initialize file logging if not already initialized
#ifndef DEBUG
    if (!_fileLogger)
    {
        NSString *logFilePath = [self.config.documentsPath stringByAppendingPathComponent:@"Logs"];
        NSError *err = nil;
        BOOL loggerInitialized = [self initFileLogger:logFilePath error:&err];
        
        if (!loggerInitialized)
        {
            // fallback to NSLog here
            NSLog(@"ERROR: Could not initialize logger: %@", err);
        }
    }
#endif
    
    if (self.delegate)
    {
        if (self.delegate && [self.delegate respondsToSelector:@selector(willBeginInitialization::)])
        {
            [self.delegate willBeginInitialization:self];
        }
    }
    
    LogInfo(@"Initializing Lightcast...");
    
    // inform of the status change
    [self informDelegateOfInitializationStageChange:LCInitializationStageBase statusMessage:LightcastLocalizedString(@"Initializing lightcast")];
    
    hasInitialized = YES;
    
    // init system objects
    [self initSystemObjects];
    
    // inform of the status change
    if (appUpgrader)
    {
        // init app upgrades
        BOOL shouldCancelInitialization = [self runAppUpgrades];
        
        if (shouldCancelInitialization)
        {
            [NSException raise:@"Exception" format:@"%@", LightcastLocalizedString(@"Cannot complete app upgrades")];
        }
    }
    
    LogInfo(@"Initializing Lightcast... DONE!");
    
    // inform of the status change
    [self informDelegateOfInitializationStageChange:LCInitializationStageDone statusMessage:LightcastLocalizedString(@"Initializing complete!")];
    
    if (delegate)
    {
        if ([delegate respondsToSelector:@selector(didFinishInitializing:)])
        {
            [delegate didFinishInitializing:self];
        }
    }
	
    // notify everyone
    [nd postNotification:[LNotification notificationWithName:lnLightcastInitialized]];
}

- (void)addConsoleLoggers {
    if (!_consoleLoggersAdded) {
        _consoleLoggersAdded = YES;
        [DDLog addLogger:[DDASLLogger sharedInstance]];
        [DDLog addLogger:[DDTTYLogger sharedInstance]];
    }
}

- (BOOL)initEnvPaths:(NSError**)error
{
    if (error != NULL)
    {
        *error = nil;
    }
    
    NSString *appLibraryPath = [[self.config.libraryPath stringByAppendingPathComponent:@"Application Support"]
                      stringByAppendingPathComponent:[LApplicationUtils bundleIdentifier]];
    
    NSString *appCachesPath = [self.config.cachesPath stringByAppendingPathComponent:[LApplicationUtils bundleIdentifier]];
    
    // create each path recursively
    NSArray *paths = [NSArray arrayWithObjects:
                      self.config.resourcesPath,
                      self.config.documentsPath,
                      self.config.temporaryPath,
                      self.config.libraryPath,
                      self.config.cachesPath,
                      appLibraryPath,
                      appCachesPath
                      , nil];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL ret = YES;
    NSError *lastErr = nil;
    
    for(NSString *path in paths)
    {
        BOOL rr = [fm createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&lastErr];
        
        if (!rr)
        {
            lassert(false);
            LogError(@"Could not create system directory %@: %@", path, lastErr);
            
            ret = NO;
        }
    }
    
    if (lastErr && error != NULL)
    {
        *error = lastErr;
    }
    
    return ret;
}

- (BOOL)initFileLogger:(NSString*)logsDirectory compressLogs:(BOOL)compressLogs error:(NSError**)error
{
    if (error != NULL)
    {
        *error = nil;
    }
    
    if (_fileLogger)
    {
        return YES;
    }
    
    if ([NSString isNullOrEmpty:logsDirectory])
    {
        lassert(false);
        return NO;
    }
    
    //NSString *logFolderName = logsDirectory;
    
    //NSString *logFolderName = [appDataFolder stringByAppendingPathComponent:@"Logs"];
    
    lassert(!_logFileManager);
    
    _logFileManager = [[LCompressingLogFileManager alloc] initWithLogsDirectory:logsDirectory];
    lassert(_logFileManager);
    
    if (_logFileManager)
    {
        // compress log files
        // disabled until this is fixed!
        //[_logFileManager compressLogFiles];
        
        _fileLogger = [[DDFileLogger alloc] initWithLogFileManager:_logFileManager];
        
        if (!_fileLogger)
        {
            lassert(false);
            return NO;
        }
        
        _fileLogger.maximumFileSize  = kLightcastDefaultLogMaxSize;
        _fileLogger.rollingFrequency =   kLightcastDefaultLogRollingFrequency * 60;
        _fileLogger.logFileManager.maximumNumberOfLogFiles = kLightcastDefaultLogMaxRotatedFiles;
        
        [DDLog addLogger:_fileLogger];
        
        LogInfo(@"File logger initialized");
    }
    
    return YES;
}

- (BOOL)initFileLogger:(NSString*)logsDirectory error:(NSError**)error
{
    return [self initFileLogger:logsDirectory compressLogs:NO error:error];
}

+ (BOOL)resetAppData:(NSError**)error configuration:(LCAppConfiguration*)aConfiguration
{
    if (error != NULL)
    {
        *error = nil;
    }
    
    if (!aConfiguration)
    {
        lassert(false);
        return NO;
    }
    
    // delete contents of the documents older
    BOOL folderWipedOut = [LApplicationUtils resetFolder:aConfiguration.documentsPath error:error];
    
    if (!folderWipedOut)
    {
        return NO;
    }
    
    LogInfo(@"Documents folder reset (%@)", aConfiguration.documentsPath);
    
    if (error != NULL)
    {
        *error = nil;
    }
    
    // delete contents of the temporary folder
    folderWipedOut = [LApplicationUtils resetFolder:aConfiguration.temporaryPath error:error];
    
    if (!folderWipedOut)
    {
        return NO;
    }
    
    LogInfo(@"Temporary folder reset (%@)", aConfiguration.temporaryPath);
    
    /*if (error != NULL)
    {
        *error = nil;
    }
    
    // delete contents of the caches folder
    folderWipedOut = [LApplicationUtils resetFolder:aConfiguration.cachesPath error:error];
    
    if (!folderWipedOut)
    {
        return NO;
    }
    
    LogInfo(@"Caches folder reset (%@)", aConfiguration.cachesPath);*/
    
    // wipe out user defaults
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud synchronize];
    
    // reset them but keep a hold on to the system ones!
    [LApplicationUtils resetUserDefaults:ud preserveKeys:[LC systemReservedNSKeys]];
    
    LogInfo(@"All NSUserDefaults removed");
    
    LogInfo(@"Application data has been reset");
    
    return YES;
}

- (void)initSystemObjects {
    
    LogDebug(@"loading system objects...");
    
    // inform of the status change
    [self informDelegateOfInitializationStageChange:LCInitializationStageSystemObjects statusMessage:LightcastLocalizedString(@"Initializing system objects")];
    
    L_RELEASE(systemObjects);
    systemObjects = [[NSMutableDictionary alloc] init];
    
    NSDictionary *objects = [self.config get:@"loaders"];
    
    if (objects)
    {
        LogDebug(@"Found %d system objects to load", (int)[objects count]);
        
        // just init them
        // TODO - find out a way to define this in configuration - system loaders must be loaded
        // in a particular order!
        NSArray *systemLoadersOrder = [NSArray arrayWithObjects:
                                       LC_LOADER_NAME_DATABASE_MANAGER,
                                       LC_LOADER_NAME_STORAGE,
                                       LC_LOADER_NAME_PLUGIN_MANAGER,
                                       nil];
        
        for (int i=0;i<[systemLoadersOrder count];i++)
        {
            NSString *objectName = [objects objectForKey:[systemLoadersOrder objectAtIndex:i]];
            
            if (objectName)
            {
                [self initSystemObject:objectName type:[systemLoadersOrder objectAtIndex:i]];
            }
        }
      
        int p = 0;
        
        // call: initialize
        for (p=0;p<[systemLoadersOrder count];p++)
        {
            // initialize the object and its configuration
            NSString *typeName = [systemLoadersOrder objectAtIndex:p];
            
            NSError *err = nil;
            LSystemObject *obj = [systemObjects objectForKey:typeName];
            
            // we obtain the default system object configuration and merge it with the main one here
            // if not already set by the user
            // TODO: We need to merge here! otherwise the user might have not set all required configurations!
            LConfiguration *defaultSystemObjectConfig = [obj defaultConfiguration];
            
            if (defaultSystemObjectConfig && ![configuration subnodeWithName:defaultSystemObjectConfig.name createIfMissing:NO])
            {
                [configuration addSubnode:defaultSystemObjectConfig];
            }
            
            BOOL loaded = [obj initialize:configuration notificationDispatcher:nd error:&err];
            
            if (!loaded)
            {
                [NSException raise:@"Exception" format:LightcastLocalizedString(@"Cannot initialize system object: %@"), err];
            }
        }
    }

    LogDebug(@"Initializing system objects... DONE!");
}

- (void)initSystemObject:(NSString*)className type:(NSString*)type {
    
    LogInfo(@"Loading %@...", type);
    
    @try 
    {
        // check if it has already been loaded
        if ([systemObjects objectForKey:type])
        {
            [NSException raise:@"Exception" format:@"%@",LightcastLocalizedString(@"The object has already been loaded")];
        }
        
        // check for the object
        Class class = NSClassFromString(className);
        
        if (![class isSubclassOfClass:[LSystemObject class]])
        {
            [NSException raise:@"Exception" format:@"%@",LightcastLocalizedString(@"Invalid system object - not inherited from LSystemObject")];
        }
        
        LSystemObject* instance = [[class alloc] init];
        
        // add it to the local array
        [systemObjects setObject:instance forKey:type];
        [instance release];
        
        LogInfo(@"Loading %@... DONE!", type);
    }
    @catch (NSException* e) 
    {
        LogError(@"Error loading system object: %@ (%@) - %@", 
                 type, className, [e description]);
        
        // re-raise the exception - if we can't load a system object - that's a big problem!
        [e raise];
    }
}

#pragma mark - Helpers

- (void)informDelegateOfInitializationStageChange:(LCInitializationStage)stage statusMessage:(NSString*)statusMessage
{
    if (delegate)
    {
        NSDictionary *statusInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                    statusMessage, lnLightcastStatusChangeCaptionKey
                                    , nil];
        
        if ([delegate respondsToSelector:@selector(initializationStageChange:currentStage:statusInfo:)])
        {
            [delegate initializationStageChange:self currentStage:stage statusInfo:statusInfo];
        }
    }
}

- (BOOL)runAppUpgrades
{
    NSError *err = nil;
    
    if (!appUpgrader)
    {
        return NO;
    }
    
    if (self.firstInstall)
    {
        LogInfo(@"Not running app upgrades on app first install!");
        return NO;
    }
    
    BOOL shouldCancelInitialization = NO;
    
    // obtain the saved integer value of the last built which was processed
    // if for example we have 1 here - it means upgrade 1 has passed successfully!
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSInteger currentlyReachedBuild = [ud integerForKey:lnLightcastAppUpgradesNSUserDefaultsSaveKey];
    
    NSInteger fromVersion = currentlyReachedBuild;
    NSInteger reachedVersion = fromVersion;
    
    LogInfo(@"Will begin processing app upgrades, currentlyReachedBuild: %d", (int)fromVersion);
    
    // set paths
    appUpgrader.documentsPath = self.documentsPath;
    appUpgrader.temporaryPath = self.temporaryPath;
    appUpgrader.resourcePath = self.resourcesPath;
    
    // inform of the status change
    [self informDelegateOfInitializationStageChange:LCInitializationStageAppUpgrades statusMessage:LightcastLocalizedString(@"Upgrading system files")];
    
    // notify delegates of the start
    if (delegate != nil)
    {
        if ([delegate respondsToSelector:@selector(willRunAppUpgrades:appUpgrader:fromVersion:)])
        {
            [delegate willRunAppUpgrades:self appUpgrader:self.appUpgrader fromVersion:fromVersion];
        }
    }
    
    BOOL res = [appUpgrader runUpgrades:fromVersion toVersion:0 reachedVersion:&reachedVersion error:&err];
    
    if (reachedVersion)
    {
        [ud setInteger:reachedVersion forKey:lnLightcastAppUpgradesNSUserDefaultsSaveKey];
        [ud synchronize];
        
        LogInfo(@"AppUpgrades stored reachedBuildNo: %d", (int)reachedVersion);
    }
    
    if (!res)
    {
        LogError(@"AppUpgrades runUpgrades failed: %@", err);
        
        lassert(false);
        
        // notify the delegate of the error
        if (delegate != nil)
        {
            if ([delegate respondsToSelector:@selector(didFailRunningAppUpgrades:appUpgrader:fromVersion:reachedVersion:error:shouldCancelInitialization:)])
            {
                [delegate didFailRunningAppUpgrades:self appUpgrader:self.appUpgrader fromVersion:fromVersion reachedVersion:reachedVersion error:err shouldCancelInitialization:&shouldCancelInitialization];
            }
        }
        
        return shouldCancelInitialization;
    }
    
    LogInfo(@"AppUpgrades have completed successfully!");
    
    // notify delegates of the end
    if (delegate != nil)
    {
        if ([delegate respondsToSelector:@selector(didFinishRunningAppUpgrades:appUpgrader:fromVersion:reachedVersion:)])
        {
            [delegate didFinishRunningAppUpgrades:self appUpgrader:self.appUpgrader fromVersion:fromVersion reachedVersion:reachedVersion];
        }
    }
    
    return shouldCancelInitialization;
}

#pragma mark -
#pragma mark Launchers

#ifdef TARGET_IOS	// iOS Target

- (void)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    LogInfo(@"LC: application didFinishLaunchingWithOptions: %@", launchOptions);
    
    // Initialize lightcast
	// Changed to not initialize when app loads - so this can be done later!
    //[self initialize:nil];
	
    // notify listeners
    NSDictionary *obj = [NSDictionary dictionaryWithObjectsAndKeys:
                         launchOptions, @"launchOptions"
                         , nil];
	// notify everyone
    [nd postNotification:[LNotification notificationWithName:lnLightcastApplicationDidFinishLaunchingWithOptions object:obj]];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    LogInfo(@"LC: application applicationWillResignActive");
    
    // notify everyone
    [nd postNotification:[LNotification notificationWithName:lnLightcastApplicationWillResignActive object:nil]];
    
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    LogInfo(@"LC: application applicationDidEnterBackground");
    
    // notify everyone
    [nd postNotification:[LNotification notificationWithName:lnLightcastApplicationDidEnterBackground object:nil]];
    
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    LogInfo(@"LC: application applicationWillEnterForeground");
    
    // notify everyone
    [nd postNotification:[LNotification notificationWithName:lnLightcastApplicationWillEnterForeground object:nil]];
    
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    LogInfo(@"LC: application applicationDidBecomeActive");
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    LogDebug(@"NSUserDefaults synchronized");
    
    // notify everyone
    [nd postNotification:[LNotification notificationWithName:lnLightcastApplicationDidBecomeActive object:nil]];
    
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    LogInfo(@"LC: application applicationWillTerminate");
    
    // notify everyone
    [nd postNotification:[LNotification notificationWithName:lnLightcastApplicationWillTerminate object:nil]];
    
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
     LogInfo(@"LC: application didRegisterForRemoteNotificationsWithDeviceToken: %@", deviceToken);
    
    // notify listeners
    NSDictionary *obj = [NSDictionary dictionaryWithObjectsAndKeys:
                         deviceToken, @"deviceToken"
                         , nil];
    // notify everyone
    [nd postNotification:[LNotification notificationWithName:lnLightcastApplicationDidRegisterForRemoteNotifications object:obj]];
    
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    LogInfo(@"LC: application didReceiveRemoteNotification: %@", userInfo);
    
    // notify listeners
    NSDictionary *obj = [NSDictionary dictionaryWithObjectsAndKeys:
                         userInfo, @"userInfo"
                         , nil];
    // notify everyone
    [nd postNotification:[LNotification notificationWithName:lnLightcastApplicationDidRegisterForRemoteNotifications object:obj]];
    
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    
    LogError(@"LC: application didFailToRegisterForRemoteNotificationsWithError: %@", error);
    
    // notify listeners
    NSDictionary *obj = [NSDictionary dictionaryWithObjectsAndKeys:
                         error, @"error"
                         , nil];
    // notify everyone
    [nd postNotification:[LNotification notificationWithName:lnLightcastApplicationDidRegisterForRemoteNotifications object:obj]];
    
}

#pragma mark - Notifications

- (void)applicationDidReceiveMemoryWarning:(NSNotification*)notification {

	LogWarn(@"Lightcast: applicationDidReceiveMemoryWarning");
	
	// notify everyone
    [nd postNotification:[LNotification notificationWithName:lnLightcastApplicationDidRegisterForRemoteNotifications object:notification.object]];
}

#endif	// end of iOS Target

#pragma mark -
#pragma mark Configuration

+ (LCAppConfiguration*)defaultConfiguration {
    LCAppConfiguration *defaultConfiguration = [[[LCAppConfiguration alloc] initWithNameAndDeepValues:LIGHTCAST_NAME
                                                                                           deepValues:
                                                 [NSDictionary dictionaryWithObjectsAndKeys:
                                                  LC_VER, @"version",
                                                  [NSDictionary dictionaryWithObjectsAndKeys:
                                                   @"LDatabaseManager", LC_LOADER_NAME_DATABASE_MANAGER,
                                                   @"LStorage",         LC_LOADER_NAME_STORAGE,
                                                   @"LPluginManager",   LC_LOADER_NAME_PLUGIN_MANAGER,
                                                   nil
                                                   ], @"loaders",
                                                  nil]] autorelease];
    
    // set the default environment paths
    defaultConfiguration.documentsPath = [[NSFileManager defaultManager] documentsPath];
    defaultConfiguration.resourcesPath = [[NSFileManager defaultManager] resourcePath];
    defaultConfiguration.temporaryPath = [[NSFileManager defaultManager] temporaryPath];
    defaultConfiguration.libraryPath = [[NSFileManager defaultManager] libraryPath];
    defaultConfiguration.cachesPath = [[NSFileManager defaultManager] cachesPath];
    
    return defaultConfiguration;
}

// TODO: Remove this - we have it now as a static method
- (LCAppConfiguration*)defaultConfiguration {
    LCAppConfiguration *defaultConfiguration = [[[LCAppConfiguration alloc] initWithNameAndDeepValues:LIGHTCAST_NAME
              deepValues:
             [NSDictionary dictionaryWithObjectsAndKeys:
              LC_VER, @"version",
              [NSDictionary dictionaryWithObjectsAndKeys:
               @"LDatabaseManager", LC_LOADER_NAME_DATABASE_MANAGER,
               @"LStorage",         LC_LOADER_NAME_STORAGE,
               @"LPluginManager",   LC_LOADER_NAME_PLUGIN_MANAGER,
               nil
               ], @"loaders",
              nil]] autorelease];
    
    // set the default environment paths
    defaultConfiguration.documentsPath = [[NSFileManager defaultManager] documentsPath];
    defaultConfiguration.resourcesPath = [[NSFileManager defaultManager] resourcePath];
    defaultConfiguration.temporaryPath = [[NSFileManager defaultManager] temporaryPath];
    defaultConfiguration.libraryPath = [[NSFileManager defaultManager] libraryPath];
    defaultConfiguration.cachesPath = [[NSFileManager defaultManager] cachesPath];
    
    return defaultConfiguration;
}

#pragma mark - Setters / Getters

- (NSString*)getResourcesPath
{
    NSString *path = configuration ? configuration.resourcesPath : nil;
    return path;
}

- (NSString*)getDocumentsPath
{
    NSString *path = configuration ? configuration.documentsPath : nil;
    return path;
}

- (NSString*)getTemporaryPath
{
    NSString *path = configuration ? configuration.temporaryPath : nil;
    return path;
}

#pragma mark -
#pragma mark LDatabaseManagerDelegate

- (void)adapterConnected:(id<LDatabaseAdapterProtocol>)anAdapter {
    
    LogInfo(@"LC:adapterConnected");
}

- (void)adapterDisconnected:(id<LDatabaseAdapterProtocol>)anAdapter {
    
    LogInfo(@"LC:adapterDisconnected");
    
}

- (void)errorInitializingAdapter:(id<LDatabaseAdapterProtocol>)anAdapter error:(NSError*)error {
    
    LogError(@"LC:errorInitializingAdapter: %@", error);
    
}

#pragma mark -
#pragma mark Other

+ (NSArray*)systemReservedNSKeys
{
    NSArray *keys = [NSArray arrayWithObjects:
                     lnLightcastAppUpgradesNSUserDefaultsSaveKey
                     , nil];
    return keys;
}

- (id)getPluginManager_ {
    return [systemObjects objectForKey:LC_LOADER_NAME_PLUGIN_MANAGER];
}

- (id)getDatabaseManager_ {
    return [systemObjects objectForKey:LC_LOADER_NAME_DATABASE_MANAGER];
}

- (id)getStorage_ {
    return [systemObjects objectForKey:LC_LOADER_NAME_STORAGE];
}

#pragma mark - Logging

+ (NSString*)defaultPathForLogs
{
    NSString *appCachesPath = [[[NSFileManager defaultManager] cachesPath] stringByAppendingPathComponent:[LApplicationUtils bundleIdentifier]];
    NSString *logFolderName = [appCachesPath stringByAppendingPathComponent:@"Logs"];
    return logFolderName;
}

- (NSString *)getLogFilesContentWithMaxSize:(NSInteger)maxSize
{
    NSMutableString *description = [NSMutableString string];
    
    NSArray *sortedLogFileInfos = [[_fileLogger logFileManager] sortedLogFileInfos];
    NSInteger count = [sortedLogFileInfos count];
    
    // we start from the last one
    for (NSInteger index = count - 1; index >= 0; index--)
    {
        DDLogFileInfo *logFileInfo = [sortedLogFileInfos objectAtIndex:index];
        
        // skip archived files
        if (logFileInfo.isArchived)
        {
            continue;
        }
        
        NSData *logData = [[NSFileManager defaultManager] contentsAtPath:[logFileInfo filePath]];
        
        if ([logData length] > 0)
        {
            NSString *result = [[NSString alloc] initWithBytes:[logData bytes]
                                                        length:[logData length]
                                                      encoding: NSUTF8StringEncoding];
            
            [description appendString:result];
            [result release];
        }
    }
    
    if ([description length] > maxSize)
    {
        description = (NSMutableString *)[description substringWithRange:NSMakeRange([description length]-maxSize-1, maxSize)];
    }
    
    return description;
}

#pragma mark - Singleton Pattern

+ (LC*)sharedLC {
	@synchronized(self)
    {
        if (sharedLC == nil) 
        {
            sharedLC = [[super alloc] init];
        }
    }
    return sharedLC;
}

+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self)
    {
        if (sharedLC == nil)
        {
            sharedLC = [super allocWithZone:zone];
            return sharedLC;  // assignment and return on first allocation
        }
    }
    return nil; //on subsequent allocation attempts return nil
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (id)retain {
    return self;
}

- (NSUInteger)retainCount {
    return NSUIntegerMax;
}

- (oneway void)release {
    //do nothing
}

- (id)autorelease {
    return self;
}

@end
