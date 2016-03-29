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
 * @changed $Id: LDatabaseSchema.m 345 2014-10-07 17:23:27Z mkovachev $
 * @author $Author: mkovachev $
 * @version $Revision: 345 $
 */

#import "LDatabaseSchema.h"

NSString *const LDatabaseSchemaErrorDomain = @"schema_upgrader.db.lightcast-ios.nimasystems.com";

NSString *const kDatabaseSchemaPrimaryIdentifier = @"global";

// Private helper methods
@interface LDatabaseSchema(Private)

- (void)reloadSchemaVersions;
- (BOOL)recreateSchemaTables:(NSError**)error;
- (BOOL)runSQLStatements:(NSArray*)sqlStatements error:(NSError**)error;

- (BOOL)schemaTableExists;

- (void)runSchemaUpgrade:(id<LDatabaseSchemaProtocol>)schemaUpgradeObject 
              schemaName:(NSString *)schemaName 
             fromVersion:(NSInteger)fromVersion toVersion:(NSInteger)toVersion;

@end

// Public methods
@implementation LDatabaseSchema

@synthesize
firstDatabaseInit=_firstDatabaseInit,
lastError;

#pragma mark - Initialization / Finalization

- (id)initWithAdapter:(LDatabaseAdapter*)adapter identifier:(NSString*)identifier {
    self = [super init];
    if (self)
    {
        _currentSchemaVersion = 0;
		_identifier = [identifier retain];
        _firstDatabaseInit = NO;
		_schemaVersions = nil;
     
        if (adapter != _adapter)
        {
            L_RELEASE(_adapter);
            _adapter = [adapter retain];
        }
		
		if (!_adapter || !_identifier)
		{
			L_RELEASE(self);
			return nil;
		}
    }
    return self;
}

- (id)init {
    return [self initWithAdapter:nil identifier:nil];
}

- (void)dealloc {
	L_RELEASE(_schemaVersions);
    L_RELEASE(_adapter);
	L_RELEASE(_identifier);
    L_RELEASE(lastError);
    [super dealloc];
}

#pragma mark - Schema Operations

- (BOOL)insertSchemaVersion:(NSInteger)toVersion error:(NSError**)error {
	
    // because of a bug which existed at some point and the inability to easily fix the problem
    // (unique index of schemaName was added as a clustered index with the Version column)
    // we will run two queries here
    NSArray *qs = [NSArray arrayWithObjects:
                   [NSString stringWithFormat:@"DELETE FROM schema WHERE schemaName = %@",
                    [_identifier sqlString]
                    ],
                   [NSString stringWithFormat:@"INSERT INTO schema (schemaName, version, date_installed)\
                    VALUES(%@, %d, CURRENT_TIMESTAMP)",
                    [_identifier sqlString],
                    (int)toVersion]
                   , nil];

	BOOL res = [_adapter executeStatements:qs error:error];
    
    if (!res)
    {
        lassert(false);
    }
	
	return res;
}

- (BOOL)runSQLStatements:(NSArray*)sqlStatements error:(NSError**)error {
	
	if (sqlStatements && [sqlStatements count])
	{
		LogInfo(@"Running sql statements: %d", (int)[sqlStatements count]);
		
		for(NSString *sql in sqlStatements)
		{
			if (!sql || [sql isEqual:[NSNull null]] || ![[sql trim] length]) continue;
			
			LogInfo(@"SQL: %@", sql);
			
			BOOL res = [_adapter executeStatement:error sql:sql];
			
			if (!res)
			{
				return NO;
			}
		}
	}
	
	return YES;
}

- (BOOL)upgradeSchema:(id<LDatabaseSchemaProtocol>)schemaSpecsObject error:(NSError**)error {
    
    // check if we are connected
    if (!_adapter)
    {
        return NO;
    }
    
    if (!schemaSpecsObject)
    {
        return NO;
    }
    
	BOOL res = [self initializeMasterSchema:error];
	
	if (!res)
	{
		return NO;
	}
    
    self.lastError = nil;
	
    NSInteger schemaNextVersion = schemaSpecsObject.currentSchemaVersion;
    
	// check if there is a problem with the currently allocated versions
	if (!schemaNextVersion || schemaNextVersion < _currentSchemaVersion)
	{
		if (error != NULL)
		{
			NSString *errStr = [NSString stringWithFormat:LightcastLocalizedString(@"Logic Error - either internal error or target schema version lower than current. Cannot Continue, current version: %d, target version: %d"), _currentSchemaVersion, schemaNextVersion];
			NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
			[errorDetail setValue:errStr forKey:NSLocalizedDescriptionKey];
			*error = [NSError errorWithDomain:LDatabaseSchemaErrorDomain code:LDatabaseSchemaErrorUpgrade userInfo:errorDetail];
		}
		
		return NO;
	}
	
	// check if we need to upgrade
	if (schemaNextVersion == _currentSchemaVersion)
	{
		LogInfo(@"Schema does NOT need any upgrades - cancelling upgrade");
		
		// NO UPGRADE NECESSARRY
		return YES;
	}
	
	/*res = [_adapter beginTransaction:error];
    
    if (!res)
    {
        return NO;
    }*/
	
    // upgrade now
    @try 
    {
        // check if there is a schema version inserted at all (it's possible in case of errorous cases)
        // if we don't have one at all - follow the next case: firstDatabaseInit
        BOOL hasSchemaRowInserted = NO;
        
        if (_schemaVersions && [_schemaVersions count])
        {
            for(NSDictionary *chk in _schemaVersions)
            {
                NSString *schemaName = [chk objectForKey:@"schemaName"];
                
                if ([schemaName isEqualToString:_identifier])
                {
                    hasSchemaRowInserted = YES;
                    break;
                }
            }
        }
        
        // for old installations (existing database) - without a schema table - we have to
		// run the upgrades from 1 to the latest to be sure everything is in
		// and pray :)
        if (!hasSchemaRowInserted || (/*_firstDatabaseInit &&*/ _masterSchemaRecreated))
        {
            LogInfo(@"This is a force database schema upgrade - upgrading to: %d without running any upgrades!", (int)schemaNextVersion);
            
            if ([schemaSpecsObject respondsToSelector:@selector(initializationSQLStatements)])
            {
                LogInfo(@"Running INITIALIZATION-sql statements...");
                
                BOOL preSQL = [self runSQLStatements:[schemaSpecsObject initializationSQLStatements] error:error];
                
                if (!preSQL)
                {
                    //[_adapter rollback:nil];
                    return NO;
                }
            }
            
            NSString * query = [NSString stringWithFormat:@"INSERT INTO schema (schemaName, version, date_installed)\
                                VALUES(%@, %d, CURRENT_TIMESTAMP)", 
                                [_identifier sqlString],
                                (int)schemaNextVersion];
			
            if (![_adapter executeStatement:error sql:query])
			{
				//[_adapter rollback:nil];
				assert(false);
				return NO;
			}
			
			if ([schemaSpecsObject respondsToSelector:@selector(postSQLStatements)])
			{
                LogInfo(@"Running POST-sql statements...");
                
				BOOL postSQL = [self runSQLStatements:[schemaSpecsObject postSQLStatements] error:error];
				
				if (!postSQL)
				{
					//[_adapter rollback:nil];
                    lassert(false);
					return NO;
				}
			}
			
			_currentSchemaVersion = schemaNextVersion;
            
			LogInfo(@"Database schemaName '%@' schema update completed", _identifier);
			
			/*res = [_adapter commit:error];
			
            if (!res)
            {
                lassert(false);
                return NO;
            }*/
            
            return YES;
        }
		
		LogInfo(@"Upgrading database schemaName '%@' schema from version: %d to version: %d", 
				_identifier, (int)_currentSchemaVersion, (int)schemaNextVersion);
		
		BOOL anyUpgradesRan = NO;
		
		for(NSInteger i=_currentSchemaVersion+1;i<=schemaNextVersion;i++)
		{
			NSInteger upgradeFrom = i-1;
			NSInteger upgradeTo = i;
			
            LogInfo(@"Upgrading schema from: %d to %d", (int)upgradeFrom, (int)upgradeTo);
            
			// find an upgrade to run from the schema definitions
            NSArray *schemaObjects = nil;
            
            if ([schemaSpecsObject respondsToSelector:@selector(schemaChangesForVersion:)])
            {
                schemaObjects = [schemaSpecsObject schemaChangesForVersion:upgradeTo];
            }
			
			if (schemaObjects)
            {
                BOOL res = [_adapter executeStatements:schemaObjects error:error];
                
                if (!res) {
                    lassert(false);
                    return NO;
                }
                
                anyUpgradesRan = YES;
            }
            
            // run custom schema updates (method based)
            SEL selector = NSSelectorFromString([NSString stringWithFormat:@"databaseSchemaUpgradeTo_%d", (int)upgradeTo]);
            
            if ([schemaSpecsObject respondsToSelector:selector])
            {
                NSError *invocationError = nil;

                NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:
                                            [[schemaSpecsObject class] instanceMethodSignatureForSelector:selector]];
                [invocation setSelector:selector];
                [invocation setTarget:schemaSpecsObject];
                
                @try
                {
                    [invocation invokeWithTarget:schemaSpecsObject];
                }
                @catch (NSException *e)
                {
                    //[_adapter rollback:nil];
                    LogError(@"Unhandled exception while upgrading to schema version: %d: %@", (int)upgradeTo, e);
                    lassert(false);
                    return NO;
                }
                
                [invocation getReturnValue:&invocationError];
                
                self.lastError = invocationError;
                
                if (invocationError)
                {
                    //[_adapter rollback:nil];
                    LogError(@"Could not run upgrade method to schema version: %d: %@", (int)upgradeTo, invocationError);
                    lassert(false);
                    
                    if (error != NULL)
                    {
                        *error = invocationError;
                    }
                    
                    return NO;
                }
            }
			
			// mark the schema version
			BOOL res = [self insertSchemaVersion:upgradeTo error:error];
			
			if (!res)
			{
				//[_adapter rollback:nil];
				lassert(false);
				return NO;
			}
		}
		
		// always raise to the last specified version by the schema
		BOOL res = [self insertSchemaVersion:schemaNextVersion error:error];
		
		if (!res)
		{
			//[_adapter rollback:nil];
			
			return NO;
		}
		
		if ([schemaSpecsObject respondsToSelector:@selector(postSQLStatements)])
		{
            LogInfo(@"Running POST-sql statements...");
            
			BOOL postSQL = [self runSQLStatements:[schemaSpecsObject postSQLStatements] error:error];
			
			if (!postSQL)
			{
				//[_adapter rollback:nil];
				return NO;
			}
		}
		
		// set the new version internally
		_currentSchemaVersion = schemaNextVersion;
		
		LogInfo(@"Database schemaName '%@' schema update completed", _identifier);
		
		/*res = [_adapter commit:error];
        
        if (!res)
        {
            lassert(false);
            return NO;
        }*/
		
		return YES;
    }
    @catch (NSException * e) 
    {
		//[_adapter rollback:nil];
		
        LogError(@"Error while upgrading database schema for schemaName: %@: %@", 
                 _identifier,
                 [e description]);
        
        if (error != NULL)
		{
			NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
			NSString * errStr = [NSString stringWithFormat:LightcastLocalizedString(@"Could not upgrade schema: %@"), [e description]];
			[errorDetail setValue:errStr forKey:NSLocalizedDescriptionKey];
			*error = [NSError errorWithDomain:LDatabaseSchemaErrorDomain code:LDatabaseSchemaErrorUpgrade userInfo:errorDetail];
		}
        
        return NO;
    }
    @finally 
    {
        // reload schema versions now
        [self reloadSchemaVersions];
    }
    
    return NO;
}

#pragma mark - Master Schema operations

- (void)reloadSchemaVersions {
    
    NSString * query = @"SELECT schemaName, version FROM schema GROUP BY schemaName";
    NSArray * res = [_adapter executeQuery:query];
    
    NSAutoreleasePool * pool = nil;
    
    NSMutableArray * tmp = [[[NSMutableArray alloc] init] autorelease];
    
    @autoreleasepool
    {
        _currentSchemaVersion = 0;
        
        if (res && [res count])
        {
            for (NSDictionary * item in res)
            {
                pool = [[NSAutoreleasePool alloc] init];
                
                @try
                {
                    NSString * schemaName = [item objectForKey:@"schemaName"];
                    NSString * version = [item objectForKey:@"version"];
                    
                    [tmp addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                    schemaName, @"schemaName",
                                    version, @"version",
                                    nil]];
                    
                    // mark the current schema version
                    if ([_identifier isEqualToString:schemaName])
                    {
                        _currentSchemaVersion = [version intValue];
                    }
                }
                @finally
                {
                    [pool drain];
                }
            }
        }
        
        L_RELEASE(_schemaVersions);
        _schemaVersions = [[NSArray arrayWithArray:tmp] retain];
        
        /*if (_schemaVersions && [_schemaVersions count])
         {
         _currentSchemaVersion = [[[_schemaVersions lastObject] objectForKey:@"version"] intValue];
         }*/
    }
}

- (BOOL)recreateSchemaTables:(NSError**)error {
	
    NSString * query = nil;
    
    @try
    {
        // drop if existing - table / indexes
        query = @"DROP TABLE IF EXISTS schema";
        [_adapter executeStatement:nil sql:query];
        
        query = @"DROP INDEX IF EXISTS SCHEMA_DATE_INSTALLED_IDX";
        [_adapter executeStatement:nil sql:query];
        
        query = @"DROP INDEX IF EXISTS SCHEMA_NAME_VERSION_UIDX";
        [_adapter executeStatement:nil sql:query];
    }
    @catch (NSException * e)
    {
        // silent
    }
    
    NSMutableArray *stms = [NSMutableArray array];
    
    // create the table
    query = [NSString stringWithFormat:@"CREATE TABLE schema (\
             schema_operation_id integer PRIMARY KEY AUTOINCREMENT,\
             schemaName VARCHAR(50) NOT NULL DEFAULT %@,\
             version integer,\
             date_installed datetime NOT NULL\
             )", kDatabaseSchemaPrimaryIdentifier];
    [stms addObject:query];
    
    // create necessary indexes
    query = @"CREATE INDEX IF NOT EXISTS SCHEMA_DATE_INSTALLED_IDX ON schema(schemaName,date_installed)";
    [stms addObject:query];
    
    query = @"CREATE UNIQUE INDEX IF NOT EXISTS SCHEMA_NAME_VERSION_UIDX ON schema(schemaName)";
    [stms addObject:query];
    
    if (![_adapter executeStatements:stms error:error])
    {
        return NO;
    }
    
    // if the schema table is recreated - that means
    // it is a brand new installation and no upgrades should be ran!
    // as it is expected - they have already been supplied in the database!
    
    // TODO - BUG
    // what if the database existed before that, but did not have a schema table and now we are supplying additional changes (or may be in the past versions)
    // think what to do here...
    //_forceLastVersion = YES;
    
    LogInfo(@"Database Schema recreated");
    
    return YES;
}

- (BOOL)schemaTableExists
{
    // drop if existing - table / indexes
    NSString *query = @"SELECT count(*) AS counted FROM sqlite_master WHERE type='table' AND name='schema'";
    
    NSArray *res = [_adapter executeQuery:query];
    
    if (!res || ![res count])
    {
        lassert(false);
        return NO;
    }
    
    BOOL exists = [[[res objectAtIndex:0] objectForKey:@"counted"] boolValue];
    return exists;
}

- (BOOL)initializeMasterSchema:(NSError**)error {
    
    // check if the schema table exists
    BOOL schemaTableExists = [self schemaTableExists];
    
    if (!schemaTableExists)
    {
        BOOL res = [self recreateSchemaTables:error];
        
        if (!res)
        {
            lassert(false);
            return NO;
        }
        
        // WE ARE AT VER 1.0 NOW!
        _masterSchemaRecreated = YES;
        _currentSchemaVersion = 0;
        
        // go to ver. 1 - the very first version
        // insert the record for this version silently and fake things :)
        /*NSString * query = [NSString stringWithFormat:
                            @"INSERT INTO schema (schemaName, version, date_installed) VALUES(%@, 1, CURRENT_TIMESTAMP)",
                            [_identifier sqlString]];
        
        if (![_adapter executeStatement:error sql:query])
        {
            return NO;
        }*/
    }
    else
    {
        [self reloadSchemaVersions];
    }
    
    LogInfo(@"Database schema initialized with version: %d", (int)_currentSchemaVersion);
    
    return YES;
}

@end