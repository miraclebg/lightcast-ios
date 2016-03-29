//
//  LWebServicesDefines.m
//  Lightcast
//
//  Created by Martin Kovachev on 4.01.16 г..
//  Copyright © 2016 г. Nimasystems Ltd. All rights reserved.
//

#import "LWebServicesDefines.h"

// default timeout
NSTimeInterval const LWebServiceDefaultTimeout = 30; // in seconds (NSTimeInterval)
NSInteger const LWebServiceDefaultAPILevel = 2;
NSString *const XLC_APILEVEL_HEADER_NAME = @"X-LC-Api-Level";
NSString *const XLC_CLIENT_APILEVEL_HEADER_NAME = @"X-LC-Client-Api-Level";