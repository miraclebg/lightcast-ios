//
//  LNumbers.h
//  Lightcast
//
//  Created by Martin N. Kovachev on 18.12.12.
//  Copyright (c) 2012 г. Nimasystems Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LNumbers : NSObject

+ (NSInteger)randomNumber;
+ (NSInteger)randomNumberInRange:(NSInteger)highBound;
+ (BOOL)randBool;

@end
