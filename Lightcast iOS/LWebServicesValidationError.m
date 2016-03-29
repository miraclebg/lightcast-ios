//
//  LWebServicesValidationError.m
//  cocoa
//
//  Created by Martin N. Kovachev on 15.12.12.
//  Copyright (c) 2012 г. Stampii S.L. All rights reserved.
//

#import "LWebServicesValidationError.h"

@implementation LWebServicesValidationError

@synthesize
fieldName,
errorMessage;

#pragma mark -
#pragma mark Initialization / Finalization

- (void)dealloc
{
    L_RELEASE(fieldName);
    L_RELEASE(errorMessage);
    
    [super dealloc];
}

#pragma mark -
#pragma mark Helpers

- (NSString*)description
{
    NSString *d = [NSString stringWithFormat:@"Field=%@ Error=%@",
                   fieldName,
                   errorMessage
                   ];
    return d;
}

@end
