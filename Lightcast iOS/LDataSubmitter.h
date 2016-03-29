//
//  LDataSubmitter.h
//  Lightcast
//
//  Created by Martin N. Kovachev on 18.06.13.
//  Copyright (c) 2013 г. Nimasystems Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Lightcast/LUrlDownloaderDelegate.h>

extern NSString *const kLDataSubmitterDefaultGroup;
extern NSString *const kLDatSubmitterErrorDomain;
extern NSInteger const kLDataSubmitterDefaultSessionKeyLength;

typedef enum
{
    LDataSubmitterStateErrorUnknown = 0,
    LDataSubmitterStateErrorGeneric = 1,
    LDataSubmitterStateErrorInvalidParams = 2,
    
    LDataSubmitterStateErrorIO = 10,
    LDataSubmitterStateErrorNetwork = 11
    
} LDataSubmitterStateError;

typedef enum
{
    LDataSubmitterStateIdle = 0,
    LDataSubmitterStateWorking = 1
    
} LDataSubmitterState;

@class LDataSubmitter;

@protocol LDataSubmitterDelegate <NSObject>

@optional

- (void)didBeginSending:(LDataSubmitter*)submitter;
- (void)didFinishSending:(LDataSubmitter*)submitter;

- (void)willBeginSendingProperties:(LDataSubmitter*)submitter properties:(NSDictionary*)properties;
- (void)didFinishSendingProperties:(LDataSubmitter*)submitter properties:(NSDictionary*)properties;
- (void)didFailSendingProperties:(LDataSubmitter*)submitter properties:(NSDictionary*)properties error:(NSError*)error;

- (void)willBeginSendingFile:(LDataSubmitter*)submitter groupName:(NSString*)groupName filename:(NSString*)filename;
- (void)didFinishSendingFile:(LDataSubmitter*)submitter groupName:(NSString*)groupName filename:(NSString*)filename;
- (void)didFailSendingFile:(LDataSubmitter*)submitter groupName:(NSString*)groupName filename:(NSString*)filename error:(NSError*)error;

@end

@interface LDataSubmitter : NSObject <LUrlDownloaderDelegate>

@property (nonatomic, copy) NSURL *remoteUrl;

@property (nonatomic, retain, readonly) NSString *sessionKey;
@property (nonatomic, assign, readonly) LDataSubmitterState state;

@property (nonatomic, retain, readonly) NSDictionary *files;
@property (nonatomic, retain, readonly) NSDictionary *properties;

@property (nonatomic, assign) NSTimeInterval connectionTimeout;
@property (nonatomic, copy) NSString *userAgent;
@property (nonatomic, copy) NSDictionary *requestHeaders;

@property (nonatomic, assign) id<LDataSubmitterDelegate> dataSubmitterDelegate;

- (id)initWithUrl:(NSURL*)url;

- (void)setFile:(NSString*)filename;
- (void)setFilesForGroup:(NSString*)groupName files:(NSArray*)filenames;
- (void)setFileForGroup:(NSString*)groupName filename:(NSString*)filename;

- (void)setProperty:(NSString*)key value:(id)value;
- (void)setPropertiesForGroup:(NSString*)groupName properties:(NSDictionary*)properties;
- (void)setPropertyForGroup:(NSString*)groupName key:(NSString*)key value:(id)value;

- (NSDictionary*)propertiesForGroup:(NSString*)groupName;
- (NSArray*)filesForGroup:(NSString*)groupName;

- (void)removeAllFiles;
- (void)removeAllProperties;

- (void)removeGroup:(NSString*)groupName;

- (BOOL)startSending:(NSError**)error;
- (BOOL)startSending:(NSString*)sessionKey error:(NSError**)error;
- (void)cancel;

@end