//
//  SSProcessInfo.h
//  SystemServicesDemo
//
//  Created by Shmoopi LLC on 9/18/12.
//  Copyright (c) 2012 Shmoopi LLC. All rights reserved.
//

#import "SystemServicesConstants.h"

@interface SSProcessInfo : NSObject

// Process Information

// Process ID
+ (int)ProcessID;

// Process Name
+ (NSString *)ProcessName;

// Process Status
+ (int)ProcessStatus;

// Parent Process ID
+ (int)ParentPID;

// Parent ID for a certain PID
+ (int)ParentPIDForProcess:(int)pid;

// List of process information including PID's, Names, PPID's, and Status'
+ (NSMutableArray *)ProcessesInformation;

@end
