//
//  LValidatorUtils.h
//  Lightcast
//
//  Created by Martin Kovachev on 19.11.15 г..
//  Copyright © 2015 г. Nimasystems Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LValidatorUtils : NSObject

+ (BOOL)validateEmail:(NSString*)email;
+ (BOOL)validateEmail:(NSString*)target strict:(BOOL)strict;

@end
