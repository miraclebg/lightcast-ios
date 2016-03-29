//
//  LVars.h
//  Lightcast
//
//  Created by Martin N. Kovachev on 17.12.12.
//  Copyright (c) 2012 г. Nimasystems Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LVars : NSObject

+ (BOOL)isNullOrEmpty:(id)var;
+ (id)nilify:(id)var;

@end
