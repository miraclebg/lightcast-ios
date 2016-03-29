//
//  SystemServices.m
//  SystemServicesDemo
//
//  Created by Shmoopi LLC on 9/15/12.
//  Copyright (c) 2012 Shmoopi LLC. All rights reserved.
//

#import "SystemServices.h"

@implementation SystemServices

// System Information

// Get all System Information (All Methods)
+ (NSDictionary *)AllSystemInformation {
    // Create an array
    NSDictionary *SystemInformationDict;
    
    // Set up all System Values
    NSString *SystemUptime = [self SystemUptime];
    NSString *DeviceModel = [self DeviceModel];
    NSString *DeviceName = [self DeviceName];
    NSString *SystemName = [self SystemName];
    NSString *SystemVersion = [self SystemVersion];
    NSString *SystemDeviceTypeFormattedNO = [self SystemDeviceTypeFormatted:NO];
    NSString *SystemDeviceTypeFormattedYES = [self SystemDeviceTypeFormatted:YES];
    NSString *ScreenWidth = [NSString stringWithFormat:@"%ld", (long)[self ScreenWidth]];
    NSString *ScreenHeight = [NSString stringWithFormat:@"%ld", (long)[self ScreenHeight]];
    NSString *MultitaskingEnabled = [NSString stringWithFormat:@"%d", [self MultitaskingEnabled]];
    NSString *ProximitySensorEnabled = [NSString stringWithFormat:@"%d", [self ProximitySensorEnabled]];
    NSString *DebuggerAttached = [NSString stringWithFormat:@"%d", [self DebuggerAttached]];
    NSString *PluggedIn = [NSString stringWithFormat:@"%d", [self PluggedIn]];
    NSString *Jailbroken = [NSString stringWithFormat:@"%d", [self Jailbroken]];
    NSString *NumberProcessors = [NSString stringWithFormat:@"%ld", (long)[self NumberProcessors]];
    NSString *NumberActiveProcessors = [NSString stringWithFormat:@"%ld", (long)[self NumberActiveProcessors]];
    NSString *ProcessorSpeed = [NSString stringWithFormat:@"%ld", (long)[self ProcessorSpeed]];
    NSString *ProcessorBusSpeed = [NSString stringWithFormat:@"%ld", (long)[self ProcessorBusSpeed]];
    
#ifdef EA_EXTERN_CLASS_AVAILABLE
    NSString *AccessoriesAttached = [NSString stringWithFormat:@"%d", [self AccessoriesAttached]];
    NSString *HeadphonesAttached = [NSString stringWithFormat:@"%d", [self HeadphonesAttached]];
    NSString *NumberAttachedAccessories = [NSString stringWithFormat:@"%d", [self NumberAttachedAccessories]];
    NSString *NameAttachedAccessories = [self NameAttachedAccessories];
#endif
    
#ifdef OPT_TELEPHONY
    NSString *CarrierName = [self CarrierName];
    NSString *CarrierCountry = [self CarrierCountry];
    NSString *CarrierMobileCountryCode = [self CarrierMobileCountryCode];
    NSString *CarrierISOCountryCode = [self CarrierISOCountryCode];
    NSString *CarrierMobileNetworkCode = [self CarrierMobileNetworkCode];
    NSString *CarrierAllowsVOIP = [NSString stringWithFormat:@"%d", [self CarrierAllowsVOIP]];
#endif
    
    NSString *BatteryLevel = [NSString stringWithFormat:@"%f", [self BatteryLevel]];
    NSString *Charging = [NSString stringWithFormat:@"%d", [self Charging]];
    NSString *FullyCharged = [NSString stringWithFormat:@"%d", [self FullyCharged]];
    NSString *CurrentIPAddress = [self CurrentIPAddress];
    NSString *CurrentMACAddress = [self CurrentMACAddress];
    NSString *CellIPAddress = [self CellIPAddress];
    NSString *CellMACAddress = [self CellMACAddress];
    NSString *CellNetmaskAddress = [self CellNetmaskAddress];
    NSString *CellBroadcastAddress = [self CellBroadcastAddress];
    NSString *WiFiIPAddress = [self WiFiIPAddress];
    NSString *WiFiMACAddress = [self WiFiMACAddress];
    NSString *WiFiNetmaskAddress = [self WiFiNetmaskAddress];
    NSString *WiFiBroadcastAddress = [self WiFiBroadcastAddress];
    NSString *ConnectedToWiFi = [NSString stringWithFormat:@"%d", [self ConnectedToWiFi]];
    NSString *ConnectedToCellNetwork = [NSString stringWithFormat:@"%d", [self ConnectedToCellNetwork]];
    NSString *ProcessID = [NSString stringWithFormat:@"%d", [self ProcessID]];
    NSString *ProcessName = [self ProcessName];
    NSString *ProcessStatus = [NSString stringWithFormat:@"%d", [self ProcessStatus]];
    NSString *ParentPID = [NSString stringWithFormat:@"%d", [self ParentPID]];
    //NSMutableArray *ProcessesInformation = [self ProcessesInformation];
    NSString *DiskSpace = [self DiskSpace];
    NSString *FreeDiskSpaceNO = [self FreeDiskSpace:NO];
    NSString *FreeDiskSpaceYES = [self FreeDiskSpace:YES];
    NSString *UsedDiskSpaceNO = [self UsedDiskSpace:NO];
    NSString *UsedDiskSpaceYES = [self UsedDiskSpace:YES];
    NSString *LongDiskSpace = [NSString stringWithFormat:@"%lld", [self LongDiskSpace]];
    NSString *LongFreeDiskSpace = [NSString stringWithFormat:@"%lld", [self LongFreeDiskSpace]];
    NSString *TotalMemory = [NSString stringWithFormat:@"%f", [self TotalMemory]];
    NSString *FreeMemoryNO = [NSString stringWithFormat:@"%f", [self FreeMemory:NO]];
    NSString *FreeMemoryYES = [NSString stringWithFormat:@"%f", [self FreeMemory:YES]];
    NSString *UsedMemoryNO = [NSString stringWithFormat:@"%f", [self UsedMemory:NO]];
    NSString *UsedMemoryYES = [NSString stringWithFormat:@"%f", [self UsedMemory:YES]];
    NSString *AvailableMemoryNO = [NSString stringWithFormat:@"%f", [self AvailableMemory:NO]];
    NSString *AvailableMemoryYES = [NSString stringWithFormat:@"%f", [self AvailableMemory:YES]];
    NSString *ActiveMemoryNO = [NSString stringWithFormat:@"%f", [self ActiveMemory:NO]];
    NSString *ActiveMemoryYES = [NSString stringWithFormat:@"%f", [self ActiveMemory:YES]];
    NSString *InactiveMemoryNO = [NSString stringWithFormat:@"%f", [self InactiveMemory:NO]];
    NSString *InactiveMemoryYES = [NSString stringWithFormat:@"%f", [self InactiveMemory:YES]];
    NSString *WiredMemoryNO = [NSString stringWithFormat:@"%f", [self WiredMemory:NO]];
    NSString *WiredMemoryYES = [NSString stringWithFormat:@"%f", [self WiredMemory:YES]];
    NSString *PurgableMemoryNO = [NSString stringWithFormat:@"%f", [self PurgableMemory:NO]];
    NSString *PurgableMemoryYES = [NSString stringWithFormat:@"%f", [self PurgableMemory:YES]];
    NSString *DeviceOrientation = [NSString stringWithFormat:@"%ld", (long)[self DeviceOrientation]];
    //NSString *AccelerometerXValue = [NSString stringWithFormat:@"%f", [self AccelerometerXValue]];
    //NSString *AccelerometerYValue = [NSString stringWithFormat:@"%f", [self AccelerometerYValue]];
    //NSString *AccelerometerZValue = [NSString stringWithFormat:@"%f", [self AccelerometerZValue]];
    NSString *Country = [self Country];
    NSString *Locale = [self Locale];
    NSString *Language = [self Language];
    NSString *TimeZone = [self TimeZone];
    NSString *Currency = [self Currency];
    NSString *ApplicationVersion = [self ApplicationVersion];
    NSString *ClipboardContent = [self ClipboardContent];
    NSString *UniqueID = [self UniqueID];
    NSString *DeviceSignature = [self DeviceSignature];
    NSString *CFUUID = [self CFUUID];
    
    // Check to make sure all values are valid (if not, make them)
    if (SystemUptime == nil || SystemUptime.length <= 0) {
        // Invalid value
        SystemUptime = @"Unkown";
    }
    if (DeviceModel == nil || DeviceModel.length <= 0) {
        // Invalid value
        DeviceModel = @"Unkown";
    }
    if (DeviceName == nil || DeviceName.length <= 0) {
        // Invalid value
        DeviceName = @"Unkown";
    }
    if (SystemName == nil || SystemName.length <= 0) {
        // Invalid value
        SystemName = @"Unkown";
    }
    if (SystemVersion == nil || SystemVersion.length <= 0) {
        // Invalid value
        SystemVersion = @"Unkown";
    }
    if (SystemDeviceTypeFormattedNO == nil || SystemDeviceTypeFormattedNO.length <= 0) {
        // Invalid value
        SystemDeviceTypeFormattedNO = @"Unkown";
    }
    if (SystemDeviceTypeFormattedYES == nil || SystemDeviceTypeFormattedYES.length <= 0) {
        // Invalid value
        SystemDeviceTypeFormattedYES = @"Unkown";
    }
    if (ScreenWidth == nil || ScreenWidth.length <= 0) {
        // Invalid value
        ScreenWidth = @"Unkown";
    }
    if (ScreenHeight == nil || ScreenHeight.length <= 0) {
        // Invalid value
        ScreenHeight = @"Unkown";
    }
    if (MultitaskingEnabled == nil || MultitaskingEnabled.length <= 0) {
        // Invalid value
        MultitaskingEnabled = @"Unkown";
    }
    if (ProximitySensorEnabled == nil || ProximitySensorEnabled.length <= 0) {
        // Invalid value
        ProximitySensorEnabled = @"Unkown";
    }
    if (DebuggerAttached == nil || DebuggerAttached.length <= 0) {
        // Invalid value
        DebuggerAttached = @"Unkown";
    }
    if (PluggedIn == nil || PluggedIn.length <= 0) {
        // Invalid value
        PluggedIn = @"Unkown";
    }
    if (Jailbroken == nil || Jailbroken.length <= 0) {
        // Invalid value
        Jailbroken = @"Unkown";
    }
    if (NumberProcessors == nil || NumberProcessors.length <= 0) {
        // Invalid value
        NumberProcessors = @"Unkown";
    }
    if (NumberActiveProcessors == nil || NumberActiveProcessors.length <= 0) {
        // Invalid value
        NumberActiveProcessors = @"Unkown";
    }
    if (ProcessorSpeed == nil || ProcessorSpeed.length <= 0) {
        // Invalid value
        ProcessorSpeed = @"Unkown";
    }
    if (ProcessorBusSpeed == nil || ProcessorBusSpeed.length <= 0) {
        // Invalid value
        ProcessorBusSpeed = @"Unkown";
    }
    
#ifdef EA_EXTERN_CLASS_AVAILABLE
    if (AccessoriesAttached == nil || AccessoriesAttached.length <= 0) {
        // Invalid value
        AccessoriesAttached = @"Unkown";
    }
    if (HeadphonesAttached == nil || HeadphonesAttached.length <= 0) {
        // Invalid value
        HeadphonesAttached = @"Unkown";
    }
    if (NumberAttachedAccessories == nil || NumberAttachedAccessories.length <= 0) {
        // Invalid value
        NumberAttachedAccessories = @"Unkown";
    }
    if (NameAttachedAccessories == nil || NameAttachedAccessories.length <= 0) {
        // Invalid value
        NameAttachedAccessories = @"Unkown";
    }
#endif
    
#ifdef OPT_TELEPHONY
    if (CarrierName == nil || CarrierName.length <= 0) {
        // Invalid value
        CarrierName = @"Unkown";
    }
    if (CarrierCountry == nil || CarrierCountry.length <= 0) {
        // Invalid value
        CarrierCountry = @"Unkown";
    }
    if (CarrierMobileCountryCode == nil || CarrierMobileCountryCode.length <= 0) {
        // Invalid value
        CarrierMobileCountryCode = @"Unkown";
    }
    if (CarrierISOCountryCode == nil || CarrierISOCountryCode.length <= 0) {
        // Invalid value
        CarrierISOCountryCode = @"Unkown";
    }
    if (CarrierMobileNetworkCode == nil || CarrierMobileNetworkCode.length <= 0) {
        // Invalid value
        CarrierMobileNetworkCode = @"Unkown";
    }
    if (CarrierAllowsVOIP == nil || CarrierAllowsVOIP.length <= 0) {
        // Invalid value
        CarrierAllowsVOIP = @"Unkown";
    }
#endif
    
    if (BatteryLevel == nil || BatteryLevel.length <= 0) {
        // Invalid value
        BatteryLevel = @"Unkown";
    }
    if (Charging == nil || Charging.length <= 0) {
        // Invalid value
        Charging = @"Unkown";
    }
    if (FullyCharged == nil || FullyCharged.length <= 0) {
        // Invalid value
        FullyCharged = @"Unkown";
    }
    if (CurrentIPAddress == nil || CurrentIPAddress.length <= 0) {
        // Invalid value
        CurrentIPAddress = @"Unkown";
    }
    if (CurrentMACAddress == nil || CurrentMACAddress.length <= 0) {
        // Invalid value
        CurrentMACAddress = @"Unkown";
    }
    if (CellIPAddress == nil || CellIPAddress.length <= 0) {
        // Invalid value
        CellIPAddress = @"Unkown";
    }
    if (CellMACAddress == nil || CellMACAddress.length <= 0) {
        // Invalid value
        CellMACAddress = @"Unkown";
    }
    if (CellNetmaskAddress == nil || CellNetmaskAddress.length <= 0) {
        // Invalid value
        CellNetmaskAddress = @"Unkown";
    }
    if (CellBroadcastAddress == nil || CellBroadcastAddress.length <= 0) {
        // Invalid value
        CellBroadcastAddress = @"Unkown";
    }
    if (WiFiIPAddress == nil || WiFiIPAddress.length <= 0) {
        // Invalid value
        WiFiIPAddress = @"Unkown";
    }
    if (WiFiMACAddress == nil || WiFiMACAddress.length <= 0) {
        // Invalid value
        WiFiMACAddress = @"Unkown";
    }
    if (WiFiNetmaskAddress == nil || WiFiNetmaskAddress.length <= 0) {
        // Invalid value
        WiFiNetmaskAddress = @"Unkown";
    }
    if (WiFiBroadcastAddress == nil || WiFiBroadcastAddress.length <= 0) {
        // Invalid value
        WiFiBroadcastAddress = @"Unkown";
    }
    if (ConnectedToWiFi == nil || ConnectedToWiFi.length <= 0) {
        // Invalid value
        ConnectedToWiFi = @"Unkown";
    }
    if (ConnectedToCellNetwork == nil || ConnectedToCellNetwork.length <= 0) {
        // Invalid value
        ConnectedToCellNetwork = @"Unkown";
    }
    if (ProcessID == nil || ProcessID.length <= 0) {
        // Invalid value
        ProcessID = @"Unkown";
    }
    if (ProcessName == nil || ProcessName.length <= 0) {
        // Invalid value
        ProcessName = @"Unkown";
    }
    if (ProcessStatus == nil || ProcessStatus.length <= 0) {
        // Invalid value
        ProcessStatus = @"Unkown";
    }
    if (ParentPID == nil || ParentPID.length <= 0) {
        // Invalid value
        ParentPID = @"Unkown";
    }
    //ProcessesInformation = [NSMutableArray arrayWithObject:@"Unkown"];
    /*if (ProcessesInformation == nil || ProcessesInformation.count <= 0) {
        // Invalid value
        ProcessesInformation = [NSMutableArray arrayWithObject:@"Unkown"];
    }*/
    if (DiskSpace == nil || DiskSpace.length <= 0) {
        // Invalid value
        DiskSpace = @"Unkown";
    }
    if (FreeDiskSpaceNO == nil || FreeDiskSpaceNO.length <= 0) {
        // Invalid value
        FreeDiskSpaceNO = @"Unkown";
    }
    if (FreeDiskSpaceYES == nil || FreeDiskSpaceYES.length <= 0) {
        // Invalid value
        FreeDiskSpaceYES = @"Unkown";
    }
    if (UsedDiskSpaceNO == nil || UsedDiskSpaceNO.length <= 0) {
        // Invalid value
        UsedDiskSpaceNO = @"Unkown";
    }
    if (UsedDiskSpaceYES == nil || UsedDiskSpaceYES.length <= 0) {
        // Invalid value
        UsedDiskSpaceYES = @"Unkown";
    }
    if (LongDiskSpace == nil || LongDiskSpace.length <= 0) {
        // Invalid value
        LongDiskSpace = @"Unkown";
    }
    if (LongFreeDiskSpace == nil || LongFreeDiskSpace.length <= 0) {
        // Invalid value
        LongFreeDiskSpace = @"Unkown";
    }
    if (TotalMemory == nil || TotalMemory.length <= 0) {
        // Invalid value
        TotalMemory = @"Unkown";
    }
    if (FreeMemoryNO == nil || FreeMemoryNO.length <= 0) {
        // Invalid value
        FreeMemoryNO = @"Unkown";
    }
    if (FreeMemoryYES == nil || FreeMemoryYES.length <= 0) {
        // Invalid value
        FreeMemoryYES = @"Unkown";
    }
    if (UsedMemoryNO == nil || UsedMemoryNO.length <= 0) {
        // Invalid value
        UsedMemoryNO = @"Unkown";
    }
    if (UsedMemoryYES == nil || UsedMemoryYES.length <= 0) {
        // Invalid value
        UsedMemoryYES = @"Unkown";
    }
    if (AvailableMemoryNO == nil || AvailableMemoryNO.length <= 0) {
        // Invalid value
        AvailableMemoryNO = @"Unkown";
    }
    if (AvailableMemoryYES == nil || AvailableMemoryYES.length <= 0) {
        // Invalid value
        AvailableMemoryYES = @"Unkown";
    }
    if (ActiveMemoryNO == nil || ActiveMemoryNO.length <= 0) {
        // Invalid value
        ActiveMemoryNO = @"Unkown";
    }
    if (ActiveMemoryYES == nil || ActiveMemoryYES.length <= 0) {
        // Invalid value
        ActiveMemoryYES = @"Unkown";
    }
    if (InactiveMemoryNO == nil || InactiveMemoryNO.length <= 0) {
        // Invalid value
        InactiveMemoryNO = @"Unkown";
    }
    if (InactiveMemoryYES == nil || InactiveMemoryYES.length <= 0) {
        // Invalid value
        InactiveMemoryYES = @"Unkown";
    }
    if (WiredMemoryNO == nil || WiredMemoryNO.length <= 0) {
        // Invalid value
        WiredMemoryNO = @"Unkown";
    }
    if (WiredMemoryYES == nil || WiredMemoryYES.length <= 0) {
        // Invalid value
        WiredMemoryYES = @"Unkown";
    }
    if (PurgableMemoryNO == nil || PurgableMemoryNO.length <= 0) {
        // Invalid value
        PurgableMemoryNO = @"Unkown";
    }
    if (PurgableMemoryYES == nil || PurgableMemoryYES.length <= 0) {
        // Invalid value
        PurgableMemoryYES = @"Unkown";
    }
    if (DeviceOrientation == nil || DeviceOrientation.length <= 0) {
        // Invalid value
        DeviceOrientation = @"Unkown";
    }
    /*if (AccelerometerXValue == nil || AccelerometerXValue.length <= 0) {
        // Invalid value
        AccelerometerXValue = @"Unkown";
    }
    if (AccelerometerYValue == nil || AccelerometerYValue.length <= 0) {
        // Invalid value
        AccelerometerYValue = @"Unkown";
    }
    if (AccelerometerZValue == nil || AccelerometerZValue.length <= 0) {
        // Invalid value
        AccelerometerZValue = @"Unkown";
    }*/
    if (Country == nil || Country.length <= 0) {
        // Invalid value
        Country = @"Unkown";
    }
    if (Locale == nil || Locale.length <= 0) {
        // Invalid value
        Locale = @"Unkown";
    }
    if (Language == nil || Language.length <= 0) {
        // Invalid value
        Language = @"Unkown";
    }
    if (TimeZone == nil || TimeZone.length <= 0) {
        // Invalid value
        TimeZone = @"Unkown";
    }
    if (Currency == nil || Currency.length <= 0) {
        // Invalid value
        Currency = @"Unkown";
    }
    if (ApplicationVersion == nil || ApplicationVersion.length <= 0) {
        // Invalid value
        ApplicationVersion = @"Unkown";
    }
    if (ClipboardContent == nil || ClipboardContent.length <= 0) {
        // Invalid value
        ClipboardContent = @"Unkown";
    }
    if (UniqueID == nil || UniqueID.length <= 0) {
        // Invalid value
        UniqueID = @"Unkown";
    }
    if (DeviceSignature == nil || DeviceSignature.length <= 0) {
        // Invalid value
        DeviceSignature = @"Unkown";
    }
    if (CFUUID == nil || CFUUID.length <= 0) {
        // Invalid value
        CFUUID = @"Unkown";
    }
    
#ifndef EA_EXTERN_CLASS_AVAILABLE
    NSString *AccessoriesAttached = @"";
    NSString *HeadphonesAttached = @"";
    NSString *NumberAttachedAccessories = @"";
#endif
    
#ifndef OPT_TELEPHONY
    NSString *CarrierName = @"";
    NSString *CarrierCountry = @"";
    NSString *CarrierMobileCountryCode = @"";
    NSString *CarrierISOCountryCode = @"";
    NSString *CarrierMobileNetworkCode = @"";
    NSString *CarrierAllowsVOIP = @"";
#endif
    
    // Get all Information in a dictionary
    SystemInformationDict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:
                                                                        SystemUptime,
                                                                        DeviceModel,
                                                                        DeviceName,
                                                                        SystemName,
                                                                        SystemVersion,
                                                                        SystemDeviceTypeFormattedNO,
                                                                        SystemDeviceTypeFormattedYES,
                                                                        ScreenWidth,
                                                                        ScreenHeight,
                                                                        MultitaskingEnabled,
                                                                        ProximitySensorEnabled,
                                                                        DebuggerAttached,
                                                                        PluggedIn,
                                                                        Jailbroken,
                                                                        NumberProcessors,
                                                                        NumberActiveProcessors,
                                                                        ProcessorSpeed,
                                                                        ProcessorBusSpeed,
                                                                        AccessoriesAttached,
                                                                        HeadphonesAttached,
                                                                        NumberAttachedAccessories,
                                                                        CarrierName,
                                                                        CarrierCountry,
                                                                        CarrierMobileCountryCode,
                                                                        CarrierISOCountryCode,
                                                                        CarrierMobileNetworkCode,
                                                                        CarrierAllowsVOIP,
                                                                        BatteryLevel,
                                                                        Charging,
                                                                        FullyCharged,
                                                                        CurrentIPAddress,
                                                                        CurrentMACAddress,
                                                                        CellIPAddress,
                                                                        CellMACAddress,
                                                                        CellNetmaskAddress,
                                                                        CellBroadcastAddress,
                                                                        WiFiIPAddress,
                                                                        WiFiMACAddress,
                                                                        WiFiNetmaskAddress,
                                                                        WiFiBroadcastAddress,
                                                                        ConnectedToWiFi,
                                                                        ConnectedToCellNetwork,
                                                                        ProcessID,
                                                                        ProcessName,
                                                                        ProcessStatus,
                                                                        ParentPID,
                                                                        /*ProcessesInformation,*/
                                                                        DiskSpace,
                                                                        FreeDiskSpaceNO,
                                                                        FreeDiskSpaceYES,
                                                                        UsedDiskSpaceNO,
                                                                        UsedDiskSpaceYES,
                                                                        LongDiskSpace,
                                                                        LongFreeDiskSpace,
                                                                        TotalMemory,
                                                                        FreeMemoryNO,
                                                                        FreeMemoryYES,
                                                                        UsedMemoryNO,
                                                                        UsedMemoryYES,
                                                                        AvailableMemoryNO,
                                                                        AvailableMemoryYES,
                                                                        ActiveMemoryNO,
                                                                        ActiveMemoryYES,
                                                                        InactiveMemoryNO,
                                                                        InactiveMemoryYES,
                                                                        WiredMemoryNO,
                                                                        WiredMemoryYES,
                                                                        PurgableMemoryNO,
                                                                        PurgableMemoryYES,
                                                                        DeviceOrientation,
                                                                        /*AccelerometerXValue,
                                                                        AccelerometerYValue,
                                                                        AccelerometerZValue,*/
                                                                        Country,
                                                                        Locale,
                                                                        Language,
                                                                        TimeZone,
                                                                        Currency,
                                                                        ApplicationVersion,
                                                                        ClipboardContent,
                                                                        UniqueID,
                                                                        DeviceSignature,
                                                                        CFUUID,
                                                                        nil]
                                                               forKeys:[NSArray arrayWithObjects:
                                                                        @"Uptime",
                                                                        @"DeviceModel",
                                                                        @"DeviceName",
                                                                        @"SystemName",
                                                                        @"SystemVersion",
                                                                        @"SystemDeviceTypeFormatted",
                                                                        @"SystemDeviceType",
                                                                        @"ScreenWidth",
                                                                        @"ScreenHeight",
                                                                        @"MultitaskingEnabled",
                                                                        @"ProximitySensorEnabled",
                                                                        @"DebuggerAttached",
                                                                        @"PluggedIn",
                                                                        @"Jailbroken",
                                                                        @"NumberProcessors",
                                                                        @"NumberActiveProcessors",
                                                                        @"ProcessorSpeed",
                                                                        @"ProcessorBusSpeed",
                                                                        @"AccessoriesAttached",
                                                                        @"HeadphonesAttached",
                                                                        @"NumberAttachedAccessories",
                                                                        @"CarrierName",
                                                                        @"CarrierCountry",
                                                                        @"CarrierMobileCountryCode",
                                                                        @"CarrierISOCountryCode",
                                                                        @"CarrierMobileNetworkCode",
                                                                        @"CarrierAllowsVOIP",
                                                                        @"BatteryLevel",
                                                                        @"Charging",
                                                                        @"FullyCharged",
                                                                        @"CurrentIPAddress",
                                                                        @"CurrentMACAddress",
                                                                        @"CellIPAddress",
                                                                        @"CellMACAddress",
                                                                        @"CellNetmaskAddress",
                                                                        @"CellBroadcastAddress",
                                                                        @"WiFiIPAddress",
                                                                        @"WiFiMACAddress",
                                                                        @"WiFiNetmaskAddress",
                                                                        @"WiFiBroadcastAddress",
                                                                        @"ConnectedToWiFi",
                                                                        @"ConnectedToCellNetwork",
                                                                        @"ProcessID",
                                                                        @"ProcessName",
                                                                        @"ProcessStatus",
                                                                        @"ParentPID",
                                                                        /*@"ProcessesInformation",*/
                                                                        @"DiskSpace",
                                                                        @"FreeDiskSpace(NotFormatted)",
                                                                        @"FreeDiskSpace(Formatted)",
                                                                        @"UsedDiskSpace(NotFormatted)",
                                                                        @"UsedDiskSpace(Formatted)",
                                                                        @"LongDiskSpace",
                                                                        @"LongFreeDiskSpace",
                                                                        @"TotalMemory",
                                                                        @"FreeMemory(NotFormatted)",
                                                                        @"FreeMemory(Formatted)",
                                                                        @"UsedMemory(NotFormatted)",
                                                                        @"UsedMemory(Formatted)",
                                                                        @"AvailableMemory(NotFormatted)",
                                                                        @"AvailableMemory(Formatted)",
                                                                        @"ActiveMemory(NotFormatted)",
                                                                        @"ActiveMemory(Formatted)",
                                                                        @"InactiveMemory(NotFormatted)",
                                                                        @"InactiveMemory(Formatted)",
                                                                        @"WiredMemory(NotFormatted)",
                                                                        @"WiredMemory(Formatted)",
                                                                        @"PurgableMemory(NotFormatted)",
                                                                        @"PurgableMemory(Formatted)",
                                                                        @"DeviceOrientation",
                                                                        /*@"AccelerometerXValue",
                                                                        @"AccelerometerYValue",
                                                                        @"AccelerometerZValue",*/
                                                                        @"Country",
                                                                        @"Locale",
                                                                        @"Language",
                                                                        @"TimeZone",
                                                                        @"Currency",
                                                                        @"ApplicationVersion",
                                                                        @"ClipboardContent",
                                                                        @"UniqueID",
                                                                        @"DeviceSignature",
                                                                        @"CFUUID",
                                                                        nil]];
    
    // Check if Dictionary is populated
    if (SystemInformationDict.count <= 0) {
        // Error, Dictionary is empty
        return nil;
    }
    
    // Successful
    return SystemInformationDict;
}

/* Hardware Information */

// System Uptime (dd hh mm)
+ (NSString *)SystemUptime {
    // Get the System Uptime
    NSString *String = [SSHardwareInfo SystemUptime];
    // Validate it
    if (String == nil || String.length <= 0) {
        // Error, no value returned
        return nil;
    }
    // Successful
    return String;
}

// Model of Device
+ (NSString *)DeviceModel {
    // Get the Device Model
    NSString *String = [SSHardwareInfo DeviceModel];
    // Validate it
    if (String == nil || String.length <= 0) {
        // Error, no value returned
        return nil;
    }
    // Successful
    return String;
}

// Device Name
+ (NSString *)DeviceName {
    // Get the Device Name
    NSString *String = [SSHardwareInfo DeviceName];
    // Validate it
    if (String == nil || String.length <= 0) {
        // Error, no value returned
        return nil;
    }
    // Successful
    return String;
}

// System Name
+ (NSString *)SystemName {
    // Get the System Name
    NSString *String = [SSHardwareInfo SystemName];
    // Validate it
    if (String == nil || String.length <= 0) {
        // Error, no value returned
        return nil;
    }
    // Successful
    return String;
}

// System Version
+ (NSString *)SystemVersion {
    // Get the System Version
    NSString *String = [SSHardwareInfo SystemVersion];
    // Validate it
    if (String == nil || String.length <= 0) {
        // Error, no value returned
        return nil;
    }
    // Successful
    return String;
}

// System Device Type (iPhone1,0) (Formatted = iPhone 1)
+ (NSString *)SystemDeviceTypeFormatted:(BOOL)formatted {
    // Get the System Device Type
    NSString *String = [SSHardwareInfo SystemDeviceTypeFormatted:formatted];
    // Validate it
    if (String == nil || String.length <= 0) {
        // Error, no value returned
        return nil;
    }
    // Successful
    return String;
}

// Get the Screen Width (X)
+ (NSInteger)ScreenWidth {
    // Get the Screen Width
    NSInteger Number = [SSHardwareInfo ScreenWidth];
    // Validate it
    if (Number <= 0) {
        // Error, no value returned
        return -1;
    }
    // Successful
    return Number;
}

// Get the Screen Height (Y)
+ (NSInteger)ScreenHeight {
    // Get the Screen Height
    NSInteger Number = [SSHardwareInfo ScreenHeight];
    // Validate it
    if (Number <= 0) {
        // Error, no value returned
        return -1;
    }
    // Successful
    return Number;
}

// Multitasking enabled?
+ (BOOL)MultitaskingEnabled {
    // Is Multitasking enabled?
    BOOL item = [SSHardwareInfo MultitaskingEnabled];
    // Successful
    return item;
}

// Proximity sensor enabled?
+ (BOOL)ProximitySensorEnabled {
    // Is Proximity Sensor enabled?
    BOOL item = [SSHardwareInfo ProximitySensorEnabled];
    // Successful
    return item;
}

// Debugger Attached?
+ (BOOL)DebuggerAttached {
    // Is Debugger Attached?
    BOOL item = [SSHardwareInfo DebuggerAttached];
    // Successful
    return item;
}

// Plugged In?
+ (BOOL)PluggedIn {
    // Is Device Plugged in?
    BOOL item = [SSHardwareInfo PluggedIn];
    // Successful
    return item;
}

/* Jailbreak Check */

// Jailbroken?
+ (BOOL)Jailbroken {
    // Is Device Jailbroken?
    BOOL item = [SSJailbreakCheck Jailbroken];
    // Successful
    return item;
}

/* Processor Information */

// Number of processors
+ (NSInteger)NumberProcessors {
    // Get the Number of Processors
    NSInteger Number = [SSProcessorInfo NumberProcessors];
    // Validate it
    if (Number <= 0) {
        // Error, no value returned
        return -1;
    }
    // Successful
    return Number;
}

// Number of Active Processors
+ (NSInteger)NumberActiveProcessors {
    // Get the Number of Active Processors
    NSInteger Number = [SSProcessorInfo NumberActiveProcessors];
    // Validate it
    if (Number <= 0) {
        // Error, no value returned
        return -1;
    }
    // Successful
    return Number;
}

// Processor Speed in MHz
+ (NSInteger)ProcessorSpeed {
    // Get the Processor Speed in MHz
    NSInteger Number = [SSProcessorInfo ProcessorSpeed];
    // Validate it
    if (Number <= 0) {
        // Error, no value returned
        return -1;
    }
    // Successful
    return Number;
}

// Processor Bus Speed in MHz
+ (NSInteger)ProcessorBusSpeed {
    // Get the Processor Bus Speed in MHz
    NSInteger Number = [SSProcessorInfo ProcessorBusSpeed];
    // Validate it
    if (Number <= 0) {
        // Error, no value returned
        return -1;
    }
    // Successful
    return Number;
}

/* Accessory Information */

#ifdef EA_EXTERN_CLASS_AVAILABLE
// Are any accessories attached?
+ (BOOL)AccessoriesAttached {
    // Are any accessories attached?
    BOOL item = [SSAccessoryInfo AccessoriesAttached];
    // Successful
    return item;
}

// Are Headphones attached?
+ (BOOL)HeadphonesAttached {
    // Are Headphones attached?
    BOOL item = [SSAccessoryInfo HeadphonesAttached];
    // Successful
    return item;
}

// Number of attached accessories
+ (NSInteger)NumberAttachedAccessories {
    // Get the Number of attached
    NSInteger Number = [SSAccessoryInfo NumberAttachedAccessories];
    // Validate it
    if (Number <= 0) {
        // Error, no value returned
        return -1;
    }
    // Successful
    return Number;
}

// Name of attached accessory/accessories (seperated by , comma's)
+ (NSString *)NameAttachedAccessories {
    // Get the Name of any attached accessories
    NSString *String = [SSAccessoryInfo NameAttachedAccessories];
    // Validate it
    if (String == nil || String.length <= 0) {
        // Error, no value returned
        return nil;
    }
    // Successful
    return String;
}
#endif

#ifdef OPT_TELEPHONY
/* Carrier Information */

// Carrier Name
+ (NSString *)CarrierName {
    // Get the Carrier Name
    NSString *String = [SSCarrierInfo CarrierName];
    // Validate it
    if (String == nil || String.length <= 0) {
        // Error, no value returned
        return nil;
    }
    // Successful
    return String;
}

// Carrier Country
+ (NSString *)CarrierCountry {
    // Get the Carrier Country
    NSString *String = [SSCarrierInfo CarrierCountry];
    // Validate it
    if (String == nil || String.length <= 0) {
        // Error, no value returned
        return nil;
    }
    // Successful
    return String;
}

// Carrier Mobile Country Code
+ (NSString *)CarrierMobileCountryCode {
    // Get the Carrier Mobile Country Code
    NSString *String = [SSCarrierInfo CarrierMobileCountryCode];
    // Validate it
    if (String == nil || String.length <= 0) {
        // Error, no value returned
        return nil;
    }
    // Successful
    return String;
}

// Carrier ISO Country Code
+ (NSString *)CarrierISOCountryCode {
    // Get the Carrier ISO Country Code
    NSString *String = [SSCarrierInfo CarrierISOCountryCode];
    // Validate it
    if (String == nil || String.length <= 0) {
        // Error, no value returned
        return nil;
    }
    // Successful
    return String;
}

// Carrier Mobile Network Code
+ (NSString *)CarrierMobileNetworkCode {
    // Get the Carrier Mobile Network Code
    NSString *String = [SSCarrierInfo CarrierMobileNetworkCode];
    // Validate it
    if (String == nil || String.length <= 0) {
        // Error, no value returned
        return nil;
    }
    // Successful
    return String;
}

// Carrier Allows VOIP
+ (BOOL)CarrierAllowsVOIP {
    // Does the carrier allow VOIP?
    BOOL item = [SSCarrierInfo CarrierAllowsVOIP];
    // Successful
    return item;
}
#endif

/* Battery Information */

// Battery Level
+ (float)BatteryLevel {
    // Get the Battery Level
    float Number = [SSBatteryInfo BatteryLevel];
    // Validate it
    if (Number <= 0) {
        // Error, no value returned
        return -1;
    }
    // Successful
    return Number;
}

// Charging?
+ (BOOL)Charging {
    // Is the device charging?
    BOOL item = [SSBatteryInfo Charging];
    // Successful
    return item;
}

// Fully Charged?
+ (BOOL)FullyCharged {
    // Is the device fully charged?
    BOOL item = [SSBatteryInfo FullyCharged];
    // Successful
    return item;
}

/* Network Information */

// Get Current IP Address
+ (NSString *)CurrentIPAddress {
    // Get the Current IP Address
    NSString *String = [SSNetworkInfo CurrentIPAddress];
    // Validate it
    if (String == nil || String.length <= 0) {
        // Error, no value returned
        return nil;
    }
    // Successful
    return String;
}

// Get Current MAC Address
+ (NSString *)CurrentMACAddress {
    // Get the Current MAC Address
    NSString *String = [SSNetworkInfo CurrentMACAddress];
    // Validate it
    if (String == nil || String.length <= 0) {
        // Error, no value returned
        return nil;
    }
    // Successful
    return String;
}

// Get Cell IP Address
+ (NSString *)CellIPAddress {
    // Get the Cell IP Address
    NSString *String = [SSNetworkInfo CellIPAddress];
    // Validate it
    if (String == nil || String.length <= 0) {
        // Error, no value returned
        return nil;
    }
    // Successful
    return String;
}

// Get Cell MAC Address
+ (NSString *)CellMACAddress {
    // Get the Cell MAC Address
    NSString *String = [SSNetworkInfo CellMACAddress];
    // Validate it
    if (String == nil || String.length <= 0) {
        // Error, no value returned
        return nil;
    }
    // Successful
    return String;
}

// Get Cell Netmask Address
+ (NSString *)CellNetmaskAddress {
    // Get the Cell Netmask Address
    NSString *String = [SSNetworkInfo CellNetmaskAddress];
    // Validate it
    if (String == nil || String.length <= 0) {
        // Error, no value returned
        return nil;
    }
    // Successful
    return String;
}

// Get Cell Broadcast Address
+ (NSString *)CellBroadcastAddress {
    // Get the Cell Broadcast Address
    NSString *String = [SSNetworkInfo CellBroadcastAddress];
    // Validate it
    if (String == nil || String.length <= 0) {
        // Error, no value returned
        return nil;
    }
    // Successful
    return String;
}

// Get WiFi IP Address
+ (NSString *)WiFiIPAddress {
    // Get the WiFi IP Address
    NSString *String = [SSNetworkInfo WiFiIPAddress];
    // Validate it
    if (String == nil || String.length <= 0) {
        // Error, no value returned
        return nil;
    }
    // Successful
    return String;
}

// Get WiFi MAC Address
+ (NSString *)WiFiMACAddress {
    // Get the WiFi MAC Address
    NSString *String = [SSNetworkInfo WiFiMACAddress];
    // Validate it
    if (String == nil || String.length <= 0) {
        // Error, no value returned
        return nil;
    }
    // Successful
    return String;
}

// Get WiFi Netmask Address
+ (NSString *)WiFiNetmaskAddress {
    // Get the WiFi Netmask Address
    NSString *String = [SSNetworkInfo WiFiNetmaskAddress];
    // Validate it
    if (String == nil || String.length <= 0) {
        // Error, no value returned
        return nil;
    }
    // Successful
    return String;
}

// Get WiFi Broadcast Address
+ (NSString *)WiFiBroadcastAddress {
    // Get the WiFi Broadcast Address
    NSString *String = [SSNetworkInfo WiFiBroadcastAddress];
    // Validate it
    if (String == nil || String.length <= 0) {
        // Error, no value returned
        return nil;
    }
    // Successful
    return String;
}

// Connected to WiFi?
+ (BOOL)ConnectedToWiFi {
    // Is the device connected to WiFi?
    BOOL item = [SSNetworkInfo ConnectedToWiFi];
    // Successful
    return item;
}

// Connected to Cellular Network?
+ (BOOL)ConnectedToCellNetwork {
    // Is the device Connected to a Cellular Network?
    BOOL item = [SSNetworkInfo ConnectedToCellNetwork];
    // Successful
    return item;
}

/* Process Information */

// Process ID
+ (int)ProcessID {
    // Get the Process ID
    int Number = [SSProcessInfo ProcessID];
    // Validate it
    if (Number <= 0) {
        // Error, no value returned
        return -1;
    }
    // Successful
    return Number;
}

// Process Name
+ (NSString *)ProcessName {
    // Get the Process Name
    NSString *String = [SSProcessInfo ProcessName];
    // Validate it
    if (String == nil || String.length <= 0) {
        // Error, no value returned
        return nil;
    }
    // Successful
    return String;
}

// Process Status
+ (int)ProcessStatus {
    // Get the Process Status
    int Number = [SSProcessInfo ProcessStatus];
    // Validate it
    if (Number <= 0) {
        // Error, no value returned
        return -1;
    }
    // Successful
    return Number;
}

// Parent Process ID
+ (int)ParentPID {
    // Get the Parent Process ID
    int Number = [SSProcessInfo ParentPID];
    // Validate it
    if (Number <= 0) {
        // Error, no value returned
        return -1;
    }
    // Successful
    return Number;
}

// Parent ID for a certain PID
+ (int)ParentPIDForProcess:(int)pid {
    // Get the Parent Process ID For a process
    int Number = [SSProcessInfo ParentPIDForProcess:pid];
    // Validate it
    if (Number <= 0) {
        // Error, no value returned
        return -1;
    }
    // Successful
    return Number;
}

// List of process information including PID's, Names, PPID's, and Status'
+ (NSMutableArray *)ProcessesInformation {
    // Get all the processes
    NSMutableArray *Array = [SSProcessInfo ProcessesInformation];
    // Validate it
    if (Array <= 0) {
        // Error, no value returned
        return nil;;
    }
    // Successful
    return Array;
}

/* Disk Information */

// Total Disk Space
+ (NSString *)DiskSpace {
    // Get the Total Disk Space
    NSString *String = [SSDiskInfo DiskSpace];
    // Validate it
    if (String == nil || String.length <= 0) {
        // Error, no value returned
        return nil;
    }
    // Successful
    return String;
}

// Total Free Disk Space
+ (NSString *)FreeDiskSpace:(BOOL)inPercent {
    // Get the Total Free Disk Space
    NSString *String = [SSDiskInfo FreeDiskSpace:inPercent];
    // Validate it
    if (String == nil || String.length <= 0) {
        // Error, no value returned
        return nil;
    }
    // Successful
    return String;
}

// Total Used Disk Space
+ (NSString *)UsedDiskSpace:(BOOL)inPercent {
    // Get the Total Used Disk Space
    NSString *String = [SSDiskInfo UsedDiskSpace:inPercent];
    // Validate it
    if (String == nil || String.length <= 0) {
        // Error, no value returned
        return nil;
    }
    // Successful
    return String;
}

// Get the total disk space in long format
+ (long long)LongDiskSpace {
    // Get the total disk space in long format
    long long Number = [SSDiskInfo LongDiskSpace];
    // Validate it
    if (Number <= 0) {
        // Error, no value returned
        return -1;
    }
    // Successful
    return Number;
}

// Get the total free disk space in long format
+ (long long)LongFreeDiskSpace {
    // Get the total disk space in long format
    long long Number = [SSDiskInfo LongFreeDiskSpace];
    // Validate it
    if (Number <= 0) {
        // Error, no value returned
        return -1;
    }
    // Successful
    return Number;
}

/* Memory Information */

// Total Memory
+ (double)TotalMemory {
    // Get the total memory
    double Number = [SSMemoryInfo TotalMemory];
    // Validate it
    if (Number <= 0) {
        // Error, no value returned
        return -1;
    }
    // Successful
    return Number;
}

// Free Memory
+ (double)FreeMemory:(BOOL)inPercent {
    // Get the free memory
    double Number = [SSMemoryInfo FreeMemory:inPercent];
    // Validate it
    if (Number <= 0) {
        // Error, no value returned
        return -1;
    }
    // Successful
    return Number;}

// Used Memory
+ (double)UsedMemory:(BOOL)inPercent {
    // Get the used memory
    double Number = [SSMemoryInfo UsedMemory:inPercent];
    // Validate it
    if (Number <= 0) {
        // Error, no value returned
        return -1;
    }
    // Successful
    return Number;
}

// Available Memory
+ (double)AvailableMemory:(BOOL)inPercent {
    // Get the available memory
    double Number = [SSMemoryInfo AvailableMemory:inPercent];
    // Validate it
    if (Number <= 0) {
        // Error, no value returned
        return -1;
    }
    // Successful
    return Number;}

// Active Memory
+ (double)ActiveMemory:(BOOL)inPercent {
    // Get the active memory
    double Number = [SSMemoryInfo ActiveMemory:inPercent];
    // Validate it
    if (Number <= 0) {
        // Error, no value returned
        return -1;
    }
    // Successful
    return Number;
}

// Inactive Memory
+ (double)InactiveMemory:(BOOL)inPercent {
    // Get the inactive memory
    double Number = [SSMemoryInfo InactiveMemory:inPercent];
    // Validate it
    if (Number <= 0) {
        // Error, no value returned
        return -1;
    }
    // Successful
    return Number;
}

// Wired Memory
+ (double)WiredMemory:(BOOL)inPercent {
    // Get the wired memory
    double Number = [SSMemoryInfo WiredMemory:inPercent];
    // Validate it
    if (Number <= 0) {
        // Error, no value returned
        return -1;
    }
    // Successful
    return Number;
}

// Purgable Memory
+ (double)PurgableMemory:(BOOL)inPercent {
    // Get the purgable memory
    double Number = [SSMemoryInfo PurgableMemory:inPercent];
    // Validate it
    if (Number <= 0) {
        // Error, no value returned
        return -1;
    }
    // Successful
    return Number;
}

/* Accelerometer Information */

// Device Orientation
+ (UIInterfaceOrientation)DeviceOrientation {
    // Get the Device Orientation
    UIInterfaceOrientation Orientation = [SSAccelerometerInfo DeviceOrientation];
    // Validate it
    if (Orientation <= 0) {
        // Error, no value returned
        return -1;
    }
    // Successful
    return Orientation;
}

// Accelerometer X Value
/*+ (float)AccelerometerXValue {
    // Get the Accelerometer X Value
    float Number = [SSAccelerometerInfo AccelerometerXValue];
    // Validate it
    if (Number <= 0) {
        // Error, no value returned
        return -1;
    }
    // Successful
    return Number;
}

// Accelerometer Y Value
+ (float)AccelerometerYValue {
    // Get the Accelerometer Y Value
    float Number = [SSAccelerometerInfo AccelerometerYValue];
    // Validate it
    if (Number <= 0) {
        // Error, no value returned
        return -1;
    }
    // Successful
    return Number;
}

// Accelerometer Z Value
+ (float)AccelerometerZValue {
    // Get the Accelerometer Z Value
    float Number = [SSAccelerometerInfo AccelerometerZValue];
    // Validate it
    if (Number <= 0) {
        // Error, no value returned
        return -1;
    }
    // Successful
    return Number;
}*/

/* Localization Information */

// Country
+ (NSString *)Country {
    // Get the User's Country
    NSString *String = [SSLocalizationInfo Country];
    // Validate it
    if (String == nil || String.length <= 0) {
        // Error, no value returned
        return nil;
    }
    // Successful
    return String;
}

// Locale
+ (NSString *)Locale {
    // Get the User's Locale
    NSString *String = [SSLocalizationInfo Locale];
    // Validate it
    if (String == nil || String.length <= 0) {
        // Error, no value returned
        return nil;
    }
    // Successful
    return String;
}

// Language
+ (NSString *)Language {
    // Get the User's Language
    NSString *String = [SSLocalizationInfo Language];
    // Validate it
    if (String == nil || String.length <= 0) {
        // Error, no value returned
        return nil;
    }
    // Successful
    return String;
}

// TimeZone
+ (NSString *)TimeZone {
    // Get the User's TimeZone
    NSString *String = [SSLocalizationInfo TimeZone];
    // Validate it
    if (String == nil || String.length <= 0) {
        // Error, no value returned
        return nil;
    }
    // Successful
    return String;
}

// Currency Symbol
+ (NSString *)Currency {
    // Get the User's Currency
    NSString *String = [SSLocalizationInfo Currency];
    // Validate it
    if (String == nil || String.length <= 0) {
        // Error, no value returned
        return nil;
    }
    // Successful
    return String;
}

/* Application Information */

// Application Version
+ (NSString *)ApplicationVersion {
    // Get the App Version
    NSString *String = [SSApplicationInfo ApplicationVersion];
    // Validate it
    if (String == nil || String.length <= 0) {
        // Error, no value returned
        return nil;
    }
    // Successful
    return String;
}

// Clipboard Content
+ (NSString *)ClipboardContent {
    // Get the Clipboard String Contents
    NSString *String = [SSApplicationInfo ClipboardContent];
    // Validate it
    if (String == nil || String.length <= 0) {
        // Error, no value returned
        return nil;
    }
    // Successful
    return String;
}

/* Universal Unique Identifiers */

// Unique ID
+ (NSString *)UniqueID {
    // Get the Unique Device ID
    NSString *String = [SSUUID UniqueID];
    // Validate it
    if (String == nil || String.length <= 0) {
        // Error, no value returned
        return nil;
    }
    // Successful
    return String;
}

// Device Signature
+ (NSString *)DeviceSignature {
    // Get a Device Signature
    NSString *String = [SSUUID DeviceSignature];
    // Validate it
    if (String == nil || String.length <= 0) {
        // Error, no value returned
        return nil;
    }
    // Successful
    return String;
}

// CFUUID
+ (NSString *)CFUUID {
    // Get a CFUUID
    NSString *String = [SSUUID CFUUID];
    // Validate it
    if (String == nil || String.length <= 0) {
        // Error, no value returned
        return nil;
    }
    // Successful
    return String;
}

@end
