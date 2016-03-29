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
 * @changed $Id: NSFileManager+Additions.h 299 2013-10-11 06:05:24Z mkovachev $
 * @author $Author: mkovachev $
 * @version $Revision: 299 $
 */

#import <Foundation/Foundation.h>

/**
 *	@category NSFileManager(Extensions)
 *	@brief Addons to the default NSFileManager class
 *	
 *	@author Martin Kovachev (miracle@nimasystems.com), Nimasystems Ltd
 */
@interface NSFileManager(LAdditions)

- (NSString*)temporaryPath;
- (NSString*)documentsPath;
- (NSString*)libraryPath;
- (NSString*)cachesPath;
- (NSString*)resourcePath;
- (NSString*)resourcePathForClass:(Class)classname;

- (NSString*)appLibraryPath;

- (NSString*)randomFilename:(NSInteger)length;

/** Removes a specified folder recursively
 *	@param NSString folderName The folder which should be removed (absolute path)
 *	@param BOOL onlyEmptyTopFolder Specify if the top level folder should also be removed (FALSE) or not (TRUE)
 *	@return BOOL Returns the status of the operation
 */
- (BOOL)removeFolderRecursively:(NSString *)folderName emptyTopFolder:(BOOL)onlyEmptyTopFolder;

/** Removes a specified folder recursively
 *	@param NSString folderName The folder which should be removed (absolute path)
 *	@param BOOL onlyEmptyTopFolder Specify if the top level folder should also be removed (FALSE) or not (TRUE)
 *  @param NSError return an error in the process
 *	@return BOOL Returns the status of the operation
 */
- (BOOL)removeFolderRecursively:(NSString *)folderName emptyTopFolder:(BOOL)onlyEmptyTopFolder error:(NSError**)error;

- (BOOL)folderExists:(NSString*)folder;

+ (NSString*)fileExtension:(NSString*)filename;
+ (NSInteger)filesize:(NSString*)filename;

- (NSString*)formattedFileSize:(NSInteger)fileSize;

+ (NSString*)combinePaths:(NSString*)path, ... NS_REQUIRES_NIL_TERMINATION;

+ (NSString*)folderContentsDescription:(NSString*)pathToFolder;

- (BOOL)markNoICloudArchiving:(NSString*)path error:(NSError**)error;

@end
