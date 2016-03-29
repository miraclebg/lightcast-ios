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
 * @changed $Id: LSQLiteDatabaseAdapter.m 347 2014-10-08 12:57:31Z mkovachev $
 * @author $Author: mkovachev $
 * @version $Revision: 347 $
 */

#import "LSQLiteDatabaseAdapter.h"
#import "unistd.h"

NSString *const LSQLiteDatabaseAdapterErrorDomain = @"sqlite_database_adapter.db.lightcast-ios.nimasystems.com";

NSInteger const LSQLiteDatabaseAdapterDefaultBusyRetryTimeout = 50000; // iterations in which we usleep(LSQLiteDatabaseAdapterDefaultBusyRetryTimeoutUSleep)
NSInteger const LSQLiteDatabaseAdapterDefaultBusyRetryTimeoutUSleep = 500;

BOOL const LSQLiteDatabaseAdapterUseOpenSharedCache = NO;

@implementation LSQLiteDatabaseAdapter {
    
    sqlite3 *_db;
    
    BOOL _isThreadSafe;
    BOOL _inTransactionalBlock;
    
    //id _attachedDatabasesLock;
    NSMutableArray *_attachedDatabases;
    
    //NSLock *_transactionLock;
}

@synthesize
busyRetryTimeout,
dataSource,
threadingMode;

#pragma mark - Initialization / Finalization

- (id)init
{
	return [self initWithConnectionString:nil];
}

- (id)initWithConnectionString:(NSString*)aConnectionString
{
	self = [super initWithConnectionString:aConnectionString];
	if (self)
	{
        if ([NSString isNullOrEmpty:aConnectionString])
        {
            L_RELEASE(self);
            lassert(false);
            return nil;
        }
        
        //_attachedDatabasesLock = [[NSObject alloc] init];
        _attachedDatabases = nil;
        
        //_transactionLock = [[NSLock alloc] init];
        
		busyRetryTimeout = LSQLiteDatabaseAdapterDefaultBusyRetryTimeout;
		
        dataSource = [aConnectionString copy];
	}
	return self;
}

- (void)dealloc
{
    [self detachAllDatabases:nil];
    
	[self close];
    
    //L_RELEASE(_transactionLock);
    L_RELEASE(dataSource);
    L_RELEASE(_attachedDatabases);
    //L_RELEASE(_attachedDatabasesLock);
    
	[super dealloc];
}

#pragma mark - Abstract methods

- (NSString*)connectionString
{
    return dataSource;
}

- (sqlite3*)sqliteBackend
{
    return _db;
}

- (BOOL)_isConnected
{
    BOOL  isConnected_ = (_db ? YES : NO);
    return isConnected_;
}

- (BOOL)isConnected
{
    __block BOOL isConnected_ = NO;
    
    void (^b)() = ^() { isConnected_ = [self _isConnected]; };
    
    if (_isThreadSafe || _inTransactionalBlock) {
        b();
    } else {
        // dispatch the rest
        dispatch_sync(self.adapterDispatchQueue, b);
    }
    
    return isConnected_;
}

- (NSString *)databaseType
{
    return @"sqlite3";
}

- (NSUInteger)lastInsertId
{
    __block NSInteger lastInsertId = 0;
    
    void (^b)() = ^() {
        if (![self _isConnected])
        {
            if (![self _open:nil])
            {
                lassert(false);
                return;
            }
        }
        
        lastInsertId = (NSUInteger)sqlite3_last_insert_rowid(_db);
    };
    
    if (_isThreadSafe || _inTransactionalBlock) {
        b();
    } else {
        // dispatch the rest
        dispatch_sync(self.adapterDispatchQueue, b);
    }
    
    lassert(lastInsertId);
    
    return lastInsertId;
}

- (BOOL)connect:(NSString*)connectinString error:(NSError**)error
{
    return [self open:error];
}

- (void)disconnect
{
    return [self close];
}

- (BOOL)reconnect:(NSError**)error
{
    if (error != NULL)
    {
        *error = nil;
    }
    
    return NO;
}

#pragma mark - Getters / Setters

- (NSInteger)getErrorCode
{
	return sqlite3_errcode(_db);
}

- (NSString*)getErrorMessage
{
	return [NSString stringWithFormat:@"%s", sqlite3_errmsg(_db)];
}

- (NSString*)getDatabaseVersion
{
    return [LSQLiteDatabaseAdapter version];
}

- (NSString*)getDatabaseType
{
    return [self databaseType];
}

- (BOOL)getIsConnected
{
    return [self isConnected];
}

#pragma mark - Attached databases

- (BOOL)attachDatabase:(NSString*)connectionString alias:(NSString*)alias secureKey:(NSString*)secureKey error:(NSError**)error
{
    if (error != NULL)
    {
        *error = nil;
    }
    
    if ([NSString isNullOrEmpty:connectionString] || [NSString isNullOrEmpty:alias])
    {
        lassert(false);
        return NO;
    }
    
    __block NSError *err = nil;
    __block BOOL ret = NO;
    
    lassert(!_inTransactionalBlock);
    
    dispatch_sync(self.adapterDispatchQueue, ^{
        
        NSString *sql = [NSString stringWithFormat:@"ATTACH DATABASE %@ AS %@ %@",
                         [connectionString sqlString],
                         [alias sqlString],
                         (![NSString isNullOrEmpty:secureKey] ? [NSString stringWithFormat:@"KEY %@", [secureKey sqlString]] : @"")
                         ];
        ret = [self _executeStatement:&err sql:sql];
        
        if (!ret)
        {
            return;
        }
        
        if (!_attachedDatabases)
        {
            _attachedDatabases = [[NSMutableArray alloc] init];
        }
        
        [_attachedDatabases addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                       alias, @"alias",
                                       connectionString, @"connectionString"
                                       , nil]];
        
        ret = YES;
    });
    
    if (error != NULL) {
        *error = err;
    }
    
    return ret;
}

- (BOOL)attachDatabase:(NSString*)connectionString alias:(NSString*)alias error:(NSError**)error
{
    return [self attachDatabase:connectionString alias:alias secureKey:nil error:error];
}

- (BOOL)detachDatabase:(NSString*)alias error:(NSError**)error {
    if (error != NULL)
    {
        *error = nil;
    }
    
    lassert(!_inTransactionalBlock);
    
    if ([NSString isNullOrEmpty:alias])
    {
        lassert(false);
        return NO;
    }
    
    __block NSError *err = nil;
    __block BOOL ret = NO;
    
    dispatch_sync(self.adapterDispatchQueue, ^{
        ret = [self _detachDatabase:alias error:&err];
    });
    
    if (error != NULL) {
        *error = err;
    }
    
    return ret;
}

- (BOOL)_detachDatabase:(NSString*)alias error:(NSError**)error
{
    if (error != NULL)
    {
        *error = nil;
    }
    
    if ([NSString isNullOrEmpty:alias])
    {
        lassert(false);
        return NO;
    }
    
    NSError *err = nil;
    BOOL ret = NO;
    
    if (!_attachedDatabases || ![_attachedDatabases count])
    {
        return NO;
    }
    
    // make a copy as the original one will mutate
    NSMutableArray *cp = [[_attachedDatabases copy] autorelease];
    
    NSInteger i = 0;
    
    for(NSDictionary *attDb in cp)
    {
        if ([[attDb objectForKey:@"alias"] isEqual:alias])
        {
            ret = [self _executeStatement:&err sql:[NSString stringWithFormat:@"DETACH DATABASE %@", alias]];
            
            if (!ret)
            {
                lassert(false);
                return NO;
            }
            
            // remove from array
            [_attachedDatabases removeObjectAtIndex:i];
            
            ret = YES;
            
            break;
        }
        
        i++;
    }
    
    if (error != NULL) {
        *error = err;
    }
    
    return ret;
}

- (BOOL)detachAllDatabases:(NSError**)error
{
    if (error != NULL)
    {
        *error = nil;
    }
    
    lassert(!_inTransactionalBlock);
    
    __block NSError *err = nil;
    __block BOOL ret = NO;
    
    dispatch_sync(self.adapterDispatchQueue, ^{
        
        if (!_attachedDatabases || ![_attachedDatabases count])
        {
            ret = YES;
            return;
        }
        
        ret = NO;
        
        // make a copy as the original one will mutate
        NSMutableArray *cp = [[_attachedDatabases copy] autorelease];
        
        for(NSDictionary *attDb in cp)
        {
            ret = [self _detachDatabase:[attDb objectForKey:@"alias"] error:&err];
            
            if (!ret)
            {
                return;
            }
        }
    });
    
    if (error != NULL) {
        *error = err;
    }
    
    return ret;
}

#pragma mark - SQL Commands

- (BOOL)_open:(NSError**)error threadingMode:(LSQLiteDatabaseAdapterThreadingMode)aThreadingMode
{
    if (error != NULL)
    {
        *error = nil;
    }
    
    if (_db)
    {
        return NO;
    }
    
    lassert(dataSource);
    lassert(aThreadingMode);
    
    threadingMode = aThreadingMode;
    
    int threadingMode_ = 0;
    
    if (aThreadingMode == LSQLiteDatabaseAdapterThreadingModeSingleThread)
    {
        threadingMode_ = 0;
    }
    else if (aThreadingMode == LSQLiteDatabaseAdapterThreadingModeMultiThread)
    {
        threadingMode_ = SQLITE_OPEN_NOMUTEX;
    }
    else if (aThreadingMode == LSQLiteDatabaseAdapterThreadingModeSerialized)
    {
        threadingMode_ = SQLITE_OPEN_FULLMUTEX;
    }
    else
    {
        // default will be Serialized
        lassert(false);
        threadingMode_ = SQLITE_OPEN_FULLMUTEX;
        threadingMode = LSQLiteDatabaseAdapterThreadingModeSerialized;
    }
    
    int params = SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE | threadingMode_ | (LSQLiteDatabaseAdapterUseOpenSharedCache ?
                                                                                SQLITE_OPEN_SHAREDCACHE : SQLITE_OPEN_PRIVATECACHE
                                                                                );
    
    _db = nil;
    
    // deprecated as of iOS 5
    /*if (LSQLiteDatabaseAdapterUseOpenSharedCache)
     {
     // http://www.sqlite.org/sharedcache.html
     
     if (!sqlite3_enable_shared_cache(1))
     {
     LogDebug(@"Could not enable open share cache");
     }
     }
     else
     {
     if (!sqlite3_enable_shared_cache(0))
     {
     LogDebug(@"Could not disable open share cache");
     }
     }*/
    
    int openRes = sqlite3_open_v2([dataSource fileSystemRepresentation], &_db, params, NULL);
    
    if (openRes != SQLITE_OK)
    {
        NSString *msg = [NSString stringWithFormat:LightcastLocalizedString(@"SQLite Opening Error: %s"), sqlite3_errmsg(_db)];
        
        if (error != NULL) {
            *error = [NSError errorWithDomainAndDescription:LSQLiteDatabaseAdapterErrorDomain
                                                          errorCode:LSQLiteDatabaseAdapterErrorGeneric
                                               localizedDescription:msg];
            return NO;
        }
    }
    
    int actualThreadingMode = sqlite3_threadsafe();
    
    // install busy handler
    sqlite3_busy_timeout(_db, LSQLiteDatabaseAdapterDefaultBusyRetryTimeoutUSleep);
    
    NSString *thModeStr = nil;
    
    _isThreadSafe = NO;
    
    if (actualThreadingMode == 1)
    {
        thModeStr = @"Serialized";
        _isThreadSafe = YES;
    }
    else if (actualThreadingMode == 2)
    {
        thModeStr = @"MultiThreaded";
        _isThreadSafe = YES;
    }
    else if (actualThreadingMode == 0)
    {
        thModeStr = @"SingleThread";
    }
    else
    {
        thModeStr = @"Unknown";
    }
    
    LogInfo(@"SQLite database opened\n--------------\nDataSource: %@\nSQLite Version: %s\nThreading mode: %@\nOpen Share Cache: %@\n--------------",
            dataSource,
            SQLITE_VERSION,
            thModeStr,
            (LSQLiteDatabaseAdapterUseOpenSharedCache ? @"YES" : @"NO"));
    
    return YES;
}

- (BOOL)open:(NSError**)error threadingMode:(LSQLiteDatabaseAdapterThreadingMode)aThreadingMode {
    
    __block NSError *err = nil;
    __block BOOL ret = NO;
    
    if (_inTransactionalBlock) {
        ret = [self _open:&err];
    } else {
        dispatch_sync(self.adapterDispatchQueue, ^{
            ret = [self _open:&err];
        });
    }
    
    if (error != NULL) {
        *error = err;
    }
    
    return ret;
}

- (BOOL)open:(NSError**)error
{
    return [self open:error threadingMode:LSQLiteDatabaseAdapterThreadingModeSerialized];
}

- (BOOL)_open:(NSError**)error
{
    return [self _open:error threadingMode:LSQLiteDatabaseAdapterThreadingModeSerialized];
}

- (void)close {
    if (_inTransactionalBlock) {
        [self _close];
    } else {
        dispatch_sync(self.adapterDispatchQueue, ^{
            [self _close];
        });
    }
}

- (void)_close
{
    if (!_db)
    {
        return;
    }
    
    NSInteger numOfRetries = busyRetryTimeout;
    int rc;
    
    do
    {
        rc = sqlite3_close(_db);
        
        if (rc == SQLITE_OK)
        {
             _db = nil;
            return;
        }
        else if (rc == SQLITE_BUSY || rc == SQLITE_IOERR_BLOCKED)
        {
            LogDebug(@"sqlite BUSY (close), retry: %d", (int)numOfRetries);
            numOfRetries--;
            usleep(LSQLiteDatabaseAdapterDefaultBusyRetryTimeoutUSleep);
            continue;
        }
        else
        {
            lassert(false);
            return;
        }
    }
    while (numOfRetries >= 0);
    
    lassert(false);
}

- (NSArray *)executeQuery:(NSString *)sql, ...
{
    __block NSArray *ret = nil;
    
    void (^b)() = ^() {
        ret = [self _executeQuery:sql];
    };
    
    if (_isThreadSafe || _inTransactionalBlock) {
        b();
    } else {
        // dispatch the rest
        dispatch_sync(self.adapterDispatchQueue, b);
    }
    
    return ret;
}

- (NSArray *)_executeQuery:(NSString *)sql, ...
{
    if (![self _isConnected])
    {
        if (![self _open:nil])
        {
            lassert(false);
            return nil;
        }
    }
    
    if ([NSString isNullOrEmpty:sql])
    {
        return nil;
    }
 
    // strip the ! from the query if set
    if ([sql startsWith:@"!"])
    {
        sql = [sql substringFromIndex:1];
    }
    
    BOOL dispatchSuccess = NO;
    NSMutableArray *results = [[[NSMutableArray alloc] init] autorelease];
    
    //LogDebug(@"QUERY: %@", sql_);
    
    sqlite3_stmt *sqlStmt = NULL;
    
    NSError *err = nil;
    
    if (![self _prepareSql:sql inStatament:(&sqlStmt) error:&err])
    {
        LogError(@"Could not prepare SQL query: %@\n\n%@\n\n", err, sql);
        
        dispatchSuccess = NO;
        lassert(false);
        return nil;
    }
    
    lassert(sqlStmt != NULL);
    
    @try
    {
        int i = 0;
        
        int columnCount = sqlite3_column_count(sqlStmt);
        
        lassert(columnCount);
        
        while ([self _hasData:sqlStmt])
        {
            NSMutableDictionary *dictionary = [[[NSMutableDictionary alloc] init] autorelease];
            
            for (i = 0; i < columnCount; ++i)
            {
                id columnName = [self _columnName:sqlStmt columnIndex:i];
                id columnData = [self _columnData:sqlStmt columnIndex:i];
                
                [dictionary setObject:columnData forKey:columnName];
            }
            
            [results addObject:dictionary];
        }
    }
    @finally
    {
        sqlite3_finalize(sqlStmt);
        sqlStmt = NULL;
    }
    
    dispatchSuccess = YES;
    
    return results;
}

- (BOOL)_executeNonQuery:(NSString *)sql error:(NSError**)error
{
    if (error != NULL)
    {
        *error = nil;
    }
    
    if ([NSString isNullOrEmpty:sql])
    {
        lassert(false);
        return NO;
    }
    
    if (![self _isConnected])
    {
        if (![self _open:error])
        {
            lassert(false);
            return NO;
        }
    }
    
    NSError *dispatchErr = nil;
    BOOL dispatchSuccess = NO;
    
    sqlite3_stmt *sqlStmt = NULL;
    
    dispatchErr = nil;
    dispatchSuccess = [self _prepareSql:sql inStatament:(&sqlStmt) error:&dispatchErr];
    
    if (dispatchSuccess)
    {
        lassert(sqlStmt != NULL);
        
        @try
        {
            dispatchErr = nil;
            dispatchSuccess = [self _executeStatement:sqlStmt error:&dispatchErr];
            
            if (dispatchSuccess)
            {
                return YES;
            }
        }
        @finally
        {
            sqlite3_finalize(sqlStmt);
            sqlStmt = NULL;
        }
    }
    
    if (error != NULL)
    {
        *error = [[dispatchErr copy] autorelease];
    }
    
    return dispatchSuccess;
}

- (BOOL)executeStatements:(NSArray*)statements error:(NSError**)error
{
    __block NSError *err = nil;
    __block BOOL ret = NO;
    
    void (^b)() = ^() {
        ret = [self _executeStatements:statements error:&err];
    };
    
    if (_isThreadSafe || _inTransactionalBlock) {
        b();
    } else {
        // dispatch the rest
        dispatch_sync(self.adapterDispatchQueue, b);
    }
    
    if (error != NULL) {
        *error = err;
    }
    
    return ret;
}

- (BOOL)executeTransactionalBlock:(BOOL (^)(LSQLiteDatabaseAdapter *adapter, NSError **error))block error:(NSError**)error {

    if (error != NULL) {
        *error = nil;
    }
    
    __block NSError *err = nil;
    
    if (![self _isConnected])
    {
        if (![self _open:&err])
        {
            lassert(false);
            return NO;
        }
    }
    
    
    __block BOOL ret = NO;
    
    void (^b)() = ^() {
        _inTransactionalBlock = YES;
        
        @try {
            ret = [self _beginTransaction:&err];
            
            if (!ret)
            {
                lassert(false);
                return;
            }
            
            BOOL res = block(self, &err);
            
            if (res)
            {
                ret = [self _commit:nil];
                
                if (!ret)
                {
                    lassert(false);
                    return;
                }
            }
            else
            {
                ret = [self _rollback:nil];
                
                if (!ret)
                {
                    lassert(false);
                    return;
                }
            }
        }
        @finally {
            _inTransactionalBlock = NO;
        }
    };
    
    if (_inTransactionalBlock) {
       ret = block(self, &err);
    } else {
        dispatch_sync(self.adapterDispatchQueue, b);
    }
    
    if (error != NULL) {
        *error = err;
    }
    
    return ret;
}

- (BOOL)_executeStatements:(NSArray*)statements error:(NSError**)error
{
    if (error != NULL)
    {
        *error = nil;
    }
    
    if (![self _isConnected])
    {
        if (![self _open:error])
        {
            lassert(false);
            return NO;
        }
    }
    
    if (!statements || ![statements count])
    {
        lassert(false);
        return NO;
    }
    
    BOOL ret = NO;
    
    ret = [self _beginImmediateTransaction:error];
    
    if (!ret)
    {
        lassert(false);
        return NO;
    }
    
    @try
    {
        BOOL res = YES;
        
        for(NSString *statement in statements)
        {
            BOOL softErrors = NO;
            
            // strip the ! from the query if set
            if ([statement startsWith:@"!"])
            {
                softErrors = YES;
                statement = [statement substringFromIndex:1];
            }
            
            
            res = [self _executeNonQuery:statement error:error];
            
            if (!res && softErrors)
            {
                res = YES;
            }
            
            if (!res)
            {
                // override the error message
                if (error != NULL)
                {
                    *error = [NSError errorWithDomain:(*error).domain code:(*error).code userInfo:[NSDictionary
                                                                                      dictionaryWithObjectsAndKeys:[NSString stringWithFormat:LLocalizedString(@"Error while executing sql statement in transaction (%@): %@"), statement, (*error).localizedDescription], NSLocalizedDescriptionKey, nil]];
                }
                
                break;
            }
        }
        
        if (res)
        {
            ret = [self _commit:error];
            
            if (!ret)
            {
                lassert(false);
                return NO;
            }
        }
        else
        {
            ret = [self _rollback:error];
            
            if (!ret)
            {
                lassert(false);
                return NO;
            }
        }
    }
    @catch (NSException * e)
    {
        @try
        {
            [self _rollback:nil];
        }
        @catch (NSException *e)
        {
            lassert(false);
            ret = NO;
        }
    }
    
    return ret;
}

- (BOOL)executeStatement:(NSString*)sql, ...
{
    __block BOOL ret = NO;
    
    void (^b)() = ^() {
        ret = [self _executeStatement:sql];
    };
    
    if (_isThreadSafe || _inTransactionalBlock) {
        b();
    } else {
        // dispatch the rest
        dispatch_sync(self.adapterDispatchQueue, b);
    }
    
    return ret;
}

- (BOOL)executeDirectStatement:(NSError**)error sql:(NSString*)sql, ... {
    BOOL ret = [self _executeStatement:error sql:sql];
    return ret;
}

- (BOOL)executeStatement:(NSError**)error sql:(NSString*)sql, ...
{
    __block NSError *err = nil;
    __block BOOL ret = NO;
    
    void (^b)() = ^() {
        ret = [self _executeStatement:&err sql:sql];
    };
    
    if (_isThreadSafe || _inTransactionalBlock) {
        b();
    } else {
        // dispatch the rest
        dispatch_sync(self.adapterDispatchQueue, b);
    }
    
    if (error != NULL) {
        *error = err;
    }
    
    return ret;
}

- (BOOL)_executeStatement:(NSError**)error sql:(NSString*)sql, ...
{
    if (error != NULL)
    {
        *error = nil;
    }
    
    BOOL softErrors = NO;
    
    // strip the ! from the query if set
    if ([sql startsWith:@"!"])
    {
        softErrors = YES;
        sql = [sql substringFromIndex:1];
    }
  
    NSError *err = nil;
    
	BOOL ret = [self _executeNonQuery:sql error:&err];
    
    if (!ret && softErrors)
    {
        return YES;
    }
    
    // override the error message
    if (err && error != NULL)
    {
        *error = [NSError errorWithDomain:err.domain code:err.code userInfo:[NSDictionary
                                                                             dictionaryWithObjectsAndKeys:[NSString stringWithFormat:LLocalizedString(@"Error while executing sql statement (%@): %@"), sql, err.localizedDescription], NSLocalizedDescriptionKey, nil]];
    }
    
    return ret;
}

- (BOOL)_executeStatement:(NSString*)sql, ...
{
	return [self _executeStatement:nil sql:sql];
}

/*
- (BOOL)commit:(NSError**)error
{
    __block NSError *err = nil;
    __block BOOL ret = NO;
    
    dispatch_sync(self.adapterDispatchQueue, ^{
        ret = [self _commit:&err];
    });
    
    return ret;
}*/

- (BOOL)_commit:(NSError**)error
{
    BOOL ret = [self _executeNonQuery:@"COMMIT TRANSACTION;" error:error];
    
    //[_transactionLock unlock];
    return ret;
}

/*- (BOOL)rollback:(NSError**)error
{
    __block NSError *err = nil;
    __block BOOL ret = NO;
    
    dispatch_sync(self.adapterDispatchQueue, ^{
        ret = [self _rollback:&err];
    });
    
    return ret;
}*/

- (BOOL)_rollback:(NSError**)error
{
	BOOL ret = [self _executeNonQuery:@"ROLLBACK TRANSACTION;" error:error];
    
    //[_transactionLock unlock];
    return ret;
}

/*
- (BOOL)beginTransaction:(NSError**)error
{
    __block NSError *err = nil;
    __block BOOL ret = NO;
    
    dispatch_sync(self.adapterDispatchQueue, ^{
        ret = [self _beginTransaction:&err];
    });
    
    return ret;
}*/

- (BOOL)_beginTransaction:(NSError**)error
{
    //[_transactionLock lock];
    
	return [self _executeNonQuery:@"BEGIN DEFERRED TRANSACTION;" error:error];
}

/*
- (BOOL)beginImmediateTransaction:(NSError**)error
{
    __block NSError *err = nil;
    __block BOOL ret = NO;
    
    dispatch_sync(self.adapterDispatchQueue, ^{
        ret = [self _beginImmediateTransaction:&err];
    });
    
    return ret;
}*/

- (BOOL)_beginImmediateTransaction:(NSError**)error
{
    //[_transactionLock lock];
    
	return [self _executeNonQuery:@"BEGIN IMMEDIATE TRANSACTION;" error:error];
}

/*
- (BOOL)commit
{
    __block BOOL ret = NO;
    
    dispatch_sync(self.adapterDispatchQueue, ^{
        ret = [self _commit:nil];
    });
    
    return ret;
}*/

- (BOOL)_commit
{
    return [self _commit:nil];
}

/*
- (BOOL)rollback
{
    __block BOOL ret = NO;
    
    dispatch_sync(self.adapterDispatchQueue, ^{
        ret = [self _rollback:nil];
    });
    
    return ret;
}*/

- (BOOL)_rollback
{
    return [self _rollback:nil];
}

/*
- (BOOL)beginTransaction
{
    __block BOOL ret = NO;
    
    dispatch_sync(self.adapterDispatchQueue, ^{
        ret = [self _beginTransaction:nil];
    });
    
    return ret;
}*/

- (BOOL)_beginTransaction
{
    return [self _beginTransaction:nil];
}

/*
- (BOOL)beginImmediateTransaction
{
    __block BOOL ret = NO;
    
    dispatch_sync(self.adapterDispatchQueue, ^{
        ret = [self _beginImmediateTransaction:nil];
    });
    
    return ret;
}*/

- (BOOL)_beginImmediateTransaction
{
    return [self _beginImmediateTransaction:nil];
}

- (BOOL)tableExists:(NSString *)tableName
{
    __block BOOL ret = NO;
    
    void (^b)() = ^() {
        ret = [self _tableExists:tableName];
    };
    
    if (_isThreadSafe || _inTransactionalBlock) {
        b();
    } else {
        // dispatch the rest
        dispatch_sync(self.adapterDispatchQueue, b);
    }
    
    return ret;
}

- (BOOL)_tableExists:(NSString *)tableName
{
    if (!tableName)
    {
        lassert(false);
        return NO;
    }
    
    // drop if existing - table / indexes
    NSString *query = [NSString stringWithFormat:@"SELECT count(*) AS counted FROM sqlite_master WHERE type='table' AND name='%@'", tableName];
    
    NSArray *res = [self _executeQuery:query];
    
    if (!res || ![res count])
    {
        lassert(false);
        return NO;
    }
    
    BOOL exists = [[[res objectAtIndex:0] objectForKey:@"counted"] boolValue];
    return exists;
}

- (BOOL)_prepareSql:(NSString *)sql inStatament:(sqlite3_stmt **)stmt
{
    lassert(sql);

    if (stmt != NULL)
    {
        *stmt = NULL;
    }
    
	return [self _prepareSql:sql inStatament:stmt error:nil];
}

- (BOOL)_prepareSql:(NSString *)sql inStatament:(sqlite3_stmt **)stmt error:(NSError**)error
{
    lassert(sql);

    if (stmt != NULL)
    {
        *stmt = NULL;
    }
    
    if (error != NULL)
    {
        *error = nil;
    }
    
	NSInteger numOfRetries = busyRetryTimeout;
	int rc = 0;
    
	do
    {
        rc = sqlite3_prepare_v2(_db, [sql UTF8String], -1, stmt, NULL);
        
        if (rc == SQLITE_OK)
        {
            return YES;
        }
        else if (rc == SQLITE_BUSY || rc == SQLITE_IOERR_BLOCKED)
        {
            LogDebug(@"sqlite BUSY (prepareSql), retry: %d", (int)numOfRetries);
            numOfRetries--;
            usleep(LSQLiteDatabaseAdapterDefaultBusyRetryTimeoutUSleep);
            continue;
        }
        else
        {
            if (error != NULL)
            {
                NSString *errorMessage = [NSString stringWithFormat:LightcastLocalizedString(@"Generic SQLite error (%d): %@"), (int)self.errorCode, self.errorMessage];

                *error = [NSError errorWithDomainAndDescription:LSQLiteDatabaseAdapterErrorDomain
                                                      errorCode:LSQLiteDatabaseAdapterErrorGeneric
                                           localizedDescription:errorMessage];
            }

            return NO;
        }
    }
    while (numOfRetries >= 0);
	
    // timed out
    if (error != NULL)
    {
        *error = [NSError errorWithDomainAndDescription:LSQLiteDatabaseAdapterErrorDomain
                                              errorCode:LSQLiteDatabaseAdapterErrorSQLiteBusy
                                   localizedDescription:LightcastLocalizedString(@"SQLite is busy")];
    }
    
    lassert(false);
    
	return NO;
}

- (BOOL)_executeStatement:(sqlite3_stmt*)stmt error:(NSError**)error
{
    lassert(stmt != NULL);

    if (error != NULL)
    {
        *error = nil;
    }
	
	NSInteger numOfRetries = busyRetryTimeout;
	int rc;
	
	do
	{
		rc = sqlite3_step(stmt);

		if (rc == SQLITE_OK || rc == SQLITE_DONE)
		{
			return YES;
		}
		else if (rc == SQLITE_BUSY || rc == SQLITE_IOERR_BLOCKED)
		{
            LogDebug(@"sqlite BUSY (executeStatement), retry: %d", (int)numOfRetries);
            numOfRetries--;
            usleep(LSQLiteDatabaseAdapterDefaultBusyRetryTimeoutUSleep);
			continue;
		}
		else
		{
			if (error != NULL)
            {
                NSString *errorMessage = [NSString stringWithFormat:LightcastLocalizedString(@"Generic SQLite error (%d): %@"), (int)self.errorCode, self.errorMessage];
                
                *error = [NSError errorWithDomainAndDescription:LSQLiteDatabaseAdapterErrorDomain
                                                      errorCode:LSQLiteDatabaseAdapterErrorGeneric
                                           localizedDescription:errorMessage];
            }
            
            return NO;
		}
	}
	while (numOfRetries >= 0);
	
    // timed out
    if (error != NULL)
    {
        *error = [NSError errorWithDomainAndDescription:LSQLiteDatabaseAdapterErrorDomain
                                              errorCode:LSQLiteDatabaseAdapterErrorSQLiteBusy
                                   localizedDescription:LightcastLocalizedString(@"SQLite is busy")];
    }
    
    lassert(false);
    
	return NO;
}

- (void)_bindObject:(id)obj toColumn:(int)idx inStatament:(sqlite3_stmt *)stmt
{
	if (obj == nil || obj == [NSNull null])
	{
		sqlite3_bind_null(stmt, idx);
		
	}
    else if ([obj isKindOfClass:[NSData class]])
	{
		sqlite3_bind_blob(stmt, idx, [obj bytes], (int)[obj length], SQLITE_STATIC);
		
	}
    else if ([obj isKindOfClass:[NSDate class]])
	{
		sqlite3_bind_double(stmt, idx, [obj timeIntervalSince1970]);
		
	}
    else if ([obj isKindOfClass:[NSNumber class]])
	{
		if (!strcmp([obj objCType], @encode(BOOL)))
		{
			sqlite3_bind_int(stmt, idx, [obj boolValue] ? 1 : 0);
		}
        else if (!strcmp([obj objCType], @encode(int)))
		{
			sqlite3_bind_int64(stmt, idx, [obj longValue]);
		}
        else if (!strcmp([obj objCType], @encode(long)))
		{
			sqlite3_bind_int64(stmt, idx, [obj longValue]);
		}
        else if (!strcmp([obj objCType], @encode(float)))
		{
			sqlite3_bind_double(stmt, idx, [obj floatValue]);
		}
        else if (!strcmp([obj objCType], @encode(double)))
		{
			sqlite3_bind_double(stmt, idx, [obj doubleValue]);
		}
        else
		{
			sqlite3_bind_text(stmt, idx, [[obj description] UTF8String], -1, SQLITE_STATIC);
		}
	}
    else
	{
		sqlite3_bind_text(stmt, idx, [[obj description] UTF8String], -1, SQLITE_STATIC);
	}
}

- (BOOL)_hasData:(sqlite3_stmt *)stmt
{
    lassert(stmt != NULL);

	NSInteger numOfRetries = busyRetryTimeout;
	int rc;
	
	do
	{
		rc = sqlite3_step(stmt);
		
		if (rc == SQLITE_ROW)
		{
			return YES;
		}
		else if (rc == SQLITE_DONE)
		{
			return NO;
		}
		else if (rc == SQLITE_BUSY || rc == SQLITE_IOERR_BLOCKED)
		{
            LogDebug(@"sqlite BUSY (hasData), retry: %d", (int)numOfRetries);
			numOfRetries--;
            usleep(LSQLiteDatabaseAdapterDefaultBusyRetryTimeoutUSleep);
            continue;
		}
        else
		{
            lassert(false);
            return NO;
		}
	} while (numOfRetries >= 0);
	
    lassert(false);
    
	return NO;
}

- (id)_columnData:(sqlite3_stmt *)stmt columnIndex:(NSInteger)index
{
	assert(stmt);

	int columnType = sqlite3_column_type(stmt, (int)index);
	
	if (columnType == SQLITE_NULL)
	{
		return @"";
		//return([NSNull null]);
	}
	else if (columnType == SQLITE_INTEGER)
	{
		return [NSNumber numberWithInt:sqlite3_column_int(stmt, (int)index)];
	}
	else if (columnType == SQLITE_FLOAT)
	{
		return [NSNumber numberWithDouble:sqlite3_column_double(stmt, (int)index)];
	}
	else if (columnType == SQLITE_TEXT)
	{
        return [NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, (int)index)];
		//const unsigned char *text = sqlite3_column_text(stmt, index);
		//return [NSString stringWithFormat:@"%s", text];
	}
	else if (columnType == SQLITE_BLOB)
	{
		int nbytes = sqlite3_column_bytes(stmt, (int)index);
		const char *bytes = sqlite3_column_blob(stmt, (int)index);
		return [NSData dataWithBytes:bytes length:nbytes];
	}
    else
    {
        lassert(false);
    }
	
	return nil;
}

- (NSString *)_columnName:(sqlite3_stmt *)stmt columnIndex:(NSInteger)index
{
	return [NSString stringWithUTF8String:sqlite3_column_name(stmt, (int)index)];
}

#pragma mark - Helpers

+ (NSString *)version
{
	return [NSString stringWithFormat:@"%s", sqlite3_libversion()];
}

+ (LSQLiteDatabaseAdapterThreadingMode)compiledSQLiteThreadingMode
{
    int threadingModeSelected = sqlite3_threadsafe();
    LSQLiteDatabaseAdapterThreadingMode trMode = LSQLiteDatabaseAdapterThreadingModeUnknown;
    
    if (threadingModeSelected == SQLITE_OPEN_NOMUTEX)
    {
        trMode = LSQLiteDatabaseAdapterThreadingModeMultiThread;
    }
    else if (threadingModeSelected == SQLITE_OPEN_FULLMUTEX)
    {
        trMode = LSQLiteDatabaseAdapterThreadingModeSerialized;
    }
    else
    {
        trMode = LSQLiteDatabaseAdapterThreadingModeSingleThread;
    }
    
    return trMode;
}

@end

