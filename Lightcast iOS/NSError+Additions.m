//
//  NSError+Additions.m
//  Lightcast
//
//  Created by Martin N. Kovachev on 19.12.12.
//  Copyright (c) 2012 г. Nimasystems Ltd. All rights reserved.
//

#import "NSError+Additions.h"

NSString *const kNSErrorAdditionsCustomDataKey = @"customData";

@implementation NSError(Additions)

+ (NSError*)errorWithDomainAndDescription:(NSString*)domain errorCode:(NSInteger)errorCode localizedDescription:(NSString*)description
{
    return [NSError errorWithDomainAndDescription:domain errorCode:errorCode localizedDescription:description customData:nil];
}

+ (NSError*)errorWithDomainAndDescription:(NSString*)domain errorCode:(NSInteger)errorCode localizedDescription:(NSString*)description customData:(id)customData
{
    NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
    
    if (description)
    {
        [errorDetail setValue:description forKey:NSLocalizedDescriptionKey];
    }
    
    if (customData)
    {
        [errorDetail setValue:customData forKey:kNSErrorAdditionsCustomDataKey];
    }
    
    NSError *err = [NSError errorWithDomain:domain code:errorCode userInfo:errorDetail];

    return err;
}

@end
