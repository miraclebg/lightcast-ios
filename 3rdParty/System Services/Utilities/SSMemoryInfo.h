//
//  SSMemoryInfo.h
//  SystemServicesDemo
//
//  Created by Shmoopi LLC on 9/19/12.
//  Copyright (c) 2012 Shmoopi LLC. All rights reserved.
//

#import "SystemServicesConstants.h"

@interface SSMemoryInfo : NSObject

// Memory Information

// Total Memory
+ (double)TotalMemory;

// Free Memory
+ (double)FreeMemory:(BOOL)inPercent;

// Used Memory
+ (double)UsedMemory:(BOOL)inPercent;

// Available Memory
+ (double)AvailableMemory:(BOOL)inPercent;

// Active Memory
+ (double)ActiveMemory:(BOOL)inPercent;

// Inactive Memory
+ (double)InactiveMemory:(BOOL)inPercent;

// Wired Memory
+ (double)WiredMemory:(BOOL)inPercent;

// Purgable Memory
+ (double)PurgableMemory:(BOOL)inPercent;

@end
