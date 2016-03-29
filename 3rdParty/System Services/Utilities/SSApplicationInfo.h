//
//  SSApplicationInfo.h
//  SystemServicesDemo
//
//  Created by Kramer on 9/20/12.
//  Copyright (c) 2012 Shmoopi LLC. All rights reserved.
//

#import "SystemServicesConstants.h"

@interface SSApplicationInfo : NSObject

// Application Information

// Application Version
+ (NSString *)ApplicationVersion;

// Clipboard Content
+ (NSString *)ClipboardContent;

@end
