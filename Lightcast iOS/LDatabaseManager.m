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
 * @changed $Id: LDatabaseManager.m 346 2014-10-08 12:54:30Z mkovachev $
 * @author $Author: mkovachev $
 * @version $Revision: 346 $
 */

#import "LDatabaseManager.h"
#import "GeneralUtils.h"
#import "LDatabaseSchema.h"
#import "LNullDatabaseAdapter.h"
#import "LSQLiteDatabaseAdapter.h"
#import "SQLParser.h"
#import "NSString+Additions.h"

NSString *const lnDatabaseManagerInitialized = @"notifications.DatabaseManagerInitialized";

@interface LDatabaseManager(Private) 

- (NSString *)copyDatabaseToDocuments:(NSString *)dbInResourcePath error:(NSError**)error;

@end;

@implementation LDatabaseManager

@synthesize
mainAdapter=_mainAdapter;

#pragma mark - Initialization / Finalization

- (id)init {
    self = [super init];
	if (self)
	{
		_mainAdapter = nil;
		_appDatabaseInstances = [[NSMutableArray alloc] init];
		_adapters = [[NSMutableDictionary alloc] init];
	}
	return self;
}

- (void)dealloc {
    
	// shutdown all live adapters
	for(NSString *adapterIdentifier in _adapters)
	{
		LDatabaseAdapter *adapter = [_adapters objectForKey:adapterIdentifier];
		
		[self shutdownAdapter:adapter];
	}
    
	L_RELEASE(_appDatabaseInstances);
	L_RELEASE(_adapters);
	L_RELEASE(_mainAdapter);
	
	[super dealloc];
}

#pragma mark - LSystemObject derived

- (BOOL)initialize:(LConfiguration*)aConfiguration notificationDispatcher:(LNotificationDispatcher*)aDispatcher error:(NSError**)error {
    
    if (![super initialize:aConfiguration notificationDispatcher:aDispatcher error:error])
    {
        return NO;
    }
    
    LConfiguration *dbConfig = [self.configuration subnodeWithName:@"database_manager"];
    
    if (dbConfig)
    {
        // load and connect the primary database specified in the configuration
        BOOL useDatabase = [[dbConfig get:@"useDatabase"] boolValue];
        
        if (useDatabase)
        {
            NSString *primaryDBIdentifier = [dbConfig get:@"primary_adapter"];
            
            if (primaryDBIdentifier && ![primaryDBIdentifier isEqual:[NSNull null]])
            {
                LogDebug(@"Primary db to be initialized: %@", primaryDBIdentifier);
                
                // try to find it
                NSArray *adapters = [dbConfig get:@"adapters"];
                
                if (adapters && ![adapters isEqual:[NSNull null]] && [adapters count])
                {
                    LogDebug(@"Found %d adapters in configuration", (int)[adapters count]);
                    
                    for(NSDictionary *adapterInfo in adapters)
                    {
                        NSString *adapterIdentifier = [adapterInfo objectForKey:@"identifier"];
                        
                        if (adapterIdentifier && [adapterIdentifier isEqualToString:primaryDBIdentifier])
                        {
                            // found it
                            LogInfo(@"Found the primary adapter %@, will try to load it: %@", primaryDBIdentifier, adapterInfo);
                            
                            NSString *adapterName = [dbConfig get:@"adapter"];
                            NSString *connectionString = [dbConfig get:@"connectionString"];
                            
                            if (adapterName && ![adapterName isEqual:[NSNull null]])
                            {
                                LDatabaseAdapter *primaryAdapter = [LDatabaseAdapter adapterFactory:adapterName connectionString:connectionString];
                                
                                if (primaryAdapter)
                                {
                                    BOOL hasInitialized = [self initializeAdapter:primaryAdapter identifier:primaryDBIdentifier connectionString:connectionString error:error];
                                    
                                    if (!hasInitialized)
                                    {
                                        return NO;
                                    }
                                }
                            }
                            
                            break;
                        }
                    }
                }
                
            }
        }
    }
    
    // notify everyone
    [self.dispatcher postNotification:[LNotification notificationWithName:lnDatabaseManagerInitialized object:self]];
    
    return YES;
}

#pragma mark - Configuration

- (LConfiguration*)defaultConfiguration {
    return [[[LConfiguration alloc] initWithNameAndDeepValues:@"database_manager"
                                                   deepValues:
             [NSDictionary dictionaryWithObjectsAndKeys:
              [NSNumber numberWithBool:NO], @"useDatabase", /* if NO - no adapter will be initialized at startup - even if defined below */
			  [NSNull null], @"primary_adapter", /* identifier of the primary adapter which must be initialized upon startup */
			  [NSArray arrayWithObjects:	/* an array of database adapters */
			   [NSDictionary dictionaryWithObjectsAndKeys:	/* null database adapter - does nothing */
				@"Null", @"adapter",	/* the adapter's name for the class factory */
				@"", @"connectionString", /* connection string */
				@"", @"identifier", /* identifier */
				nil],
			   nil], @"adapters",
              nil]] autorelease];
}

#pragma mark - Database Adapters Initialization / Management

- (BOOL)initializeAdapter:(LDatabaseAdapter*)adapter identifier:(NSString*)identifier connectionString:(NSString*)connectionString error:(NSError **)error {
    
    @synchronized(self)
	{
		@try 
		{
			if (![adapter connect:connectionString error:error])
			{
				return NO;
			}
			
			// check if not already existing
			if ([_adapters objectForKey:identifier])
			{
				if (error != NULL)
				{
					NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
					NSString *errStr = [NSString stringWithFormat:LightcastLocalizedString(@"Database adapter with the same identifier (%@) already initialized"), identifier];
					[errorDetail setValue:errStr forKey:NSLocalizedDescriptionKey];
					*error = [NSError errorWithDomain:LERR_DOMAIN_DB code:LERR_DB_CANT_INIT_ADAPTER userInfo:errorDetail];
				}
				
				return NO;
			}
			
			// add it to all adapters
			[_adapters setObject:adapter forKey:identifier];
			
			LogInfo(@"Database adapter with identifier: %@ initialized", identifier);
			
			// make it primary if no adapters exist prior this one
			if ([_adapters count] <= 1)
			{
				if (_mainAdapter != adapter)
				{
					L_RELEASE(_mainAdapter);
					_mainAdapter = [adapter retain];
					
					LogInfo(@"Main database adapter with identifier: %@ set", identifier);
				}
			}
		}
		@catch (NSException *e) 
		{
			LogError(@"Error while trying to initialize db adapter: %@", e);
			return NO;
		}
		
		return YES;
	}
}

- (void)disconnectAllAdapters {
	
	LogInfo(@"DatabaseManager: Disconnect All Adapters");
	
	for (NSString *adapterIdentifier in _adapters)
	{
		[[_adapters objectForKey:adapterIdentifier] disconnect];
	}
}

- (void)shutdownAdapterWithIdentifier:(NSString*)identifier {
	
	for (NSString *adapterIdentifier in _adapters)
	{
		if ([adapterIdentifier isEqualToString:identifier])
		{
			[self shutdownAdapter:[_adapters objectForKey:adapterIdentifier]];
			break;
		}
	}
}

- (void)shutdownAdapter:(LDatabaseAdapter<LDatabaseAdapterProtocol>*)adapter {
	
	@synchronized(self)
	{
		LogInfo(@"Shutdown db adapter: %@", adapter);
		
		LDatabaseAdapter *foundAdapter = nil;
		NSString *foundIdentifier = nil;
		
		// try to find it
		for(NSString *adapterIdentifer in _adapters)
		{
			LDatabaseAdapter *obj = [_adapters objectForKey:adapterIdentifer];
			foundIdentifier = adapterIdentifer;
			
			if ([obj isEqual:adapter])
			{
				foundAdapter = obj;
				
				break;
			}
		}
		
		if (!foundAdapter)
		{
			LogError(@"DB Adapter not found");
			return;
		}
		
		// disconnect
		@try 
		{
			[foundAdapter disconnect];
		}
		@catch (NSException *e) 
		{
			LogError(@"Error while trying to shutdown adapter %@", foundAdapter);
		}
		
		// remove from holder and main db var if it is the main db
		[_adapters removeObjectForKey:foundIdentifier];
		
		LogInfo(@"DB Adapter shutdown");
		
		if ([_mainAdapter isEqual:foundAdapter])
		{
			L_RELEASE(_mainAdapter);
			
			LogInfo(@"Main db adapter shutdown");
		}
	}
}

- (LDatabaseAdapter*)adapterWithIdentifier:(NSString*)adapterIdentifier {
	
	for (NSString *identifier in _adapters)
	{
		if ([identifier isEqualToString:adapterIdentifier])
		{
			LDatabaseAdapter *adapter = [_adapters objectForKey:identifier];
			
			return adapter;
		}
	}
	
	return nil;
}

#pragma mark - AppDatabaseInstances methods

- (BOOL)initializeAppDatabaseInstance:(id<LAppDatabaseInstance>)databaseInstanceObject error:(NSError**)error {
	return [self initializeAppDatabaseInstance:databaseInstanceObject databaseAdapter:nil error:error];
}

- (BOOL)initializeAppDatabaseInstance:(id<LAppDatabaseInstance>)databaseInstanceObject databaseAdapter:(LDatabaseAdapter*)databaseAdapter error:(NSError**)error
{	
	LDatabaseAdapter *adapter = databaseAdapter;
    
    @try
    {
        // set resource params
        if ([databaseInstanceObject respondsToSelector:@selector(setConfiguration:)])
        {
            [databaseInstanceObject setConfiguration:configuration];
        }
        
        // check if has already been initialized
        if ([_appDatabaseInstances indexOfObject:databaseInstanceObject] != NSNotFound)
        {
            if (error != NULL)
            {
                NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
                NSString *errStr = [NSString stringWithFormat:LightcastLocalizedString(@"AppDatabaseInstance with identifier: (%@) already initialized"), databaseInstanceObject.identifier];
                [errorDetail setValue:errStr forKey:NSLocalizedDescriptionKey];
                *error = [NSError errorWithDomain:LERR_DOMAIN_DB code:LERR_DB_CANT_INIT_APP_DATABASE_INSTANCE userInfo:errorDetail];
            }
            
            return NO;
        }
        
        // check the required fields
        if (!databaseInstanceObject.identifier || [databaseInstanceObject.identifier isEqual:[NSNull null]] ||
            !databaseInstanceObject.adapterType || [databaseInstanceObject.adapterType isEqual:[NSNull null]] ||
            !databaseInstanceObject.dbURL || [databaseInstanceObject.dbURL isEqual:[NSNull null]])
        {
            if (error != NULL)
            {
                NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
                NSString *errStr = [NSString stringWithFormat:LightcastLocalizedString(@"AppDatabaseInstance with identifier: (%@) cannot be initialized - invalid arguments supplied"), databaseInstanceObject.identifier, databaseInstanceObject.adapterType];
                [errorDetail setValue:errStr forKey:NSLocalizedDescriptionKey];
                *error = [NSError errorWithDomain:LERR_DOMAIN_DB code:LERR_DB_CANT_INIT_APP_DATABASE_INSTANCE userInfo:errorDetail];
            }
            
            return NO;
        }
        
        // check if there is an adapter initialized with the same name
        for(NSString *adapterIdentifier in _adapters)
        {
            if ([adapterIdentifier isEqualToString:databaseInstanceObject.identifier])
            {
                if (error != NULL)
                {
                    NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
                    NSString *errStr = [NSString stringWithFormat:LightcastLocalizedString(@"AppDatabaseInstance with identifier: (%@) cannot be initialized - there is an active adapter with the same identifier"), databaseInstanceObject.identifier];
                    [errorDetail setValue:errStr forKey:NSLocalizedDescriptionKey];
                    *error = [NSError errorWithDomain:LERR_DOMAIN_DB code:LERR_DB_CANT_INIT_APP_DATABASE_INSTANCE userInfo:errorDetail];
                }
                
                return NO;
                
                break;
            }
        }
        
        // check if the adapter type specified by the instance is valid and exists
        BOOL adapterExists = [LDatabaseAdapter adapterExists:databaseInstanceObject.adapterType];
        
        if (!adapterExists)
        {
            if (error != NULL)
            {
                NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
                NSString *errStr = [NSString stringWithFormat:LightcastLocalizedString(@"AppDatabaseInstance with identifier: (%@) cannot be initialized - adapter with type: %@ does not exist"), databaseInstanceObject.identifier, databaseInstanceObject.adapterType];
                [errorDetail setValue:errStr forKey:NSLocalizedDescriptionKey];
                *error = [NSError errorWithDomain:LERR_DOMAIN_DB code:LERR_DB_CANT_INIT_APP_DATABASE_INSTANCE userInfo:errorDetail];
            }
            
            return NO;
        }
        
        NSFileManager *fm = [NSFileManager defaultManager];
        
        // check if the target database already exists - if yes - skip recreating it
        NSURL *targetDbURL = databaseInstanceObject.dbURL;
        
        // marker which tells us if this is the first time the database is being initialized
        BOOL firstInit = NO;
        
        adapter = nil;
        
        // when importing from .sql file
        NSArray *sqlExecFileStatements = nil;
        
        @try
        {
            if (![fm fileExistsAtPath:[targetDbURL path]])
            {
                LogInfo(@"Target database not found - will try to initialize for the first time!");
                
                firstInit = YES;
                
                // target database does not exist
                // - if there is an assigned template database to copy from - copy from it - otherwise - create a blank database
                // - run the initial preloaded SQL specified by the Instance
                
                // create the folder in which the db should reside
                NSURL *cutDownURL = [targetDbURL URLByDeletingLastPathComponent];
                NSString *dirPath = [[cutDownURL pathComponents] componentsJoinedByString:@"/"];
                
                BOOL mkdir = [fm createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:error];
                
                if (!mkdir)
                {
                    return NO;
                }
                
                // copy the source to the target if source is set
                if ([databaseInstanceObject respondsToSelector:@selector(initialTemplateURL)])
                {
                    NSURL *sourceURL = [databaseInstanceObject initialTemplateURL];
                    
                    if (sourceURL)
                    {
                        // if set - but does not exist - this is an error
                        if (![fm fileExistsAtPath:[sourceURL path]])
                        {
                            if (error != NULL)
                            {
                                NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
                                NSString *errStr = [NSString stringWithFormat:LightcastLocalizedString(@"AppDatabaseInstance with identifier: (%@) cannot be initialized - source template database specified: %@ - but does not exist"), databaseInstanceObject.identifier, sourceURL];
                                [errorDetail setValue:errStr forKey:NSLocalizedDescriptionKey];
                                *error = [NSError errorWithDomain:LERR_DOMAIN_DB code:LERR_DB_CANT_INIT_APP_DATABASE_INSTANCE userInfo:errorDetail];
                            }
                            
                            return NO;
                        }
                        
                        // check if the extension is .sql - in this case - parse and run it after the adapter inits
                        if ([[sourceURL pathExtension] isEqualToString:@"sql"])
                        {
                            // INIT SQL COMMANDS FROM SQL FILE
                            LogInfo(@"Will create database from .sql statements file");
                            
                            SQLParser *parser = [[SQLParser alloc] initWithContentsOfFile:[sourceURL path]];
                            
                            if (!parser)
                            {
                                if (error != NULL)
                                {
                                    NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
                                    [errorDetail setValue:LightcastLocalizedString(@"Cannot initialize SQL parser") forKey:NSLocalizedDescriptionKey];
                                    *error = [NSError errorWithDomain:LERR_DOMAIN_DB code:LERR_DB_CANT_INIT_APP_DATABASE_INSTANCE userInfo:errorDetail];
                                }
                                
                                return NO;
                            }
                            
                            @try
                            {
                                sqlExecFileStatements = parser.sqlItems;
                            }
                            @finally
                            {
                                [parser release];
                            }
                            
                        } else
                        {
                            //// NORMAL COPY TEMPLATE DATABASE
                            LogInfo(@"Will copy a database template into live one");
                            
                            // copy now
                            BOOL copyOperation = [fm copyItemAtURL:sourceURL toURL:targetDbURL error:error];
                            
                            if (!copyOperation)
                            {
                                return NO;
                            }
                        }
                    }
                }
            }
            
            // initialize the adapter
            adapter = [LDatabaseAdapter adapterFactory:databaseInstanceObject.adapterType connectionString:databaseInstanceObject.connectionString];
            
            BOOL adapterInit = [self initializeAdapter:adapter identifier:databaseInstanceObject.identifier
                                      connectionString:databaseInstanceObject.connectionString error:error];
            
            if (!adapterInit)
            {
                [NSException raise:@"internal" format:@":) smile and be happy"];
            }
            
            // run the .sql create statements if database is being loaded from .sql
            if (sqlExecFileStatements && [sqlExecFileStatements count])
            {
                LogInfo(@"Executing initial SQL statements: %d", (int)[sqlExecFileStatements count]);
                
                for(NSString *sql in sqlExecFileStatements)
                {
                    if (!sql || [sql isEqual:[NSNull null]] || ![[sql trim] length]) continue;
                    
                    LogInfo(@"SQL: %@", sql);
                    
                    BOOL res = [adapter executeStatement:error sql:sql];
                    
                    if (!res)
                    {
                        LogError(@"Error running query: %@", *error);
                        [NSException raise:@"internal" format:@":) smile and be happy"];
                    }
                }
            }
            
            // run the initial sql statements if specified by Instance
            if ([databaseInstanceObject respondsToSelector:@selector(initializationSQLStatements)])
            {
                NSArray *preloadedSQL = [databaseInstanceObject initializationSQLStatements];
                
                if (preloadedSQL && [preloadedSQL count])
                {
                    LogInfo(@"Executing preloaded SQL statements: %d", (int)[preloadedSQL count]);
                    
                    for(NSString *sql in preloadedSQL)
                    {
                        if (!sql || [sql isEqual:[NSNull null]] || ![[sql trim] length]) continue;
                        
                        LogInfo(@"SQL: %@", sql);
                        
                        BOOL res = [adapter executeStatement:error sql:sql];
                        
                        if (!res)
                        {
                            LogError(@"Error running query: %@", *error);
                            [NSException raise:@"internal" format:@":) smile and be happy"];
                        }
                    }
                }
            }
            
            LogInfo(@"First time database init - successful!");
        }
        @catch (NSException *e)
        {
            // there was an error while initializing the adapter
            // if it was a first time init - cleanup!
            LogError(@"Error while trying to initialize AppDatabaseInstance: %@", e);
            
            if (firstInit)
            {
                LogWarn(@"Error occured while initializing database - will cleanup...");
                
                [fm removeItemAtURL:targetDbURL error:error];
            }
            
            return NO;
        }
        
        // schema upgrades
        
        // make a backup of the database before these operations
        NSURL *backupfileURL = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@~", [targetDbURL path]]];
        
        LogInfo(@"Starting database schema upgrade...");
        
        LogInfo(@"Will backup the database to %@", backupfileURL);
        
        // remove stale copies before that
        [fm removeItemAtURL:backupfileURL error:nil];
        
        // backup it now
        BOOL copyRes = [fm copyItemAtURL:targetDbURL toURL:backupfileURL error:error];
        
        if (!copyRes)
        {
            return NO;
        }
        
        // set adapter to databaseInstanceObject
        if ([databaseInstanceObject respondsToSelector:@selector(setDatabaseAdapter:)])
        {
            [databaseInstanceObject setDatabaseAdapter:adapter];
        }
        
        // in case of a hard error - we will restore the db from the backup
        @try 
        {
            NSString *schemaIdentifier = databaseInstanceObject.identifier;
            LDatabaseSchema *schemaUpgrader = [[LDatabaseSchema alloc] initWithAdapter:adapter identifier:schemaIdentifier];
            
            @try 
            {
                // this is to force schema upgrader to save the last version or to run all upgrades from 1 > N for old and existing databases
                schemaUpgrader.firstDatabaseInit = firstInit;
                
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
                
                BOOL upgradeRan = [schemaUpgrader upgradeSchema:databaseInstanceObject error:error];
                
                if (!upgradeRan)
                {
                    LogError(@"Schema upgrader error: %@", *error);
                    
                    // this will restore from backup in the exception handler block below
                    [NSException raise:@"internal" format:@":) smile and be happy"];
                }
            }
            @finally 
            {
                L_RELEASE(schemaUpgrader);
            }
        }
        @catch (NSException *e) 
        {
            LogError(@"Error while upgrading database schema - will restore from the backup...");
            
            // disconnect adapter
            [self shutdownAdapter:adapter];
            
            // remove the current potentialy broken copy
            [fm removeItemAtURL:targetDbURL error:nil];
            
            // copy from backup to the original location
            BOOL copyRes = [fm copyItemAtURL:backupfileURL toURL:targetDbURL error:error];
            
            // bad if this happens
            if (!copyRes)
            {
                if (error != NULL)
                {
                    NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
                    [errorDetail setValue:LightcastLocalizedString(@"Error while trying to restore the database from the backup - backup the application and contact support!") forKey:NSLocalizedDescriptionKey];
                    *error = [NSError errorWithDomain:LERR_DOMAIN_DB code:LERR_DB_CANT_INIT_APP_DATABASE_INSTANCE userInfo:errorDetail];
                }
                
                return NO;
            }
            
            LogInfo(@"Database has been restored from the backup!");
            
            return NO;
        }
        
        LogInfo(@"Schema upgrade complete");
    }
    @catch (NSException *e) 
    {
        LogError(@"Error while trying to initialize AppDatabaseInstance: %@", e);
        
        return NO;
    }
    
    return YES;
}

#pragma mark - PrimaryAdapter: Quick shortcuts to the main adapter

- (NSArray *)executeQuery:(NSString *)sql, ... {
    
	if (!_mainAdapter) 
	{
		return [NSArray array];
	}
	
	NSArray *res = [_mainAdapter executeQuery:sql];
	
	if (!res)
	{
		return [NSArray array];
	}
	
	return res;
}

- (BOOL)executeSql:(NSString *)sql, ... {
    return [self executeStatement:sql];
}

- (BOOL)exec:(NSString *)sql, ... {
    return [self executeStatement:sql];
}

- (BOOL)executeStatement:(NSError**)error sql:(NSString*)sql, ... {
	
	if (!_mainAdapter)
	{
		return NO;
	}
	
	return [_mainAdapter executeStatement:error sql:sql];
}

- (BOOL)executeStatement:(NSString*)sql, ... {
	return [self executeStatement:nil sql:sql];
}

- (BOOL)executeDirectStatement:(NSError**)error sql:(NSString*)sql, ... {
    if (!_mainAdapter)
    {
        return NO;
    }
    
    return [_mainAdapter executeDirectStatement:error sql:sql];
}

- (BOOL)executeStatements:(NSArray*)statements error:(NSError**)error {
    return [_mainAdapter executeStatements:statements error:error];
}

- (BOOL)executeTransactionalBlock:(BOOL (^)(LDatabaseAdapter *adapter, NSError **error))block error:(NSError**)error {
    return [_mainAdapter executeTransactionalBlock:block error:error];
}

- (NSUInteger)lastInsertId {
    
	if (!_mainAdapter)
	{
		return NSNotFound;
	}
	
	if ([_mainAdapter respondsToSelector:@selector(lastInsertId)])
	{
		return [_mainAdapter lastInsertId];
	}
	
	return NO;
}

/*
- (BOOL)commit:(NSError**)error {
    
    if (error != NULL)
    {
        *error = nil;
    }
    
    if (!_mainAdapter)
    {
        return NO;
    }
    
	if ([_mainAdapter respondsToSelector:@selector(commit:)])
	{
		return [_mainAdapter commit:error];
	}
	
	return NO;
}

- (BOOL)rollback:(NSError**)error {
    
    if (error != NULL)
    {
        *error = nil;
    }
    
    if (!_mainAdapter)
    {
        return NO;
    }
    
	if ([_mainAdapter respondsToSelector:@selector(rollback:)])
	{
		return [_mainAdapter rollback:error];
	}
	
	return NO;
}

- (BOOL)beginTransaction:(NSError**)error {
    
    if (error != NULL)
    {
        *error = nil;
    }
    
    if (!_mainAdapter)
    {
        return NO;
    }
    
	if ([_mainAdapter respondsToSelector:@selector(beginTransaction:)])
	{
		return [_mainAdapter beginTransaction:error];
	}
	
	return NO;
}*/

- (BOOL)connect:(NSString*)connectinString error:(NSError**)error {
	
	if (!_mainAdapter)
	{
		return NO;
	}
	
	if ([_mainAdapter isConnected])
	{
		return YES;
	}
	
    return [_mainAdapter connect:connectinString error:error];
}

- (BOOL)reconnect:(NSError**)error {
	
	if (!_mainAdapter)
	{
		return NO;
	}
	
    return [_mainAdapter reconnect:error];
}

- (void)disconnect {
	
	if (!_mainAdapter)
	{
		return;
	}
	
	if (![_mainAdapter isConnected])
	{
		return;
	}
	
	[_mainAdapter disconnect];
}

- (BOOL)isConnected {
	
	if (!_mainAdapter)
	{
		return NO;
	}
	
    return [_mainAdapter isConnected];
}

@end
