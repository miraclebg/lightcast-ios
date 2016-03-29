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
 * @changed $Id: LWebServiceClient.m 341 2014-08-28 05:21:47Z mkovachev $
 * @author $Author: mkovachev $
 * @version $Revision: 341 $
 */

#import "LWebServiceClient.h"
#import "LWebServicesDefines.h"
#import "NSURLRequest+SSLChecks.h"

@interface LWebServiceClient(Private)

- (BOOL)makeRequest:(NSError**)error;
- (void)reset;
- (NSURL*)urlForCurrentRequest;
- (NSData*)convertToPostWithServiceName:(NSString*)_serviceForPost methodName:(NSString*)_methodForPost andParams:(NSString*)_paramsForPost andURL:(NSString*)_urlForPost error:(NSError**)_errorPost;
- (NSString *)urlEncodeValue:(NSString *)str;

@end

@implementation LWebServiceClient

@synthesize
lastError=_lastError,
secureCalls=_secureCalls,
response=_response,
results=_results;

#pragma mark - Initialization / Finalization

- (id)init
{
    return [self initWithHost:nil makeSecureCalls:NO];
}

- (id)initWithHost:(NSString*)hostname makeSecureCalls:(BOOL)secureCalls {
	self = [super init];
	if (self)
	{
		if (!hostname || [hostname isEqual:[NSNull null]])
		{
			[self release];
			self = nil;
			return nil;
		}
		
		_secureCalls = secureCalls;
		_hostname = [hostname retain];
		
		[self reset];
	}
	return self;
}

- (void)dealloc {
	
	L_RELEASE(_hostname);
	
	[self reset];
	
	[super dealloc];
}

#pragma mark - Request

- (BOOL)makeRequest:(NSString*)serviceName methodName:(NSString*)methodName error:(NSError**)error {
	return [self makeRequest:serviceName methodName:methodName params:nil error:error];
}

- (BOOL)makeRequest:(NSString*)serviceName methodName:(NSString*)methodName params:(NSArray*)params error:(NSError**)error {
	
	LogInfo(@"LWebServiceClient:makeRequest:%@/%@:%@", serviceName, methodName, params);
	
	if (!serviceName || [serviceName isEqual:[NSNull null]])
	{
		if (error != NULL)
		{
			NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
			[errorDetail setValue:LightcastLocalizedString(@"Invalid Parameters - missing serviceName") forKey:NSLocalizedDescriptionKey];
			*error = [NSError errorWithDomain:LERR_WEBSERVICES_DOMAIN code:LERR_WEBSERVICES_INVALID_PARAMS userInfo:errorDetail];
		}
		return NO;
	}
	
	[self reset];
	
	if (serviceName != _serviceName)
	{
		L_RELEASE(_serviceName);
		_serviceName = [serviceName retain];
	}
	
	if (methodName != _methodName)
	{
		L_RELEASE(_methodName);
		_methodName = [methodName retain];
	}
	
	if (params != _params)
	{
		L_RELEASE(_params);
		_params = [params retain];
	}
	
	BOOL res = [self makeRequest:error];
	
	if (error != NULL && *error != nil)
	{
		L_RELEASE(_lastError);
		_lastError = [*error copy];
	}
	
	return res;
}

- (void)reset {
	L_RELEASE(_results);
	L_RELEASE(_request);
	L_RELEASE(_data);
	L_RELEASE(_lastError);
	L_RELEASE(_serviceName);
	L_RELEASE(_methodName);
	
	_response = nil;
}

- (BOOL)makeRequest:(NSError**)error {
	
	NSURL *url = [self urlForCurrentRequest];
	
	LogDebug(@"Generated url: %@", url);
	
	if (!url)
	{
		if (error != NULL)
		{
			NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
			[errorDetail setValue:LightcastLocalizedString(@"Cannot obtain URL for the connection") forKey:NSLocalizedDescriptionKey];
			*error = [NSError errorWithDomain:LERR_WEBSERVICES_DOMAIN code:LERR_WEBSERVICES_GENERAL_ERROR userInfo:errorDetail];
		}
		
		return NO;
	}
	    
    if ([_methodName isEqualToString:@"create_member"] || [_methodName isEqualToString:@"link_member_facebook_token"]) 
    {   
        _data = [[self convertToPostWithServiceName:_serviceName methodName:_methodName andParams:paramsStrForPost andURL:[NSString stringWithFormat:@"%@://%@", (_secureCalls ? @"https" : @"http"), _hostname] error:error] retain];
    }
    else
    {
        _request = [[NSMutableURLRequest alloc] initWithURL:url];
    }
    
	if (!_request)
	{
		if (error != NULL)
		{
			NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
			[errorDetail setValue:LightcastLocalizedString(@"Cannot create request") forKey:NSLocalizedDescriptionKey];
			*error = [NSError errorWithDomain:LERR_WEBSERVICES_DOMAIN code:LERR_WEBSERVICES_GENERAL_ERROR userInfo:errorDetail];
		}
		
		return NO;
	}
	
	@try 
	{
#ifdef DEBUG
		[NSURLRequest setAllowsAnyHTTPSCertificate:YES forHost:[url host]];	
#endif
		
        if (![_methodName isEqualToString:@"create_member"] && ![_methodName isEqualToString:@"link_member_facebook_token"]) 
        {
            _data = [[NSURLConnection sendSynchronousRequest:_request returningResponse:&_response error:error] retain];
        }
        
		NSInteger statusCode = _response ? [_response statusCode] : 0;
		
		// check response
		// todo: implement caching of data
		if (!_response || !_data || !statusCode || (statusCode != 200/* && statusCode != 304*/))
		{
			NSString *err = [NSString stringWithFormat:LightcastLocalizedString(@"Invalid response returned from server, status code: %d, data: %s"), statusCode, [_data bytes]];
			
			if (error != NULL)
			{
				NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
				[errorDetail setValue:err forKey:NSLocalizedDescriptionKey];
				*error = [NSError errorWithDomain:LERR_WEBSERVICES_DOMAIN code:LERR_WEBSERVICES_GENERAL_ERROR userInfo:errorDetail];
			}
			
			return NO;
		}
		
		@try 
		{
			// SBJsonParser is weak-linked in Lightcast - verify if it is here!
			
			SBJsonParser *parser = [[SBJsonParser alloc] init];
			id parserResult = nil;
			
			if (!parser)
			{
				if (error != NULL)
				{
					NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
					[errorDetail setValue:LightcastLocalizedString(@"Cannot initialize JSON Parser") forKey:NSLocalizedDescriptionKey];
					*error = [NSError errorWithDomain:LERR_WEBSERVICES_DOMAIN code:LERR_WEBSERVICES_GENERAL_ERROR userInfo:errorDetail];
				}
				
				return NO;
			}
			
			@try 
			{
				parserResult = [parser objectWithData:_data];
			}
			@finally 
			{
				L_RELEASE(parser);
			}
			
			// validate the returned object
			if (!parserResult || ![parserResult objectForKey:@"error"] || ![parserResult objectForKey:@"result"])
			{
				if (error != NULL)
				{
					NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
					[errorDetail setValue:LightcastLocalizedString(@"Invalid Response") forKey:NSLocalizedDescriptionKey];
					*error = [NSError errorWithDomain:LERR_WEBSERVICES_DOMAIN code:LERR_WEBSERVICES_GENERAL_ERROR userInfo:errorDetail];
				}
				
				return NO;
			}
			
			NSInteger errCode = [parserResult objectForKey:@"error"] ? [[parserResult objectForKey:@"error"] intValue] : 0;
			id result = [parserResult objectForKey:@"result"];
			
			// create a web service error if such is in
			if (errCode)
			{
				if (error != NULL)
				{
					NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
					[errorDetail setValue:(NSString*)result forKey:NSLocalizedDescriptionKey];
					*error = [NSError errorWithDomain:LERR_WEBSERVICES_DOMAIN code:errCode userInfo:errorDetail];
				}
				
				return NO;
			}    
			
			// check if null
			id objres = [parserResult objectForKey:@"result"];
			
			if ([objres isKindOfClass:[NSNumber class]])
			{
				BOOL res = [objres boolValue];
				
				if (!res)
				{
					// here the web service simply does not return results - or - returns FALSE
					objres = nil;
					
					/*if (error != NULL)
					{
						NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
						[errorDetail setValue:@"Invalid Response" forKey:NSLocalizedDescriptionKey];
						*error = [NSError errorWithDomain:LERR_WEBSERVICES_DOMAIN code:LERR_WEBSERVICES_GENERAL_ERROR userInfo:errorDetail];
					}
					
					return NO;*/
				}
			}
			
			// assign
			_results = [objres retain];
		}
		@catch (NSException *e) 
		{
			if (error != NULL)
			{
				NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
				[errorDetail setValue:[NSString stringWithFormat:LightcastLocalizedString(@"General error: %@"), [e description]] forKey:NSLocalizedDescriptionKey];
				*error = [NSError errorWithDomain:LERR_WEBSERVICES_DOMAIN code:LERR_WEBSERVICES_GENERAL_ERROR userInfo:errorDetail];
			}
			
			return NO;
		}
	}
	@finally 
	{
		L_RELEASE(_request);
	}
	
	return YES;
}

- (NSURL*)urlForCurrentRequest {
	
	NSURL *url = nil;
	NSString *paramsStr = nil;
	NSMutableArray *tmpArr = [[NSMutableArray alloc] init];
	NSInteger count = 1;
	
	@try 
	{
		// format the params
		if (_params && [_params count])
		{
			for(id obj in _params)
			{
				if (![obj isKindOfClass:[NSString class]])
				{
					return nil;
				}
				
				NSString *value = [(NSString*)obj urlEncoded];
				
				if (!value || [obj isEqual:[NSNull null]] || [obj length] < 1)
				{
					value = @"";
				}
				
				[tmpArr addObject:[NSString stringWithFormat:@"param%d=%@", (int)count, value]];
				
				count++;
			}
			
			paramsStr = [NSString stringWithFormat:@"&%@", [tmpArr componentsJoinedByString:@"&"]];
		}
	}
	@finally 
	{
		L_RELEASE(tmpArr);
	}
	
	NSString *str = [NSString stringWithFormat:@"%@://%@/?service=%@&method=%@%@",
					 (_secureCalls ? @"https" : @"http"),
					 _hostname,
					 _serviceName,
					 _methodName,
					 (paramsStr ? paramsStr : @"")];
    
    paramsStrForPost = (paramsStr ? paramsStr : @"");
    
    //[self convertToPostWithServiceName:_serviceName methodName:_methodName andParams:(paramsStr ? paramsStr : @"") andURL:[NSString stringWithFormat:@"%@://%@", (_secureCalls ? @"https" : @"http"), _hostname]];
	
	url = [NSURL URLWithString:str];
	
	return url;
}

- (NSData*)convertToPostWithServiceName:(NSString*)_serviceForPost methodName:(NSString*)_methodForPost andParams:(NSString*)_paramsForPost andURL:(NSString*)_urlForPost error:(NSError**)_errorPost {
    
    //NSString * post =[[NSString alloc] initWithFormat:@"?service=%@&method=%@%@",_serviceForPost, _methodForPost, _paramsForPost];
    NSString * post = [[[NSString alloc] initWithFormat:@"%@", _paramsForPost] autorelease];
    
    //NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding];
    
    NSString *postLength = [NSString stringWithFormat:@"%ld", (long)[postData length]];
    
    NSString * tmpUrl = [NSString stringWithFormat:@"%@/?service=%@&method=%@", _urlForPost, _serviceForPost, _methodForPost];
    //NSString * tmpUrl = [NSString stringWithFormat:@"%@/%@", _urlForPost, post];
    
     _request = [[NSMutableURLRequest alloc] init];
    [_request setHTTPMethod:@"POST"];
    [_request setURL:[NSURL URLWithString:tmpUrl]];
    [_request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [_request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [_request setHTTPBody:postData];
    
    NSData * tmp = [NSURLConnection sendSynchronousRequest:_request returningResponse:&_response error:_errorPost];
    
#ifdef DEBUG
    NSString * data = [[[NSString alloc]initWithData:tmp encoding:NSUTF8StringEncoding] autorelease];
    LogDebug(@"%@",data);
#endif
    
    return tmp;
}

- (NSString *)urlEncodeValue:(NSString *)str {
    NSString *result = (NSString *) CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)str, NULL, CFSTR("?=&+"), kCFStringEncodingUTF8);
    return [result autorelease];
}

#pragma mark - Static method for a new request

+ (id)webServiceClientWithRequest:(NSString*)hostname makeSecureCalls:(BOOL)secureCalls serviceName:(NSString*)serviceName methodName:(NSString*)methodName params:(NSArray*)params error:(NSError**)error {
	LWebServiceClient *wc = [[LWebServiceClient alloc] initWithHost:hostname makeSecureCalls:secureCalls];
	
	if (!wc) return nil;
	
	[wc makeRequest:serviceName methodName:methodName params:params error:error];
	
	return [wc autorelease];
}

@end
