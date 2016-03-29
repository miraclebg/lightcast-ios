//
//  LStringObfuscator.h
//  Lightcast
//
//  Created by Martin Kovachev on 06.12.13.
//  Copyright (c) 2013 г. Nimasystems Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LStringObfuscator : NSObject

- (NSString *)obfuscate:(NSString *)string withKey:(NSString *)key;

- (NSData*)obsd:(unsigned char *)input len:(uint)len cls:(Class)cls;
- (NSString*)obs:(unsigned char *)input len:(uint)len cls:(Class)cls;

@end
