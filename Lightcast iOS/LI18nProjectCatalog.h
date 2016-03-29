//
//  LI18nProjectCatalog.h
//  Lightcast
//
//  Created by Martin N. Kovachev on 15.03.13.
//  Copyright (c) 2013 г. Nimasystems Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const LI18nProjectCatalogErrorDomain;
extern NSString *const LI18nProjectCatalogDefaultLanguage;

typedef enum
{
    LI18nProjectCatalogErrorUnknown = 0,
    LI18nProjectCatalogErrorGeneric = 1,
    LI18nProjectCatalogErrorInvalidParams = 2,
    
    LI18nProjectCatalogErrorIO = 10
    
} LI18nProjectCatalogError;

@interface LI18nProjectCatalog : NSObject

@property (nonatomic, copy, readonly) NSString *baseDir;

@property (nonatomic, copy) NSString *bundleName;
@property (nonatomic, copy) NSArray *skippedItems;
@property (nonatomic, copy) NSArray *fileExtensions;
@property (nonatomic, copy) NSArray *matchPatterns;

- (id)initWithBaseDir:(NSString*)projectBaseDir;

- (BOOL)parseAndMergeToBundle:(NSArray*)languages error:(NSError**)error;
- (BOOL)parseAndMergeToBundle:(NSError**)error;

- (BOOL)parseSourceFiles:(NSDictionary**)parsedStrings error:(NSError**)error;
- (NSDictionary*)currentBundleLanguages;

- (NSArray*)defaultFileExtensions;

@end
