//
//  LCloudFile.h
//  Lightcast
//
//  Created by Dimitrinka Ivanova on 1/29/14.
//  Copyright (c) 2014 Nimasystems Ltd. All rights reserved.
//

@interface LCloudFile : NSObject

@property (nonatomic, copy) NSString *filename;
@property (nonatomic, copy) NSString *iCloudPath;
@property (nonatomic, copy) NSString *filePathInApp;
@property (nonatomic, assign) BOOL overwriteIfExisting;
@property (nonatomic, copy) NSString *formatFile;

@end
