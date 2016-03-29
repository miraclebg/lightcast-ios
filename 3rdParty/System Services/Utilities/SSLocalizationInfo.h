//
//  SSLocalizationInfo.h
//  SystemServicesDemo
//
//  Created by Kramer on 9/20/12.
//  Copyright (c) 2012 Shmoopi LLC. All rights reserved.
//

#import "SystemServicesConstants.h"

@interface SSLocalizationInfo : NSObject

// Localization Information

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

@end
