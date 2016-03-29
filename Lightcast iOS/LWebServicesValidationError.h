//
//  LWebServicesValidationError.h
//  cocoa
//
//  Created by Martin N. Kovachev on 15.12.12.
//  Copyright (c) 2012 г. Stampii S.L. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LWebServicesValidationError : NSObject

@property (retain) NSString *fieldName;
@property (retain) NSString *errorMessage;

@end
