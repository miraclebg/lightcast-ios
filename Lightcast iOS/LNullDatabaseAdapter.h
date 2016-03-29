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
 * @changed $Id: LNullDatabaseAdapter.h 345 2014-10-07 17:23:27Z mkovachev $
 * @author $Author: mkovachev $
 * @version $Revision: 345 $
 */

#import <Foundation/Foundation.h>
#import <Lightcast/LDatabaseAdapter.h>

@interface LNullDatabaseAdapter : LDatabaseAdapter<LDatabaseAdapterProtocol> {
    
}

- (NSArray *)executeQuery:(NSString *)sql, ...;

- (BOOL)executeStatement:(NSError**)error sql:(NSString*)sql, ...;
- (BOOL)executeStatement:(NSString*)sql, ...;
- (BOOL)executeStatements:(NSArray*)statements error:(NSError**)error;

- (BOOL)connect:(NSString*)connectinString error:(NSError**)error;
- (BOOL)reconnect:(NSError**)error;
- (void)disconnect;
- (BOOL)isConnected;

/*
- (BOOL)beginTransaction;
- (BOOL)commit;
- (BOOL)rollback;*/

- (NSString *)databaseType;

- (NSString *)connectionString;

@end
