//
//  LWebServiceError.h
//  cocoa
//
//  Created by Martin N. Kovachev on 15.12.12.
//  Copyright (c) 2012 г. Stampii S.L. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const StampiiAPIErrorDomain;

@interface LWebServiceError : NSError

@property (retain, readonly) NSString *apiDomainName;

@property (copy) NSString *trace;
@property (copy) NSString *exceptionName;
@property (copy) NSString *extraData;
@property (copy) NSArray *validationErrors;

- (id)initWithStampiiError:(NSString*)apiDomainName_ errorMessage:(NSString*)errorMessage_ errorCode:(NSInteger)errorCode_;

@end
