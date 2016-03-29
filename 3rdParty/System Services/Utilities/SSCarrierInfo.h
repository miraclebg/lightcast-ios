//
//  SSCarrierInfo.h
//  SystemServicesDemo
//
//  Created by Shmoopi LLC on 9/17/12.
//  Copyright (c) 2012 Shmoopi LLC. All rights reserved.
//

#ifdef OPT_TELEPHONY

#import "SystemServicesConstants.h"

@interface SSCarrierInfo : NSObject

// Carrier Information

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

@end

#endif