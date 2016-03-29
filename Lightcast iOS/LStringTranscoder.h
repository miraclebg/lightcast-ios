//
//  LStringTranscoder.h
//  Lightcast
//
//  Created by Martin N. Kovachev on 04.08.13.
//  Copyright (c) 2013 г. Nimasystems Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LStringTranscoder : NSObject

+ (NSArray*)latinToCyrillicMap;

- (NSString*)ucfirstCyr:(NSString*)str;
- (NSString*)toCyrUppercase:(NSString*)lowercaseChar;

- (NSString*)transcodeLatToCyrString:(NSString*)string;

@end
