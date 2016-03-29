//
//  LI18nLocalizedStringsFile.h
//  Lightcast
//
//  Created by Martin N. Kovachev on 15.03.13.
//  Copyright (c) 2013 г. Nimasystems Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const LI18nLocalizedStringsFileErrorDomain;
extern NSString *const kLI18nLocalizedStringsFileDefaultComment;

typedef enum
{
    LI18nLocalizedStringsFileErrorUnknown = 0,
    LI18nLocalizedStringsFileErrorGeneric = 1,
    LI18nLocalizedStringsFileErrorInvalidParams = 2,
    
    LI18nLocalizedStringsFileErrorIO = 10
    
} LI18nLocalizedStringsFileError;

@interface LI18nLocalizedStringsFile : NSObject

@property (nonatomic, retain) NSArray *strings;

- (BOOL)loadFromFile:(NSString*)filename error:(NSError**)error;
- (BOOL)saveToFile:(NSString*)filename error:(NSError**)error;

- (void)mergeStringsWithKeys:(NSDictionary*)newKeys;

@end
