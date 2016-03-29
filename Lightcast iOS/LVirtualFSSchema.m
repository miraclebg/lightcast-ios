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
 * @changed $Id: LVirtualFSSchema.m 93 2011-07-27 14:48:50Z mkovachev $
 * @author $Author: mkovachev $
 * @version $Revision: 93 $
 */

#import "LVirtualFSSchema.h"

@implementation LVirtualFSSchema

#pragma mark - LDatabaseSchemaProtocol Protocl

- (NSString*)identifier {
	return @"virtual_fs";
}

- (NSInteger)currentSchemaVersion {
	return 1;
}

- (NSArray*)schemaChangesForVersion:(NSInteger)schemaVersion {
	return nil;
}

- (NSArray*)initializationSQLStatements {
	return [NSArray arrayWithObjects:
            /* filesystem table and indexes */
            @"CREATE TABLE IF NOT EXISTS [filesystem] (file_id integer PRIMARY KEY AUTOINCREMENT,filename varchar(150) NOT NULL,filetype varchar(15),filesize integer NOT NULL,created_on datetime,dir_hash varchar(32) NOT NULL,file_hash varchar(32) NOT NULL)",
            
            @"CREATE INDEX IF NOT EXISTS IDX_FILESYSTEM_CREATED_ON ON filesystem(created_on)",
            
            @"CREATE INDEX IF NOT EXISTS IDX_FILESYSTEM_FILESIZE ON filesystem(filesize)",
            
            @"CREATE INDEX IF NOT EXISTS IDX_FILESYSTEM_DIR_HASH ON filesystem(dir_hash)",
            nil];
}

@end
