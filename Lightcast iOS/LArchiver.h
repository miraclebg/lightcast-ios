//
//  LArchiver.h
//  Zipping
//
//  Created by Georgi Petrov on 7/25/11.
//  Copyright 2011 Nimasystems Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

#define LARCHIVER_ERROR_DOMAIN @"com.nimasystems.lightcast-ios.larchiver"
#define LARCHIVER_ERROR_CODE_NO_FILE                    1
#define LARCHIVER_ERROR_CODE_NO_ARCHIVE_NAME            2
#define LARCHIVER_ERROR_CODE_NO_DESTIONATION_PATH       3
#define LARCHIVER_ERROR_CODE_ARCHIVING_EXCEPTION        4
#define LARCHIVER_ERROR_CODE_UNARCHIVING_EXCEPTION      5

@interface LArchiver : NSObject 

/**
 Method for archiving content from path to path with sepcified archive name
 @param NSString *filePath        - The path of content which will be archived
 @param NSString *zipName         - The name of the archive (may contain .zip extention or not)
 @param NSString *destinationPath - The path of the destination direcotry where the archive will be created (if the dir does not exists it will be created)
 @param NSError  **error          - Pointer to the error if any
 @return BOOL - success of the operation
 */
+ (BOOL)archiveContent:(NSString*)filePath withArchiveName:(NSString*)zipName andDestination:(NSString*)destinationPath error:(NSError**)error;

/**Nimasystems Ltd Method for unarchiving .zip archive
 @param NSString *filePath        - The path to the .zip archive
 @param NSString *destinationPath - The path to the direcotry where the archive will be unarchived
 @param NSError  **error          - Pointer to the error if ant
 @return BOOL succes of the operation
 */
+ (BOOL)unarchiveContent:(NSString*)filePath toPatht:(NSString*)destinationPath error:(NSError**)error;

@end
