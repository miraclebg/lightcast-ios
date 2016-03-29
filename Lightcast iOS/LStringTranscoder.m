//
//  LStringTranscoder.m
//  Lightcast
//
//  Created by Martin N. Kovachev on 04.08.13.
//  Copyright (c) 2013 г. Nimasystems Ltd. All rights reserved.
//

#import "LStringTranscoder.h"

@implementation LStringTranscoder

static NSArray *sLStringTranscoderLatCyrMap = nil;
static NSDictionary *cLStringLowercaseMap = nil;

- (NSString*)ucfirstCyr:(NSString*)str {
    if (!str || !str.length) {
        return str;
    }
    
    NSString *str2 = [NSString stringWithFormat:@"%@%@",
                      [self toCyrUppercase:[str substringToIndex:1]],
                      [str substringFromIndex:1]
                      ];
    return str2;
}

- (NSString*)toCyrUppercase:(NSString*)lowercaseChar {
    NSString *r = nil;
    if (!cLStringLowercaseMap) {
        cLStringLowercaseMap = [[NSDictionary dictionaryWithObjectsAndKeys:
                                @"А", @"а",
                                @"Б", @"б",
                                @"В", @"в",
                                @"Г", @"г",
                                @"Д", @"д",
                                @"Е", @"е",
                                @"Ж", @"ж",
                                @"З", @"з",
                                @"И", @"и",
                                @"Й", @"й",
                                @"К", @"к",
                                @"Л", @"л",
                                @"М", @"м",
                                @"Н", @"н",
                                @"О", @"о",
                                @"П", @"п",
                                @"Р", @"р",
                                @"С", @"с",
                                @"Т", @"т",
                                @"У", @"у",
                                @"Ф", @"ф",
                                @"Х", @"х",
                                @"Ц", @"ц",
                                @"Ч", @"ч",
                                @"Ш", @"ш",
                                @"Щ", @"щ",
                                @"Я", @"я",
                                @"Ь", @"ь",
                                 nil] retain];
    }
    
    r = ([cLStringLowercaseMap objectForKey:lowercaseChar] ? [cLStringLowercaseMap objectForKey:lowercaseChar] : lowercaseChar);
    return r;
}

+ (NSArray*)latinToCyrillicMap
{
    if (sLStringTranscoderLatCyrMap)
    {
        return sLStringTranscoderLatCyrMap;
    }
    
    // order is important!
    // longest phrases must be first!
    
    NSArray *map = @[
                     @{@"SHCH" : @"Щ"},
                     @{@"SHT" : @"Щ"},
                     
                     @{@"shch": @"щ"},
                     @{@"sht": @"щ"},
                     
                     @{@"ZH": @"Ж"},
                     @{@"KH": @"Х"},
                     @{@"TS": @"Ц"},
                     @{@"CH": @"Ч"},
                     @{@"SH": @"Ш"},
                     @{@"YU": @"Ю"},
                     @{@"YA": @"Я"},
                     
                     @{@"zh": @"ж"},
                     @{@"kh": @"х"},
                     @{@"ts": @"ц"},
                     @{@"ch": @"ч"},
                     @{@"sh": @"ш"},
                     @{@"yu": @"ю"},
                     @{@"ya": @"я"},
                     
                     @{@"A": @"А"},
                     @{@"B": @"Б"},
                     @{@"C": @"Ц"},
                     @{@"D": @"Д"},
                     @{@"E": @"Е"},
                     @{@"F": @"Ф"},
                     @{@"G": @"Г"},
                     @{@"H": @"Х"},
                     @{@"I": @"И"},
                     @{@"J": @"Ж"},
                     @{@"K": @"К"},
                     @{@"L": @"Л"},
                     @{@"M": @"М"},
                     @{@"N": @"Н"},
                     @{@"O": @"О"},
                     @{@"P": @"П"},
                     @{@"Q": @"Я"},
                     @{@"R": @"Р"},
                     @{@"S": @"С"},
                     @{@"T": @"Т"},
                     @{@"U": @"У"},
                     @{@"V": @"В"},
                     @{@"W": @"В"},
                     @{@"X": @"КС"},
                     @{@"Y": @"Й"},
                     @{@"Z": @"З"},
                     
                     @{@"a": @"а"},
                     @{@"b": @"б"},
                     @{@"c": @"ц"},
                     @{@"d": @"д"},
                     @{@"e": @"е"},
                     @{@"f": @"ф"},
                     @{@"g": @"г"},
                     @{@"h": @"х"},
                     @{@"i": @"и"},
                     @{@"j": @"ж"},
                     @{@"k": @"к"},
                     @{@"l": @"л"},
                     @{@"m": @"м"},
                     @{@"n": @"н"},
                     @{@"o": @"о"},
                     @{@"p": @"п"},
                     @{@"q": @"я"},
                     @{@"r": @"р"},
                     @{@"s": @"с"},
                     @{@"t": @"т"},
                     @{@"u": @"у"},
                     @{@"v": @"в"},
                     @{@"w": @"в"},
                     @{@"x": @"кс"},
                     @{@"y": @"й"},
                     @{@"z": @"з"},
                     ];
    
    sLStringTranscoderLatCyrMap = [map retain];
    
    return sLStringTranscoderLatCyrMap;
}

- (NSString*)transcodeLatToCyrString:(NSString*)string
{
    if ([NSString isNullOrEmpty:string])
    {
        return nil;
    }
    
    // iterate the map and replace chars
    NSString *ret = [[string copy] autorelease];
    
    NSArray *map = [LStringTranscoder latinToCyrillicMap];
    
    for(NSDictionary *mm in map)
    {
        NSString *k = [[mm allKeys] objectAtIndex:0];
        NSString *v = [mm objectForKey:k];
        
        ret = [ret stringByReplacingOccurrencesOfString:k withString:v];
    }
    
    return ret;
}

@end
