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
 * @changed $Id: LPluginManager.m 348 2014-10-18 20:59:25Z mkovachev $
 * @author $Author: mkovachev $
 * @version $Revision: 348 $
 */

#import "LPluginManager.h"
#import "LVersionComparator.h"
#import "LC.h"

NSString *const lnPluginManagerInitialized = @"notifications.PluginManagerInitialized";

@interface LPluginManager(Private)

- (BOOL)upgradePluginDbSchema:(LPlugin*)plugin schemaInstance:(id<LDatabaseSchemaProtocol>)schemaInstance error:(NSError**)error;

@end

@implementation LPluginManager {
    
    NSMutableDictionary * plugins;
    LDatabaseManager *db;
}

@synthesize
plugins,
delegate,
count;

#pragma mark -
#pragma mark Initialization / Finalization

- (id)init {
    self = [super init];
    if (self)
    {
        plugins = [[NSMutableDictionary alloc] init];
        db = nil;
    }
    return self;
}

- (void)dealloc {
    L_RELEASE(plugins);
    L_RELEASE(db);
    [super dealloc];
}

#pragma mark -
#pragma mark LPluginManager delegate

- (BOOL)upgradePluginDbSchema:(LPlugin*)plugin schemaInstance:(id<LDatabaseSchemaProtocol>)schemaInstance error:(NSError**)error {
    
    LogInfo(@"Upgrading plugin database schema");
 
    @try 
	{
		NSString *schemaIdentifier = schemaInstance.identifier;
		LDatabaseSchema *schemaUpgrader = [[LDatabaseSchema alloc] initWithAdapter:db.mainAdapter identifier:schemaIdentifier];
		
		@try 
		{
			// this is to force schema upgrader to save the last version or to run all upgrades from 1 > N for old and existing databases
			schemaUpgrader.firstDatabaseInit = NO;
			
			if (!schemaUpgrader)
			{
				if (error != NULL)
				{
					NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
					[errorDetail setValue:LightcastLocalizedString(@"Schema upgrader cannot be initialized") forKey:NSLocalizedDescriptionKey];
					*error = [NSError errorWithDomain:LERR_DOMAIN_DB code:LERR_DB_CANT_INIT_APP_DATABASE_INSTANCE userInfo:errorDetail];
				}
				
				return NO;
			}
			
			BOOL upgradeRan = [schemaUpgrader upgradeSchema:schemaInstance error:error];
			
			if (!upgradeRan)
			{
				LogError(@"Schema upgrader error: %@", *error);
				
				return NO;
			}
		}
		@finally 
		{
			L_RELEASE(schemaUpgrader);
		}
		
		LogInfo(@"Plugin database schema upgrade complete");
	}
	@catch (NSException *e) 
	{
		LogError(@"Error upgrading plugin database schema: %@", e);
		return NO;
	}
	
	return YES;
}

#pragma mark - 
#pragma mark LSystemObject derived

- (BOOL)initialize:(LCAppConfiguration*)aConfiguration notificationDispatcher:(LNotificationDispatcher*)aDispatcher error:(NSError**)error {
    
    if (![super initialize:aConfiguration notificationDispatcher:aDispatcher error:error]) return NO;
    
    db = [[LC sharedLC].db retain];
    
    // notify everyone
    [self.dispatcher postNotification:[LNotification notificationWithName:lnPluginManagerInitialized object:self]];
    
    return YES;
}

#pragma mark - Inherited from LSystemObject

- (void)didReceiveMemoryWarning:(NSDictionary*)additionalInformation {
	[super didReceiveMemoryWarning:additionalInformation];
	
	// alert each plugin
	if (plugins)
	{
		for(LPlugin *plugin in plugins)
		{
			if ([plugin conformsToProtocol:@protocol(LPluginBehaviour)])
			{
				if ([plugin respondsToSelector:@selector(didReceiveMemoryWarning:)])
				{
					[plugin didReceiveMemoryWarning:additionalInformation];
				}
			}
		}
	}
}

#pragma mark - 
#pragma mark Other

- (NSInteger)getPluginsCount {
    return [plugins count];
}

#pragma mark -
#pragma mark Plugin Operations

- (BOOL)loadPlugins:(NSArray*)pluginNames errors:(NSArray **)errors {
    
    NSMutableArray * arr = [[NSMutableArray alloc] init];
    
    BOOL ok = YES;
    
    @try 
    {
        for(NSString* plName in pluginNames)
        {
            NSError * err = nil;
            BOOL res = [self loadPlugin:plName error:&err];
            
            if (!res)
            {
                ok = NO;
                
                if (err)
                {
                  [arr addObject:err];  
                }
            }
        }
    }
    @finally 
    {
        arr = [arr autorelease];
        
        if (arr)
        {
           *errors = arr;  
        }
    }
    
    return ok;
}

- (BOOL)loadPlugin:(NSString*)pluginName configuration:(LConfiguration*)aConfiguration error:(NSError **)error {
    if ([self isPluginLoaded:pluginName]) return YES;
    
    BOOL res = NO;
    
    @try 
    {
        LPlugin *plugin = [LPlugin pluginFactory:pluginName];
        
        // cant find plugin
        if (!plugin)
        {
            if (error != NULL)
			{
				NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
				[errorDetail setValue:[NSString stringWithFormat:@"%@ %@", LightcastLocalizedString(@"Could not find plugin:"), pluginName] forKey:NSLocalizedDescriptionKey];
				*error = [NSError errorWithDomain:LERR_DOMAIN_PLUGINS code:LERR_PLUGINS_CANT_LOAD userInfo:errorDetail];
			}
            
            // inform the delegate
            if([self.delegate respondsToSelector:@selector(errorLoadingPlugin::)])
            {
                [self.delegate errorLoadingPlugin:pluginName error:*error];
            }
            
            return NO;
        }
        
        // check the plugin's dependancies
        BOOL reqMet = [self pluginMeetsRequirements:plugin error:error];
        
        if (!reqMet)
        {
            // inform the delegate
            if([self.delegate respondsToSelector:@selector(errorLoadingPlugin::)])
            {
                [self.delegate errorLoadingPlugin:pluginName error:*error];
            }
            
            return NO;
        }
        
        // run schema updates
		if ([plugin respondsToSelector:@selector(databaseSchemaInstance)])
		{
			id schemaInstance = [plugin databaseSchemaInstance];
			
			if (schemaInstance)
            {
                BOOL res = [self upgradePluginDbSchema:(LPlugin*)plugin schemaInstance:schemaInstance error:error];
                
                if (!res)
                {
                    return NO;
                }
            }
		}
      
        // inform the delegate
        if([self.delegate respondsToSelector:@selector(pluginLoaded:)])
        {
            [self.delegate pluginLoaded:plugin];
        }
        
        // initialize it
        NSError * pluginError = nil;
        //BOOL initialized = [plugin initialize:[self.configuration subnodeWithName:@"plugins"] notificationDispatcher:self.dispatcher error:&pluginError]; was
        
        aConfiguration = aConfiguration ? aConfiguration : [plugin defaultConfiguration];
        BOOL initialized = [plugin initialize:aConfiguration notificationDispatcher:self.dispatcher error:&pluginError];
        
        if (!initialized)
        {
            // inform the delegate
            if([self.delegate respondsToSelector:@selector(errorLoadingPlugin::)])
            {
                [self.delegate errorLoadingPlugin:pluginName error:pluginError];
            }
            
            return NO;
        }
        
        [plugins setObject:plugin forKey:pluginName];
        
        LogInfo(LightcastLocalizedString(@"Plugin %@ initialized"), pluginName);
        
        // inform the delegate
        if([self.delegate respondsToSelector:@selector(pluginInitialized:)])
        {
            [self.delegate pluginInitialized:plugin];
        }
        
        res = YES;
    }
    @catch (NSException * e) 
    {
        if (error != NULL)
		{
			NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
			[errorDetail setValue:[NSString stringWithFormat:LightcastLocalizedString(@"Plugin could not be initialized properly, error: %@"), [e description]] forKey:NSLocalizedDescriptionKey];
			*error = [NSError errorWithDomain:LERR_DOMAIN_PLUGINS code:LERR_PLUGINS_CANT_INITIALIZE userInfo:errorDetail];
		}
        
        // inform the delegate
        if([self.delegate respondsToSelector:@selector(errorLoadingPlugin::)])
        {
            [self.delegate errorLoadingPlugin:pluginName error:*error];
        }
        
        return NO;
    }
    
    return res;
}

- (BOOL)loadPlugin:(NSString*)pluginName error:(NSError **)error {
    return [self loadPlugin:pluginName configuration:nil error:error];
}

- (BOOL)pluginExists:(NSString*)pluginName {
    return [LPlugin pluginExists:pluginName];
}

- (BOOL)isPluginLoaded:(NSString*)pluginName {
    return [plugins objectForKey:pluginName] ? YES : NO;
}

- (LPlugin*)plugin:(NSString *)pluginName {
    return [plugins objectForKey:pluginName];
}

- (BOOL)pluginMeetsRequirements:(LPlugin*)plugin error:(NSError**)error; {
    
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    
    @try 
    {
        // plugin does not have any dependancies
        if(![plugin respondsToSelector:@selector(checkPluginRequirements: maxLightcastVer: pluginRequirements:)])
        {
            return YES;
        }
        
        NSString * minLightcastVer = nil;
        NSString * maxLightcastVer = nil;
        NSArray * pluginRequirements = nil;
        
        NSInteger currentLightcastVersion = [LVersionComparator strVerToIntVer:LC_VER];
        
        BOOL doCheck = [plugin checkPluginRequirements:&minLightcastVer maxLightcastVer:&maxLightcastVer pluginRequirements:&pluginRequirements];
        
        // plugin does not want us to verify this
        if (!doCheck)
        {
            return YES;
        }
        
        // validate lightcast version
        NSInteger tmpMin = [LVersionComparator strVerToIntVer:minLightcastVer];
        NSInteger tmpMax = [LVersionComparator strVerToIntVer:maxLightcastVer];
        
        if ((minLightcastVer && currentLightcastVersion < tmpMin) ||
            (maxLightcastVer && currentLightcastVersion > tmpMax))
        {
            if (error != NULL)
			{
				NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
				NSString * errStr = [NSString stringWithFormat:LightcastLocalizedString(@"Lightcast version does not meet the plugin's requirements (%@), min: %@, max: %@, current: %@ "),
									 plugin.pluginName, minLightcastVer, maxLightcastVer, LC_VER];
				[errorDetail setValue:errStr forKey:NSLocalizedDescriptionKey];
				*error = [NSError errorWithDomain:LERR_DOMAIN_PLUGINS code:LERR_PLUGINS_REQUIREMENTS_NOT_MET userInfo:errorDetail]; 
			}
			
            return NO;
        }
        
        // validate dependant plugins and their versions
        NSMutableArray * mar = [[NSMutableArray alloc] init];
        
        // name
        // min
        // max
        
        @try 
        {
            if (pluginRequirements)
            {
                for (NSDictionary * pluginReq in pluginRequirements)
                {
                    if (![pluginReq isKindOfClass:[NSDictionary class]])
                    {
                        LogWarn(@"Incorrect plugin requirement definition for plugin: %@", plugin.pluginName);
                        continue;
                    }
                    
                    NSString * pName = [pluginReq objectForKey:@"name"];
                    NSString * pMin = [pluginReq objectForKey:@"min"];
                    NSString * pMax = [pluginReq objectForKey:@"max"];
                    
                    if (!pName || ![pName length] || [pName isEqualToString:plugin.pluginName])
                    {
                        LogWarn(@"Incorrect plugin requirement definition for plugin: %@", plugin.pluginName);
                        continue;
                    }
                    
                    LPlugin* pl = [plugins objectForKey:pName];
                    
                    // not loaded
                    if (!pl)
                    {
                        [mar addObject:pName];
                        break;
                    }
                    
                    NSString * plVersion = pl.version;
                    
                    // min ver
                    if (pMin)
                    {
                        LVersionComparismentResult res1 = [LVersionComparator compareVersion:plVersion to:pMin];
                        
                        if ((res1 != lVersionHigher) && (res1 != lVersionEqual))
                        {
                            [mar addObject:pName];
                            break;
                        }
                    }
                    
                    // max ver
                    if (pMax)
                    {
                        LVersionComparismentResult res1 = [LVersionComparator compareVersion:plVersion to:pMax];
                        
                        if ((res1 != lVersionLower) && (res1 != lVersionEqual))
                        {
                            [mar addObject:pName];
                            break;
                        }
                    }
                }
            }
            
            // plugin deps errors
            if ([mar count])
            {
                if (error != NULL)
				{
					NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
					NSString * errStr = [NSString stringWithFormat:LightcastLocalizedString(@"Dependant plugins missing - for plugin (%@): %@ "),
										 plugin.pluginName, mar];
					[errorDetail setValue:errStr forKey:NSLocalizedDescriptionKey];
					*error = [NSError errorWithDomain:LERR_DOMAIN_PLUGINS code:LERR_PLUGINS_REQUIREMENTS_NOT_MET userInfo:errorDetail]; 
				}
				
                return NO;
            }
        }
        @finally 
        {
            [mar release];
        }
    }
    @finally 
    {
        [pool drain];
    }
    
    return YES;
}

@end
