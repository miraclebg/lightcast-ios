//
//  LI18nProjectCatalog.m
//  Lightcast
//
//  Created by Martin N. Kovachev on 15.03.13.
//  Copyright (c) 2013 г. Nimasystems Ltd. All rights reserved.
//

#import "LI18nProjectCatalog.h"
#import "LI18nLocalizedStringsFile.h"

NSString *const LI18nProjectCatalogErrorDomain = @"com.nimasystems.lightcast.i18n.projectCatalog";

NSString *const LI18nProjectCatalogDefaultLanguage = @"en";

@implementation LI18nProjectCatalog {
    
    NSFileManager *_fm;
}

@synthesize
baseDir,
bundleName,
skippedItems,
fileExtensions,
matchPatterns;

#pragma mark - Initialization / Finalization

- (id)initWithBaseDir:(NSString*)projectBaseDir
{
    self = [super init];
    if (self)
    {
        if ([NSString isNullOrEmpty:projectBaseDir])
        {
            lassert(false);
            L_RELEASE(self);
            return nil;
        }
        
        _fm = [[NSFileManager defaultManager] retain];
        
        fileExtensions = [[self defaultFileExtensions] retain];
        
        baseDir = [projectBaseDir copy];
    }
    return self;
}

- (id)init
{
    return [self initWithBaseDir:nil];
}

- (void)dealloc
{
    L_RELEASE(baseDir);
    L_RELEASE(bundleName);
    L_RELEASE(fileExtensions);
    L_RELEASE(skippedItems);
    L_RELEASE(matchPatterns);
    L_RELEASE(_fm);
    
    [super dealloc];
}

#pragma mark - Config

- (NSArray*)defaultFileExtensions
{
    NSArray *ret = [NSArray arrayWithObjects:
                    @"m",
                    @"mm",
                    @"c"
                    , nil];
    return ret;
}

#pragma mark - Bundle

- (NSDictionary*)currentBundleLanguages
{
    NSString *fullBundlePath = [self.baseDir stringByAppendingPathComponent:(bundleName ? bundleName : @"")];
    
    if (![_fm fileExistsAtPath:fullBundlePath])
    {
        return nil;
    }
    
    NSError *err = nil;
    NSArray *objects = [_fm contentsOfDirectoryAtPath:fullBundlePath error:&err];
    
    if (!objects || ![objects count])
    {
        return nil;
    }
    
    NSMutableDictionary *found = [[[NSMutableDictionary alloc] init] autorelease];
    
    for (NSString *file in objects)
    {
        NSString *fullPath = [fullBundlePath stringByAppendingPathComponent:file];
        
        BOOL isDirectory = NO;
        BOOL exists = [_fm fileExistsAtPath:fullPath isDirectory:&isDirectory];
        
        if (exists && !isDirectory)
        {
            continue;
        }
        
        NSString *pathExtension = [file pathExtension];
        
        if (![pathExtension isEqualToString:@"lproj"])
        {
            continue;
        }
        
        NSString *f = [file stringByDeletingPathExtension];
        [found setObject:fullPath forKey:f];
    }
    
    return found;
}

- (BOOL)parseAndMergeToBundle:(NSError**)error
{
    return [self parseAndMergeToBundle:nil error:error];
}

- (BOOL)parseAndMergeToBundle:(NSArray*)languages error:(NSError**)error
{
    if (error != NULL)
    {
        *error = nil;
    }
    
    // first parse the files
    NSDictionary *results = nil;
    BOOL parsed = [self parseSourceFiles:&results error:error];
    
    if (!parsed)
    {
        return NO;
    }
    
    NSMutableDictionary *preparedResults = nil;
    
    // prepare them
    if (results)
    {
        preparedResults = [self mergedParsedStrings:results];
    }
    
    // add the default if no languages exist
    languages = languages && [languages count] ? languages : [NSArray arrayWithObject:LI18nProjectCatalogDefaultLanguage];
    
    // obtain the locale files
    NSMutableDictionary *languageFiles = [[[NSMutableDictionary alloc] initWithDictionary:[self currentBundleLanguages]] autorelease];
    
    NSString *bName = self.bundleName ? self.bundleName : @"";
    
    // add the ones which do not exist
    for(NSString *langCode in languages)
    {
        if (![languageFiles objectForKey:langCode])
        {
            NSString *fpath = [NSString stringWithFormat:@"%@.lproj", [[self.baseDir stringByAppendingPathComponent:bName] stringByAppendingPathComponent:langCode]];
            [languageFiles setObject:fpath forKey:langCode];
        }
    }
    
    // prepare the keys as a pair of key:comment
    NSMutableDictionary *newKeys = [[[NSMutableDictionary alloc] init] autorelease];
    
    for(NSString *key in preparedResults)
    {
        NSArray *containedInFiles = [preparedResults objectForKey:key];
        NSString *comment = (containedInFiles && [containedInFiles count]) ? [containedInFiles componentsJoinedByString:@", "] : kLI18nLocalizedStringsFileDefaultComment;
        [newKeys setObject:comment forKey:key];
    }
    
    // create an instance of each catalog
    for(NSString *langCode in languageFiles)
    {
        @autoreleasepool
        {
            NSString *dirName = [languageFiles objectForKey:langCode];
            NSString *fname = [dirName stringByAppendingPathComponent:@"Localizable.strings"];
            
            LI18nLocalizedStringsFile *p = [[[LI18nLocalizedStringsFile alloc] init] autorelease];
            
            NSError *err = nil;
            [p loadFromFile:fname error:&err];
            
            // merge
            [p mergeStringsWithKeys:newKeys];
         
            // create the dir if missing
            [_fm createDirectoryAtPath:dirName withIntermediateDirectories:YES attributes:nil error:nil];
            
            // write back
            BOOL written = [p saveToFile:fname error:&err];
            
            if (!written)
            {
                lassert(false);
                continue;
            }
        }
    }
    
    return YES;
}

#pragma mark - File system methods

- (NSArray*)findFiles:(NSString*)baseDir_ allowedFileExtensions:(NSArray*)fileExtensions_ skippedItems:(NSArray*)skippedItems_
{
    lassert(![NSString isNullOrEmpty:baseDir_]);
    
    NSError *err = nil;
    NSArray *objects = [_fm subpathsOfDirectoryAtPath:baseDir_ error:&err];
    lassert(!err);
    
    if (!objects)
    {
        return nil;
    }
    
    NSMutableArray *found = [[[NSMutableArray alloc] init] autorelease];
    
    for (NSString *file in objects)
    {
        // skip hidden files
        if ([[file substringToIndex:1] isEqualToString:@"."] || [file containsString:@"/."])
        {
            continue;
        }
        
        NSString *fullPath = [baseDir_ stringByAppendingPathComponent:file];
        
        BOOL isDirectory = NO;
        BOOL exists = [_fm fileExistsAtPath:fullPath isDirectory:&isDirectory];
        
        if (exists && !isDirectory)
        {
            NSString *pathExtension = [file pathExtension];
            
            // check if we need to skip it
            if (skippedItems_)
            {
                BOOL shouldSkip = NO;
                
                for(NSString *skipItem in skippedItems_)
                {
                    if ([file containsString:skipItem])
                    {
                        shouldSkip = YES;
                        break;
                    }
                }
                
                if (shouldSkip)
                {
                    continue;
                }
            }
            
            // check if file extension matches
            if (fileExtensions_)
            {
                BOOL shouldSkip = YES;
                
                for(NSString *extension in fileExtensions_)
                {
                    if ([pathExtension isEqualToString:extension])
                    {
                        shouldSkip = NO;
                        break;
                    }
                }
                
                if (shouldSkip)
                {
                    continue;
                }
            }
            
            // all ok - add it
            [found addObject:fullPath];
        }
    }
    
    return found;
}

#pragma mark - Parsing

- (BOOL)parseSourceFiles:(NSDictionary**)parsedStrings error:(NSError**)error
{
    if (error != NULL)
    {
        *error = nil;
    }
    
    if (parsedStrings != NULL)
    {
        *parsedStrings = nil;
    }
    
    // check the base dir
    if (![_fm folderExists:baseDir])
    {
        if (error != NULL)
        {
            *error = [NSError errorWithDomainAndDescription:LI18nProjectCatalogErrorDomain
                                                  errorCode:LI18nProjectCatalogErrorIO
                                       localizedDescription:LLocalizedString(@"Project directory is unavailable")];
        }
        
        return NO;
    }
    
    NSMutableDictionary *parsedStrings_ = [[[NSMutableDictionary alloc] init] autorelease];
    
    // find the files in the project's base directory
    NSArray *foundFiles = [self findFiles:self.baseDir allowedFileExtensions:self.fileExtensions skippedItems:self.skippedItems];
    
    if (foundFiles && [foundFiles count])
    {
        NSError *err = nil;
        BOOL ret = NO;
        LI18nTranslationSourceParser *parser = nil;
        
        for(NSString *filename in foundFiles)
        {
            @autoreleasepool
            {
                // parse
                NSData *fdata = [NSData dataWithContentsOfFile:filename];
                
                if (!fdata)
                {
                    lassert(false);
                    continue;
                }
                
                NSString *fdata_ = [[[NSString alloc] initWithData:fdata encoding:NSUTF8StringEncoding] autorelease];
                lassert(fdata_);
                parser = [[[LI18nTranslationSourceParser alloc] initWithSourceString:fdata_] autorelease];
                parser.patterns = self.matchPatterns;
                ret = [parser parse:&err];
                lassert(ret);
                
                if (!ret || !parser.parsedStrings)
                {
                    continue;
                }
                
                [parsedStrings_ setObject:parser.parsedStrings forKey:filename];
            }
        }
    }
    
    if ([parsedStrings_ count] && parsedStrings != NULL)
    {
        *parsedStrings = parsedStrings_;
    }
    
    return YES;
}

- (NSMutableDictionary*)mergedParsedStrings:(NSDictionary*)parseResults
{
    lassert(parseResults);
    
    // prepare the comments
    NSMutableDictionary *tmp = [[[NSMutableDictionary alloc] init] autorelease];
    
    for(NSString *filename in parseResults)
    {
        NSString *baseFilename = [filename lastPathComponent];
        NSArray *strings = [parseResults objectForKey:filename];
        
        for(NSString *key in strings)
        {
            NSMutableArray *ar = [tmp objectForKey:key] ? [tmp objectForKey:key] : [[[NSMutableArray alloc] init] autorelease];
            
            if ([ar containsObject:baseFilename])
            {
                continue;
            }
            
            [ar addObject:baseFilename];
            [tmp setObject:ar forKey:key];
        }
    }
    
    return tmp;
}

@end
