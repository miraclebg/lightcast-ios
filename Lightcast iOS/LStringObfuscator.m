//
//  LStringObfuscator.m
//  Lightcast
//
//  Created by Martin Kovachev on 06.12.13.
//  Copyright (c) 2013 г. Nimasystems Ltd. All rights reserved.
//

#import "LStringObfuscator.h"

@implementation LStringObfuscator

- (NSString *)obfuscate:(NSString *)string withKey:(NSString *)key
{
    // Create data object from the string
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    
    // Get pointer to data to obfuscate
    char *dataPtr = (char *) [data bytes];
    
    // Get pointer to key data
    char *keyData = (char *) [[key dataUsingEncoding:NSUTF8StringEncoding] bytes];
    
    // Points to each char in sequence in the key
    char *keyPtr = keyData;
    int keyIndex = 0;
    
    // For each character in data, xor with current value in key
    for (int x = 0; x < [data length]; x++)
    {
        // Replace current character in data with
        // current character xor'd with current key value.
        // Bump each pointer to the next character
        *dataPtr = *dataPtr ^ *keyPtr;
        dataPtr++;
        keyPtr++;
        
        // If at end of key data, reset count and
        // set key pointer back to start of key value
        if (++keyIndex == [key length])
            keyIndex = 0, keyPtr = keyData;
    }
    
    return [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
}

- (NSData*)obsd:(unsigned char *)input len:(uint)len cls:(Class)cls {
    //unsigned char obfuscatedSecretKey[] = { 0xDE, 0xAD, 0xBE, 0xEF, 0xDE, 0xAD, 0xBE, 0xEF, 0xDE, 0xAD, 0xBE, 0xEF, 0xDE, 0xAD, 0xBE, 0xEF };
    
    // Get the SHA1 of a class name, to form the obfuscator.
    unsigned char obfuscator[CC_SHA1_DIGEST_LENGTH];
    NSData *className = [NSStringFromClass(cls)
                         dataUsingEncoding:NSUTF8StringEncoding];
    CC_SHA1(className.bytes, (CC_LONG)className.length, obfuscator);
    
    // XOR the class name against the obfuscated key, to form the real key.
    unsigned char as[len];
    for (int i=0; i<len; i++) {
        as[i] = input[i] ^ obfuscator[i];
    }
    
    NSData *d = [NSData dataWithBytes:as length:sizeof(as)];
    return d;
}

- (NSString*)obs:(unsigned char *)input len:(uint)len cls:(Class)cls {
    NSData *d = [self obsd:input len:len cls:cls];
    NSString *o = [NSString stringWithCString:[d bytes] encoding:NSUTF8StringEncoding];
    return o;
}

@end
