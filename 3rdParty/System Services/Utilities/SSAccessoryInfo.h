//
//  SSAccessoryInfo.h
//  SystemServicesDemo
//
//  Created by Shmoopi LLC on 9/17/12.
//  Copyright (c) 2012 Shmoopi LLC. All rights reserved.
//

#import "SystemServicesConstants.h"

@interface SSAccessoryInfo : NSObject

// Accessory Information

// Are any accessories attached?
+ (BOOL)AccessoriesAttached;

// Are headphone attached?
+ (BOOL)HeadphonesAttached;

// Number of attached accessories
+ (NSInteger)NumberAttachedAccessories;

// Name of attached accessory/accessories (seperated by , comma's)
+ (NSString *)NameAttachedAccessories;

@end
