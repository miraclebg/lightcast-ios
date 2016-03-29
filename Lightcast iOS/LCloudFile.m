//
//  LCloudFile.m
//  Lightcast
//
//  Created by Dimitrinka Ivanova on 1/29/14.
//  Copyright (c) 2014 Nimasystems Ltd. All rights reserved.
//

#import "LCloudFile.h"

@implementation LCloudFile

@synthesize
filename,
iCloudPath,
filePathInApp,
overwriteIfExisting,
formatFile;

#pragma mark - Initialization / Finalization

- (id)init
{
    self = [super init];
    if (self)
    {
        //
    }
    return self;
}

- (void)dealloc
{
    L_RELEASE(filename);
    L_RELEASE(iCloudPath);
    L_RELEASE(filePathInApp);
    L_RELEASE(formatFile);
    
    [super dealloc];
}

@end
