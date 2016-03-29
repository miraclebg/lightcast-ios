//
//  LCloudBackup.m
//  Lightcast
//
//  Created by Dimitrinka Ivanova on 1/22/14.
//  Copyright (c) 2014 Nimasystems Ltd. All rights reserved.
//

#import "LCloudBackup.h"

NSString *const LCloudBackupErrorDomain = @"com.nimasystems.iCloudBackup";

@implementation LCloudBackup{
    
    NSMetadataQuery *queryFile;
    
    LCloudFile *_uploadFile;
    NSArray *_uploadFiles;

    BOOL _isCancelled;
    
    NSObject *_queryLock;
    
    dispatch_queue_t _loadDataQueue;
    dispatch_queue_t _queryDataQueue;
    dispatch_semaphore_t _querySyncSemaphore;
    
    dispatch_queue_t _downloadDataQueue;
    dispatch_queue_t _queryDataQueueDownload;
    dispatch_semaphore_t _querySyncSemaphoreDownload;
}

@synthesize
uploadDataDelegate,
downloadDataDelegate,
iCloudAccess,
tempPath,
isUploading,
isDownloading,
arrayFilesInICloud;

#pragma mark - Initialization / Finalization

- (id)init
{
    self = [super init];
    if (self)
    {
        _queryDataQueue = dispatch_queue_create("com.nimasystems.dreams.queryDataQueue", DISPATCH_QUEUE_SERIAL);
        _loadDataQueue = dispatch_queue_create("com.nimasystems.dreams.loadDataQueue", DISPATCH_QUEUE_SERIAL);
        
        _queryDataQueueDownload = dispatch_queue_create("com.nimasystems.dreams.queryDataQueueDownload", DISPATCH_QUEUE_SERIAL);
        _downloadDataQueue = dispatch_queue_create("com.nimasystems.dreams.downloadDataQueue", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (void)dealloc
{
    if (_queryDataQueue)
    {
        dispatch_sync(_queryDataQueue, ^{});
        dispatch_release(_queryDataQueue);
        _queryDataQueue = NULL;
    }
    
    if (_loadDataQueue)
    {
        dispatch_sync(_loadDataQueue, ^{});
        dispatch_release(_loadDataQueue);
        _loadDataQueue = NULL;
    }
    
    if (_queryDataQueueDownload)
    {
        dispatch_sync(_queryDataQueueDownload, ^{});
        dispatch_release(_queryDataQueueDownload);
        _queryDataQueueDownload = NULL;
    }
    
    if (_downloadDataQueue)
    {
        dispatch_sync(_downloadDataQueue, ^{});
        dispatch_release(_downloadDataQueue);
        _downloadDataQueue = NULL;
    }
    
    uploadDataDelegate = nil;
    downloadDataDelegate = nil;
    
    @synchronized(_queryLock) {
        L_RELEASE(queryFile);
    }
    
    L_RELEASE(arrayFilesInICloud);
    L_RELEASE(tempPath);
    L_RELEASE(_uploadFile);
    L_RELEASE(_uploadFiles);
    L_RELEASE(_queryLock);
    
    [super dealloc];
}

#pragma mark - Setters / Getters

- (BOOL)getICloudAccess
{
    NSURL *ubiq = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
    BOOL hasAccess = (ubiq != nil);
    return hasAccess;
}

#pragma mark - Mathods

- (void)cancelAllOperations {
    if (_isCancelled) {
        return;
    }
    
    _isCancelled = YES;
    
    LogInfo(@"Cancelling all operations");
}

- (void)waitUntilAllUploadsFinished {
    dispatch_sync(_queryDataQueue, ^{});
}

- (void)waitUntilAllDownloadsFinished {
    dispatch_sync(_downloadDataQueue, ^{});
}

#pragma mark - Methods Add File

- (BOOL)startUploadingFile:(LCloudFile*)file error:(NSError **)error
{
    if (error != NULL)
    {
        *error = nil;
    }
    
    lassert(self.tempPath);
    
    if (!self.iCloudAccess)
    {
        if (error != NULL)
        {
            NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
            NSString *errStr = LLocalizedString(@"iCloud is unreachable");
            [errorDetail setValue:errStr forKey:NSLocalizedDescriptionKey];
            
            *error = [NSError errorWithDomain:LCloudBackupErrorDomain code:LCloudBackupErrorAccess userInfo:errorDetail];
        }
        
        return NO;
    }
    
    // inform the delegate
    if (uploadDataDelegate && [uploadDataDelegate respondsToSelector:@selector(willBeginUploadingData:filename:)])
    {
        [uploadDataDelegate willBeginUploadingData:self filename:file.filename];
    }
    
    isUploading = YES;
    
    // put on queue
    dispatch_async(_queryDataQueue, ^{
        
        @try {
            lassert(_querySyncSemaphore == NULL);
            _querySyncSemaphore = dispatch_semaphore_create(0);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                NSError *err = nil;
                
                // start uploading the file
                lassert(!queryFile);
                
                queryFile = [[NSMetadataQuery alloc] init];
                [queryFile setSearchScopes:[NSArray arrayWithObject:NSMetadataQueryUbiquitousDocumentsScope]];

                NSPredicate *pred = [NSPredicate predicateWithFormat: @"%K == %@", NSMetadataItemFSNameKey, file.filename];
                [queryFile setPredicate:pred];
                
                if (_uploadFile != file) {
                    L_RELEASE(_uploadFile);
                    _uploadFile = [file retain];
                }
                
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(queryDidFinishGatheringForFile:) name:NSMetadataQueryDidFinishGatheringNotification object:queryFile];
                
                BOOL started = [queryFile startQuery];
                
                if (!started) {
                    lassert(false);
                    
                    NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
                    NSString *errStr = LLocalizedString(@"Could not start remote query");
                    [errorDetail setValue:errStr forKey:NSLocalizedDescriptionKey];
                    
                    err = [NSError errorWithDomain:LCloudBackupErrorDomain code:LCloudBackupErrorPathFromLoadDataNotExists userInfo:errorDetail];
                    
                    isUploading = NO;
                    
                    if (uploadDataDelegate && [uploadDataDelegate respondsToSelector:@selector(didCompleteUploadingDataWithError:filename:error:)])
                    {
                        [uploadDataDelegate didCompleteUploadingDataWithError:self filename:file.filename error:err];
                    }
                }
                
                // query has now started async
            });
            
            // wait here
            dispatch_semaphore_wait(_querySyncSemaphore, DISPATCH_TIME_FOREVER);
            dispatch_release(_querySyncSemaphore);
            _querySyncSemaphore = NULL;
        }
        @catch (NSException *e) {
            LogError(@"Unhandled exception while executing _queryDataQueue: %@", e);
            lassert(false);
            
            isUploading = NO;
            
            if (uploadDataDelegate && [uploadDataDelegate respondsToSelector:@selector(didCompleteUploadingDataWithError:filename:error:)])
            {
                [uploadDataDelegate didCompleteUploadingDataWithError:self filename:file.filename error:nil];
            }
        }
    });
    
    return YES;
}

- (void)queryDidFinishGatheringForFile:(NSNotification *)notification
{
    LogDebug(@"queryDidFinishGathering");
    
    NSMetadataQuery *queryData = [notification object];
    
    LCloudFile *file = _uploadFile;
    
    BOOL _isUploading = NO;
    
    NSURL *ubiq = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
    lassert(ubiq);
    
    NSURL *remoteUrl = [ubiq URLByAppendingPathComponent:file.iCloudPath];
    remoteUrl = [remoteUrl URLByAppendingPathComponent:file.filename];
    
    @try {
        
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:NSMetadataQueryDidFinishGatheringNotification
                                                      object:queryData];
        
        [queryData disableUpdates];
        [queryData stopQuery];
        
        BOOL fileExistsOnCloud = ([queryData resultCount] > 0);

        if (fileExistsOnCloud && !file.overwriteIfExisting)
        {
            LogInfo(@"File already existed on iCloud, overwrite: NO - so doing nothing");
            
            isUploading = NO;
            
            if (uploadDataDelegate && [uploadDataDelegate respondsToSelector:@selector(didCompleteUploadingData:filename:)])
            {
                [uploadDataDelegate didCompleteUploadingData:self filename:file.filename];
            }
            
            return;
        }
        
        @synchronized(_queryLock) {
            L_RELEASE(queryFile);
        }
        
        _isUploading = YES;
        
        dispatch_async(_loadDataQueue, ^{
            @try {
                if (_isCancelled)
                {
                    isUploading = NO;
                    return;
                }
                
                NSError *err = nil;
                BOOL success = [self uploadFile:file.filename getFileFromPath:file.filePathInApp remoteUrl:remoteUrl deleteFirst:fileExistsOnCloud error:&err];
                
                if (!success)
                {
                    isUploading = NO;
                    
                    if (uploadDataDelegate && [uploadDataDelegate respondsToSelector:@selector(didCompleteUploadingDataWithError:filename:error:)])
                    {
                        [uploadDataDelegate didCompleteUploadingDataWithError:self filename:file.filename error:err];
                    }
                    
                    return;
                }
                
                isUploading = NO;
                
                // success
                if (uploadDataDelegate && [uploadDataDelegate respondsToSelector:@selector(didCompleteUploadingData:filename:)])
                {
                    [uploadDataDelegate didCompleteUploadingData:self filename:file.filename];
                }
            }
            @catch (NSException *e) {
                LogError(@"Unhandled exception while executing _loadDataQueue: %@", e);
                lassert(false);
                
                isUploading = NO;
                
                if (uploadDataDelegate && [uploadDataDelegate respondsToSelector:@selector(didCompleteUploadingDataWithError:filename:error:)])
                {
                    [uploadDataDelegate didCompleteUploadingDataWithError:self filename:file.filename error:nil];
                }
            }
            @finally {
                 dispatch_semaphore_signal(_querySyncSemaphore);
            }
        });
    }
    @catch (NSException *e) {
        LogError(@"Unhandled exception while executing _queryDataQueue: %@", e);
        lassert(false);
        
        isUploading = NO;
        
        if (uploadDataDelegate && [uploadDataDelegate respondsToSelector:@selector(didCompleteUploadingDataWithError:filename:error:)])
        {
            [uploadDataDelegate didCompleteUploadingDataWithError:self filename:file.filename error:nil];
        }
    }
    @finally {
        if (!_isUploading) {
            dispatch_semaphore_signal(_querySyncSemaphore);
        }
    }
}

- (BOOL)uploadFile:(NSString*)localFilename getFileFromPath:(NSString*)getFileFromPath remoteUrl:(NSURL*)remoteUrl deleteFirst:(BOOL)deleteFirst error:(NSError**)error
{
    if (error != NULL)
    {
        *error = nil;
    }
    
    LogInfo(@"Upload file: from: %@, to: %@", localFilename, remoteUrl);
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    // copy the local file to a temp location
    if (!self.tempPath) {
        lassert(false);
        return NO;
    };
    
    NSString *tempFilename = [self.tempPath stringByAppendingPathComponent:localFilename];
    
    // remove if existing first
    if ([fileManager fileExistsAtPath:tempFilename]) {
        [fileManager removeItemAtPath:tempFilename error:nil];
    }
    
    BOOL ret = [fileManager copyItemAtPath:[getFileFromPath stringByAppendingPathComponent:localFilename] toPath:tempFilename error:error];
    
    if (!ret) {
        lassert(false);
        return NO;
    }
    
    BOOL success = NO;
    
    @try {
        // create icloud path
        NSURL *fPath = [remoteUrl URLByDeletingLastPathComponent];
        
        if (![remoteUrl checkResourceIsReachableAndReturnError:error])
        {
            // create new directory in iCloud
            if (![fileManager createDirectoryAtURL:fPath withIntermediateDirectories:YES attributes:nil error:error])
            {
                return NO;
            }
        }
        
        // delete it first
        if (deleteFirst) {
            success = [fileManager removeItemAtURL:remoteUrl error:error];
            
            if (!success) {
                return NO;
            }
        }
        
        // create file and give it URL
        NSURL *localUrl = [NSURL fileURLWithPath:tempFilename];
        lassert(localUrl);
        
        success = [fileManager setUbiquitous:YES
                                        itemAtURL:localUrl
                                   destinationURL:remoteUrl
                                            error:error];
    }
    @finally {
        [fileManager removeItemAtPath:tempFilename error:nil];
    }
    
    return success;
}


- (BOOL)startUploadingFiles:(NSArray*)uploadFiles error:(NSError **)error
{
    if (error != NULL)
    {
        *error = nil;
    }
    
    if (!uploadFiles)
    {
        if (error != NULL)
        {
            NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
            NSString *errStr = LLocalizedString(@"No files requested for uploading");
            [errorDetail setValue:errStr forKey:NSLocalizedDescriptionKey];
            
            *error = [NSError errorWithDomain:LCloudBackupErrorDomain code:LCloudBackupErrorUnknown userInfo:errorDetail];
        }
        
        return NO;
    }
    
    lassert(self.tempPath);
    
    if (!self.iCloudAccess)
    {
        if (error != NULL)
        {
            NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
            NSString *errStr = LLocalizedString(@"iCloud is unreachable");
            [errorDetail setValue:errStr forKey:NSLocalizedDescriptionKey];
            
            *error = [NSError errorWithDomain:LCloudBackupErrorDomain code:LCloudBackupErrorAccess userInfo:errorDetail];
        }
        
        return NO;
    }
    
    // inform the delegate
    if (uploadDataDelegate && [uploadDataDelegate respondsToSelector:@selector(willBeginUploadingData:filename:)])
    {
        [uploadDataDelegate willBeginUploadingData:self filename:nil];
    }
    
    isUploading = YES;
    
    // put on queue
    dispatch_async(_queryDataQueue, ^{
        
        @try {
            lassert(_querySyncSemaphore == NULL);
            _querySyncSemaphore = dispatch_semaphore_create(0);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                NSError *err = nil;
                
                // start uploading the file
                lassert(!queryFile);
                
                queryFile = [[NSMetadataQuery alloc] init];
                [queryFile setSearchScopes:[NSArray arrayWithObject:NSMetadataQueryUbiquitousDocumentsScope]];
                
                NSPredicate *pred = [NSPredicate predicateWithFormat: @"%K LIKE '*'", NSMetadataItemFSNameKey];
                [queryFile setPredicate:pred];
                
                if (_uploadFiles != uploadFiles)
                {
                    L_RELEASE(_uploadFiles);
                    _uploadFiles = [uploadFiles retain];
                }
                
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(queryDidFinishGathering:) name:NSMetadataQueryDidFinishGatheringNotification object:queryFile];
                
                BOOL started = [queryFile startQuery];
                
                if (!started)
                {
                    lassert(false);
                    
                    NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
                    NSString *errStr = LLocalizedString(@"Could not start remote query");
                    [errorDetail setValue:errStr forKey:NSLocalizedDescriptionKey];
                    
                    err = [NSError errorWithDomain:LCloudBackupErrorDomain code:LCloudBackupErrorPathFromLoadDataNotExists userInfo:errorDetail];
                    
                    isUploading = NO;
                    
                    if (uploadDataDelegate && [uploadDataDelegate respondsToSelector:@selector(didCompleteUploadingDataWithError:filename:error:)])
                    {
                        [uploadDataDelegate didCompleteUploadingDataWithError:self filename:nil error:err];
                    }
                }
                
                // query has now started async
            });
            
            // wait here
            dispatch_semaphore_wait(_querySyncSemaphore, DISPATCH_TIME_FOREVER);
            dispatch_release(_querySyncSemaphore);
            _querySyncSemaphore = NULL;
        }
        @catch (NSException *e)
        {
            LogError(@"Unhandled exception while executing _queryDataQueue: %@", e);
            lassert(false);
            
            isUploading = NO;
            
            if (uploadDataDelegate && [uploadDataDelegate respondsToSelector:@selector(didCompleteUploadingDataWithError:filename:error:)])
            {
                [uploadDataDelegate didCompleteUploadingDataWithError:self filename:nil error:nil];
            }
        }
    });
    
    return YES;
}

- (void)queryDidFinishGathering:(NSNotification *)notification
{
    LogDebug(@"queryDidFinishGathering");
    
    NSMetadataQuery *queryData = [notification object];
    
    BOOL _isUploading = NO;
    
    @try {
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:NSMetadataQueryDidFinishGatheringNotification
                                                      object:queryData];
        
        [queryData disableUpdates];
        [queryData stopQuery];
        
        NSMutableArray *arrayBackups = [NSMutableArray array];
        
        for (NSMetadataItem *item in [queryData results])
        {
            NSURL *url = [item valueForAttribute:NSMetadataItemURLKey];
            [arrayBackups addObject:url.lastPathComponent];
        }
        
        @synchronized(_queryLock) {
            L_RELEASE(queryFile);
        }
        
        _isUploading = YES;
        
        NSMutableArray *arrayFileForICloud = [NSMutableArray array];
        
        if (_uploadFiles && [_uploadFiles count] > 0)
        {
            BOOL isAddFile = NO;
            
            for (LCloudFile *file in _uploadFiles)
            {
                NSMutableDictionary *dic = [[[NSMutableDictionary alloc] init] autorelease];
                
                NSString *localFilename = file.filename;
                
                if (arrayBackups && [arrayBackups count] > 0)
                {
                    for (NSString *backupFilename in arrayBackups)
                    {
                        if ([backupFilename isEqualToString:localFilename] )
                        {
                            isAddFile = YES;
                            
                            if (file.overwriteIfExisting)
                            {
                                // added file exist and overwrite
                                [dic setObject:file forKey:@"file"];
                                [dic setObject:[NSNumber numberWithInteger:1] forKey:@"delete"];
                                
                                [arrayFileForICloud addObject:dic];
                                isAddFile = YES;
                            }
                            
                            break;
                        }
                    }
                }
                
                // added file is not exist
                if (!isAddFile)
                {
                    [dic setObject:file forKey:@"file"];
                    [dic setObject:[NSNumber numberWithInteger:0] forKey:@"delete"];
                    
                    [arrayFileForICloud addObject:dic];
                }
                
                isAddFile = NO;
            }
        }

        dispatch_async(_loadDataQueue, ^{
            @try {
//#warning delete me
//                [NSThread sleepForTimeInterval:5];
                
                NSURL *ubiq = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
                lassert(ubiq);
                
                if (_isCancelled)
                {
                    isUploading = NO;
                    return;
                }
                
                for (NSDictionary *dic in arrayFileForICloud)
                {
                    LCloudFile *file = [dic objectForKey:@"file"];
                    BOOL deleteFirst = [[dic objectForKey:@"delete"] boolValue];
                    
                    NSURL *remoteUrl = [[ubiq URLByAppendingPathComponent:file.iCloudPath] URLByAppendingPathComponent:file.filename];
                    
                    @try {
                        
                        NSError *err = nil;
                        BOOL success = [self uploadFile:file.filename getFileFromPath:file.filePathInApp remoteUrl:remoteUrl deleteFirst:deleteFirst error:&err];
                        
                        if (!success)
                        {
                            if (uploadDataDelegate && [uploadDataDelegate respondsToSelector:@selector(didCompleteUploadingDataWithError:filename:error:)])
                            {
                                [uploadDataDelegate didCompleteUploadingDataWithError:self filename:file.filename error:err];
                            }
                            
                            break;
                        }
                        
                        // success
                        if (uploadDataDelegate && [uploadDataDelegate respondsToSelector:@selector(didCompleteUploadingData:filename:)])
                        {
                            [uploadDataDelegate didCompleteUploadingData:self filename:file.filename];
                        }
                        
                        if (_isCancelled)
                        {
                            isUploading = NO;
                            return;
                        }
                    }
                    @catch (NSException *e)
                    {
                        LogError(@"Unhandled exception while executing _loadDataQueue: %@", e);
                        lassert(false);

                        if (uploadDataDelegate && [uploadDataDelegate respondsToSelector:@selector(didCompleteUploadingDataWithError:filename:error:)])
                        {
                            [uploadDataDelegate didCompleteUploadingDataWithError:self filename:file.filename error:nil];
                        }
                        
                        dispatch_semaphore_signal(_querySyncSemaphore);
                        
                        return;
                    }
                }
                
                isUploading = NO;
            }
            @finally
            {
                dispatch_semaphore_signal(_querySyncSemaphore);
            }
        });
    }
    @catch (NSException *exception)
    {
        LogError(@"Unhandled exception while executing _queryDataQueue: %@", exception);
        lassert(false);
        
        isUploading = NO;
        
        if (uploadDataDelegate && [uploadDataDelegate respondsToSelector:@selector(didCompleteUploadingDataWithError:filename:error:)])
        {
            [uploadDataDelegate didCompleteUploadingDataWithError:self filename:nil error:nil];
        }
    }
    @finally
    {
        if (!_isUploading)
        {
            dispatch_semaphore_signal(_querySyncSemaphore);
        }
        
        
    }
}

#pragma mark - Methods Download File

- (BOOL)getFilesFromICloud:(NSError**)error
{
    if (error != NULL)
    {
        *error = nil;
    }
    
    if (!self.iCloudAccess)
    {
        if (error != NULL)
        {
            NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
            NSString *errStr = LLocalizedString(@"iCloud is unreachable");
            [errorDetail setValue:errStr forKey:NSLocalizedDescriptionKey];
            
            *error = [NSError errorWithDomain:LCloudBackupErrorDomain code:LCloudBackupErrorAccess userInfo:errorDetail];
        }
        
        return NO;
    }
    
    if (downloadDataDelegate && [downloadDataDelegate respondsToSelector:@selector(willBeginGettingFilenames:)])
    {
        [downloadDataDelegate willBeginGettingFilenames:self];
    }
    
    dispatch_async(_queryDataQueueDownload, ^{
        
        @try {
            lassert(_querySyncSemaphoreDownload == NULL);
            _querySyncSemaphoreDownload = dispatch_semaphore_create(0);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                NSError *err = nil;
                lassert(!queryFile);
                
                queryFile = [[NSMetadataQuery alloc] init];
                [queryFile setSearchScopes:[NSArray arrayWithObject:NSMetadataQueryUbiquitousDocumentsScope]];

                NSPredicate *pred = [NSPredicate predicateWithFormat: @"%K LIKE '*'", NSMetadataItemFSNameKey];
                [queryFile setPredicate:pred];
                
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileListReceived:) name:NSMetadataQueryDidFinishGatheringNotification object:queryFile];
                
                BOOL started = [queryFile startQuery];
                
                if (!started)
                {
                    lassert(false);
                    
                    NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
                    NSString *errStr = LLocalizedString(@"Could not start remote query");
                    [errorDetail setValue:errStr forKey:NSLocalizedDescriptionKey];
                    
                    err = [NSError errorWithDomain:LCloudBackupErrorDomain code:LCloudBackupErrorPathFromLoadDataNotExists userInfo:errorDetail];
                    
                    if (downloadDataDelegate && [downloadDataDelegate respondsToSelector:@selector(didCompleteGettingFilenamesWithError:error:)])
                    {
                        [downloadDataDelegate didCompleteGettingFilenamesWithError:self error:err];
                    }
                }
                
                // query has now started async
            });
            
            // wait here
            dispatch_semaphore_wait(_querySyncSemaphoreDownload, DISPATCH_TIME_FOREVER);
            dispatch_release(_querySyncSemaphoreDownload);
            _querySyncSemaphoreDownload = NULL;

        }
        @catch (NSException *e)
        {
            LogError(@"Unhandled exception while executing _queryDataQueueDownload: %@", e);
            lassert(false);
        }
    });
    
    return YES;
}

- (void)fileListReceived:(NSNotification *)notification
{
    LogDebug(@"fileListReceived");
    
    NSMetadataQuery *queryData = [notification object];
    
    BOOL _isDownloading = NO;
    
    @try {
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:NSMetadataQueryDidFinishGatheringNotification
                                                      object:queryData];
        
        [queryData disableUpdates];
        [queryData stopQuery];
        
        NSMutableArray *_downloadFiles = [[[NSMutableArray alloc] init] autorelease];
        
        for (NSMetadataItem *item in [queryData results])
        {
            NSURL *url = [item valueForAttribute:NSMetadataItemURLKey];
            [_downloadFiles addObject:url.lastPathComponent];
        }
        
        arrayFilesInICloud = [_downloadFiles retain];
        
        @synchronized(_queryLock) {
            L_RELEASE(queryFile);
        }
    }
    @catch (NSException *exception)
    {
        LogError(@"Unhandled exception : %@", exception);
        lassert(false);
        
        if (downloadDataDelegate && [downloadDataDelegate respondsToSelector:@selector(didCompleteGettingFilenamesWithError:error:)])
        {
            [downloadDataDelegate didCompleteGettingFilenamesWithError:self error:nil];
        }
    }
    @finally
    {
        if (downloadDataDelegate && [downloadDataDelegate respondsToSelector:@selector(didCompleteGettingFilenames:)])
        {
            [downloadDataDelegate didCompleteGettingFilenames:self];
        }
        
        if (!_isDownloading)
        {
            dispatch_semaphore_signal(_querySyncSemaphoreDownload);
        }
    }
}

//
- (void)downloadFileFromICloud:(NSString*)filename pathToDownload:(NSString*)pathToDownload iCloudPath:(NSString*)iCloudPath
{
    NSURL *ubiq = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
    lassert(ubiq);
    
    NSURL *itemURL = [[ubiq URLByAppendingPathComponent:iCloudPath] URLByAppendingPathComponent:filename];
    
    NSError *err = nil;
    NSFileCoordinator *coordinator = [[[NSFileCoordinator alloc] initWithFilePresenter:nil] autorelease];
    
    [coordinator coordinateReadingItemAtURL:itemURL options:0 error:&err byAccessor:^(NSURL *newURL) {
        
        NSData *data = [NSData dataWithContentsOfURL:newURL];
        
        if (!data)
        {
            NSError *theError = nil;
            NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
            NSString *errStr = LLocalizedString(@"File not exist on iCloud");
            [errorDetail setValue:errStr forKey:NSLocalizedDescriptionKey];
            
            theError = [NSError errorWithDomain:LCloudBackupErrorDomain code:LCloudBackupErrorICloudFileNotExist userInfo:errorDetail];
            
            if (downloadDataDelegate && [downloadDataDelegate respondsToSelector:@selector(didCompleteDownloadingDataWithError:filename:error:)])
            {
                [downloadDataDelegate didCompleteDownloadingDataWithError:self filename:filename error:theError];
            }
            
            return;
        }
        
        NSString  *newPath = [pathToDownload stringByAppendingPathComponent:filename];
        
        NSFileManager *fm = [NSFileManager defaultManager];
        
        // create newPath if not exists
        if (![fm fileExistsAtPath:pathToDownload])
        {
            NSError *err = nil;
            BOOL ret = [fm createDirectoryAtPath:pathToDownload withIntermediateDirectories:YES attributes:nil error:&err];
            
            if (!ret)
            {
                LogError(@"Could not create local download path: %@", err);
            }
        }
        
        BOOL success = [fm createFileAtPath:newPath
                                    contents:data
                                    attributes:nil];
        if (!success)
        {
            LogError(@"Could not create iCloud path: %@", newPath);
            
            if (downloadDataDelegate && [downloadDataDelegate respondsToSelector:@selector(didCompleteDownloadingDataWithError:filename:error:)])
            {
                [downloadDataDelegate didCompleteDownloadingDataWithError:self filename:filename error:nil];
            }
        }
        
    }];
}

- (BOOL)startDownloadingFile:(LCloudFile*)file error:(NSError **)error
{
    if (error != NULL)
    {
        *error = nil;
    }
    
    if (!self.iCloudAccess)
    {
        if (error != NULL)
        {
            NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
            NSString *errStr = LLocalizedString(@"iCloud is unreachable");
            [errorDetail setValue:errStr forKey:NSLocalizedDescriptionKey];
            
            *error = [NSError errorWithDomain:LCloudBackupErrorDomain code:LCloudBackupErrorAccess userInfo:errorDetail];
        }
        
        return NO;
    }
    
    if (downloadDataDelegate && [downloadDataDelegate respondsToSelector:@selector(willBeginDownloadingData:filename:)])
    {
        [downloadDataDelegate willBeginDownloadingData:self filename:file.filename];
    }

    dispatch_async(_downloadDataQueue, ^{
        @try {
            
            [self downloadFileFromICloud:file.filename pathToDownload:file.filePathInApp iCloudPath:file.iCloudPath];
            
        }
        @catch (NSException *exception)
        {
            LogError(@"Unhandled exception while executing _downloadDataQueue: %@", exception);
            lassert(false);
            
            if (downloadDataDelegate && [downloadDataDelegate respondsToSelector:@selector(didCompleteDownloadingDataWithError:filename:error:)])
            {
                [downloadDataDelegate didCompleteDownloadingDataWithError:self filename:file.filename error:nil];
            }
        }
        @finally
        {
            if (downloadDataDelegate && [downloadDataDelegate respondsToSelector:@selector(didCompleteDownloadingData:filename:)])
            {
                [downloadDataDelegate didCompleteDownloadingData:self filename:file.filename];
            }
        }
    });
    
    return YES;
}

- (BOOL)startDownloadingFiles:(NSArray*)downloadFiles error:(NSError **)error
{
    if (error != NULL)
    {
        *error = nil;
    }
    
    if (!self.iCloudAccess)
    {
        if (error != NULL)
        {
            NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
            NSString *errStr = LLocalizedString(@"iCloud is unreachable");
            [errorDetail setValue:errStr forKey:NSLocalizedDescriptionKey];
            
            *error = [NSError errorWithDomain:LCloudBackupErrorDomain code:LCloudBackupErrorAccess userInfo:errorDetail];
        }
        
        return NO;
    }
    
    if (downloadDataDelegate && [downloadDataDelegate respondsToSelector:@selector(willBeginDownloadingData:filename:)])
    {
        [downloadDataDelegate willBeginDownloadingData:self filename:nil];
    }
    
    dispatch_async(_downloadDataQueue, ^{
        
//        NSURL *ubiq = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
//        lassert(ubiq);
        
        for (LCloudFile *file in downloadFiles)
        {
            @autoreleasepool {
                
                @try {
                    
                    [self downloadFileFromICloud:file.filename pathToDownload:file.filePathInApp iCloudPath:file.iCloudPath];
                    
                }
                @catch (NSException *exception)
                {
                    LogError(@"Unhandled exception while executing _downloadDataQueue: %@", exception);
                    lassert(false);
                    
                    if (downloadDataDelegate && [downloadDataDelegate respondsToSelector:@selector(didCompleteDownloadingDataWithError:filename:error:)])
                    {
                        [downloadDataDelegate didCompleteDownloadingDataWithError:self filename:file.filename error:nil];
                    }
                }
                @finally
                {
                    if (downloadDataDelegate && [downloadDataDelegate respondsToSelector:@selector(didCompleteDownloadingData:filename:)])
                    {
                        [downloadDataDelegate didCompleteDownloadingData:self filename:file.filename];
                    }
                }
            }
        }

    });
    
    return YES;
}

#pragma mark - remove from iCloud

- (BOOL)removeFileFromICloud:(LCloudFile*)file error:(NSError **)error
{
    if (error != NULL)
    {
        *error = nil;
    }
    
    if (!self.iCloudAccess)
    {
        if (error != NULL)
        {
            NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
            NSString *errStr = LLocalizedString(@"iCloud is unreachable");
            [errorDetail setValue:errStr forKey:NSLocalizedDescriptionKey];
            
            *error = [NSError errorWithDomain:LCloudBackupErrorDomain code:LCloudBackupErrorAccess userInfo:errorDetail];
        }
        
        return NO;
    }
    
    if (!file)
    {
        lassert(false);
        return NO;
    }
    
    NSError *err = nil;
    BOOL result = [self removeFile:file error:&err];
    
    if (!result)
    {
        LogError(@"Error while removing a file from iCloud: %@, filename: %@", err, file.filename);
        lassert(false);
        return NO;
    }
    
    return YES;
}

- (BOOL)removeFilesFromICloud:(NSArray*)files error:(NSError **)error
{
    if (error != NULL)
    {
        *error = nil;
    }
    
    if (!self.iCloudAccess)
    {
        if (error != NULL)
        {
            NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
            NSString *errStr = LLocalizedString(@"iCloud is unreachable");
            [errorDetail setValue:errStr forKey:NSLocalizedDescriptionKey];
            
            *error = [NSError errorWithDomain:LCloudBackupErrorDomain code:LCloudBackupErrorAccess userInfo:errorDetail];
        }
        
        return NO;
    }
    
    if (!files || (files && [files count] == 0))
    {
        lassert(false);
        return NO;
    }
    
    for (LCloudFile *file in files)
    {
        NSError *err = nil;
        BOOL result = [self removeFile:file error:&err];
        
        if (!result)
        {
            LogError(@"Error while removing a file from iCloud: %@, filename: %@", err, file.filename);
            lassert(false);
            return NO;
        }
    }
    
    return YES;
}

- (BOOL)removeFile:(LCloudFile*)file error:(NSError **)error
{
    NSURL *ubiq = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
    NSURL *url = [[ubiq URLByAppendingPathComponent:file.iCloudPath] URLByAppendingPathComponent:file.filename];
    
    BOOL success = [[NSFileManager defaultManager] removeItemAtURL:url error:error];
    
    if (!success)
    {
        lassert(false);
        return NO;
    }
    
    return YES;
}

@end
