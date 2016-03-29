//
//  LUrlDownloaderDelegate.h
//  Lightcast
//
//  Created by Martin N. Kovachev on 04.01.13.
//  Copyright (c) 2013 г. Nimasystems Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LUrlDownloader;

@protocol LUrlDownloaderDelegate <NSObject>

@optional

- (void)downloaderWillBeginDownloading:(LUrlDownloader*)downloader;
- (void)downloaderDidBeginDownloading:(LUrlDownloader*)downloader;

- (void)downloaderWillBeginConnection:(LUrlDownloader*)downloader url:(NSURL*)url;
- (void)downloaderDidInitializeConnection:(LUrlDownloader*)downloader url:(NSURL*)url;

- (void)downloader:(LUrlDownloader*)downloader didFinishDownloading:(NSString*)downloadLocation;
- (void)downloader:(LUrlDownloader*)downloader didFailWithError:(NSError*)error;

// TODO: Implement this
- (void)downloader:(LUrlDownloader*)downloader didSendData:(NSData*)sentData;

- (void)downloader:(LUrlDownloader*)downloader didDownloadData:(NSData*)downloadedData;

- (void)downloader:(LUrlDownloader*)downloader didRunRunloop:(NSDate*)lastTimeRan elapsedTime:(NSTimeInterval)elapsedTime;

@end
