//
//  SSHardwareInfo.h
//  SystemServicesDemo
//
//  Created by Shmoopi LLC on 9/15/12.
//  Copyright (c) 2012 Shmoopi LLC. All rights reserved.
//

#import "SystemServicesConstants.h"

@interface SSHardwareInfo : NSObject

// System Hardware Information

// System Uptime (dd hh mm)
+ (NSString *)SystemUptime;

// Model of Device
+ (NSString *)DeviceModel;

// Device Name
+ (NSString *)DeviceName;

// System Name
+ (NSString *)SystemName;

// System Version
+ (NSString *)SystemVersion;

// System Device Type (iPhone1,0) (Formatted = iPhone 1)
+ (NSString *)SystemDeviceTypeFormatted:(BOOL)formatted;

// Get the Screen Width (X)
+ (NSInteger)ScreenWidth;

// Get the Screen Height (Y)
+ (NSInteger)ScreenHeight;

// Multitasking enabled?
+ (BOOL)MultitaskingEnabled;

// Proximity sensor enabled?
+ (BOOL)ProximitySensorEnabled;

// Debugger Attached?
+ (BOOL)DebuggerAttached;

// Plugged In?
+ (BOOL)PluggedIn;

@end
