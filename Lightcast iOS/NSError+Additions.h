//
//  NSError+Additions.h
//  Lightcast
//
//  Created by Martin N. Kovachev on 19.12.12.
//  Copyright (c) 2012 г. Nimasystems Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const kNSErrorAdditionsCustomDataKey;

@interface NSError(Additions)

+ (NSError*)errorWithDomainAndDescription:(NSString*)domain errorCode:(NSInteger)errorCode localizedDescription:(NSString*)description;
+ (NSError*)errorWithDomainAndDescription:(NSString*)domain errorCode:(NSInteger)errorCode localizedDescription:(NSString*)description customData:(id)customData;

@end
