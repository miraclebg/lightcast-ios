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
 * @changed $Id: LDatabaseAdapter.m 345 2014-10-07 17:23:27Z mkovachev $
 * @author $Author: mkovachev $
 * @version $Revision: 345 $
 */

#import "LDatabaseAdapter.h"

NSString* const LSQLDateFormat = @"yyyy-MM-dd";
NSString* const LSQLTimeFormat = @"HH:mm:ss";
NSString* const LSQLDateTimeFormat = @"yyyy-MM-dd HH:mm:ss";

@implementation LDatabaseAdapter {
    
}

@synthesize
adapterDispatchQueue;

- (id)initWithConnectionString:(NSString*)aConnectionString dispatchQueue:(dispatch_queue_t)queue
{
    self = [super init];
    if (self)
    {
        if ([NSString isNullOrEmpty:aConnectionString])
        {
            L_RELEASE(self);
            lassert(false);
            return nil;
        }
        
        dispatch_queue_t queue_ = queue;
        
        if (queue_ == NULL)
        {
            // create a new serial dispatch queue
            queue_ = dispatch_queue_create("com.lightcast.LDatabaseAdapter", DISPATCH_QUEUE_SERIAL);
        }
        else
        {
            dispatch_retain(queue);
        }
        
        dispatch_queue_t high = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
        dispatch_set_target_queue(queue_,high);
        
        lassert(queue_);
        
        adapterDispatchQueue = queue_;
    }
    return self;
}

- (id)initWithConnectionString:(NSString*)aConnectionString
{
    return [self initWithConnectionString:aConnectionString dispatchQueue:nil];
}

- (id)init
{
    return [self initWithConnectionString:nil];
}

- (void)dealloc
{
    // wait until all operations finish with a hack
    if (adapterDispatchQueue)
    {
        dispatch_sync(adapterDispatchQueue, ^{});
        dispatch_release(adapterDispatchQueue);
        adapterDispatchQueue = NULL;
    }
    
    [super dealloc];
}

#pragma mark -
#pragma mark Class Factory

+ (BOOL)adapterExists:(NSString*)adapterName {
    
    if (!adapterName) return NO;
    
    NSString * className = [NSString stringWithFormat:@"L%@DatabaseAdapter", adapterName];
    
    Class class = NSClassFromString(className);
    
    if (![class isSubclassOfClass:[LDatabaseAdapter class]])
    {
        return NO;
    }
    
    return YES;
}

+ (LDatabaseAdapter*)adapterFactory:(NSString*)adapterName connectionString:(NSString*)connectionString {
    
    if (![LDatabaseAdapter adapterExists:adapterName] || [NSString isNullOrEmpty:connectionString])
    {
        LogError(@"adapterFactory: adapter not found: %@", adapterName);
        return nil;
    }
    
    NSString * className = [NSString stringWithFormat:@"L%@DatabaseAdapter", adapterName];
    Class class = NSClassFromString(className);
    LDatabaseAdapter *instance = [((LDatabaseAdapter*)[class alloc]) initWithConnectionString:connectionString];
    
    return [instance autorelease];
}

#pragma mark - LDatabaseAdapterProtocol stubs

- (NSArray *)executeQuery:(NSString *)sql, ... {
	return [NSArray array];
}

- (BOOL)connect:(NSString*)connectinString error:(NSError**)error {
	return NO;
}

- (BOOL)open:(NSError **)error
{
    if (error != NULL)
    {
        *error = nil;
    }
    
    return NO;
}

- (void)disconnect {
	//
}

- (void)close
{
    //
}

- (BOOL)reconnect:(NSError**)error {
	return NO;
}

- (BOOL)isConnected {
	return NO;
}

- (NSString*)databaseType {
	return nil;
}

- (NSString*)connectionString {
	return nil;
}

- (BOOL)executeStatement:(NSError**)error sql:(NSString*)sql, ... {
	return NO;
}

- (BOOL)executeDirectStatement:(NSError**)error sql:(NSString*)sql, ... {
    return NO;
}

- (BOOL)executeStatement:(NSString*)sql, ... {
	return NO;
}

- (BOOL)executeStatements:(NSArray*)statements error:(NSError**)error {
    return NO;
}

@end