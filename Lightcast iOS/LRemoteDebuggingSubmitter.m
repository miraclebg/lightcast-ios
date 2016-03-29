//
//  LRemoteDebuggingSubmitter.m
//  Lightcast
//
//  Created by Martin Kovachev on 7/30/11.
//  Copyright 2011 Nimasystems Ltd. All rights reserved.
//

#import "LRemoteDebuggingSubmitter.h"
#import "LRemoteError.h"

@implementation LRemoteDebuggingSubmitter

@synthesize
hostname=_hostname,
secure=_secure;

#pragma mark - Initialization / Finalization

- (id)init {
    return [self initWithHostname:nil];
}

- (id)initWithHostname:(NSString*)hostname {
	self = [super init];
    if (self) 
	{
        if (!hostname)
		{
			L_RELEASE(self);
			return nil;
		}
		
		_secure = NO;
		_hostname = [hostname retain];
		
		LogInfo(@"LRemoteDebuggingSubmitter initialized with host: %@", hostname);
    }
    
    return self;
}

- (void)dealloc {
	
	L_RELEASE(_hostname);
	
	[super dealloc];
}

#pragma mark - Submitting

+ (BOOL)submitError:(NSString*)hostname submittedError:(LRemoteError*)submittedError {
	
	BOOL res = NO;
	
	@try 
	{
		LRemoteDebuggingSubmitter *submitter = [[[LRemoteDebuggingSubmitter alloc] initWithHostname:hostname] autorelease];
		
		res = [submitter submitError:submittedError error:nil];
	}
	@catch (NSException *e) 
	{
		res = NO;
	}
	
	return res;
}

- (BOOL)submitError:(LRemoteError*)submittedError error:(NSError**)error {
	
	BOOL res = NO;
	
	@try 
	{
		// obtain sysinfo
		NSMutableDictionary *deviceSysInfo = [NSMutableDictionary dictionary];
		
#ifdef TARGET_IOS	// iOS Target
		
		UIDevice * dev = [UIDevice currentDevice];
		
		[deviceSysInfo setObject:dev.model forKey:@"UIDevice_model"];
		[deviceSysInfo setObject:dev.systemVersion forKey:@"UIDevice_systemVersion"];
		
#endif
		
		// get version info
		NSString *errorString = nil;
		NSData *sysVerData = [[NSData alloc] initWithContentsOfFile:@"/System/Library/CoreServices/SystemVersion.plist"];
		
		@try
		{
			NSDictionary *dict = [NSPropertyListSerialization propertyListFromData: sysVerData
																	mutabilityOption: NSPropertyListImmutable
																			  format: NULL errorDescription:&errorString];
			
			if (dict)
			{
				[deviceSysInfo addEntriesFromDictionary:dict];
			}
		}
		@finally 
		{
			[sysVerData release];
		}
		
		// make a request to the web service
		NSArray *params = [NSArray arrayWithObjects:
						   deviceSysInfo,
						   submittedError,
						   nil];
		
		LWebServiceClient *client = [[LWebServiceClient alloc] initWithHost:_hostname makeSecureCalls:_secure];
		
		@try 
		{
			res = [client makeRequest:@"remote_debugging" methodName:@"submit_ios_error" params:params error:error];
			
			if (!res)
			{
				return NO;
			}
		}
		@finally 
		{
			[client release];
		}
	}
	@catch (NSException *e) 
	{
		res = NO;
	}
	
	return res;
}

@end
