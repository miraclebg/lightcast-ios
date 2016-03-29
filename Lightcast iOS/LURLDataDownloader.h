//
//  LURLDataDownloader.h
//  Lightcast
//
//  Created by Martin Kovachev on 04.02.14.
//  Copyright (c) 2014 г. Nimasystems Ltd. All rights reserved.
//

#import <Lightcast/LURLDownloader.h>

extern NSTimeInterval const kLURLDataDownloaderDefaultTimeout;

@class LURLDataDownloader;

@protocol LURLDataDownloaderDelegate <NSObject>

@optional

- (void)dataDownloader:(LURLDataDownloader*)downloader didDownloadData:(NSURL*)url downloadedUrl:(NSURL*)downloadedUrl;
- (void)dataDownloader:(LURLDataDownloader*)downloader didFailToDownloadData:(NSURL*)url error:(NSError*)error;

@end

@interface LURLDataDownloader : NSObject

@property (nonatomic, copy) NSString *cacheDir;
@property (nonatomic, readonly, retain) NSURL *url;

@property (nonatomic, assign) NSTimeInterval timeout;

@property (nonatomic, readonly, retain) LUrlDownloader *downloader;

@property (nonatomic, retain, readonly) NSURL *downloadedUrl;

- (id)initWithUrl:(NSURL*)url;

+ (LURLDataDownloader*)downloadedUrlData:(NSURL*)url cacheDir:(NSString*)cacheDir;

- (BOOL)startDownloading:(NSError**)error;

@end
