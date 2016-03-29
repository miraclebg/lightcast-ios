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
 * @changed $Id: LDatabaseAdapterProtocol.h 346 2014-10-08 12:54:30Z mkovachev $
 * @author $Author: mkovachev $
 * @version $Revision: 346 $
 */

#import <Foundation/Foundation.h>

@class LDatabaseAdapter;

@protocol LDatabaseAdapterProtocol <NSObject>

@required

- (NSArray *)executeQuery:(NSString*)sql, ...; // must NEVER return nil - [NSArray array] otherwise!

- (BOOL)executeStatements:(NSArray*)statements error:(NSError**)error;
- (BOOL)executeStatement:(NSError**)error sql:(NSString*)sql, ...;
- (BOOL)executeStatement:(NSString*)sql, ...;
- (BOOL)executeDirectStatement:(NSError**)error sql:(NSString*)sql, ...;

- (BOOL)open:(NSError**)error;
- (void)close;

- (BOOL)connect:(NSString*)connectinString error:(NSError**)error;
- (void)disconnect;
- (BOOL)reconnect:(NSError**)error;

- (BOOL)isConnected;

- (NSString*)databaseType;

- (NSString*)connectionString; // not to sure about this, but for now it will stay here! :)

@optional

- (NSUInteger)lastInsertId;

- (BOOL)executeTransactionalBlock:(BOOL (^)(LDatabaseAdapter *adapter, NSError **error))block error:(NSError**)error;

/*
- (BOOL)beginTransaction:(NSError**)error;
- (BOOL)commit:(NSError**)error;
- (BOOL)rollback:(NSError**)error;

- (BOOL)commit;
- (BOOL)rollback;
- (BOOL)beginTransaction;
- (BOOL)beginImmediateTransaction;*/

@end
