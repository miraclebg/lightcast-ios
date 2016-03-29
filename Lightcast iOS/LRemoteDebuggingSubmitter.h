//
//  LRemoteDebuggingSubmitter.h
//  Lightcast
//
//  Created by Martin Kovachev on 7/30/11.
//  Copyright 2011 Nimasystems Ltd. All rights reserved.
//

#import <Lightcast/LRemoteError.h>
#import <Lightcast/LWebServiceClient.h>

@interface LRemoteDebuggingSubmitter : NSObject {
	
	NSString *_hostname;
	BOOL _secure;
}

@property (nonatomic, retain, readonly) NSString *hostname;
@property (nonatomic, assign) BOOL secure;

- (id)initWithHostname:(NSString*)hostname;

+ (BOOL)submitError:(NSString*)hostname submittedError:(LRemoteError*)submittedError;

- (BOOL)submitError:(LRemoteError*)submittedError error:(NSError**)error;

@end
