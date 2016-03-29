//
//  LDeviceSystemInfo.m
//  Lightcast
//
//  Created by Martin N. Kovachev on 05.01.13.
//  Copyright (c) 2013 г. Nimasystems Ltd. All rights reserved.
//

#import "LDeviceSystemInfo.h"

#ifdef TARGET_OSX
#include <stdlib.h>
#include <stdio.h>
#include <sys/types.h>
#include <sys/sysctl.h>
#import <SystemConfiguration/SystemConfiguration.h>
#endif

#ifdef TARGET_IOS
#import <Lightcast/LUUIDHandler.h>
#endif

#import <netinet/in.h>
#import <netdb.h>
#import <sys/socket.h>
#import <sys/types.h>
#import <arpa/inet.h>
#import <netinet/in.h>

// Needed to get the MAC address
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>

CGFloat const kLDeviceSystemInfoDefaultNavBarHeight = 44.0;
CGFloat const kLDeviceSystemInfoDefaultTabBarHeight = 50.0;

@interface LDeviceSystemInfo(Private)

- (void)initDeviceOSInfo;

@end

@implementation LDeviceSystemInfo

@synthesize
primaryMacAddress,
deviceName,
currentResolution,
deviceDescription;

#ifdef TARGET_IOS
@synthesize
screenBounds,
applicationFrame,
statusBarHeight,
navBarFrame,
UUID;
#endif

#pragma mark -
#pragma mark Initialization / Finalization

- (void)dealloc
{
    L_RELEASE(primaryMacAddress);
    L_RELEASE(deviceName);
    L_RELEASE(deviceDescription);
    
    [super dealloc];
}

- (void)initDeviceOSInfo
{
	NSString * ret = nil;
	
#ifdef TARGET_IOS
	
	UIDevice * dev = [UIDevice currentDevice];
	
	ret = [NSString stringWithFormat:@"%@ %@", dev.model, dev.systemVersion];
    
#else
	
	NSString * errorString = nil;
	NSData *sysVerData = [[[NSData alloc] initWithContentsOfFile:@"/System/Library/CoreServices/SystemVersion.plist"] autorelease];
	
    lassert(sysVerData);
    
    if (sysVerData)
    {
        NSDictionary *sysVer = [NSPropertyListSerialization propertyListFromData: sysVerData
                                                                mutabilityOption: NSPropertyListImmutable
                                                                          format: NULL errorDescription: &errorString];
        
        if (sysVer)
        {
            ret = [NSString stringWithFormat:@"%@ %@ (%@)",
                   [sysVer objectForKey:@"ProductName"],
                   [sysVer objectForKey:@"ProductVersion"],
                   [sysVer objectForKey:@"ProductBuildVersion"]
                   ];
        }
    }
	
#endif
	
    lassert(![NSString isNullOrEmpty:ret]);
    
	if (deviceDescription != ret)
	{
		L_RELEASE(deviceDescription);
		deviceDescription = [ret retain];
	}
}

- (void)initPrimaryMacAddress
{
    L_RELEASE(primaryMacAddress);
    
    int                 mgmtInfoBase[6];
    char                *msgBuffer = NULL;
    NSString            *errorFlag = NULL;
    size_t              length;
    
    // Setup the management Information Base (mib)
    mgmtInfoBase[0] = CTL_NET;        // Request network subsystem
    mgmtInfoBase[1] = AF_ROUTE;       // Routing table info
    mgmtInfoBase[2] = 0;
    mgmtInfoBase[3] = AF_LINK;        // Request link layer information
    mgmtInfoBase[4] = NET_RT_IFLIST;  // Request all configured interfaces
    
    // With all configured interfaces requested, get handle index
    if ((mgmtInfoBase[5] = if_nametoindex("en0")) == 0)
        errorFlag = @"if_nametoindex failure";
    // Get the size of the data available (store in len)
    else if (sysctl(mgmtInfoBase, 6, NULL, &length, NULL, 0) < 0)
        errorFlag = @"sysctl mgmtInfoBase failure";
    // Alloc memory based on above call
    else if ((msgBuffer = malloc(length)) == NULL)
        errorFlag = @"buffer allocation failure";
    // Get system information, store in buffer
    else if (sysctl(mgmtInfoBase, 6, msgBuffer, &length, NULL, 0) < 0)
    {
        free(msgBuffer);
        errorFlag = @"sysctl msgBuffer failure";
    }
    else
    {
        // Map msgbuffer to interface message structure
        struct if_msghdr *interfaceMsgStruct = (struct if_msghdr *) msgBuffer;
        
        // Map to link-level socket structure
        struct sockaddr_dl *socketStruct = (struct sockaddr_dl *) (interfaceMsgStruct + 1);
        
        // Copy link layer address data in socket structure to an array
        unsigned char macAddress[6];
        memcpy(&macAddress, socketStruct->sdl_data + socketStruct->sdl_nlen, 6);
        
        // Read from char array into a string object, into traditional Mac address format
        NSString *macAddressString = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
                                      macAddress[0], macAddress[1], macAddress[2], macAddress[3], macAddress[4], macAddress[5]];
        
        // Release the buffer memory
        free(msgBuffer);
        
        primaryMacAddress = [macAddressString retain];
        
        return;
    }
    
    LogError(@"Could not obtain device mac address: %@", errorFlag);
    
    lassert(false);
}

#pragma mark -
#pragma mark Getters / Setters

#ifdef TARGET_IOS

- (NSString*)getUUID
{
    return [LUUIDHandler UUID];
}

- (CGRect)getNavBarFrame
{
    return CGRectMake(self.applicationFrame.origin.x, 0, self.applicationFrame.size.width, kLDeviceSystemInfoDefaultNavBarHeight);
}

- (NSInteger)getStatusBarHeight
{
    return self.screenBounds.size.height - self.applicationFrame.size.height;
}
#endif

- (NSString*)getDeviceDescription
{
    if (!deviceDescription)
    {
        [self initDeviceOSInfo];
    }
    
    return deviceDescription;
}

- (NSString*)getDeviceName
{
    if (!deviceName)
    {
        // init the rest
#ifdef TARGET_IOS
        deviceName = [[UIDevice currentDevice].name retain];
#else
        deviceName = (NSString*)SCDynamicStoreCopyComputerName(NULL, NULL);
#endif
    }
    
    return deviceName;
}

#ifdef TARGET_IOS
- (CGRect)getScreenBounds
{
    return [UIScreen mainScreen].bounds;
}

- (CGRect)getApplicationFrame
{
    return [UIScreen mainScreen].applicationFrame;
}
#endif

- (NSString*)getPrimaryMacAddress
{
    if (!primaryMacAddress)
    {
        [self initPrimaryMacAddress];
    }
    
    return primaryMacAddress;
}

- (NSString*)getCurrentResolution
{
    CGRect rect;
    
#ifdef TARGET_IOS
    rect = [[UIScreen mainScreen] bounds];
#else
    rect = [NSScreen mainScreen].frame;
#endif
    
    NSString *resolution = [NSString stringWithFormat:@"%d%@%d", (int)rect.size.width, @"x", (int)rect.size.height];
    
    return resolution;
}

#ifdef TARGET_IOS
- (UIDeviceOrientation)getOrientation
{
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    return orientation;
}
#endif

- (NSString*)getModel
{
    NSString *model = nil;
    
#ifdef TARGET_IOS
    model = [[UIDevice currentDevice] model];
#endif
    
#ifdef TARGET_OSX
    @try
    {
        size_t len = 0;
        
        sysctlbyname("hw.model", NULL, &len, NULL, 0);
        
        if (len)
        {
            char *model1 = malloc(len*sizeof(char));
            sysctlbyname("hw.model", model1, &len, NULL, 0);
            model = [[[NSString alloc] initWithString:[NSString stringWithFormat:@"%s", model1]] autorelease];
            free(model1);
        }
    }
    @catch (NSException *e)
    {
        lassert(false);
        return nil;
    }
#endif
    
    return model;
}

- (NSString*)getLocalizedModel
{
    NSString *localizedModel = nil;
    
#ifdef TARGET_IOS
    localizedModel = [[UIDevice currentDevice] localizedModel];
#endif
    
#ifdef TARGET_OSX
    return [self getModel];
#endif
    
    return localizedModel;
}

- (NSString*)getSystemName
{
    NSString *systemName = nil;

#ifdef TARGET_IOS
    systemName = [[UIDevice currentDevice] systemName];
#endif
    
#ifdef TARGET_OSX
    systemName = @"MacOSX";
#endif
    
    return systemName;
}

- (NSString*)getSystemVersion
{
    NSString *systemVersion = nil;
    
#ifdef TARGET_IOS
    systemVersion = [[UIDevice currentDevice] systemVersion];
#endif
    
#ifdef TARGET_OSX
    NSProcessInfo *p = [NSProcessInfo processInfo];
    systemVersion = [p operatingSystemVersionString];
#endif
    
    return systemVersion;
}

#ifdef TARGET_OSX
- (NSString*)cpuName
{
    // from: http://www.cocoabuilder.com/archive/cocoa/87182-how-obtain-cpu-info-from-ioregistry.html
    
    kern_return_t        kernResult;
    mach_port_t        machPort;
    io_iterator_t        iterator;
    io_object_t        serviceObj;
    CFMutableDictionaryRef    classesToMatch;
    const UInt8*         rawdata = NULL;
    CFDataRef        data = NULL;
    NSString*        devType = @"";
    NSString*        nsCPU = @"Unknown";
    
    kernResult = IOMasterPort( MACH_PORT_NULL, &machPort );
    
    if ( kernResult == KERN_SUCCESS  )
    {
        classesToMatch = IOServiceMatching( "IOPlatformDevice" );
        
        if ( classesToMatch )
        {
            kernResult = IOServiceGetMatchingServices( machPort,
                                                      classesToMatch, &iterator );
            if ( (kernResult == KERN_SUCCESS) && iterator )
            {
                do
                {
                    serviceObj = IOIteratorNext( iterator );
                    
                    if ( serviceObj  )
                    {
                        data = IORegistryEntryCreateCFProperty( serviceObj,
                                                               CFSTR( "device_type" ), kCFAllocatorDefault, 0 );

                        if (data != NULL)
                        {
                            rawdata = CFDataGetBytePtr(data);
                            devType = [NSString stringWithCString:(const char *)rawdata encoding:NSUTF8StringEncoding];
                            
                            CFRelease(data);
                            data = NULL;
                        }
                    }
                }
                while (![devType isEqual:@"cpu"]);
                
                data = IORegistryEntryCreateCFProperty( serviceObj, CFSTR(
                                                                          "name" ), kCFAllocatorDefault, 0 );
                
                if (data != NULL)
                {
                    rawdata = CFDataGetBytePtr(data);
                    nsCPU = [NSString stringWithCString:(const char *)rawdata encoding:NSUTF8StringEncoding];
                    CFRelease(data);
                    data = NULL;
                }
                
                IOObjectRelease(serviceObj);
            }
            
            IOObjectRelease(iterator);
        }
    }
    
    mach_port_deallocate(mach_task_self(), machPort);
    
    return nsCPU;
}
#endif

@end
