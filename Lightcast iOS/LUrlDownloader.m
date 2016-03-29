//
//  LUrlDownloader.m
//  Lightcast
//
//  Created by Martin N. Kovachev on 04.01.13.
//  Copyright (c) 2013 г. Nimasystems Ltd. All rights reserved.
//

#import "LUrlDownloader.h"
#import "LUrlDownloaderPostFile.h"

// TODO: Finish up post methods

#define _kCFStreamPropertyReadTimeout CFSTR("_kCFStreamPropertyReadTimeout")

NSString *const LUrlDownloaderErrorDomain = @"com.lightcast.LUrlDownloader";
NSInteger const LUrlDownloaderDefaultTimeout = 30; // in seconds
NSInteger const LUrlDownloaderDefaultReadBufferSize = 4096;
NSInteger const LUrlDownloaderDefaultWriteBufferSize = 32768;
BOOL const kLUrlDownloaderDefaulShouldCompressResponse = YES;

NSInteger const LUrlDownloaderMaxInternalRedirects = 3;
NSInteger const LUrlDownloaderMaxHTTPAuthRetry = 3;
NSInteger const LUrlDownloaderRandomFilenameLength = 40;

static NSLock *_cachedHttpAuthLock;
static CFHTTPAuthenticationRef _cachedHttpAuth = NULL;

static dispatch_once_t _lUrlDownloaderSyncEvt;

@interface LUrlDownloader(Private)

- (void)handleNetworkEvent:(CFStreamEventType)type;
- (BOOL)handleBytesAvailable:(NSError**)error;
- (void)handleStreamComplete;
- (void)handleStreamError;

- (NSDictionary*)defaultRequestHeaders;
- (NSDictionary*)mergedRequestHeaders;

- (void)prepareRequestHeaders;
- (void)preparePostData;

- (void)setSSLCertificateVerificationForUrl:(NSURL*)aUrl;
- (void)setProxySettings;

- (void)resetCfObjects;

- (void)setLastError:(NSError*)error;
- (void)setDownloadState:(LUrlDownloadState)aDownloadState;
- (void)stopWithError:(NSError*)error;

- (BOOL)openFileHandle:(NSError**)error;
- (void)closeFileHandle;
- (BOOL)writeCurrentBufferDataToFile:(NSError**)error;

- (void)updateProgress;

- (void)removeDownloadedFile;

- (NSString*)downloadRequestMethodDescription:(LUrlDownloadRequestMethod)aDownloadRequestMethod;

- (BOOL)createRequest:(NSError**)error;
- (BOOL)createConnection:(NSURL*)aUrl error:(NSError**)error;

- (void)internalStopWithState:(LUrlDownloadState)aDownloadState;

#ifdef TARGET_IOS
- (void)changeIOSDeviceProgressIndicators:(BOOL)shownOrHidden;
#endif

@end

/** Stream callback, refering to a method in HTTPRequest
 *	@param CFReadStreamRef stream The stream which is being read
 *	@param CFStreamEventType type The event we are being notified of
 *	@param void clientCallBackInfo A pointer to the method for execution
 *	@return void
 */
static void LUrlDownloaderReadStreamClientCallBack(CFReadStreamRef stream, CFStreamEventType type, void *clientCallBackInfo)
{
	// callback the object
	if (clientCallBackInfo == NULL || !clientCallBackInfo) return;
	
    @autoreleasepool
    {
        [((LUrlDownloader*)clientCallBackInfo) handleNetworkEvent:type];
    } 
}

/** Stream Network Events
 */
static const CFOptionFlags kLUrlDownloaderNetworkEvents =
kCFStreamEventOpenCompleted |	/**	Stream has been open */
kCFStreamEventHasBytesAvailable |	/** Bytes received */
kCFStreamEventEndEncountered |	/** Stream end has been reached */
kCFStreamEventErrorOccurred;	/** Stream error occured */

@implementation LUrlDownloader {
    
    CFHTTPMessageRef _request;
    CFReadStreamRef _stream;
    CFHTTPMessageRef _response;
    CFHTTPAuthenticationRef _httpAuth;
    
    NSInteger _httpAuthTimesProcessed;
    
    BOOL _responseParsed;
    
    BOOL _isMultipartRequest;
    NSString *_multipartBoundaryValue1;
    
    NSDate *_lastTimeRead;
    
    NSFileHandle *_fileHandle;
    
    NSURL *_currentUrl;
    NSData *_preparedPostData;
    NSMutableDictionary *_preparedRequestHeaders;
    NSInteger _totalInternalRedirects;
    NSMutableArray *_redirectUrls;
    
    id _lastErrorLock;
    id _startStopLock;
    
    NSMutableData *_tmpWriteBuffer;
    NSData *_decompressedData;
    BOOL _isResponseDataDecompressed;
    
    long long bytesWritten;
    
    BOOL _finished;
    
    NSRunLoop *_runLoop;
}

@synthesize
url,
finalDownloadUrl=_currentUrl,
redirectUrls=_redirectUrls,
downloadState,
downloadPath,
keepDownloadedFile,
timeout,
requestMethod,
cookies,
userAgent,
bufferSize,
isResponseCompressed,
requestHeaders,
responseHeaders,
requestLocale,
responseCode,
responseLength,
responseDescription,
responseContentType,
postFiles,
requestIfModifiedSince,
postData,
isSuccessful,
shouldVerifySSLCerfiticate,
postParams,
httpAuthEnabled,
httpAuthUsername,
httpAuthPassword,
bytesDownloaded,
receivedData,
responseData,
progress,
pathToDownloadedFile,
lastError,
downloadDelegate,
runLoop,
pollAndBlockMode,
isCancelled,
tag,
allowCompressedResponse;

#pragma mark - Initialization / Finalization

- (id)initWithUrl:(NSURL*)aUrl timeout:(NSTimeInterval)aTimeout
{
     return [self initWithUrl:aUrl downloadTo:nil requestMethod:LUrlDownloadRequestMethodGet timeout:aTimeout];
}

- (id)initWithUrl:(NSURL*)aUrl downloadTo:(NSString*)aDownloadPath
{
    return [self initWithUrl:aUrl downloadTo:aDownloadPath requestMethod:LUrlDownloadRequestMethodGet timeout:LUrlDownloaderDefaultTimeout];
}

- (id)initWithUrl:(NSURL*)aUrl downloadTo:(NSString*)aDownloadPath requestMethod:(LUrlDownloadRequestMethod)aRequestMethod timeout:(NSTimeInterval)aTimeout
{
    return [self initWithUrl:aUrl downloadTo:aDownloadPath requestMethod:aRequestMethod timeout:aTimeout bufferSize:LUrlDownloaderDefaultReadBufferSize];
}

- (id)initWithUrl:(NSURL*)aUrl downloadTo:(NSString*)aDownloadPath requestMethod:(LUrlDownloadRequestMethod)aRequestMethod timeout:(NSTimeInterval)aTimeout bufferSize:(NSInteger)aBufferSize
{
    self = [super init];
    if (self)
    {
        if (!aUrl || !aRequestMethod || !aTimeout || !aBufferSize)
        {
            L_RELEASE(self);
            lassert(false);
            return nil;
        }
        
        downloadState = LUrlDownloadStateNotRunning;
        downloadDelegate = nil;
        
        _startStopLock = [[NSObject alloc] init];
        _lastErrorLock = [[NSObject alloc] init];
        
        _redirectUrls = [[NSMutableArray alloc] init];
        _tmpWriteBuffer = [[NSMutableData alloc] init];
        
        _httpAuth = NULL;
        
        _currentUrl = nil;
        _preparedPostData = nil;
        _preparedRequestHeaders = nil;
        _response = nil;
        _fileHandle = nil;
        responseContentType = nil;
        
        // verify SSL certificate by default
        shouldVerifySSLCerfiticate = YES;
        
        keepDownloadedFile = NO;
        
        // allow compression by default if not saving gradually to a file
        if (!aDownloadPath)
        {
            allowCompressedResponse = kLUrlDownloaderDefaulShouldCompressResponse;
        }
        
        _totalInternalRedirects = 0;
        
        url = [aUrl copy];
        downloadPath = [aDownloadPath copy];
        requestMethod = aRequestMethod;
        timeout = aTimeout;
        bufferSize = aBufferSize;
        
        // sync events
        dispatch_once(&_lUrlDownloaderSyncEvt, ^{
            // create a locking mutex for the auth el
            if (!_cachedHttpAuthLock) {
                _cachedHttpAuthLock = [[NSLock alloc] init];
            }
        });
    }
    return self;
}

+ (id)urlDownloaderWithUrl:(NSURL*)aUrl downloadTo:(NSString*)aDownloadPath requestMethod:(LUrlDownloadRequestMethod)aRequestMethod timeout:(NSTimeInterval)aTimeout pathToDownloadedFile:(NSString**)aPathToDownloadedFile isSuccessful:(BOOL*)isSuccessful error:(NSError**)error
{
    // TODO: complete this
    
    return nil;
}

- (void)dealloc
{
    // first we get rid of the delegate!
    downloadDelegate = nil;
    
    // make sure the connection is stopped (blocking here)
    [self internalStopWithState:LUrlDownloadStateNotRunning];
    
    [self resetCfObjects];
    
    // we keep this out of resetCfObjects as the connection may be reinitialized several times
    if (_httpAuth) {
        CFRelease(_httpAuth);
        _httpAuth = NULL;
    }
    
    L_RELEASE(url);
    L_RELEASE(downloadPath);
    L_RELEASE(cookies);
    L_RELEASE(userAgent);
    L_RELEASE(responseHeaders);
    L_RELEASE(pathToDownloadedFile);
    L_RELEASE(lastError);
    L_RELEASE(postData);
    L_RELEASE(postParams);
    L_RELEASE(requestHeaders);
    L_RELEASE(postFiles);
    L_RELEASE(_currentUrl);
    L_RELEASE(_preparedPostData);
    L_RELEASE(_preparedRequestHeaders);
    L_RELEASE(responseDescription);
    L_RELEASE(responseContentType);
    L_RELEASE(_fileHandle);
    L_RELEASE(_redirectUrls);
    L_RELEASE(runLoop);
    L_RELEASE(_runLoop);
    L_RELEASE(_tmpWriteBuffer);
    L_RELEASE(_decompressedData);
    L_RELEASE(_lastTimeRead);
    L_RELEASE(requestIfModifiedSince);
    L_RELEASE(_multipartBoundaryValue1);
    L_RELEASE(requestLocale);
    L_RELEASE(httpAuthUsername);
    L_RELEASE(httpAuthPassword);
    
    L_RELEASE(_startStopLock);
    L_RELEASE(_lastErrorLock);
    
    
#ifdef TARGET_IOS
    [self changeIOSDeviceProgressIndicators:NO];
#endif
    
    [super dealloc];
}

#pragma mark - Connection control

- (BOOL)startDownload:(NSError**)error
{
    @synchronized(_startStopLock)
    {
        if (error != NULL)
        {
            *error = nil;
        }
        
        // check if already running
        if ([self getDownloadState] != LUrlDownloadStateNotRunning)
        {
            if (error != NULL)
            {
                *error = [NSError errorWithDomainAndDescription:LUrlDownloaderErrorDomain
                                                      errorCode:LUrlDownloaderErrorBusy
                                           localizedDescription:LightcastLocalizedString(@"Download already started")];
            }
            
            return NO;
        }
        
        // start it
        BOOL ret = [self createRequest:error];
        
        return ret;
    }
}

- (void)cancel
{
    if ([self getDownloadState] != LUrlDownloadStateRunning || isCancelled)
    {
        return;
    }
    
    isCancelled = YES;
}

#pragma mark - CFNetwork / Callbacks

- (void)handleNetworkEvent:(CFStreamEventType)type
{
    if (_finished)
    {
        return;
    }
    
    // mark the last reading
    NSDate* date = [NSDate date];
    
    if (date != _lastTimeRead)
    {
        L_RELEASE(_lastTimeRead);
        _lastTimeRead = [date retain];
    }
    
    // Dispatch the stream events.
    switch (type)
	{
        case kCFStreamEventHasBytesAvailable:
        {
            NSError *err = nil;
            BOOL processed = [self handleBytesAvailable:&err shouldContinuePolling:nil];
            
            if (!processed)
            {
                self.lastError = err;
                _finished = YES;
            }
            
            break;
        }
        case kCFStreamEventEndEncountered:
        {
            [self handleStreamComplete];
            break;
        }
        case kCFStreamEventErrorOccurred:
        {
            [self handleStreamError];
            break;
        }
        case kCFStreamEventOpenCompleted:
        {
            //
            break;
        }
        case kCFStreamEventCanAcceptBytes:
        {
            //
            break;
        }
        default:
        {
            //
            break;
        }
    }
}

- (BOOL)handleStreamStatus:(NSError**)error
{
    if (error != NULL)
    {
        *error = nil;
    }
    
    if (!_stream) {
        return YES;
    }
    
    CFStreamStatus streamStatus = CFReadStreamGetStatus(_stream);
    
    if (streamStatus == kCFStreamStatusClosed)
    {
        if (error != NULL)
        {
            *error = [NSError errorWithDomainAndDescription:LUrlDownloaderErrorDomain
                                                  errorCode:LUrlDownloaderErrorConnectionClosed
                                       localizedDescription:LightcastLocalizedString(@"Connection is closed")];
        }
        
        return NO;
    }
    else if (streamStatus == kCFStreamStatusError)
    {
        if (error != NULL)
        {
            CFStreamError cfError = CFReadStreamGetError(_stream);
            
            // create the error
            *error = [NSError errorWithDomainAndDescription:LUrlDownloaderErrorDomain
                                                          errorCode:LUrlDownloaderErrorInvalidServerResponse
                                               localizedDescription:[NSString stringWithFormat:LightcastLocalizedString(@"Could not read data from server (%d)"), cfError.error]];
        }
        
        return NO;
    }
    else if (streamStatus == kCFStreamStatusAtEnd)
    {
        // write any pending leftover data
        BOOL ret = [self handleConnectionEnd:error];
        
        return ret;
    }
    
    return YES;
}

- (BOOL)parseStreamHeaders:(NSError**)error
{
    @synchronized(self)
    {
        if (_responseParsed)
        {
            return YES;
        }
        
        if (error != NULL)
        {
            *error = nil;
        }
        
        // save the response
        if (_response && _response != NULL)
        {
            CFRelease(_response);
            _response = nil;
        }

        // parse the response and set headers / response code
        _response = (CFHTTPMessageRef)CFReadStreamCopyProperty(_stream, kCFStreamPropertyHTTPResponseHeader);
        
        if (_response)
        {
            NSDictionary * _responseHeaders = [(NSDictionary*)CFHTTPMessageCopyAllHeaderFields(_response) autorelease];
            
            if (_responseHeaders != responseHeaders)
            {
                L_RELEASE(responseHeaders);
                responseHeaders = [_responseHeaders copy];
            }
            
            // parse the headers
            NSString *redirectLocation = nil;
            
            if (responseHeaders)
            {
                // set contentLength
                if ([responseHeaders objectForKey:@"Content-Length"])
                {
                    responseLength = [[responseHeaders objectForKey:@"Content-Length"] longLongValue];
                }
                
                /*  // set content type
                 NSString *contentType_ = [responseHeaders objectForKey:@"Content-Type"];
                 
                 if (contentType_ != responseContentType)
                 {
                 L_RELEASE(responseContentType);
                 responseContentType = [contentType_ copy];
                 }*/
                
                // redirect location
                redirectLocation = [responseHeaders objectForKey:@"Location"];
            }
            
            NSString * _responseDescription = [(NSString*)CFHTTPMessageCopyResponseStatusLine(_response) autorelease];
            
            if (_responseDescription != responseDescription)
            {
                L_RELEASE(responseDescription);
                responseDescription = [_responseDescription copy];
            }
            
            responseCode = CFHTTPMessageGetResponseStatusCode(_response);
            
            if (responseCode == 301) {
                // support redirects
                // check if redirects are too much
                if (_totalInternalRedirects >= LUrlDownloaderMaxInternalRedirects)
                {
                    [self closeConnection];
                    
                    // yes - cancel the connection
                    // create the error
                    NSError *err = [NSError errorWithDomainAndDescription:LUrlDownloaderErrorDomain errorCode:LUrlDownloaderErrorTooManyRedirects localizedDescription:[NSString stringWithFormat:LightcastLocalizedString(@"Reached the maximum number of redirects"), responseCode]];
                    
                    if (error != NULL)
                    {
                        *error = err;
                    }
                    
                    return NO;
                }
                
                // check the Location header
                NSURL *nextRedirectUrl = ![NSString isNullOrEmpty:redirectLocation] ? [NSURL URLWithString:redirectLocation] : nil;
                
                if (!nextRedirectUrl)
                {
                    [self closeConnection];
                    
                    // create the error
                    NSError *err = [NSError errorWithDomainAndDescription:LUrlDownloaderErrorDomain errorCode:LUrlDownloaderErrorInvalidServerResponse localizedDescription:[NSString stringWithFormat:LightcastLocalizedString(@"Invalid Server Response (Invalid redirect)"), responseCode] customData:nil];
                    
                    if (error != NULL)
                    {
                        *error = err;
                    }
                    
                    return NO;
                }
                
                // all ok - close the connection and reinit with the next url
                
                _totalInternalRedirects += 1;
                
                [self closeConnection];
                
                NSError *reopenError = nil;
                BOOL reopened = [self createConnection:nextRedirectUrl error:&reopenError];
                
                if (!reopened)
                {
                    // create the error
                    NSError *err = [NSError errorWithDomainAndDescription:LUrlDownloaderErrorDomain errorCode:LUrlDownloaderErrorGeneric localizedDescription:[NSString stringWithFormat:LightcastLocalizedString(@"Could not create next connection (%@)"), redirectLocation]];
                    
                    if (error != NULL)
                    {
                        *error = err;
                    }
                    
                    return NO;
                }
            } else if (responseCode == 401) {
                // Authentication required
                
                // check if max retries has been reached
                if (_httpAuthTimesProcessed >= LUrlDownloaderMaxHTTPAuthRetry) {
                    [self closeConnection];
                    
                    // yes - cancel the connection
                    // create the error
                    NSError *err = [NSError errorWithDomainAndDescription:LUrlDownloaderErrorDomain errorCode:LUrlDownloaderErrorTooManyRedirects localizedDescription:[NSString stringWithFormat:LightcastLocalizedString(@"Reached the maximum number of HTTP Authentication tries"), responseCode]];
                    
                    if (error != NULL)
                    {
                        *error = err;
                    }
                    
                    return NO;
                }
                
                _httpAuthTimesProcessed++;
                
                if (_httpAuth == NULL) {
                    // obtain the authentication information
                    _httpAuth = CFHTTPAuthenticationCreateFromResponse(kCFAllocatorDefault, _response);
                    
                    if (_httpAuth != NULL) {
                        // cache it
                        [_cachedHttpAuthLock lock];
                        
                        // reuse the cached auth if available
                        @try {
                            if (_cachedHttpAuth == NULL) {
                                _cachedHttpAuth = _httpAuth;
                                CFRetain(_cachedHttpAuth);
                            }
                        }
                        @finally {
                            [_cachedHttpAuthLock unlock];
                        }
                        
                        // recreate the connection
                        [self closeConnection];
                        
                        NSError *reopenError = nil;
                        BOOL reopened = [self createConnection:self.url error:&reopenError];
                        
                        if (!reopened)
                        {
                            // create the error
                            NSError *err = [NSError errorWithDomainAndDescription:LUrlDownloaderErrorDomain errorCode:LUrlDownloaderErrorGeneric localizedDescription:[NSString stringWithFormat:LightcastLocalizedString(@"Could not reopen connection after obtaining HTTP Authentication information (%@)"), reopenError]];
                            
                            if (error != NULL)
                            {
                                *error = err;
                            }
                            
                            return NO;
                        }
                    }
                }
            }
        }

        _responseParsed = YES;
        
        return YES;
    }
}

- (BOOL)responseValid {
    BOOL ret = (responseCode == 200 || responseCode == 206);
    return ret;
}

- (BOOL)verifyResponseCode:(NSError**)error {
    
    // we support only 200, 206, 301, 304 codes
    
    if (responseCode == 301)
    {
        // create the error
        NSError *err = [NSError errorWithDomainAndDescription:LUrlDownloaderErrorDomain errorCode:LUrlDownloaderErrorInvalidServerResponse localizedDescription:[NSString stringWithFormat:LightcastLocalizedString(@"Invalid Server Response (%d)"), responseCode] customData:nil];
        
        if (error != NULL)
        {
            *error = err;
        }
        
        return NO;
    }
    else if (responseCode == 304)
    {
        // create the error
        NSError *err = [NSError errorWithDomainAndDescription:LUrlDownloaderErrorDomain errorCode:LUrlDownloaderErrorInvalidServerResponse localizedDescription:[NSString stringWithFormat:LightcastLocalizedString(@"Invalid Server Response (%d)"), responseCode] customData:nil];
        
        if (error != NULL)
        {
            *error = err;
        }
        
        return NO;
    }
    else if (responseCode != 200 && responseCode != 206)
    {
        // something unsupported or error - we fail here
        
        // create the error
        NSError *err = [NSError errorWithDomainAndDescription:LUrlDownloaderErrorDomain errorCode:LUrlDownloaderErrorInvalidServerResponse localizedDescription:[NSString stringWithFormat:LightcastLocalizedString(@"Invalid Server Response (%d)"), responseCode] customData:nil];
        
        if (error != NULL)
        {
            *error = err;
        }
        
        return NO;
    }
    return YES;
}

- (BOOL)handleBytesAvailable:(NSError**)error shouldContinuePolling:(BOOL*)shouldContinuePolling
{
    if (error != NULL)
    {
        *error = nil;
    }
    
    if (shouldContinuePolling != NULL)
    {
        *shouldContinuePolling = NO;
    }
    
    if (_finished) {
        return NO;
    }
    
    // Work out stream's data
    lassert(_stream);
    
    // wait for data and continue polling until data is here
    if (_stream)
    {
        if (!CFReadStreamHasBytesAvailable(_stream))
        {
            if (shouldContinuePolling != NULL)
            {
                *shouldContinuePolling = YES;
            }
            
            return YES;
        }
    }
    
    // continue with filling in the buffer
    UInt8 buffer[bufferSize];
    
    CFIndex bytesRead = CFReadStreamRead(_stream, buffer, bufferSize);
    
    // Less than zero is an error
    /*if (bytesRead < 0)
    {
        if (downloadPath)
        {
            lassert(_fileHandle);
            
            // write any pending leftover data
            NSError *writeErr = nil;
            BOOL written = [self writeCurrentBufferDataToFile:&writeErr];
            
            if (!written)
            {
                if (error != NULL)
                {
                    *error = writeErr;
                }
                
                return NO;
            }
        }
        
        CFStreamError cfError = CFReadStreamGetError(_stream);
        
        // create the error
        NSError *err = [NSError errorWithDomainAndDescription:LUrlDownloaderErrorDomain
                                                    errorCode:LUrlDownloaderErrorInvalidServerResponse
                                         localizedDescription:[NSString stringWithFormat:LightcastLocalizedString(@"Could not read data from server (%d)"), cfError.error]];
        
        if (error != NULL)
        {
            *error = err;
        }
        
        return NO;
    }
    else */
    
    if (bytesRead > 0)
    {
        // save the total bytes downloaded so far
        bytesDownloaded += bytesRead;
        
        // NSLog(@"\n\nSERVER DATA:\n\n%s\n\n", buffer);
        
        // write the current data to the file
        NSData *currentData = [NSData dataWithBytes:buffer length:bytesRead];
        
        lassert(currentData);
        
        // append to write buffer
        [_tmpWriteBuffer appendBytes:[currentData bytes] length:[currentData length]];
        
        BOOL headersParsed = [self parseStreamHeaders:error];
        
        if (!headersParsed)
        {
            return NO;
        }
        
        if (_finished) {
            return NO;
        }
        
        // parse the data - save to disk - if downloadPath has been set
        // otherwise - store it in the local data
        if (!_fileHandle && downloadPath)
        {
            // try to create and open the file for the first time
            NSError *err = nil;
            BOOL fileOpened = [self openFileHandle:&err];
            
            if (!fileOpened)
            {
                if (error != NULL)
                {
                    *error = err;
                }
                
                return NO;
            }
        }
        
        if (currentData)
        {
            // inform the delegate
            if (downloadDelegate)
            {
                if ([downloadDelegate respondsToSelector:@selector(downloader:didDownloadData:)])
                {
                    [downloadDelegate downloader:self didDownloadData:currentData];
                }
            }
            
            // if storing to a file
            // store the current write data from write buffer
            // if it reaches the write buffer size
            if (downloadPath && [_tmpWriteBuffer length] >= LUrlDownloaderDefaultWriteBufferSize)
            {
                lassert(_fileHandle);
                
                NSError *writeErr = nil;
                BOOL written = [self writeCurrentBufferDataToFile:&writeErr];
                
                if (!written)
                {
                    if (error != NULL)
                    {
                        *error = writeErr;
                    }
                    
                    return NO;
                }
            }
        }
        
        // update the download progress value
        [self updateProgress];
        
        if (shouldContinuePolling != NULL)
        {
            *shouldContinuePolling = YES;
        }
        
        return YES;
        
    }
    
    /*else if (bytesRead == 0)
    {
        // all data received - close the connection
        if (CFReadStreamGetStatus(_stream) == kCFStreamStatusAtEnd)
        {
            if (shouldContinuePolling != NULL)
            {
                *shouldContinuePolling = NO;
            }
            
            BOOL handledEnd = [self handleConnectionEnd:error];
            
            if (!handledEnd)
            {
                return NO;
            }

            return NO;
        }
    }*/
    
    if (shouldContinuePolling != NULL)
    {
        *shouldContinuePolling = YES;
    }
    
    return YES;
}

- (void)handleStreamComplete
{
    // Received when the streaming has ended
    
    NSError *err = nil;
    BOOL ret = [self handleConnectionEnd:&err];
    
    if (!ret)
    {
        return;
    }
}

- (void)handleStreamError
{
    // Received when an error has occured while streaming
    lassert(_stream);
    
    CFErrorRef streamError = CFReadStreamCopyError(_stream);
    
    if (streamError != NULL)
    {
        NSError *strErr = (NSError*)streamError;
        self.lastError = strErr;
        CFRelease(streamError);
        streamError = NULL;
    }
    
    _finished = YES;
}

#pragma mark - Storage handling

- (BOOL)handleConnectionEnd:(NSError**)error
{
    if (error != NULL)
    {
        *error = nil;
    }
    
    // try to parse the headers if not parsed yet
    NSError *err = nil;
    BOOL headersParsed = [self parseStreamHeaders:&err];
    
    if (!headersParsed)
    {
        LogError(@"Could not parse stream headers: %@", err);
    }
    
    if (_finished)
    {
        // do nothing else here
        return YES;
    }
    
    lassert(_tmpWriteBuffer);
    
    /*if (![_tmpWriteBuffer length])
    {
        // file was never opened for writing - zero bytes
        // create the error
        NSError *err = [NSError errorWithDomainAndDescription:LUrlDownloaderErrorDomain errorCode:LUrlDownloaderErrorZeroBytesResponse localizedDescription:LightcastLocalizedString(@"Server did not return any data")];
        
        if (error != NULL)
        {
            *error = err;
        }
        
        return NO;
    }*/
    
    // write any pending leftover data
    if (downloadPath)
    {
        lassert(_fileHandle);
        
        NSError *writeErr = nil;
        BOOL written = [self writeCurrentBufferDataToFile:&writeErr];
        
        if (!written)
        {
            if (error != NULL)
            {
                *error = writeErr;
            }
            
            lassert(false);
            return NO;
        }
    }
    
    _finished = YES;
    isSuccessful = YES;
    
    return YES;
}

- (BOOL)openFileHandle:(NSError**)error
{
    lassert(!_fileHandle);
    lassert(downloadPath);
    //lassert(!pathToDownloadedFile);
    
    if (error != NULL)
    {
        *error = nil;
    }
    
    NSFileManager *fm = [NSFileManager defaultManager];
    
    // check the target dir first
    BOOL isDir = NO;
    BOOL ret = [fm fileExistsAtPath:downloadPath isDirectory:&isDir];
    
    if (!ret || !isDir)
    {
        if (error != NULL)
        {
            *error = [NSError errorWithDomainAndDescription:LUrlDownloaderErrorDomain errorCode:LUrlDownloaderErrorIO localizedDescription:LightcastLocalizedString(@"Target download directory is not available")];
        }
        
        return NO;
    }
    
    // generate a random filename
    NSString *filename = [fm randomFilename:LUrlDownloaderRandomFilenameLength];
    
    lassert(filename);
    
    filename = [NSFileManager combinePaths:downloadPath, filename, nil];
    
    if (pathToDownloadedFile != filename)
    {
        L_RELEASE(pathToDownloadedFile);
        pathToDownloadedFile = [filename retain];
    }
    
    // try to create the file
    BOOL created = [fm createFileAtPath:filename contents:nil attributes:nil];
    
    if (!created)
    {
        if (error != NULL)
        {
            *error = [NSError errorWithDomainAndDescription:LUrlDownloaderErrorDomain
                                                  errorCode:LUrlDownloaderErrorIO
                                       localizedDescription:[NSString stringWithFormat:LightcastLocalizedString(@"Could not create temporary file for storing the downloaded data (%@)"), filename]];
        }
        
        return NO;
    }
    
    @try
    {
        NSURL *furl = [NSURL fileURLWithPath:filename];
        
        lassert(furl);
        
        // create the file handle
        _fileHandle = [[NSFileHandle fileHandleForWritingToURL:furl error:error] retain];
        
        if (!_fileHandle || (error != NULL && *error))
        {
            lassert(false);
            return NO;
        }
        
        bytesWritten = 0;
    }
    @finally
    {
        // if opening the file failed - wipe out the temp file
        if (!_fileHandle)
        {
            NSError *tmpErr = nil;
            BOOL removed = [fm removeItemAtPath:filename error:&tmpErr];
            lassert(removed);
            
            if (!removed)
            {
                LogError(@"Could not remove file: %@", filename);
            }
        }
    }
    
    return YES;
}

- (BOOL)writeCurrentBufferDataToFile:(NSError**)error
{
    if (error != NULL)
    {
        *error = nil;
    }
    
    lassert(_fileHandle);
    lassert(_tmpWriteBuffer);
    
    if (![_tmpWriteBuffer length])
    {
        return YES;
    }
    
    @try
    {
        // write to the file only if we have a valid response
        if ([self responseValid]) {
            [_fileHandle writeData:_tmpWriteBuffer];
        }
        
        bytesWritten += [_tmpWriteBuffer length];
        
        // clear the temp buffer
        L_RELEASE(_tmpWriteBuffer);
        _tmpWriteBuffer = [[NSMutableData alloc] init];
        //[_tmpWriteBuffer setData:nil];
    }
    @catch (NSException *e)
    {
        // create the error
        if (error != NULL)
        {
            *error = [NSError errorWithDomainAndDescription:LUrlDownloaderErrorDomain
                                                errorCode:LUrlDownloaderErrorInvalidServerResponse
                                     localizedDescription:[NSString stringWithFormat:LightcastLocalizedString(@"Could not write downloaded data to disk: %@"), e.reason]];
        }
   
        return NO;
    }
    
    return YES;
}

- (void)closeFileHandle
{
    if (_fileHandle)
    {
        // write any left over data which has not been written yet
        [self writeCurrentBufferDataToFile:nil];
        
        [_fileHandle closeFile];
        L_RELEASE(_fileHandle);
        
        lassert(bytesWritten == bytesDownloaded);
        
        L_RELEASE(_tmpWriteBuffer);
        _tmpWriteBuffer = [[NSMutableData alloc] init];
        //[_tmpWriteBuffer setData:nil];
    }
}

#pragma mark - Getters / Setters

- (LUrlDownloadState)getDownloadState
{
    return downloadState;
}

- (void)setDownloadState:(LUrlDownloadState)aDownloadState
{
    downloadState = aDownloadState;
}

- (BOOL)getIsResponseCompressed
{
    NSString *encoding = [self.responseHeaders objectForKey:@"Content-Encoding"];
	return encoding && [encoding rangeOfString:@"gzip"].location != NSNotFound;
}

- (NSData*)getReceivedData
{
    BOOL isCompressed = self.isResponseCompressed;

    if (isCompressed)
    {
        if (!_isResponseDataDecompressed)
        {
            _isResponseDataDecompressed = YES;
            
            // decompress and set now
            NSError *err = nil;
            NSData *decompressedData = [LUrlDownloaderDecompressor uncompressData:_tmpWriteBuffer error:&err];
            
            if (err)
            {
                lassert(false);
                LogError(@"Could not decompress response data: %@", err);
                return nil;
            }
            
            if (decompressedData != _decompressedData)
            {
                L_RELEASE(_decompressedData);
                _decompressedData = [decompressedData retain];
            }
            
            return _decompressedData;
        }
        else
        {
            // just return the decompressed data
            return _decompressedData;
        }
    }

    // not a compressed response - return the actual data
    return _tmpWriteBuffer;
}

#pragma mark - Private methods

- (BOOL)createRequest:(NSError**)error
{
    if (error != NULL)
    {
        *error = nil;
    }
    
    lassert(url);
    lassert(!_request);
    lassert(!_stream);
    lassert(!_response);
    lassert(requestMethod);
    lassert([self getDownloadState] == LUrlDownloadStateNotRunning);
    
    [self setDownloadState:LUrlDownloadStateNotRunning];
    
    // reset vars to initial state
    L_RELEASE(lastError);
    L_RELEASE(pathToDownloadedFile);
    L_RELEASE(_preparedPostData);
    L_RELEASE(_multipartBoundaryValue1);
    isCancelled = NO;
    progress = 0;
    _totalInternalRedirects = 0;
    _finished = NO;
    isSuccessful = NO;
    _isMultipartRequest = NO;
    
    [_redirectUrls removeAllObjects];
    
    // prepare the post data
    [self preparePostData];
    
    // prepare the headers
    [self prepareRequestHeaders];
    
    // inform the delegate
    if (downloadDelegate)
    {
        if ([downloadDelegate respondsToSelector:@selector(downloaderWillBeginDownloading:)])
        {
            [downloadDelegate downloaderWillBeginDownloading:self];
        }
    }
    
    // change the state
    [self setDownloadState:LUrlDownloadStateRunning];
    
    // inform the delegate
    if (downloadDelegate)
    {
        if ([downloadDelegate respondsToSelector:@selector(downloaderDidBeginDownloading:)])
        {
            [downloadDelegate downloaderDidBeginDownloading:self];
        }
    }
    
    // start the connection
    BOOL ret = [self createConnection:url error:error];
    
    if (!ret)
    {
        return NO;
    }
    
    return YES;
}

- (BOOL)createConnection:(NSURL*)aUrl error:(NSError**)error
{
    lassert(!_request);
    lassert(!_stream);
    lassert(!_response);
    
    if (!aUrl)
    {
        lassert(false);
        return NO;
    }
    
    if (error != NULL)
    {
        *error = nil;
    }
    
    // reset state vars
    _responseParsed = NO;
    responseLength = 0;
    bytesDownloaded = 0;
    responseCode = 0;
    L_RELEASE(responseContentType);
    L_RELEASE(responseHeaders);
    L_RELEASE(responseDescription);
    
    //[_tmpWriteBuffer setData:nil];
    
    L_RELEASE(_tmpWriteBuffer);
    _tmpWriteBuffer = [[NSMutableData alloc] init];
    
    L_RELEASE(_decompressedData);
    _isResponseDataDecompressed = NO;
    
    NSRunLoop *rl = runLoop ? runLoop : [NSRunLoop currentRunLoop];
    
    if (_runLoop != rl)
    {
        L_RELEASE(_runLoop);
        _runLoop = [rl retain];
    }
    
    // save the last used url
    if (aUrl != _currentUrl)
    {
        L_RELEASE(_currentUrl);
        _currentUrl = [aUrl retain];
    }
    
    // add to the list of redirect urls
    [_redirectUrls addObject:aUrl];
    
    // inform the delegate
    if (downloadDelegate)
    {
        if ([downloadDelegate respondsToSelector:@selector(downloaderWillBeginConnection:url:)])
        {
            [downloadDelegate downloaderWillBeginConnection:self url:aUrl];
        }
    }
    
    // create context and request
    CFStreamClientContext ctxt = {0, self, NULL, NULL, NULL};
    NSString *downloadRequestStr = [self downloadRequestMethodDescription:requestMethod];
    
    _request = CFHTTPMessageCreateRequest(kCFAllocatorDefault, (CFStringRef)downloadRequestStr, (CFURLRef)aUrl, kCFHTTPVersion1_1);
    
    if (!_request)
    {
        lassert(false);
        return NO;
    }
    
    // prepare HTTP authentication part of message
    if (self.httpAuthEnabled && ![NSString isNullOrEmpty:self.httpAuthUsername] &&
        ![NSString isNullOrEmpty:self.httpAuthPassword]) {
        
        [_cachedHttpAuthLock lock];
        
        // reuse the cached auth if available
        @try {
            if (_httpAuth == NULL && _cachedHttpAuth != NULL && CFHTTPAuthenticationAppliesToRequest(_cachedHttpAuth, _request)) {
                _httpAuth = _cachedHttpAuth;
                CFRetain(_httpAuth);
            }
        }
        @finally {
            [_cachedHttpAuthLock unlock];
        }
        
        if (_httpAuth != NULL) {
            // check the auth
            NSMutableDictionary *httpAuthCredentials = [NSMutableDictionary dictionary];
            [httpAuthCredentials setObject:self.httpAuthUsername forKey:(NSString *)kCFHTTPAuthenticationUsername];
            [httpAuthCredentials setObject:self.httpAuthPassword forKey:(NSString *)kCFHTTPAuthenticationPassword];
            
            if (!CFHTTPMessageApplyCredentialDictionary(_request, _httpAuth, (CFMutableDictionaryRef)httpAuthCredentials, NULL)) {
                // clear the auth
                CFRelease(_httpAuth);
                _httpAuth = NULL;
                
                lassert(false);
                return NO;
            }
        }
    }
    
    if (_preparedPostData)
    {
        CFHTTPMessageSetBody(_request,(CFDataRef)_preparedPostData);
    }
    
    // set the headers
    NSMutableDictionary *headers = _preparedRequestHeaders;
    
    lassert(headers);
    
    // append Host header
    if (![headers objectForKey:@"Host"])
    {
        NSString *host = [aUrl host];
        
        // it turns out that can happen!
        if (![NSString isNullOrEmpty:host])
        {
            [headers setObject:host forKey:@"Host"];
        }
    }
    
    // set all headers to the request
    for(NSString *key in headers)
    {
        CFHTTPMessageSetHeaderFieldValue(_request, (CFStringRef)key, (CFStringRef)[headers objectForKey:key]);
    }
    
    // create the stream for the request.
    lassert(!_stream);
    
    _stream = CFReadStreamCreateForHTTPRequest(kCFAllocatorDefault, _request);
    
    if (!_stream)
    {
        lassert(false);
        return NO;
    }
    
    // set the read timeout
    long long tm = self.timeout;
    CFNumberRef num = CFNumberCreate(kCFAllocatorDefault, kCFNumberDoubleType, &tm);
    CFReadStreamSetProperty(_stream, _kCFStreamPropertyReadTimeout, num);
    CFRelease(num);
    
    // proxy settings
    [self setProxySettings];
    
    // SSL certificate verification
    [self setSSLCertificateVerificationForUrl:aUrl];
    
    // why polling is better: http://stackoverflow.com/questions/598762/cfreadstreamhasbytesavailable-polling-best-practices
    
    lassert(_runLoop);
    
    // if we are in runloop mode - set it up
    if (!pollAndBlockMode)
    {
        // set the ctx client
        if (!CFReadStreamSetClient(_stream, kLUrlDownloaderNetworkEvents, LUrlDownloaderReadStreamClientCallBack, &ctxt))
        {
            lassert(false);
            return NO;
        }
        
        // schedule the stream
        CFReadStreamScheduleWithRunLoop(_stream, [_runLoop getCFRunLoop], kCFRunLoopDefaultMode);
    }
    
    // start the connection
    if (!CFReadStreamOpen(_stream))
    {
        [self resetCfObjects];
        lassert(false);
        return NO;
    }
    
    // check status of the stream opening when in pollAndBlock mode
    if (pollAndBlockMode)
    {
        if (CFReadStreamGetStatus(_stream) != kCFStreamStatusOpen)
        {
            [self resetCfObjects];
            lassert(false);
            return NO;
        }
    }
       
    // show the network indicators for iOS
#ifdef TARGET_IOS
    [self changeIOSDeviceProgressIndicators:YES];
#endif
    
    // inform the delegate
    if (downloadDelegate)
    {
        if ([downloadDelegate respondsToSelector:@selector(downloaderDidInitializeConnection:url:)])
        {
            [downloadDelegate downloaderDidInitializeConnection:self url:aUrl];
        }
    }
    
    BOOL ret = YES;
    BOOL streamStatus = NO;
    
    if (!pollAndBlockMode)
    {
        NSError *err = nil;
        
        // mark the first reading
        NSDate* date = [NSDate date];
        
        if (date != _lastTimeRead)
        {
            L_RELEASE(_lastTimeRead);
            _lastTimeRead = [date retain];
        }
        
        // run the runloop
        while(!isCancelled && !_finished)
        {
            err = nil;
            
            BOOL ran = [_runLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
            
            if (!ran)
            {
                break;
            }
            
            NSTimeInterval newTimeout = ([[NSDate date] timeIntervalSince1970] - [_lastTimeRead timeIntervalSince1970]);
            
            if (self.downloadDelegate && [self.downloadDelegate respondsToSelector:@selector(downloader:didRunRunloop:elapsedTime:)]) {
                [self.downloadDelegate downloader:self didRunRunloop:_lastTimeRead elapsedTime:newTimeout];
            }
            
            //LogDebug(@"New timeout: %f", newTimeout);
            
            if (_lastTimeRead && newTimeout > timeout)
            {
                // Call timed out
                err = [NSError errorWithDomainAndDescription:LUrlDownloaderErrorDomain
                                                      errorCode:LUrlDownloaderErrorConnectionTimeout
                                           localizedDescription:[NSString stringWithFormat:LightcastLocalizedString(@"Connection timeout (%f)"), newTimeout]];
                
                break;
            }

            // check stream status
            streamStatus = [self handleStreamStatus:&err];
            
            if (!streamStatus)
            {
                break;
            }
        }
        
        if (!self.lastError)
        {
            self.lastError = err;
        }
        
        NSError *err2 = [[self.lastError copy] autorelease];
        
        if (!isSuccessful)
        {
            [self stopWithError:err2];
            ret = NO;
        }
        else
        {
            // verify response code
            ret = [self verifyResponseCode:&err2];
            
            if (!ret) {
                [self stopWithError:err2];
                ret = NO;
            } else {
                ret = YES;
            }
            
            [self internalStopWithState:LUrlDownloadStateNotRunning];
        }
        
        if (error != NULL)
        {
            *error = err2;
        }
        
        return ret;
    }
    else
    {
        // if we are polling - start polling
        
        BOOL shouldContinuePolling = NO;
        BOOL pollSuccess = NO;
        NSError *err = nil;
        
        do
        {
            err = nil;
            
            pollSuccess = [self handleBytesAvailable:&err shouldContinuePolling:&shouldContinuePolling];
            
            if (!pollSuccess)
            {
                break;
            }
            
            // check if we are cancelled
            if (isCancelled)
            {
                _finished = YES;
                break;
            }
            
            // check stream status
            streamStatus = [self handleStreamStatus:&err];
            
            if (!streamStatus)
            {
                self.lastError = err;
                break;
            }
            
            // TODO: Is this a valid value?
            usleep(3600);
        }
        while (shouldContinuePolling && pollSuccess);
        
        if (!self.lastError)
        {
            self.lastError = err;
        }
        
        NSError *err2 = [[self.lastError copy] autorelease];
        
        if (!isSuccessful)
        {
            [self stopWithError:err2];
            ret = NO;
        }
        else
        {
            // verify response code
            ret = [self verifyResponseCode:&err2];
            
            if (!ret) {
                [self stopWithError:err2];
                ret = NO;
            } else {
                ret = YES;
            }
            
            [self internalStopWithState:LUrlDownloadStateNotRunning];
        }
        
        if (error != NULL)
        {
            *error = err2;
        }
        
        return ret;
    }
    
    return NO;
}

- (void)closeConnection
{
    [self resetCfObjects];
    
    // hide the network indicators for iOS
#ifdef TARGET_IOS
    [self changeIOSDeviceProgressIndicators:NO];
#endif
}

- (void)internalStopWithState:(LUrlDownloadState)aDownloadState
{
    @synchronized(_startStopLock)
    {
        if (downloadState == LUrlDownloadStateRunning)
        {
            // close the file stream if opened
            if (downloadPath)
            {
                [self closeFileHandle];
            }
            
            lassert(_stream);
            
            // close the connection
            [self closeConnection];
        }
        
        // change the state
        [self setDownloadState:aDownloadState];
        
        // inform the delegate
        if (downloadDelegate)
        {
            NSError *err = self.lastError;
            
            // if we have an error - notify with the eror method
            if (err != nil)
            {
                if ([downloadDelegate respondsToSelector:@selector(downloader:didFailWithError:)])
                {
                    [downloadDelegate downloader:self didFailWithError:err];
                }
            }
            else
            {
                if ([downloadDelegate respondsToSelector:@selector(downloader:didFinishDownloading:)])
                {
                    [downloadDelegate downloader:self didFinishDownloading:pathToDownloadedFile];
                }
            }
        }
    }
}

- (void)removeDownloadedFile
{
    if (pathToDownloadedFile && !keepDownloadedFile)
    {
        if ([[NSFileManager defaultManager] fileExistsAtPath:pathToDownloadedFile])
        {
            NSError *err = nil;
            BOOL deleted = [[NSFileManager defaultManager] removeItemAtPath:pathToDownloadedFile error:&err];
            lassert(deleted);
            
            if (!deleted)
            {
                LogError(@"Could not remove temp file: %@", pathToDownloadedFile);
            }
        }
    }
}

- (void)updateProgress
{
    if (!responseLength)
    {
        return;
    }
    
    progress = ((float)bytesDownloaded / (float)responseLength)*100.0f;
}

- (NSDictionary*)defaultRequestHeaders
{
    NSDictionary *headers = [NSDictionary dictionaryWithObjectsAndKeys:
                             @"*/*", @"Accept",
                             [LApplicationUtils currentLocale], @"Accept-Language",
                             @"max-age=0", @"Cache-Control",
                             @"-1", @"Expires",
                             @"no-cache", @"Pragma",
                             [NSString stringWithFormat:@"Lightcast %@/LUrlDownloader", LC_VER], @"X-Requested-With"
                             , nil];
    
    return headers;
}

- (void)preparePostData
{
    // TODO: Posting large files with this implementation may break things seriously!
    // Everything is loaded in memory before posting
    // Needs to be reworked - to stream the data out bits by bits
    
    // we can't have both post params and data at the same time
    lassert(!((postParams || postFiles) && postData));
    
    NSData *newPreparedData_ = nil;
    
    // check if we have files for uploading
    // if yes - we have to make a multipart request!
    if (self.postFiles && [self.postFiles count])
    {
        // set a marker
        _isMultipartRequest = YES;
        
        // set a random boundary value
        NSString *boundaryValue = [NSString randomString:15];
        
        if (boundaryValue != _multipartBoundaryValue1)
        {
            L_RELEASE(_multipartBoundaryValue1);
            _multipartBoundaryValue1 = [boundaryValue retain];
        }
        
        // multipart post
        newPreparedData_ = [self combinedMultipartPostData:boundaryValue];
    }
    else if (postParams && [postParams count])
    {
        // normal post
        NSString *postParams_ = postParams ? [self getPostStringForParams:postParams] : nil;
        
        newPreparedData_ = postParams ? [postParams_ dataUsingEncoding:NSUTF8StringEncoding] : nil;
        lassert(newPreparedData_);
    }
    
    //NSString *str = [[[NSString alloc] initWithData:newPreparedData_ encoding:NSUTF8StringEncoding] autorelease];
    //LogDebug(@"DATA: %@", str);
    
    // assign the prepared post data
    if (newPreparedData_ != _preparedPostData)
    {
        L_RELEASE(_preparedPostData);
        _preparedPostData = [newPreparedData_ retain];
    }
}

- (NSData *)combinedMultipartPostData:(NSString *)boundaryValue
{
	NSMutableData * tmpData = [NSMutableData data];
	NSData * bstrData = [[NSString stringWithFormat:@"-----------------------------%@", boundaryValue]
						 dataUsingEncoding:NSUTF8StringEncoding];
	
	// first the POST params
	for (NSString * key in postParams)
	{
		@autoreleasepool
        {
            NSString *val = [NSString stringWithFormat:@"%@", [postParams objectForKey:key]];
            
            if ([NSString isNullOrEmpty:val])
            {
                // skip params with empty value
                continue;
            }
            
            NSString * header = [NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"", [self urlEncodeValue:key]];
            NSString * full = [NSString stringWithFormat:@"%@\r\n\r\n%@\r\n", header, [self urlEncodeValue:val]];
            
            [tmpData appendData:bstrData];
            [tmpData appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            
            NSData * dta = [full dataUsingEncoding:NSUTF8StringEncoding];
            [tmpData appendData:dta];
        }
	}
	
	// then - the FILES
	NSInteger i = 0;
	
	for (LUrlDownloaderPostFile * file in postFiles)
	{
        if (![file isKindOfClass:[LUrlDownloaderPostFile class]])
        {
            lassert(false);
            continue;
        }
        
		@try
		{
			@autoreleasepool
            {
				NSData * fdta = [file getActualData];
                
                if (!fdta)
                {
                    LogWarn(@"No data was read for file - skipping it: %@", file);
                    continue;
                }
                
                NSString *filename = ![NSString isNullOrEmpty:file.filename] ? [file.filename lastPathComponent] : [NSString stringWithFormat:@"file_%ld", (long)i];
                NSString *mimetype = ![NSString isNullOrEmpty:file.mimetype] ? file.mimetype : @"application/binary";
                
                NSString * header = [NSString stringWithFormat:
									 @"Content-Disposition: form-data; name=\"uploaded_file[%ld]\"; filename=\"%@\"",
									 (long)i, [self urlEncodeValue:filename]];
				NSString * full = [NSString stringWithFormat:@"%@\r\nContent-Type: %@", header, mimetype];
				full = [NSString stringWithFormat:@"%@\r\nContent-Transfer-Encoding: binary\r\n\r\n", full];
				
				[tmpData appendData:bstrData];
				[tmpData appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
				
				NSData * dta = [full dataUsingEncoding:NSUTF8StringEncoding];
				[tmpData appendData:dta];
				
				// append the data of the file now
				[tmpData appendData:fdta];
				[tmpData appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
				
				LogDebug(@"Added file to request: %@, size: %ld", filename, (long)[fdta length]);
            }
			
			i++;
		}
		@catch (NSException * e)
		{
            LogError(@"Unhandled exception while preparing HTTP file for posting: %@", e);
            lassert(false);
			continue;
		}
	}
	
	[tmpData appendData:bstrData];
	[tmpData appendData:[@"-----------------------------" dataUsingEncoding:NSUTF8StringEncoding]];
	
	return tmpData;
}

- (NSString*)getPostStringForParams:(NSDictionary*)params
{
    NSString *paramsStr = nil;
    
    if (params)
    {
        NSMutableArray *tmpA = [[NSMutableArray alloc] initWithCapacity:[params count]];
        
        for(NSString *key in params)
        {
            NSString *val = [NSString stringWithFormat:@"%@", [params objectForKey:key]];
            
            if ([NSString isNullOrEmpty:key] || [NSString isNullOrEmpty:val])
            {
                // skip params with empty value
                continue;
            }
            
            NSString *tmp = [NSString stringWithFormat:@"%@=%@",
                             [self urlEncodeValue:key],
                             [self urlEncodeValue:val]
                             ];
            
            [tmpA addObject:tmp];
        }
        
        if ([tmpA count])
        {
            paramsStr = [[[NSString alloc] initWithString:[tmpA componentsJoinedByString:@"&"]] autorelease];
        }
        
        [tmpA release];
    }
    
    return paramsStr;
}

- (NSString *)urlEncodeValue:(NSString *)str
{
    @try {
        NSString *result = (NSString *) CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)str, CFSTR("[]"), CFSTR("?=&+"), kCFStringEncodingUTF8);
        return [result autorelease];
    }
    @catch (NSException *e) {
        lassert(false);
        return nil;
    }
}

- (void)prepareRequestHeaders
{
    // prepare and set the headers
    NSMutableDictionary *headers = [[[NSMutableDictionary alloc] initWithDictionary:[self mergedRequestHeaders]] autorelease];
    
    lassert(headers);
    
    // append User-Agent header
    if (![NSString isNullOrEmpty:userAgent])
    {
        [headers setObject:userAgent forKey:@"User-Agent"];
    }
    
    // gzip / other response decompression
    if (allowCompressedResponse)
    {
        [headers setObject:@"gzip" forKey:@"Accept-Encoding"];
    }
    
    // content-length
    if (requestMethod == LUrlDownloadRequestMethodPost)
    {
        if (postData)
        {
            [headers setObject:[NSString stringWithFormat:@"%lu", (unsigned long)[postData length]] forKey:@"Content-Length"];
        }
        
        // if a multipart request we have a different header
        if (_isMultipartRequest)
        {
            lassert(![NSString isNullOrEmpty:_multipartBoundaryValue1]);
            
            NSString *multipartContentTypeValue = [NSString stringWithFormat:
                           @"multipart/form-data; boundary=---------------------------%@",
                           _multipartBoundaryValue1
                           ];
            
            [headers setValue:multipartContentTypeValue forKey:@"Content-Type"];
        }
        else
        {
            [headers setValue:@"application/x-www-form-urlencoded" forKey:@"Content-Type"];
        } 
    }
    
    // If-Modified-Since
    if (requestIfModifiedSince)
    {
        // format the date
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        df.dateFormat = @"EEE',' dd MMM yyyy HH':'mm':'ss 'GMT'";
        df.locale = [[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] autorelease];
        df.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
        NSString *lastModDT = [df stringFromDate:requestIfModifiedSince];
        [df release];
        
        lassert(lastModDT);
        
        if (lastModDT)
        {
            [headers setValue:lastModDT forKey:@"If-Modified-Since"];
        }
    }
    
    // locale
    if (![NSString isNullOrEmpty:self.requestLocale])
    {
        NSString *localeConverted = [self.requestLocale stringByReplacingOccurrencesOfString:@"_" withString:@"-"];
        
        if (localeConverted)
        {
            [headers setValue:localeConverted forKey:@"Accept-Language"];
        }
    }
    
    // set cookies
    if (cookies && [cookies count])
    {
        NSMutableArray *cookiesTmp = [[[NSMutableArray alloc] init] autorelease];
        
        for(NSString *key in cookies)
        {
            // TODO: Cookies escaping?
            [cookiesTmp addObject:[NSString stringWithFormat:@"%@=%@", key, [cookies objectForKey:key]]];
        }
        
        NSString *cookiesCombined = [cookiesTmp componentsJoinedByString:@"; "];
        
        lassert(cookiesCombined);
        
        if ([cookiesTmp count] && cookiesCombined)
        {
            [headers setObject:cookiesCombined forKey:@"Cookie"];
        }
    }
    
    if (headers != _preparedRequestHeaders)
    {
        L_RELEASE(_preparedRequestHeaders);
        _preparedRequestHeaders = [headers retain];
    }
}

- (void)resetCfObjects
{
    if (_stream)
    {
        CFReadStreamClose(_stream);
        
        if (!pollAndBlockMode)
        {
            CFReadStreamSetClient(_stream, 0, NULL, NULL);
            CFReadStreamUnscheduleFromRunLoop(_stream, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
        }
        
        CFRelease(_stream);
        _stream = nil;
    }
    
    if (_request)
    {
        CFRelease(_request);
        _request = nil;
    }
    
    if (_response)
    {
        CFRelease(_response);
        _response = nil;
    }
}

- (NSError*)getLastError
{
    @synchronized(_lastErrorLock)
    {
        return lastError;
    }
}

- (void)setLastError:(NSError*)error
{
    @synchronized(_lastErrorLock)
    {
        // set the last error
        if (lastError != error)
        {
            L_RELEASE(lastError);
            lastError = [error copy];
        }
    }
}

- (void)stopWithError:(NSError*)error
{
    self.lastError = error;
    
    // process the end result
    [self internalStopWithState:LUrlDownloadStateNotRunning];
}

- (NSString*)downloadRequestMethodDescription:(LUrlDownloadRequestMethod)aDownloadRequestMethod
{
    NSString *description = nil;
    
    switch(aDownloadRequestMethod)
    {
        case LUrlDownloadRequestMethodGet:
        {
            description = @"GET";
            
            break;
        }
        case LUrlDownloadRequestMethodPost:
        {
            description = @"POST";
            
            break;
        }
        default:
        {
            description = nil;
            break;
        }
    }
    
    lassert(description);
    
    return description;
}

- (void)setSSLCertificateVerificationForUrl:(NSURL *)aUrl
{
    if (!aUrl)
    {
        lassert(false);
        return;
    }
    
    lassert(_stream);
    
    // check if this is an ssl url
    if (![[aUrl absoluteString] startsWith:@"https://"])
    {
        return;
    }
    
    CFMutableDictionaryRef securityDictRef = CFDictionaryCreateMutable(
                                                                       kCFAllocatorDefault,
                                                                       0,
                                                                       &kCFTypeDictionaryKeyCallBacks,
                                                                       &kCFTypeDictionaryValueCallBacks);
    
    lassert(securityDictRef);
    
    if (shouldVerifySSLCerfiticate)
    {
        LogDebug(@"SSL VERIFICATION = YES");
        
        // we restrict everything in release mode here
        
        // VERIFY
        // - valid certificate (not expired)
        // - valid root provider
        // - valid name in the certificate (has to match the server name provided in the connection)
        // - specify the highest allowed level of SSL encryption
        // - i believe we don't need to check FINGERPRINT here, because we check for validity of certificate AND name, no?
        
        CFDictionarySetValue(securityDictRef, kCFStreamSSLValidatesCertificateChain, kCFBooleanTrue);
        //CFDictionarySetValue(securityDictRef, kCFStreamSSLAllowsExpiredCertificates, kCFBooleanFalse);
        //CFDictionarySetValue(securityDictRef, kCFStreamSSLAllowsExpiredRoots, kCFBooleanFalse);
        //CFDictionarySetValue(securityDictRef, kCFStreamSSLAllowsAnyRoot, kCFBooleanFalse);
        CFDictionarySetValue(securityDictRef, kCFStreamSSLPeerName, (CFStringRef)[url host]);
        CFDictionarySetValue(securityDictRef, kCFStreamSSLLevel, kCFStreamSocketSecurityLevelNegotiatedSSL);
    }
    else
    {
        LogDebug(@"SSL VERIFICATION = NO");
        
        // ignore invalid SSL certificates (self-generated)
        CFDictionarySetValue(securityDictRef, kCFStreamSSLValidatesCertificateChain, kCFBooleanFalse);
        //CFDictionarySetValue(securityDictRef, kCFStreamSSLAllowsExpiredCertificates, kCFBooleanTrue);
        //CFDictionarySetValue(securityDictRef, kCFStreamSSLAllowsExpiredRoots, kCFBooleanTrue);
        //CFDictionarySetValue(securityDictRef, kCFStreamSSLAllowsAnyRoot, kCFBooleanTrue);
    }
    
    CFReadStreamSetProperty(_stream, kCFStreamPropertySSLSettings, securityDictRef);
    
    if (securityDictRef != NULL)
    {
        CFRelease(securityDictRef);
    }
}

- (CFHTTPAuthenticationRef)httpAuthDetails {
    return _httpAuth;
}

- (void)setProxySettings
{
    CFDictionaryRef proxySettingsDic = CFNetworkCopySystemProxySettings();
    CFReadStreamSetProperty(_stream, kCFStreamPropertyHTTPProxy, proxySettingsDic);
    CFRelease(proxySettingsDic);
}

- (NSDictionary*)mergedRequestHeaders
{
    NSMutableDictionary *mergedHeaders = [[[NSMutableDictionary alloc] init] autorelease];
    
    // get the defaults
    [mergedHeaders addEntriesFromDictionary:[self defaultRequestHeaders]];
    
    // merge with the custom ones if any
    if (requestHeaders && [requestHeaders count])
    {
        [mergedHeaders addEntriesFromDictionary:requestHeaders];
    }
    
    return mergedHeaders;
}

#ifdef TARGET_IOS

- (void)changeIOSDeviceProgressIndicators:(BOOL)shownOrHidden
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        UIApplication* app = [UIApplication sharedApplication];
        
        // hide the network connection icon for iphone
        app.networkActivityIndicatorVisible = shownOrHidden;
        
        // allow sleep
        app.idleTimerDisabled = shownOrHidden;
    });
}

#endif

@end
