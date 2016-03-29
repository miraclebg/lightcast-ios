//
//  LFilteredNSDictionary.m
//  Lightcast
//
//  Created by Martin N. Kovachev on 10.01.13.
//  Copyright (c) 2013 г. Nimasystems Ltd. All rights reserved.
//

#import "LFilteredNSDictionary.h"

@interface LFilteredNSDictionary(Private)

- (NSDictionary*)actualDictionary;

@end

@implementation LFilteredNSDictionary {
    
    NSMutableDictionary *_unfilteredDictionary;
    NSDictionary *_filteredDictionary;
}

@synthesize
isFiltered,
unfilteredDictionary=_unfilteredDictionary,
filterDelegate;

#pragma mark - Initialization / Finalization

- (instancetype)initWithObjects:(const id [])objects forKeys:(const id <NSCopying> [])keys count:(NSUInteger)cnt
{
    self = [super init];
    if (self)
    {
        _filteredDictionary = nil;
        _unfilteredDictionary = [[NSMutableDictionary alloc] init];
        [_unfilteredDictionary addEntriesFromDictionary:[NSDictionary dictionaryWithObjects:objects forKeys:keys count:cnt]];
    }
    return self;
}

- (void)dealloc
{
    filterDelegate = nil;
    
    L_RELEASE(_unfilteredDictionary);
    L_RELEASE(_filteredDictionary);
    
    [super dealloc];
}

#pragma mark - Getters / Setters

- (BOOL)getIsFiltered
{
    BOOL isFiltered_ = _filteredDictionary ? YES : NO;
    return isFiltered_;
}

#pragma mark - Filtering

- (NSDictionary*)actualDictionary
{
    NSDictionary *d = _filteredDictionary ? _filteredDictionary : _unfilteredDictionary;
    return d;
}

- (void)resetFilter
{
    if (!_filteredDictionary)
    {
        return;
    }
    
    L_RELEASE(_filteredDictionary);
    
    // inform the delegate
    if (filterDelegate && [filterDelegate respondsToSelector:@selector(filteredNSDictionaryDidResetFilter:)])
    {
        [filterDelegate filteredNSDictionaryDidResetFilter:self];
    }
}

- (void)setFilter:(LFilteredNSDictionaryExecuteFilterBlock)block
{
    if (![_unfilteredDictionary count])
    {
        return;
    }
    
    NSMutableDictionary *filteredDictionary_ = [[[NSMutableDictionary alloc] init] autorelease];
    
    for(id key in _unfilteredDictionary)
    {
        BOOL filterTest = block(key, [_unfilteredDictionary objectForKey:key]);
        
        if (filterTest)
        {
            [filteredDictionary_ setObject:[_unfilteredDictionary objectForKey:key] forKey:key];
        }
    }
    
    if (filteredDictionary_ != _filteredDictionary)
    {
        L_RELEASE(_filteredDictionary);
        _filteredDictionary = [[NSDictionary dictionaryWithDictionary:filteredDictionary_] retain];
    }
    
    // inform the delegate
    if (filterDelegate && [filterDelegate respondsToSelector:@selector(filteredNSDictionaryDidSetFilter:)])
    {
        [filterDelegate filteredNSDictionaryDidSetFilter:self];
    }
}

- (void)setObject:(id)object forKey:(id<NSCopying>)key
{
    if (!object || !key)
    {
        lassert(false);
        return;
    }
    
    [_unfilteredDictionary setObject:object forKey:key];
    
    // TODO: Pass the filter for actual dictionary again as it has changed now
}

#pragma mark - NSDictionary methods

- (NSUInteger)count
{
    return [[self actualDictionary] count];
}

- (id)objectForKey:(id)aKey
{
    return [[self actualDictionary] objectForKey:aKey];
}

- (NSEnumerator *)keyEnumerator
{
    return [[self actualDictionary] keyEnumerator];
}

- (NSArray *)allKeys
{
    return [[self actualDictionary] allKeys];
}

- (NSArray *)allKeysForObject:(id)anObject
{
    return [[self actualDictionary] allKeysForObject:anObject];
}

- (NSArray *)allValues
{
    return [[self actualDictionary] allValues];
}

- (NSString *)description
{
    return [[self actualDictionary] description];
}

- (NSString *)descriptionInStringsFileFormat
{
    return [[self actualDictionary] descriptionInStringsFileFormat];
}

- (NSString *)descriptionWithLocale:(id)locale
{
    return [[self actualDictionary] descriptionWithLocale:locale];
}

- (NSString *)descriptionWithLocale:(id)locale indent:(NSUInteger)level
{
    return [[self actualDictionary] descriptionWithLocale:locale indent:level];
}

- (BOOL)isEqualToDictionary:(NSDictionary *)otherDictionary
{
    return [[self actualDictionary] isEqualToDictionary:otherDictionary];
}

- (NSEnumerator *)objectEnumerator
{
    return [[self actualDictionary] objectEnumerator];
}

- (NSArray *)objectsForKeys:(NSArray *)keys notFoundMarker:(id)marker
{
    return [[self actualDictionary] objectsForKeys:keys notFoundMarker:marker];
}

- (BOOL)writeToFile:(NSString *)path atomically:(BOOL)useAuxiliaryFile
{
    return [[self actualDictionary] writeToFile:path atomically:useAuxiliaryFile];
}

- (BOOL)writeToURL:(NSURL *)url atomically:(BOOL)atomically // the atomically flag is ignored if url of a type that cannot be written atomically.
{
    return [[self actualDictionary] writeToURL:url atomically:atomically];
}
 
- (NSArray *)keysSortedByValueUsingSelector:(SEL)comparator
{
    return [[self actualDictionary] keysSortedByValueUsingSelector:comparator];
}

- (void)getObjects:(id __unsafe_unretained [])objects andKeys:(id __unsafe_unretained [])keys
{
    return [[self actualDictionary] getObjects:objects andKeys:keys];
}

#if NS_BLOCKS_AVAILABLE

- (void)enumerateKeysAndObjectsUsingBlock:(void (^)(id key, id obj, BOOL *stop))block NS_AVAILABLE(10_6, 4_0)
{
    return [[self actualDictionary] enumerateKeysAndObjectsUsingBlock:block];
}

- (void)enumerateKeysAndObjectsWithOptions:(NSEnumerationOptions)opts usingBlock:(void (^)(id key, id obj, BOOL *stop))block NS_AVAILABLE(10_6, 4_0)
{
    return [[self actualDictionary] enumerateKeysAndObjectsWithOptions:opts usingBlock:block];
}

- (NSArray *)keysSortedByValueUsingComparator:(NSComparator)cmptr NS_AVAILABLE(10_6, 4_0)
{
    return [[self actualDictionary] keysSortedByValueUsingComparator:cmptr];
}

- (NSArray *)keysSortedByValueWithOptions:(NSSortOptions)opts usingComparator:(NSComparator)cmptr NS_AVAILABLE(10_6, 4_0)
{
    return [[self actualDictionary] keysSortedByValueWithOptions:opts usingComparator:cmptr];
}

- (NSSet *)keysOfEntriesPassingTest:(BOOL (^)(id key, id obj, BOOL *stop))predicate NS_AVAILABLE(10_6, 4_0)
{
    return [[self actualDictionary] keysOfEntriesPassingTest:predicate];
}

- (NSSet *)keysOfEntriesWithOptions:(NSEnumerationOptions)opts passingTest:(BOOL (^)(id key, id obj, BOOL *stop))predicate NS_AVAILABLE(10_6, 4_0)
{
    return [[self actualDictionary] keysOfEntriesWithOptions:opts passingTest:predicate];
}

#endif

@end
