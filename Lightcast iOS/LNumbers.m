//
//  LNumbers.m
//  Lightcast
//
//  Created by Martin N. Kovachev on 18.12.12.
//  Copyright (c) 2012 г. Nimasystems Ltd. All rights reserved.
//

#import "LNumbers.h"
#include <stdlib.h>

@implementation LNumbers

+ (NSInteger)randomNumber
{
    srandom((unsigned)time(NULL));
    NSInteger ret = random();
    
    return ret;
}

+ (NSInteger)randomNumberInRange:(NSInteger)highBound
{
    if (!highBound)
    {
        return 0;
    }
    
    return arc4random_uniform((int)highBound);
    /*
    if (!highBound)
    {
        return 0;
    }
    
    srandom((unsigned)time(NULL));
    NSInteger ret = random() % highBound;
    
    return ret;*/
}

+ (BOOL)randBool
{
    u_int32_t randomNumber = (arc4random() % ((unsigned)RAND_MAX + 1));
    
    if(randomNumber % 5 == 0) {
        return YES;
    }
    
    return NO;
}

@end
