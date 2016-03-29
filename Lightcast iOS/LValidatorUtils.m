//
//  LValidatorUtils.m
//  Lightcast
//
//  Created by Martin Kovachev on 19.11.15 г..
//  Copyright © 2015 г. Nimasystems Ltd. All rights reserved.
//

#import "LValidatorUtils.h"

@implementation LValidatorUtils

+ (BOOL)validateEmail:(NSString*)target {
    return [LValidatorUtils validateEmail:target strict:NO];
}

+ (BOOL)validateEmail:(NSString*)target strict:(BOOL)strict {
    if ([NSString isNullOrEmpty:target]) {
        return NO;
    }
    
    // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"^[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}$";
    NSString *laxString = @"^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$";
    NSString *emailRegex = strict ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:target];
}

@end
