//
//  SSProcessorInfo.h
//  SystemServicesDemo
//
//  Created by Shmoopi LLC on 9/17/12.
//  Copyright (c) 2012 Shmoopi LLC. All rights reserved.
//

#import "SystemServicesConstants.h"

@interface SSProcessorInfo : NSObject

// Processor Information

// Number of processors
+ (NSInteger)NumberProcessors;

// Number of Active Processors
+ (NSInteger)NumberActiveProcessors;

// Processor Speed in MHz
+ (NSInteger)ProcessorSpeed;

// Processor Bus Speed in MHz
+ (NSInteger)ProcessorBusSpeed;

@end
