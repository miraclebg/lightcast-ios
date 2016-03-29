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
 * @changed $Id: LDatabaseManager.h 357 2015-04-16 06:29:29Z mkovachev $
 * @author $Author: mkovachev $
 * @version $Revision: 357 $
 */

/* How to initialize the database within an app:
  
 SystemDatabaseInstance *systemDatabaseInstance = [[[SystemDatabaseInstance alloc] init] autorelease];
 
 BOOL initDbObject = [lc.db initializeAppDatabaseInstance:systemDatabaseInstance error:&error];
 
 if (!initDbObject)
 {
 hasStartupError = YES;
 
 LogError(@"Could not init the system database: %@", error);
 
 return;
 }
 */

#import <Lightcast/NSString+DB.h>
#import <Lightcast/LDatabaseAdapter.h>
#import <Lightcast/LDatabaseSchema.h>
#import <Lightcast/LSystemObject.h>
#import <Lightcast/LAppDatabaseInstance.h>

#define LERR_DOMAIN_DB @"db.lightcast-ios.nimasystems.com"
#define LERR_DB_CANT_INIT 101
#define LERR_DB_CANT_INIT_ADAPTER 201
#define LERR_DB_CANT_INIT_APP_DATABASE_INSTANCE 301

@interface LDatabaseManager : LSystemObject {

	LDatabaseAdapter *_mainAdapter;
	NSMutableDictionary *_adapters;
	
	NSMutableArray *_appDatabaseInstances;
}

@property (nonatomic, retain, readonly) LDatabaseAdapter *mainAdapter;

- (BOOL)initializeAdapter:(LDatabaseAdapter*)adapter identifier:(NSString*)identifier connectionString:(NSString*)connectionString error:(NSError **)error;

- (void)shutdownAdapterWithIdentifier:(NSString*)identifier;
- (void)shutdownAdapter:(LDatabaseAdapter*)adapter;

- (void)disconnectAllAdapters;

- (LDatabaseAdapter*)adapterWithIdentifier:(NSString*)adapterIdentifier;

@end

@interface LDatabaseManager(AppDatabaseInstances)

- (BOOL)initializeAppDatabaseInstance:(id<LAppDatabaseInstance>)databaseInstanceObject error:(NSError**)error;
- (BOOL)initializeAppDatabaseInstance:(id<LAppDatabaseInstance>)databaseInstanceObject databaseAdapter:(LDatabaseAdapter*)databaseAdapter error:(NSError**)error;

@end

@interface LDatabaseManager(PrimaryAdapter)

- (BOOL)connect:(NSString*)connectinString error:(NSError**)error;
- (void)disconnect;
- (BOOL)reconnect:(NSError**)error;
- (BOOL)isConnected;

- (NSArray *)executeQuery:(NSString *)sql, ...;
- (BOOL)executeSql:(NSString *)sql, ...;
- (BOOL)exec:(NSString *)sql, ...;

- (BOOL)executeStatement:(NSError**)error sql:(NSString*)sql, ...;
- (BOOL)executeStatement:(NSString*)sql, ...;
- (BOOL)executeDirectStatement:(NSError**)error sql:(NSString*)sql, ...;
- (BOOL)executeStatements:(NSArray*)statements error:(NSError**)error;

- (BOOL)executeTransactionalBlock:(BOOL (^)(LDatabaseAdapter *adapter, NSError **error))block error:(NSError**)error;

- (NSUInteger)lastInsertId;

/*
- (BOOL)commit:(NSError**)error;
- (BOOL)rollback:(NSError**)error;
- (BOOL)beginTransaction:(NSError**)error;*/

@end

extern NSString *const lnDatabaseManagerInitialized;