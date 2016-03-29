//
//  SSDiskInfo.h
//  SystemServicesDemo
//
//  Created by Shmoopi LLC on 9/18/12.
//  Copyright (c) 2012 Shmoopi LLC. All rights reserved.
//

#import "SystemServicesConstants.h"

@interface SSDiskInfo : NSObject

// Disk Information

// Total Disk Space
+ (NSString *)DiskSpace;

// Total Free Disk Space
+ (NSString *)FreeDiskSpace:(BOOL)inPercent;

// Total Used Disk Space
+ (NSString *)UsedDiskSpace:(BOOL)inPercent;

// Get the total disk space in long format
+ (long long)LongDiskSpace;

// Get the total free disk space in long format
+ (long long)LongFreeDiskSpace;

@end
