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
 * @changed $Id: LCacheFIFO.m 138 2011-08-12 08:50:18Z mkovachev $
 * @author $Author: mkovachev $
 * @version $Revision: 138 $
 */

#import <Lightcast/LCacheFIFO.h>

@implementation LCacheFIFO

- (void)flushExcessiveCacheBeforeInsert {
	if ([cacheKeys count] + 1 > maximumCacheObjects)
	{
		[cacheKeys removeObjectAtIndex:0];
		[cacheObjects removeObjectAtIndex:0];
		
		LogDebug(@"Cache flush");
	}
}

- (BOOL)has:(NSString *)aIdentifier {
	return [cacheKeys containsObject:aIdentifier];
}

- (NSInteger)getCount {
	return [cacheKeys count];
}

- (BOOL)set:(NSString *)identifier object:(id)aObject {
	return [self insertOrReplace:identifier cachedObject:aObject];
}

- (BOOL)insertOrReplace:(NSString *)identifier cachedObject:(id)cachedObject {
	
	if (!cachedObject)
	{
		LogWarn(@"Warning: attempted to insert a nil cache!");
		return FALSE;
	}
	
	[self flushExcessiveCacheBeforeInsert];
	
	NSUInteger objIdx = [cacheKeys indexOfObject:identifier];
	
	if (objIdx != NSNotFound)
	{
		id obj = [cacheObjects objectAtIndex:objIdx];
		
		if (obj == cachedObject)
		{
			return FALSE;
		}
		else
		{
			[cacheObjects replaceObjectAtIndex:objIdx withObject:cachedObject];
			
			LogDebug(@"Cache value replaced for key: %@", identifier);
		}
	}
	else
	{
		NSInteger nextIdx = [cacheKeys count];
		[cacheKeys insertObject:identifier atIndex:nextIdx];
		[cacheObjects insertObject:cachedObject atIndex:nextIdx];
		
		//LogDebug(@"Cache value inserted for key: %@", identifier);
	}
	
	return YES;
}

- (id)get:(NSString *)aIdentifier {
	
	if (!aIdentifier) return nil;
	NSUInteger objIdx = [cacheKeys indexOfObject:aIdentifier];

	if (objIdx == NSNotFound) return nil;
	
	//LogDebug(@"got '%@' from cache for", identifier);
	
	return [cacheObjects objectAtIndex:objIdx];
}

- (id)get:(NSString *)identifier removeFromCache:(BOOL)removeFromCache {
	
	id obj = [self get:identifier];
	
	if (!obj) return nil;
	
	if (removeFromCache) 
	{
		[obj retain];
		[self remove:identifier];
        [obj release];
	}
	
	return obj;
}

- (BOOL)remove:(NSString *)aIdentifier {
	
	NSUInteger objIdx = [cacheKeys indexOfObject:aIdentifier];
	
	if (objIdx == NSNotFound) return NO;
	
	[cacheObjects removeObjectAtIndex:objIdx];
	[cacheKeys removeObjectAtIndex:objIdx];
	
	//LogDebug(@"cache removed for key: %@", identifier);
	
	return YES;
}

- (void)clear {
	[cacheObjects removeAllObjects];
	[cacheKeys removeAllObjects];
	
	//LogDebug(@"cache cleared");
}

- (NSInteger)cachedObjectsCount {
	return [cacheObjects count];
}

- (id)initWithObjectsLimit:(int)newMaximumCacheObjects {
	self = [self init];
	if (self != nil)
	{
		maximumCacheObjects = newMaximumCacheObjects;
	}
	return self;
}

- (id)init {
	self = [super init];
	if (self != nil)
	{
		cacheObjects = [[NSMutableArray alloc] init];
		cacheKeys = [[NSMutableArray alloc] init];
		maximumCacheObjects = DEFAULT_MAX_CACHE_OBJECTS;
	}
	return self;
}

- (void)dealloc {
	[cacheObjects release];
	[cacheKeys release];
	[super dealloc];
}

@end
