//
//  LDeviceSystemInfo.h
//  Lightcast
//
//  Created by Martin N. Kovachev on 05.01.13.
//  Copyright (c) 2013 г. Nimasystems Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

extern CGFloat const kLDeviceSystemInfoDefaultNavBarHeight;
extern CGFloat const kLDeviceSystemInfoDefaultTabBarHeight;

@interface LDeviceSystemInfo : NSObject

@property (retain, readonly, getter = getPrimaryMacAddress) NSString *primaryMacAddress;
@property (retain, readonly, getter = getDeviceName) NSString *deviceName;
@property (retain, readonly, getter = getDeviceDescription) NSString *deviceDescription;

@property (retain, readonly, getter = getCurrentResolution) NSString *currentResolution;

@property (retain, readonly, getter = getModel) NSString *model;                    // e.g. @"iPhone", @"iPod Touch"
@property (retain, readonly, getter = getLocalizedModel) NSString *localizedModel;  // localized version of model
@property (retain, readonly, getter = getSystemName) NSString *systemName;          // e.g. @"iPhone OS"
@property (retain, readonly, getter = getSystemVersion) NSString *systemVersion;    // e.g. @"2.0"

#ifdef TARGET_IOS
@property (readonly, getter = getScreenBounds) CGRect screenBounds;
@property (readonly, getter = getApplicationFrame) CGRect applicationFrame;
@property (readonly, getter = getStatusBarHeight) NSInteger statusBarHeight;
@property (readonly, getter = getNavBarFrame) CGRect navBarFrame;

@property (readonly, getter = getOrientation) UIDeviceOrientation orientation;

@property (retain, readonly, getter = getUUID) NSString *UUID;
#endif

#ifdef TARGET_OSX
- (NSString*)cpuName;
#endif

@end