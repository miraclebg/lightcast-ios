/*
 * Lightcast for iOS Framework
 * Copyright (C) 2007-2011 Nimasystems Ltd
 *
 * This program is NOT free software; you cannot redistribute and/or modify
 * it's sources under any circumstances without the explicit knowledge and
 * agreement of the rightful owner of the software - Nimasystems Ltd.
 *
 * This program is distributed WITHOUT ANY WARRANTY; without even the
 * implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
 * PURPOSE.  See the LICENSE.txt file for more information.
 *
 * You should have received a copy of LICENSE.txt file along with this
 * program; if not, write to:
 * NIMASYSTEMS LTD 
 * Plovdiv, Bulgaria
 * ZIP Code: 4000
 * Address: 95 "Kapitan Raycho" Str., 6th Floor
 * General E-Mail: info@nimasystems.com
 * Tel./Fax: +359 32 395 282
 * Mobile: +359 896 610 876
 */

/**
 * File Description
 * @package File Category
 * @subpackage File Subcategory
 * @changed $Id: LWebServiceClient.h 357 2015-04-16 06:29:29Z mkovachev $
 * @author $Author: mkovachev $
 * @version $Revision: 357 $
 */

#import <SBJson/SBJsonParser.h>

typedef enum
{
    LWebServiceVersion1 = 1,
    LWebServiceVersion2 = 2
} LWebServiceVersion;

@interface LWebServiceClient : NSObject {

	NSString *_hostname;
	BOOL _secureCalls;
	
	NSString *_serviceName;
	NSString *_methodName;
	NSArray *_params;
    NSString * paramsStrForPost;
	
	// temporary vars
	NSMutableURLRequest *_request;
	NSHTTPURLResponse *_response;
	NSData *_data;
	
	id _results;

	NSError *_lastError;
}

@property (nonatomic, retain, readonly) NSError*lastError;
@property (nonatomic, readonly) BOOL secureCalls;
@property (nonatomic, retain, readonly) NSHTTPURLResponse *response;
@property (nonatomic, retain, readonly) id results;

+ (id)webServiceClientWithRequest:(NSString*)hostname makeSecureCalls:(BOOL)secureCalls serviceName:(NSString*)serviceName methodName:(NSString*)methodName params:(NSArray*)params error:(NSError**)error;

- (id)initWithHost:(NSString*)hostname makeSecureCalls:(BOOL)secureCalls;

- (BOOL)makeRequest:(NSString*)serviceName methodName:(NSString*)methodName error:(NSError**)error;
- (BOOL)makeRequest:(NSString*)serviceName methodName:(NSString*)methodName params:(NSArray*)params error:(NSError**)error;

@end
