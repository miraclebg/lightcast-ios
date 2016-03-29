//
//  LI18nLocalizedStringsFile.m
//  Lightcast
//
//  Created by Martin N. Kovachev on 15.03.13.
//  Copyright (c) 2013 г. Nimasystems Ltd. All rights reserved.
//

#import "LI18nLocalizedStringsFile.h"
#import "LI18nParsedString.h"

NSString *const LI18nLocalizedStringsFileErrorDomain = @"com.nimasystems.lightcast.i18n.localizedStringsFile";

NSString *const kLI18nLocalizedStringsFileDefaultComment = @"No comment provided by engineer.";

@implementation LI18nLocalizedStringsFile

@synthesize
strings;

#pragma mark - Initialization / Finalization

- (void)dealloc
{
    L_RELEASE(strings);
    
    [super dealloc];
}

#pragma mark - File Operations

- (BOOL)loadFromFile:(NSString*)filename error:(NSError**)error
{
    if (error != NULL)
    {
        *error = nil;
    }
    
    if (!filename)
    {
        lassert(false);
        return NO;
    }
    
    L_RELEASE(strings);
    
    // TODO: Redevelop this by custom parsing
    
    NSDictionary *strings_ = [NSDictionary dictionaryWithContentsOfFile:filename];
    
    if (strings_)
    {
        // slash them
        NSMutableDictionary *slashed = [[[NSMutableDictionary alloc] init] autorelease];
        
        for(NSString *key in strings_)
        {
            NSString *keyNew = [key stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"];
            keyNew = [keyNew stringByReplacingOccurrencesOfString:@"\r" withString:@"\\r"];
            keyNew = [keyNew stringByReplacingOccurrencesOfString:@"\t" withString:@"\\t"];
            
            NSString *value = [strings_ objectForKey:key];
            value = [value stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"];
            value = [value stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"];
            value = [value stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"];
            
            [slashed setObject:value forKey:keyNew];
        }
        
        NSMutableArray *ar = [[[NSMutableArray alloc] init] autorelease];
        
        for(NSString *key in slashed)
        {
            // skip duplicates
            BOOL found = NO;
            
            for(LI18nParsedString *l in ar)
            {
                if ([l.key isEqualToString:key])
                {
                    found = YES;
                    break;
                }
            }
            
            if (found)
            {
                continue;
            }
            
            if ([key isEqualToString:@"Version: %@\nCopyright 2009-%@\nStampii S.L."])
            {
                LogDebug(@"ys");
            }
            
            LI18nParsedString *str = [[[LI18nParsedString alloc] init] autorelease];
            str.key = key;
            str.value = [slashed objectForKey:key];
            [ar addObject:str];
        }
        
        if ([ar count])
        {
            self.strings = ar;
        }
    }
    
    return YES;
}

- (BOOL)hasKey:(NSString*)key
{
    if ([NSString isNullOrEmpty:key])
    {
        return NO;
    }
    
    for(LI18nParsedString *parsedString in self.strings)
    {
        if ([parsedString.key isEqualToString:key])
        {
            return YES;
        }
    }
    
    return NO;
}

- (BOOL)saveToFile:(NSString*)filename error:(NSError**)error
{
    if (error != NULL)
    {
        *error = nil;
    }
    
    if (!filename)
    {
        lassert(false);
        return NO;
    }
    
    // first - sort them
    NSArray *sortedStrings = [self.strings sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        
        LI18nParsedString *l1 = obj1;
        LI18nParsedString *l2 = obj2;
        
        NSComparisonResult res = NSOrderedSame;
        
        if ([NSString isNullOrEmpty:l1.value] && [NSString isNullOrEmpty:l2.value])
        {
            return res;
        }
        else
        {
            res = [NSString isNullOrEmpty:l1.value] ? NSOrderedAscending : NSOrderedDescending;
        }
        
        return res;
    }];
    
    NSMutableArray *ar = [[[NSMutableArray alloc] init] autorelease];
    
    if (self.strings)
    {
        for(LI18nParsedString *parsedString in sortedStrings)
        {
            NSString *comment = parsedString.comment ? parsedString.comment : kLI18nLocalizedStringsFileDefaultComment;
            
            [ar addObject:[NSString stringWithFormat:@"/* %@ */", comment]];
            
            NSString *slashedKey = [self addSlashes:parsedString.key];
            lassert(![NSString isNullOrEmpty:slashedKey]);
            
            NSString *slashedValue = [self addSlashes:parsedString.value];
            slashedValue = ![NSString isNullOrEmpty:slashedValue] ? slashedValue : @"";
            
            [ar addObject:[NSString stringWithFormat:@"\"%@\" = \"%@\";\n", slashedKey, slashedValue]];
        }
    }
    
    NSString *compiled = [ar componentsJoinedByString:@"\n"];
    compiled = compiled ? compiled : @"";
    
    BOOL ret = [compiled writeToFile:filename atomically:YES encoding:NSUTF8StringEncoding error:error];

    return ret;
}

#pragma mark - Merging

- (void)mergeStringsWithKeys:(NSDictionary*)newKeys
{
    if (!newKeys)
    {
        lassert(false);
        return;
    }
    
    // if there are no current strings - set the newKeys to the strings
    if (!self.strings || ![self.strings count])
    {
        NSMutableArray *newStrings = [[[NSMutableArray alloc] init] autorelease];
        
        for(NSString *key in newKeys)
        {
            NSString *comment = [newKeys objectForKey:key];
            LI18nParsedString *str = [[[LI18nParsedString alloc] init] autorelease];
            str.key = key;
            str.comment = comment;
            [newStrings addObject:str];
        }
        
        self.strings = newStrings;
        
        return;
    }

    // remove obsolete ones - which are no longer seen in newKeys
    NSMutableArray *compiled = [[[NSMutableArray alloc] init] autorelease];
    
    for(LI18nParsedString *ps in self.strings)
    {
        BOOL found = NO;
        
        for(NSString *key in newKeys)
        {
            if ([key isEqualToString:ps.key])
            {
                found = YES;
                break;
            }
        }
        
        if (found)
        {
            [compiled addObject:ps];
        }
    }
    
    // append keys which are only seen in newKeys
    for(NSString *key in newKeys)
    {
        NSString *comment = [newKeys objectForKey:key];
        
        BOOL exists = NO;
        
        for(LI18nParsedString *psold in compiled)
        {
            if ([key isEqualToString:psold.key])
            {
                LI18nParsedString *k = psold;
                // just update the comment
                k.comment = comment;
                exists = YES;
                break;
            }
        }
        
        if (!exists)
        {
            // add it
            LI18nParsedString *ps = [[[LI18nParsedString alloc] init] autorelease];
            ps.key = key;
            ps.comment = comment;
            [compiled addObject:ps];
        }
    }
    
    self.strings = compiled;
}

#pragma mark - Parsing

- (NSString*)addSlashes:(NSString*)value
{
    if (!value)
    {
        return nil;
    }
    
    value = [value stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    value = [value stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"];
    
    return value;
}

- (BOOL)parseStringData:(NSString*)string parsedStrings:(NSArray**)parsedStrings error:(NSError**)error
{
    if (parsedStrings != NULL)
    {
        *parsedStrings = nil;
    }
    
    if (error != NULL)
    {
        *error = nil;
    }
    
    if ([NSString isNullOrEmpty:string])
    {
        return YES;
    }
    
    return YES;
}

@end
