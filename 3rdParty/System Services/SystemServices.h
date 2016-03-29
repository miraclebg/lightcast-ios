//
//  SystemServices.h
//  SystemServicesDemo
//
//  Created by Shmoopi LLC on 9/15/12.
//  Copyright (c) 2012 Shmoopi LLC. All rights reserved.
//

#import "SSHardwareInfo.h"
#import "SSJailbreakCheck.h"
#import "SSProcessorInfo.h"
#import "SSAccessoryInfo.h"

#ifdef CORETELEPHONY_EXTERN_CLASS
#import "SSCarrierInfo.h"
#endif

#import "SSBatteryInfo.h"
#import "SSNetworkInfo.h"
#import "SSProcessInfo.h"
#import "SSDiskInfo.h"
#import "SSMemoryInfo.h"
#import "SSAccelerometerInfo.h"
#import "SSLocalizationInfo.h"
#import "SSApplicationInfo.h"
#import "SSUUID.h"

/* New Hardware Stuff, new accelerometer stuff, localization stuff, and application info */

@interface SystemServices : NSObject

// System Information

// Get all System Information (All Methods)
+ (NSDictionary *)AllSystemInformation;

/* Hardware Information */

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

/* Jailbreak Check */

// Jailbroken?
+ (BOOL)Jailbroken;

/* Processor Information */

// Number of processors
+ (NSInteger)NumberProcessors;

// Number of Active Processors
+ (NSInteger)NumberActiveProcessors;

// Processor Speed in MHz
+ (NSInteger)ProcessorSpeed;

// Processor Bus Speed in MHz
+ (NSInteger)ProcessorBusSpeed;

#ifdef EA_EXTERN_CLASS_AVAILABLE
/* Accessory Information */

// Are any accessories attached?
+ (BOOL)AccessoriesAttached;

// Are headphone attached?
+ (BOOL)HeadphonesAttached;

// Number of attached accessories
+ (NSInteger)NumberAttachedAccessories;

// Name of attached accessory/accessories (seperated by , comma's)
+ (NSString *)NameAttachedAccessories;
#endif

#ifdef OPT_TELEPHONY
/* Carrier Information */

// Carrier Name
+ (NSString *)CarrierName;

// Carrier Country
+ (NSString *)CarrierCountry;

// Carrier Mobile Country Code
+ (NSString *)CarrierMobileCountryCode;

// Carrier ISO Country Code
+ (NSString *)CarrierISOCountryCode;

// Carrier Mobile Network Code
+ (NSString *)CarrierMobileNetworkCode;

// Carrier Allows VOIP
+ (BOOL)CarrierAllowsVOIP;
#endif

/* Battery Information */

// Battery Level
+ (float)BatteryLevel;

// Charging?
+ (BOOL)Charging;

// Fully Charged?
+ (BOOL)FullyCharged;

/* Network Information */

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

/* Process Information */

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

/* Disk Information */

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

/* Memory Information */

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

/* Accelerometer Information */

// Device Orientation
+ (UIInterfaceOrientation)DeviceOrientation;

// Accelerometer X Value
//+ (float)AccelerometerXValue;

// Accelerometer Y Value
//+ (float)AccelerometerYValue;

// Accelerometer Z Value
//+ (float)AccelerometerZValue;

/* Localization Information */

// Country
+ (NSString *)Country;

// Locale
+ (NSString *)Locale;

// Language
+ (NSString *)Language;

// TimeZone
+ (NSString *)TimeZone;

// Currency Symbol
+ (NSString *)Currency;

/* Application Information */

// Application Version
+ (NSString *)ApplicationVersion;

// Clipboard Content
+ (NSString *)ClipboardContent;

/* Universal Unique Identifiers */

// Unique ID
+ (NSString *)UniqueID;

// Device Signature
+ (NSString *)DeviceSignature;

// CFUUID
+ (NSString *)CFUUID;

@end
