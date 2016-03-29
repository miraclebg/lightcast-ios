//
//  LUrlDownloader.h
//  Lightcast
//
//  Created by Martin N. Kovachev on 04.01.13.
//  Copyright (c) 2013 г. Nimasystems Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Lightcast/LUrlDownloaderDelegate.h>
#import <Lightcast/LUrlDownloaderPostFile.h>
#import <Lightcast/LUrlDownloaderDecompressor.h>

extern NSString *const LUrlDownloaderErrorDomain;
extern NSInteger const LUrlDownloaderDefaultTimeout;
extern NSInteger const LUrlDownloaderDefaultReadBufferSize;
extern NSInteger const LUrlDownloaderDefaultWriteBufferSize;

// TODO: Gzip http requests / decompression

typedef enum
{
    LUrlDownloaderErrorUnknown = 0,
    LUrlDownloaderErrorGeneric = 1,
    LUrlDownloaderErrorInvalidParams = 2,
    LUrlDownloaderErrorBusy = 3,
    
    LUrlDownloaderErrorInvalidServerResponse = 10,
    LUrlDownloaderErrorIncompleteDownload = 11,
    LUrlDownloaderErrorTooManyRedirects = 12,
    LUrlDownloaderErrorZeroBytesResponse = 13,
    LUrlDownloaderErrorConnectionClosed = 14,
    LUrlDownloaderErrorConnectionTimeout = 15,
    
    LUrlDownloaderErrorIO = 20
    
} LUrlDownloaderError;

typedef enum
{
    LUrlDownloadStateNotRunning = 0,
    LUrlDownloadStateRunning = 1
    
} LUrlDownloadState;

typedef enum
{
    LUrlDownloadRequestMethodGet = 1,
    LUrlDownloadRequestMethodPost = 2
    
} LUrlDownloadRequestMethod;

@interface LUrlDownloader : NSObject

@property (nonatomic, copy) NSURL *url;
@property (nonatomic, retain, readonly) NSURL *finalDownloadUrl;
@property (nonatomic, retain, readonly) NSArray *redirectUrls;
@property (nonatomic, readonly, getter = getDownloadState) LUrlDownloadState downloadState;
@property (nonatomic, copy) NSString *downloadPath;
@property (nonatomic, assign) BOOL keepDownloadedFile;
@property (nonatomic, assign) LUrlDownloadRequestMethod requestMethod;

@property (nonatomic, assign) NSTimeInterval timeout;

@property (nonatomic, readonly) NSInteger bufferSize;

@property (nonatomic, assign) BOOL shouldVerifySSLCerfiticate;
@property (nonatomic, copy) NSDictionary *cookies;
@property (nonatomic, copy) NSString *userAgent;
@property (nonatomic, copy) NSString *requestLocale;
@property (nonatomic, copy) NSDictionary *requestHeaders;
@property (nonatomic, copy) NSDate *requestIfModifiedSince;

@property (nonatomic, copy) NSDictionary *postParams;
@property (nonatomic, copy) NSArray *postFiles;
@property (nonatomic, copy) NSData *postData;

@property (nonatomic, assign) BOOL httpAuthEnabled;
@property (nonatomic, copy) NSString *httpAuthUsername;
@property (nonatomic, copy) NSString *httpAuthPassword;

@property (nonatomic, assign) BOOL allowCompressedResponse;

@property (nonatomic, retain, readonly) NSDictionary *responseHeaders;
@property (nonatomic, readonly) NSInteger responseCode;
@property (nonatomic, readonly) long long responseLength;
@property (nonatomic, retain, readonly) NSString *responseContentType;
@property (nonatomic, retain, readonly) NSString *responseDescription;
@property (readonly, getter = getIsResponseCompressed) BOOL isResponseCompressed;

@property (nonatomic, readonly) long long bytesDownloaded;
@property (nonatomic, readonly) NSInteger progress;

@property (nonatomic, retain, readonly) NSString *pathToDownloadedFile;
@property (nonatomic, retain, readonly, getter = getReceivedData) NSData *receivedData;
@property (nonatomic, retain, readonly, getter = getReceivedData) NSData *responseData;

@property (nonatomic, retain, readonly) NSError *lastError;
@property (nonatomic, readonly) BOOL isSuccessful;

@property (nonatomic, assign) id<LUrlDownloaderDelegate> downloadDelegate;

@property (nonatomic, retain) NSRunLoop *runLoop;
@property (nonatomic, assign) BOOL pollAndBlockMode;

@property (nonatomic, assign) BOOL isCancelled;

@property (nonatomic, assign) NSInteger tag;

- (id)initWithUrl:(NSURL*)aUrl timeout:(NSTimeInterval)aTimeout;
- (id)initWithUrl:(NSURL*)aUrl downloadTo:(NSString*)aDownloadPath;
- (id)initWithUrl:(NSURL*)aUrl downloadTo:(NSString*)aDownloadPath requestMethod:(LUrlDownloadRequestMethod)aRequestMethod timeout:(NSTimeInterval)aTimeout;
- (id)initWithUrl:(NSURL*)aUrl downloadTo:(NSString*)aDownloadPath requestMethod:(LUrlDownloadRequestMethod)aRequestMethod timeout:(NSTimeInterval)aTimeout bufferSize:(NSInteger)aBufferSize;

- (BOOL)startDownload:(NSError**)error;
- (void)cancel;

+ (id)urlDownloaderWithUrl:(NSURL*)aUrl downloadTo:(NSString*)aDownloadPath requestMethod:(LUrlDownloadRequestMethod)aRequestMethod timeout:(NSTimeInterval)aTimeout pathToDownloadedFile:(NSString**)aPathToDownloadedFile isSuccessful:(BOOL*)isSuccessful error:(NSError**)error;

- (CFHTTPAuthenticationRef)httpAuthDetails;

@end
