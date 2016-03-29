//
//  LUUIDHandler.m
//  Lightcast
//
//  Created by Martin N. Kovachev on 19.12.12.
//  Copyright (c) 2012 г. Nimasystems Ltd. All rights reserved.
//

#import "LUUIDHandler.h"

static CFStringRef luuidHandlerAccount = CFSTR("lightcast_uuid_account");
static CFStringRef luuidHandlerService = CFSTR("lightcast_uuid_service");
static NSString *luuidHandlerUUID = nil;
static NSString *luuidHandlerAccessGroup = nil;

@interface LUUIDHandler(Private)

static CFMutableDictionaryRef CreateKeychainQueryDictionary(void);
+ (NSString*)generateUUID;
+ (NSString*)storeUUID:(BOOL)itemExists;

@end

@implementation LUUIDHandler

static CFMutableDictionaryRef CreateKeychainQueryDictionary(void)
{
	CFMutableDictionaryRef query = CFDictionaryCreateMutable(kCFAllocatorDefault, 4, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    CFDictionarySetValue(query, kSecClass, kSecClassGenericPassword);
    CFDictionarySetValue(query, kSecAttrAccount, luuidHandlerAccount);
    CFDictionarySetValue(query, kSecAttrService, luuidHandlerService);
#if !TARGET_IPHONE_SIMULATOR
    if ([LUUIDHandler accessGroup])
    {
        CFDictionarySetValue(query, kSecAttrAccessGroup, [LUUIDHandler accessGroup]);
    }
#endif
    return query;
}

+ (NSString*)generateUUID
{
    @synchronized(self)
    {
        NSString *uuid = nil;
      
        /*
#if TARGET_IPHONE_SIMULATOR && (TESTING || DEBUG)
        if ([[UIDevice currentDevice] respondsToSelector:@selector(uniqueIdentifier)])
        {
            uuid = [[UIDevice currentDevice] performSelector:@selector(uniqueIdentifier)];
            return uuid;
        }
#endif*/
        
        CFUUIDRef uuidRef = CFUUIDCreate(NULL);
        CFStringRef uuidStringRef = CFUUIDCreateString(NULL, uuidRef);
        CFRelease(uuidRef);
        uuid = [(NSString *)uuidStringRef autorelease];
        
        return uuid;
    }
}

+ (NSString*)storeUUID:(BOOL)itemExists
{
	@synchronized(self)
    {
        // Build a query
        CFMutableDictionaryRef query = CreateKeychainQueryDictionary();
        
        NSString *uuid = [[self class] generateUUID];
        
        CFDataRef dataRef = CFRetain([uuid dataUsingEncoding:NSUTF8StringEncoding]);
        OSStatus status;

        if (itemExists)
        {
            CFMutableDictionaryRef passwordDictionaryRef = CFDictionaryCreateMutable(kCFAllocatorDefault, 4, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
            CFDictionarySetValue(passwordDictionaryRef, kSecValueData, dataRef);
            
            // should prevent keychain being inaccessible when the device is locked (iOS7)
            CFDictionarySetValue(passwordDictionaryRef, kSecAttrAccessible, kSecAttrAccessibleAlways);
            status = SecItemUpdate(query, passwordDictionaryRef);
            CFRelease(passwordDictionaryRef);
        }
        else
        {
            CFDictionarySetValue(query, kSecValueData, dataRef);
            
            // should prevent keychain being inaccessible when the device is locked (iOS7)
            CFDictionarySetValue(query, kSecAttrAccessible, kSecAttrAccessibleAlways);
            
            status = SecItemAdd(query, NULL);
        }
        
        if (status != noErr)
        {
            LogError(@"LUUIDHandler Keychain Save Error: %ld", (long)status);
            uuid = nil;
        }
        
        CFRelease(dataRef);
        CFRelease(query);
        
        return uuid;
    }
}

+ (NSString *)UUID
{
	@synchronized(self)
    {
        if (luuidHandlerUUID != nil)
        {
            return luuidHandlerUUID;
        }
        
        // Build a query
        CFMutableDictionaryRef query = CreateKeychainQueryDictionary();
        
        // See if the attribute exists
        CFTypeRef attributeResult = NULL;
        OSStatus status = SecItemCopyMatching(query, (CFTypeRef *)&attributeResult);
        
        if (attributeResult != NULL)
        {
            CFRelease(attributeResult);
        }
        
        if (status != noErr)
        {
            CFRelease(query);
            
            if (status == errSecItemNotFound) // If there's no entry, store one
            {
                return [[self class] storeUUID:NO];
            }
            else // Any other error, log it and return nil
            {
                LogError(@"LUUIDHandler Unhandled Keychain Error %ld", (long)status);
                return nil;
            }
        }
        
        // Fetch stored attribute
        CFDictionaryRemoveValue(query, kSecReturnAttributes);
        CFDictionarySetValue(query, kSecReturnData, (id)kCFBooleanTrue);
        CFTypeRef resultData = NULL;
        status = SecItemCopyMatching(query, &resultData);
        
        if (status != noErr)
        {
            CFRelease(query);
            
            if (status == errSecItemNotFound) // If there's no entry, store one
            {
                return [[self class] storeUUID:NO];
            }
            else // Any other error, log it and return nil
            {
                LogError(@"LUUIDHandler Unhandled Keychain Error %ld", (long)status);
                return nil;
            }
        }
        
        if (resultData != NULL)
        {
            luuidHandlerUUID = [[NSString alloc] initWithData:(NSData *)resultData encoding:NSUTF8StringEncoding];
            CFRelease(resultData);
        }
        
        CFRelease(query);
        
        return luuidHandlerUUID;
    }
}

+ (void)reset
{
	@synchronized(self)
    {
        L_RELEASE(luuidHandlerUUID);
        
        // Build a query
        CFMutableDictionaryRef query = CreateKeychainQueryDictionary();
        
        // See if the attribute exists
        CFTypeRef attributeResult = NULL;
        CFDictionarySetValue(query, kSecReturnAttributes, (id)kCFBooleanTrue);
        OSStatus status = SecItemCopyMatching(query, (CFTypeRef *)&attributeResult);
        
        if (attributeResult != NULL)
        {
            CFRelease(attributeResult);
        }
        
        if (status == errSecItemNotFound)
        {
            CFRelease(query);
            return;
        }
        
        status = SecItemDelete(query);
        
        if (status != noErr)
        {
            LogError(@"LUUIDHandler Keychain Delete Error: %ld", (long)status);
        }
        
        CFRelease(query);
    }
}

+ (NSString *)accessGroup
{
	return luuidHandlerAccessGroup;
}

+ (void)setAccessGroup:(NSString*)accessGroup
{
    if (luuidHandlerAccessGroup != accessGroup)
    {
        L_RELEASE(luuidHandlerAccessGroup);
        luuidHandlerAccessGroup = [accessGroup retain];
    }
}

@end
