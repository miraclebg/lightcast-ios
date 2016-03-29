//
//  LCloudBackupDownloadDataDelegate.h
//  Lightcast
//
//  Created by Dimitrinka Ivanova on 1/22/14.
//  Copyright (c) 2014 Nimasystems Ltd. All rights reserved.
//

@class LCloudBackup;

@protocol LCloudBackupDownloadDataDelegate <NSObject>

@optional

- (void)willBeginDownloadingData:(LCloudBackup*)controller filename:(NSString*)filename;
- (void)didCompleteDownloadingData:(LCloudBackup*)controller filename:(NSString*)filename;
- (void)didCompleteDownloadingDataWithError:(LCloudBackup*)controller filename:(NSString*)filename error:(NSError*)error;

- (void)willBeginGettingFilenames:(LCloudBackup*)controller;
- (void)didCompleteGettingFilenames:(LCloudBackup*)controller;
- (void)didCompleteGettingFilenamesWithError:(LCloudBackup*)controller error:(NSError*)error;

@end
