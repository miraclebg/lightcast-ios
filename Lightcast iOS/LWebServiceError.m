//
//  LWebServiceError.m
//  cocoa
//
//  Created by Martin N. Kovachev on 15.12.12.
//  Copyright (c) 2012 г. Stampii S.L. All rights reserved.
//

#import "LWebServiceError.h"

NSString *const APIErrorDomain = @"com.nimasystems.lightcast.APIError";

@implementation LWebServiceError

@synthesize
apiDomainName,
trace,
exceptionName,
extraData,
validationErrors;

#pragma mark -
#pragma mark Initialization / Finalization

- (id)initWithStampiiError:(NSString*)apiDomainName_ errorMessage:(NSString*)errorMessage_ errorCode:(NSInteger)errorCode_
{
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          (errorMessage_ ? [[errorMessage_ copy] autorelease] : @""), NSLocalizedDescriptionKey
                          , nil];
    self = [super initWithDomain:APIErrorDomain code:errorCode_ userInfo:dict];
    if (self)
    {
        apiDomainName = [apiDomainName_ retain];
    }
    return self;
}

- (id)initWithDomain:(NSString *)domain code:(NSInteger)code userInfo:(NSDictionary *)dict
{
    return [self initWithStampiiError:nil errorMessage:nil errorCode:0];
}

- (void)dealloc
{
    L_RELEASE(apiDomainName);
    L_RELEASE(trace);
    L_RELEASE(exceptionName);
    L_RELEASE(extraData);
    L_RELEASE(validationErrors);

    [super dealloc];
}

#pragma mark -
#pragma mark Helpers

- (NSString*)description
{
    NSString *pd = [super description];
    
    NSString *d = [NSString stringWithFormat:@"%@ ApiDomainName=%@ ExceptionName=%@ Trace=%@ ExtraData=%@ ValidationErrors=%@",
                   pd,
                    apiDomainName,
                   exceptionName,
                   trace,
                   extraData,
                   validationErrors
                   ];
    return d;
}

@end