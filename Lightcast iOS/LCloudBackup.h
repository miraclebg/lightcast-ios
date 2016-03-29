//
//  LCloudBackup.h
//  Lightcast
//
//  Created by Dimitrinka Ivanova on 1/22/14.
//  Copyright (c) 2014 Nimasystems Ltd. All rights reserved.
//

#import <Lightcast/LCloudBackupLoadDataDelegate.h>
#import <Lightcast/LCloudBackupDownloadDataDelegate.h>
#import <Lightcast/LCloudFile.h>

extern NSString *const LCloudBackupErrorDomain;

typedef enum
{
    LCloudBackupErrorUnknown = 0,
    LCloudBackupErrorAccess = 1,
    LCloudBackupErrorNoItemsLoad = 2,
    LCloudBackupErrorPathFromLoadDataNotExists = 3,
    LCloudBackupErrorPathToDownloadNotExists = 4,
    LCloudBackupErrorCreateDirectoryInICloud = 5,
    LCloudBackupErrorICloudFileNotExist = 6
    
} LCloudBackupError;

@interface LCloudBackup : NSObject

@property (nonatomic, assign) id<LCloudBackupLoadDataDelegate> uploadDataDelegate;
@property (nonatomic, assign) id<LCloudBackupDownloadDataDelegate> downloadDataDelegate;

@property (nonatomic, copy) NSString *tempPath;

@property (nonatomic, assign, readonly) BOOL isUploading;
@property (nonatomic, assign, readonly) BOOL isDownloading;

@property (nonatomic, retain, readonly) NSArray *arrayFilesInICloud;

@property (nonatomic, readonly, getter = getICloudAccess) BOOL iCloudAccess;

- (void)cancelAllOperations;

- (void)waitUntilAllUploadsFinished;
- (void)waitUntilAllDownloadsFinished;

- (BOOL)startUploadingFile:(LCloudFile*)file error:(NSError **)error;
- (BOOL)startUploadingFiles:(NSArray*)uploadFiles error:(NSError **)error;

- (BOOL)getFilesFromICloud:(NSError**)error;
- (BOOL)startDownloadingFile:(LCloudFile*)file error:(NSError **)error;
- (BOOL)startDownloadingFiles:(NSArray*)downloadFiles error:(NSError **)error;

- (BOOL)removeFileFromICloud:(LCloudFile*)file error:(NSError **)error;
- (BOOL)removeFilesFromICloud:(NSArray*)file error:(NSError **)error;

@end
