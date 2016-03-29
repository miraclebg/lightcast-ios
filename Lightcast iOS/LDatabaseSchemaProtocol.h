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
 * @changed $Id: LDatabaseSchemaProtocol.h 284 2013-08-06 06:02:53Z mkovachev $
 * @author $Author: mkovachev $
 * @version $Revision: 284 $
 */

/**
 *	@protocol DatabaseSchemaProtocol
 *	@brief Protocol to which the database schema updater classes should conform
 *
 *	All schema updaters (user / system / other database) effectively work the same way - only
 *	the schema updates are different as the database structure is different.
 *	Thus - we put them under the same hat with this protocol.
 *
 *	@author Martin Kovachev (miracle@nimasystems.com), Nimasystems Ltd
 */
@protocol LDatabaseSchemaProtocol<NSObject>

@required

- (NSString*)identifier;
- (NSInteger)currentSchemaVersion;

@optional

- (NSArray*)initializationSQLStatements;
- (NSArray*)postSQLStatements; // always ran after every schema upgrade

/**
 * Made optional in Rev. 96 after the implementation of method based updates
 * instead of SQL array of updates
 */
- (NSArray*)schemaChangesForVersion:(NSInteger)schemaVersion;

@end
