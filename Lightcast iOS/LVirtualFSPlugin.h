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
 * @changed $Id: LVirtualFSPlugin.h 357 2015-04-16 06:29:29Z mkovachev $
 * @author $Author: mkovachev $
 * @version $Revision: 357 $
 */

#import <Foundation/Foundation.h>
#import <Lightcast/LVirtualFile.h>
#import <Lightcast/LDatabaseAdapter.h>
#import <Lightcast/LDatabaseManager.h>
#import <Lightcast/LPlugin.h>
#import <Lightcast/LPluginBehaviour.h>

#define VFS_DEFAULT_FILES_PER_FOLDER 200
#define VFS_DEFAULT_BASE_PATH_NAME @"vfs/data"

#define LERR_DOMAIN_VIRTUALFS @"virtualfs.plugins.lightcast-ios.nimasystems.com"
#define LERR_PLUGIN_VFS_FILE_NOT_FOUND 101
#define LERR_PLUGIN_VFS_FILE__LOAD_ERROR 201
#define LERR_PLUGIN_VFS_FILE_CREATE_ERROR 301
#define LERR_PLUGIN_VFS_FILE__REMOVE_ERROR 401
#define LERR_PLUGIN_VFS_FILE_APPEND_ERROR 501

extern NSString *const LVirtualFSPluginErrorDomain;

typedef enum
{
    LVirtualFSPluginErrorUnknown = 0,
    LVirtualFSPluginErrorGeneric,
    LVirtualFSPluginErrorInvalidParams,
    
    LVirtualFSPluginErrorIO = 10
    
} LVirtualFSPluginError;

@interface LVirtualFSPlugin : LPlugin {
    
    NSString *basePath;
    NSString *currentDir;
    NSInteger filesCountInCurrentDir;
    
    LDatabaseManager *db;
}

@property (nonatomic, retain, readonly) NSString *basePath;

- (LVirtualFile*)appendFileDataToVFSFile:(NSInteger)vfsFileId sourceFile:(NSString*)sourceFilePath createIfMissing:(BOOL)createIfMissing error:(NSError**)error;

/**
 * Imports a file from a given path
 * @param pathToFile The path at which the file resides
 * @param error Error information upon failure
 * @return LVirtualFile containing all the neccessary things to operate with the file
 */
- (LVirtualFile *)importFileAtPath:(NSString *)pathToFile
                             error:(NSError**)error;

- (LVirtualFile *)importFileAtPath:(NSString *)pathToFile
                          filename:(NSString*)filename
                    resourceValues:(NSDictionary*)resourceValues
                             error:(NSError**)error;

- (LVirtualFile *)importFileAtPath:(NSString *)pathToFile
                    resourceValues:(NSDictionary*)resourceValues
                             error:(NSError**)error;

/**
 * Imports a file from a NSData memory buffer
 * @param data The data container object in memory with the file
 * @param filename What name to save it with internally, could be nil
 * @param extension What extension to save it with, could be nil
 * @param error Error information upon failure
 * @return LVirtualFile containing all the neccessary things to operate with the file
 */
- (LVirtualFile *)importFileWithData:(NSData*)data
                            filename:(NSString*)filename 
						   extension:(NSString*)extension
                               error:(NSError**)error;

- (LVirtualFile *)importFileWithData:(NSData*)data
                            filename:(NSString*)filename
						   extension:(NSString*)extension
                      resourceValues:(NSDictionary*)resourceValues
                               error:(NSError**)error;

/**
 * @param fileId The file_id inside the vfs
 * @param error Object storing error operation upon failure
 * @return LVirtualFile instance which has info about the file
 */
- (LVirtualFile *)fileById:(NSInteger)fileId
                     error:(NSError**)error;

/**
 * Removes a file by a given id
 * @param fileId The file_id in the vfs
 * @param error Object with information upon error
 * @return Upon successfull removal return YES
 */
- (BOOL)removeFileById:(NSInteger)fileId
                 error:(NSError**)error;

/**
 * Returns a dictionary with the statistics for the file system containing the number of files and the total file size
 */
- (NSDictionary *)vfsStats;

@end