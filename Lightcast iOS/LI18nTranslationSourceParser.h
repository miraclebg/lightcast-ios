//
//  LI18nTranslationSourceParser.h
//  Lightcast
//
//  Created by Martin N. Kovachev on 15.03.13.
//  Copyright (c) 2013 г. Nimasystems Ltd. All rights reserved.
//

extern NSString *const kLCI18nTranslationParserErrorDomain;

typedef enum
{
    LI18nTranslationSourceParserErrorUnknown = 0,
    LI18nTranslationSourceParserErrorGeneric = 1,
    LI18nTranslationSourceParserErrorInvalidParams = 2,
    
    LI18nTranslationSourceParserErrorPatternsNotProvided = 3,
    
    LI18nTranslationSourceParserErrorIO = 20
    
    
} LI18nTranslationSourceParserError;

@interface LI18nTranslationSourceParser : NSObject

@property (nonatomic, retain, readonly) NSString *sourceString;
@property (nonatomic, retain) NSArray *patterns;

@property (nonatomic, retain, readonly) NSArray *parsedStrings;

- (id)initWithSourceString:(NSString*)string;

- (BOOL)parse:(NSError**)error;

@end
