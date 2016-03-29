/*
 * Lightcast for iOS Framework
 * Copyright (C) 2007-2011 Nimasystems Ltd
 *
 * This program is NOT free software; you cannot redistribute and/or modify
 * it's sources under any circumstances without the explicit knowledge and
 * agreement of the rightful owner of the software - Nimasystems Ltd.
 *
 * This program is distributed WITHOUT ANY WARRANTY; without even the
 * implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
 * PURPOSE.  See the LICENSE.txt file for more information.
 *
 * You should have received a copy of LICENSE.txt file along with this
 * program; if not, write to:
 * NIMASYSTEMS LTD 
 * Plovdiv, Bulgaria
 * ZIP Code: 4000
 * Address: 95 "Kapitan Raycho" Str., 6th Floor
 * General E-Mail: info@nimasystems.com
 * Tel./Fax: +359 32 395 282
 * Mobile: +359 896 610 876
 */

/**
 * File Description
 * @package File Category
 * @subpackage File Subcategory
 * @changed $Id: LConfiguration.m 189 2012-12-21 10:37:46Z mkovachev $
 * @author $Author: mkovachev $
 * @version $Revision: 189 $
 */

#import "LConfiguration.h"

// private class
@interface LConfiguration(Private)

- (LConfiguration*)_subnodeDeep:(LConfiguration**)parent lookIn:(NSArray*)lookupArray nextIndex:(NSInteger)nextIndex autocreateMissingNodes:(BOOL)autocreateMissingNodes;
- (NSString *)replaceConstantsForConfigValue:(NSString*)configValue;

@end

// public class
@implementation LConfiguration

@synthesize 
subnodesCount,
name,
values,
subnodes;

#pragma mark -
#pragma mark Initialization / Finalization

- (id)initWithName:(NSString*)aName {
    return [self initWithName:aName values:nil];
}

- (id)initWithName:(NSString*)aName values:(NSDictionary*)someValues {
    self = [super init];
    if (self)
    {
        name = [aName retain];
        values = [[NSMutableDictionary alloc] init];
        subnodes = [[NSMutableArray alloc] init];
        
        if (someValues)
        {
            [values addEntriesFromDictionary:someValues];
        }
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self)
    {
        name = [[aDecoder decodeObjectForKey:@"name"] retain];
        values = [[aDecoder decodeObjectForKey:@"values"] retain];
        subnodes = [[aDecoder decodeObjectForKey:@"subnodes"] retain];
    }
    return self;
}

- (id)initWithNameAndDeepValues:(NSString*)configName deepValues:(NSDictionary*)deepValues {
    self = [self initWithName:configName];
    if (self)
    {
        if (deepValues)
        {
            for(NSString * configKey in deepValues)
            {
                [self set:[deepValues objectForKey:configKey] key:configKey];
            }
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:name forKey:@"name"];
    [encoder encodeObject:values forKey:@"values"];
    
    // save only subnodes which have values
    //NSMutableDictionary * d = [NSMutableDictionary dictionary];
    
    // TODO - clear out unnecessary subnodes here!
    
    [encoder encodeObject:subnodes forKey:@"subnodes"];
}

- (void)dealloc {
    L_RELEASE(name);
    L_RELEASE(values);
    L_RELEASE(subnodes);
    [super dealloc];
}

#pragma mark -
#pragma mark Class Logic

- (NSInteger)getSubnodesCount {
    return [subnodes count];
}

- (NSInteger)getValuesCount {
    return [values count];
}

- (NSString *)description {
    
    // todo - pretty print
    
    NSMutableString * subnodesDescr = [[NSMutableString alloc] init];
    
    for (LConfiguration* subnode in subnodes)
    {
        [subnodesDescr appendString:[subnode description]];
    }
    
    NSString * outStr = [NSString stringWithFormat:@"\n(cfg node) : %@:\nValues: %@\n\nSubnodes:\t\t%@", 
                      name,
                      values,
                      subnodesDescr];

    [subnodesDescr release];
    
    return outStr;
}

- (NSString *)replaceConstantsForConfigValue:(NSString*)configValue {
    
    
    return nil;
}

#pragma mark -
#pragma mark Subnodes

- (void)addSubnode:(LConfiguration*)subnode {
    [subnodes addObject:subnode];
}

- (BOOL)removeSubnodeWithName:(NSString*)aName {
    
    for (LConfiguration * obj in subnodes)
    {
        if ([obj.name isEqualToString:aName])
        {
            [subnodes removeObject:obj];
            return YES;
        }
    }
    
    return NO;
}

- (LConfiguration*)subnodeWithName:(NSString*)aName createIfMissing:(BOOL)shouldCreateIfMissing
{
    LConfiguration* tree = nil;
    
    // two ways to obtain a subnode:
    // aName = subnode_name (in the current node)
    // aName = subnode_name1.subnode_name2.subnode_name3 (looks two levels deeper)
    
    // check if it is a deep-looking key or a normal one
    NSArray * tmp = [aName componentsSeparatedByString:LC_CONFIG_HOLDER_DEEP_CFG_SEPARATOR];
    
    tree = [self _subnodeDeep:&self lookIn:tmp nextIndex:0 autocreateMissingNodes:shouldCreateIfMissing];
    
    return tree;
}

- (LConfiguration*)subnodeWithName:(NSString*)aName {
    
    return [self subnodeWithName:aName createIfMissing:YES];
}

- (BOOL)hasSubnodeWithName:(NSString*)aName
{
    BOOL has = NO;
    
    NSArray * tmp = [aName componentsSeparatedByString:LC_CONFIG_HOLDER_DEEP_CFG_SEPARATOR];
    LConfiguration *tree = [self _subnodeDeep:&self lookIn:tmp nextIndex:0 autocreateMissingNodes:NO];
    
    has = (tree != nil);
    
    return has;
}

#pragma mark -
#pragma mark Values

- (void)setMany:(NSDictionary *)someValues {
    [values addEntriesFromDictionary:someValues];
}

- (void)setObject:(id)value forKey:(NSString*)key {
    [self set:value forKey:key];
}

- (void)set:(id)value key:(NSString*)key {
    [self set:value forKey:key];
}

- (void)set:(id)value forKey:(NSString*)key {
    
    // two ways to set a configuration value:
    // key = some_key
    // key = key.subnode1.subnode2.subnode3.valueKey
    
    // check if it is a deep-looking key or a normal one
    NSArray * tmp = [key componentsSeparatedByString:LC_CONFIG_HOLDER_DEEP_CFG_SEPARATOR];
    int foundPartsCount = (int)[tmp count];
    
    // that means we have a subnode+key
    if (foundPartsCount > 1)
    {
        // deep
        NSIndexSet * idxSet = [[NSIndexSet alloc] initWithIndexesInRange:NSMakeRange(0, [tmp count]-1)];
        NSArray * tmp2 = [tmp objectsAtIndexes:idxSet];
        [idxSet release];
        
        NSString * valueKey = [tmp objectAtIndex:[tmp count]-1];
        
        // if just one subnode we can fetch it right away, otherwise - deep
        if ([tmp2 count] > 1)
        {
            NSString * subNodeStr = [tmp2 componentsJoinedByString:LC_CONFIG_HOLDER_DEEP_CFG_SEPARATOR];
            
            LConfiguration * subnode = [self subnodeWithName:subNodeStr];
            
            if (subnode)
            {
                [subnode set:value forKey:valueKey];
            }
        }
        else 
        {
            // just the next subnode
            for (LConfiguration * obj in subnodes)
            {
                if ([obj.name isEqualToString:[tmp2 objectAtIndex:0]])
                {
                    [obj set:value forKey:valueKey];
                    break;
                }
            }
        }
        
    }
    else 
    {
        // shallow
        [values setObject:value forKey:key];
    }
}

- (id)get:(NSString*)key {
    
    // two ways to obtain a configuration value:
    // key = some_key
    // key = key.subnode1.subnode2.subnode3.valueKey
    
    // check if it is a deep-looking key or a normal one
    NSArray * tmp = [key componentsSeparatedByString:LC_CONFIG_HOLDER_DEEP_CFG_SEPARATOR];
    int foundPartsCount = (int)[tmp count];
    
    id res = nil;
    
    // that means we have a subnode+key
    if (foundPartsCount > 1)
    {
        // deep
        NSIndexSet * idxSet = [[NSIndexSet alloc] initWithIndexesInRange:NSMakeRange(0, [tmp count]-1)];
        NSArray * tmp2 = [tmp objectsAtIndexes:idxSet];
        [idxSet release];
        
        NSString * valueKey = [tmp objectAtIndex:[tmp count]-1];
        
        // if just one subnode we can fetch it right away, otherwise - deep
        if ([tmp2 count] > 1)
        {
            NSString * subNodeStr = [tmp2 componentsJoinedByString:LC_CONFIG_HOLDER_DEEP_CFG_SEPARATOR];
            
            LConfiguration * subnode = [self subnodeWithName:subNodeStr];
            
            if (subnode)
            {
                res = [subnode get:valueKey];
            }
        }
        else 
        {
            // just the next subnode
            for (LConfiguration * obj in subnodes)
            {
                if ([obj.name isEqualToString:[tmp2 objectAtIndex:0]])
                {
                    res = [obj get:valueKey];
                    break;
                }
            }
        }
        
    }
    else 
    {
        // shallow
        res = [values objectForKey:key];
    }
    
    return res;
}

- (void)remove:(NSString*)key {
    [values removeObjectForKey:key];
}

#pragma mark -
#pragma mark Private Methods


- (LConfiguration*)_subnodeDeep:(LConfiguration**)parent lookIn:(NSArray*)lookupArray nextIndex:(NSInteger)nextIndex autocreateMissingNodes:(BOOL)autocreateMissingNodes {
    
    // check the index
    if (!lookupArray) return nil;
    if (nextIndex < 0 || nextIndex > [lookupArray count]-1) return nil;
    
    NSString * lookupStr = [lookupArray objectAtIndex:nextIndex];
    
    for (LConfiguration * obj in (*parent).subnodes)
    {
        if ([obj.name isEqualToString:lookupStr])
        {
            // if we are at the end return the object, otherwise recurse
            if (nextIndex == [lookupArray count]-1)
            {
                return obj;  
            }
            else 
            {
                return [self _subnodeDeep:&obj lookIn:lookupArray nextIndex:nextIndex+1 autocreateMissingNodes:autocreateMissingNodes];
            }
        }
    }
    
    // auto-create missing subnodes
    LConfiguration * newHolder = nil;
    
    if (autocreateMissingNodes)
    {
        newHolder = [[LConfiguration alloc] initWithName:lookupStr];
        [*parent addSubnode:newHolder];
        [newHolder release];
    }
    
    // if we are at the end return the object, otherwise recurse
    if (nextIndex == [lookupArray count]-1)
    {
        return newHolder;
    }
    else
    {
        return [self _subnodeDeep:&newHolder lookIn:lookupArray nextIndex:nextIndex+1 autocreateMissingNodes:autocreateMissingNodes];
    }
    
    return nil;
}


@end
