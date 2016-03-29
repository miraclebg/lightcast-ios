//
//  LWebServicesDefines.h
//  Lightcast
//
//  Created by Martin N. Kovachev on 15.12.12.
//  Copyright (c) 2012 г. Nimasystems Ltd. All rights reserved.
//

#define LERR_WEBSERVICES_DOMAIN @"com.lightcast.web_services"

#define LERR_WEBSERVICES_UNKNOWN 0
#define LERR_WEBSERVICES_GENERAL_ERROR 1
#define LERR_WEBSERVICES_INVALID_PARAMS 2
#define LERR_WEBSERVICES_INVALID_SERVER_RESPONSE 10
#define LERR_WEBSERVICES_JSON_ERROR 11
#define LERR_WEBSERVICES_API_UNSUPPORTED 12
#define LERR_WEBSERVICES_IO_ERROR 20

// default timeout
extern NSTimeInterval const LWebServiceDefaultTimeout; // in seconds (NSTimeInterval)
extern NSInteger const LWebServiceDefaultAPILevel;
extern NSString *const XLC_APILEVEL_HEADER_NAME;
extern NSString *const XLC_CLIENT_APILEVEL_HEADER_NAME;