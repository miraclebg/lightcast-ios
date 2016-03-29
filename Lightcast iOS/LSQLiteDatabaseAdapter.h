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
 * @changed $Id: LSQLiteDatabaseAdapter.h 357 2015-04-16 06:29:29Z mkovachev $
 * @author $Author: mkovachev $
 * @version $Revision: 357 $
 */

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "LDatabaseAdapter.h"

extern NSString *const LSQLiteDatabaseAdapterErrorDomain;

typedef enum
{
    LSQLiteDatabaseAdapterErrorUnknown = 0,
    
    LSQLiteDatabaseAdapterErrorLockTimeout = 50,
    
    LSQLiteDatabaseAdapterErrorGeneric = 101,
    LSQLiteDatabaseAdapterErrorSQLPrepare = 102,
    LSQLiteDatabaseAdapterErrorSQLExecute = 103,
    LSQLiteDatabaseAdapterErrorSQLiteBusy = 104
    
    
} LSQLiteDatabaseAdapterError;

typedef enum
{
    LSQLiteDatabaseAdapterThreadingModeUnknown = 0,
    LSQLiteDatabaseAdapterThreadingModeSingleThread = 1, /* not safe to call simultaneously from more than 1 thread */
    LSQLiteDatabaseAdapterThreadingModeMultiThread = 2, /* safe to call from within the context of the current thread only */
    LSQLiteDatabaseAdapterThreadingModeSerialized = 3 /* this is the default - safe to call from any thread */
    
} LSQLiteDatabaseAdapterThreadingMode;

@interface LSQLiteDatabaseAdapter : LDatabaseAdapter

@property (readonly) LSQLiteDatabaseAdapterThreadingMode threadingMode;
@property (readonly, getter = getErrorMessage) NSString *errorMessage;
@property (readonly, getter = getErrorCode) NSInteger errorCode;

@property (readonly, getter = getIsConnected) BOOL isConnected;
@property (readonly, getter = getDatabaseType) NSString *databaseType;
@property (readonly, getter = getDatabaseVersion) NSString *databaseVersion;

@property NSInteger busyRetryTimeout;
@property (nonatomic, retain, readonly) NSString *dataSource;

+ (NSString *)version;

- (id)initWithConnectionString:(NSString*)aConnectionString;

- (BOOL)open:(NSError**)error threadingMode:(LSQLiteDatabaseAdapterThreadingMode)aThreadingMode;
- (BOOL)open:(NSError**)error;
- (void)close;

- (BOOL)executeStatement:(NSError**)error sql:(NSString*)sql, ...;
- (BOOL)executeDirectStatement:(NSError**)error sql:(NSString*)sql, ...;
- (BOOL)executeStatement:(NSString*)sql, ...;
- (BOOL)executeStatements:(NSArray*)statements error:(NSError**)error;

- (BOOL)executeTransactionalBlock:(BOOL (^)(LSQLiteDatabaseAdapter *adapter, NSError **error))block error:(NSError**)error;

- (NSArray *)executeQuery:(NSString *)sql, ...;

//- (BOOL)commit:(NSError**)error;
//- (BOOL)rollback:(NSError**)error;
//- (BOOL)beginTransaction:(NSError**)error;
//- (BOOL)beginImmediateTransaction:(NSError**)error;

//- (BOOL)commit;
//- (BOOL)rollback;
//- (BOOL)beginTransaction;
//- (BOOL)beginImmediateTransaction;

- (NSUInteger)lastInsertId;
- (NSString *)databaseType;
- (BOOL)isConnected;

- (BOOL)connect:(NSString*)connectinString error:(NSError**)error;
- (void)disconnect;
- (BOOL)reconnect:(NSError**)error;

- (BOOL)attachDatabase:(NSString*)connectionString alias:(NSString*)alias secureKey:(NSString*)secureKey error:(NSError**)error;
- (BOOL)attachDatabase:(NSString*)connectionString alias:(NSString*)alias error:(NSError**)error;
- (BOOL)detachDatabase:(NSString*)alias error:(NSError**)error;
- (BOOL)detachAllDatabases:(NSError**)error;

- (BOOL)tableExists:(NSString*)tableName;

+ (LSQLiteDatabaseAdapterThreadingMode)compiledSQLiteThreadingMode;

- (sqlite3*)sqliteBackend;

@end

