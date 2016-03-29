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
 * @changed $Id: LiTunesImportExportPluginDelegate.h 114 2011-08-02 14:18:57Z ppetrov $
 * @author $Author: ppetrov $
 * @version $Revision: 114 $
 */

@protocol LiTunesImportExportPluginDelegate <NSObject>

- (BOOL)foundBundlesForImport:(NSArray*)bundlesFound newBundles:(NSArray**)newBundles;

- (BOOL)willImportBundle:(NSString*)bundlePath;

- (BOOL)willUpdateDatabaseData:(NSString*)bundlePath database:(NSString*)databasePath tableName:(NSString*)tableName primaryKey:(NSString*)pk rowNames:(NSArray*)rowNames newData:(NSArray**)newData mergedData:(NSMutableArray**)mergedData oldValues:(NSMutableArray**)oldValues;
//- (BOOL)willUpdateDatabaseData:(NSString*)bundlePath database:(NSString*)databasePath tableName:(NSString*)tableName primaryKey:(NSString*)pk data:(NSString*)data newData:(NSArray**)newData;
//- (BOOL)willUpdateDatabaseData:(NSString*)bundlePath database:(NSString*)databasePath;
- (BOOL)willUpdateFile:(NSString*)bundlePath filename:(NSString*)filename;

- (BOOL)modifyDocumentsPathWithPath:(NSString*)newPath;

@end
