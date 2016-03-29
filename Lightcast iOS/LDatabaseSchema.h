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
 * @changed $Id: LDatabaseSchema.h 251 2013-03-28 07:42:53Z mkovachev $
 * @author $Author: mkovachev $
 * @version $Revision: 251 $
 */

#import <Lightcast/LDatabaseSchemaProtocol.h>
#import <Lightcast/LDatabaseAdapter.h>

extern NSString *const LDatabaseSchemaErrorDomain;

typedef enum
{
    LDatabaseSchemaErrorUnknown = 0,
    LDatabaseSchemaErrorGeneric = 1,
    LDatabaseSchemaErrorInvalidParams = 2,
    
    LDatabaseSchemaErrorMasterSchema = 10,
    LDatabaseSchemaErrorUpgrade = 11
    
    
} LDatabaseSchemaError;

extern NSString *const kDatabaseSchemaPrimaryIdentifier;

@interface LDatabaseSchema : NSObject {
	
    LDatabaseAdapter *_adapter;
	
	NSString *_identifier;
    NSInteger _currentSchemaVersion;
	
	NSArray *_schemaVersions;
    
    BOOL _firstDatabaseInit;
	BOOL _masterSchemaRecreated;
}

@property (nonatomic, assign) BOOL firstDatabaseInit;
@property (nonatomic, copy) NSError *lastError;

- (id)initWithAdapter:(LDatabaseAdapter*)adapter identifier:(NSString*)identifier;

- (BOOL)initializeMasterSchema:(NSError**)error;

- (BOOL)upgradeSchema:(id<LDatabaseSchemaProtocol>)schemaSpecsObject error:(NSError**)error;

@end

