//
//  SSNetworkInfo.h
//  SystemServicesDemo
//
//  Created by Shmoopi LLC on 9/18/12.
//  Copyright (c) 2012 Shmoopi LLC. All rights reserved.
//

#import "SystemServicesConstants.h"

@interface SSNetworkInfo : NSObject

// Network Information

// Get Current IP Address
+ (NSString *)CurrentIPAddress;

// Get Current MAC Address
+ (NSString *)CurrentMACAddress;

// Get Cell IP Address
+ (NSString *)CellIPAddress;

// Get Cell MAC Address
+ (NSString *)CellMACAddress;

// Get Cell Netmask Address
+ (NSString *)CellNetmaskAddress;

// Get Cell Broadcast Address
+ (NSString *)CellBroadcastAddress;

// Get WiFi IP Address
+ (NSString *)WiFiIPAddress;

// Get WiFi MAC Address
+ (NSString *)WiFiMACAddress;

// Get WiFi Netmask Address
+ (NSString *)WiFiNetmaskAddress;

// Get WiFi Broadcast Address
+ (NSString *)WiFiBroadcastAddress;

// Connected to WiFi?
+ (BOOL)ConnectedToWiFi;

// Connected to Cellular Network?
+ (BOOL)ConnectedToCellNetwork;

@end
