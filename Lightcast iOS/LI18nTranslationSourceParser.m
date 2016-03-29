//
//  LI18nTranslationSourceParser.m
//  Lightcast
//
//  Created by Martin N. Kovachev on 15.03.13.
//  Copyright (c) 2013 г. Nimasystems Ltd. All rights reserved.
//

#import "LI18nTranslationSourceParser.h"
#import "LI18nParsedString.h"

NSString *const kLCI18nTranslationParserErrorDomain = @"com.nimasystems.lightcast.i18n.translationSourceParser";

@implementation LI18nTranslationSourceParser

@synthesize
sourceString,
patterns,
parsedStrings;

#pragma mark - Initialization / Finalization

- (id)initWithSourceString:(NSString*)string
{
    self = [super init];
    if (self)
    {
        sourceString = [string retain];
    }
    return self;
}

- (id)init
{
    return [self initWithSourceString:nil];
}

- (void)dealloc
{
    L_RELEASE(patterns);
    L_RELEASE(sourceString);
    L_RELEASE(parsedStrings);
    
    [super dealloc];
}

#pragma mark - Parsing

- (BOOL)parse:(NSError**)error
{
    if (error != NULL)
    {
        *error = nil;
    }
    
    /*patterns = [[NSArray arrayWithObjects:
                @"\\[LI18n[\\s]+?localizedString\\:\\@\"([\\w\\d\\s]+?)\"[\\s\\n]*\\]",
                @"\\[LI18n[\\s]+?localizedStringWithFormat\\:\\@\"([\\w\\d\\s]+?)\".*\\]",
                 nil] retain];*/

    // check for patterns
    if (!patterns || ![patterns count])
    {
        if (error != NULL)
        {
            *error = [NSError errorWithDomainAndDescription:kLCI18nTranslationParserErrorDomain
                                                  errorCode:LI18nTranslationSourceParserErrorPatternsNotProvided
                                       localizedDescription:LLocalizedString(@"Patterns not provided")];
        }
        
        return NO;
    }
    
    if ([NSString isNullOrEmpty:sourceString])
    {
        return YES;
    }
    
    L_RELEASE(parsedStrings);
    
    // walk each regex and find translations
    NSMutableArray *ret1 = [[[NSMutableArray alloc] init] autorelease];

    for(NSString *pattern in patterns)
    {
        NSArray *parsedStrings_ = nil;
        BOOL ret = [self parseSourceStringWithPattern:pattern parsedStrings:&parsedStrings_ error:error];
        
        if (!ret)
        {
            lassert(false);
            return NO;
        }
        
        // merge with main array
        if (parsedStrings_ && [parsedStrings_ count])
        {
            for(NSString *string in parsedStrings_)
            {
                if ([ret1 containsObject:string])
                {
                    continue;
                }
                
                [ret1 addObject:string];
            }
        }
    }
    
    // assign
    if ([ret1 count])
    {
        // sort it
        [ret1 sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            
            NSString *sobj1 = (NSString*)obj1;
            NSString *sobj2 = (NSString*)obj2;
            
            NSComparisonResult res = [sobj1 compare:sobj2];
            
            return res;
        }];
        
        if (parsedStrings != ret1)
        {
            L_RELEASE(parsedStrings);
            parsedStrings = [ret1 retain];
        }
    }
    
    return YES;
}

- (BOOL)parseSourceStringWithPattern:(NSString*)pattern parsedStrings:(NSArray**)parsedStrings_ error:(NSError**)error
{
    if (error != NULL)
    {
        *error = nil;
    }
    
    if (parsedStrings_ != NULL)
    {
        *parsedStrings_ = nil;
    }
    
    lassert(![NSString isNullOrEmpty:pattern]);
    
    // create the regex
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                           options:(NSRegularExpressionCaseInsensitive /*| NSRegularExpressionDotMatchesLineSeparators*/)
                                                                             error:error];
    
    if (!regex)
    {
        return NO;
    }
    
    // TODO: Check 10.7 as a minimum here!
    
    NSString *stmp = sourceString;
    stmp = [stmp stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
    lassert(![NSString isNullOrEmpty:stmp]);
    
    NSMutableArray *foundStrings = [[[NSMutableArray alloc] init] autorelease];
    
    [regex enumerateMatchesInString:stmp options:NSMatchingReportCompletion range:NSMakeRange(0, [stmp length]) usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop)
    {
        if (!match)
        {
            *stop = YES;
            return;
        }
        
        NSInteger matches = [match numberOfRanges];

        if (matches == 2)
        {
            NSString *matchedString = [stmp substringWithRange:[match rangeAtIndex:1]];
            
            [foundStrings addObject:matchedString];
        }
    }];
    
    if ([foundStrings count] && parsedStrings_ != NULL)
    {
        *parsedStrings_ = foundStrings;
    }
    
    return YES;
}

@end
