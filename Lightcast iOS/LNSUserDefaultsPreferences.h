//
//  LNSUserDefaultsPreferences.h
//  Lightcast
//
//  Created by Martin N. Kovachev on 05.01.13.
//  Copyright (c) 2013 г. Nimasystems Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Lightcast/LPreferences.h>

@interface LNSUserDefaultsPreferences : LPreferences

- (id)initWithUserDefaults:(NSUserDefaults*)userDefaults;

@end
