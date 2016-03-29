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
 * @changed $Id: LNullDatabaseAdapter.m 345 2014-10-07 17:23:27Z mkovachev $
 * @author $Author: mkovachev $
 * @version $Revision: 345 $
 */

#import "LNullDatabaseAdapter.h"

@implementation LNullDatabaseAdapter

- (NSArray *)executeQuery:(NSString *)sql, ... {
    return [NSArray array];
}

- (BOOL)executeStatement:(NSError**)error sql:(NSString*)sql, ... {
	return NO;
}

- (BOOL)executeStatements:(NSArray*)statements error:(NSError**)error {
    return NO;
}

- (BOOL)executeStatement:(NSString*)sql, ... {
	return NO;
}

- (BOOL)connect:(NSString*)connectinString error:(NSError**)error {
    return YES;
}

- (BOOL)reconnect:(NSError**)error {
	return NO;
}

- (void)disconnect {
    return;
}

- (BOOL)isConnected {
    return YES;
}

/*
- (BOOL)beginTransaction {
    return YES;
}

- (BOOL)commit {
    return YES;
}

- (BOOL)rollback {
    return YES;
}*/

- (NSString *)databaseType {
    return nil;
}

- (NSString *)connectionString {
    return nil;
}

@end
