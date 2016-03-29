//
//  LCloudBackupLoadDataDelegate.h
//  Lightcast
//
//  Created by Dimitrinka Ivanova on 1/22/14.
//  Copyright (c) 2014 Nimasystems Ltd. All rights reserved.
//

@class LCloudBackup;

@protocol LCloudBackupLoadDataDelegate <NSObject>

@optional

- (void)willBeginUploadingData:(LCloudBackup*)controller filename:(NSString*)filename;
- (void)didCompleteUploadingData:(LCloudBackup*)controller filename:(NSString*)filename;
- (void)didCompleteUploadingDataWithError:(LCloudBackup*)controller filename:(NSString*)filename error:(NSError*)error;

@end
