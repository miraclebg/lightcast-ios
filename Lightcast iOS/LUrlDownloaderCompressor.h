//
//  LUrlDownloaderCompressor.h
//  Lightcast
//
//  Created by Martin N. Kovachev on 03.04.13.
//  Copyright (c) 2013 г. Nimasystems Ltd. All rights reserved.
//

// Copied and converted from ASIHTTPRequest

#import <Foundation/Foundation.h>
#import <zlib.h>

extern NSInteger const kLUrlDownloaderCompressorDataChunkSize;
extern NSInteger const kLUrlDownloaderCompressorCompressionAmount;

extern NSString *const LUrlDownloaderCompressorErrorDomain;

typedef enum
{
    LUrlDownloaderCompressorErrorUnknown = 0,
    LUrlDownloaderCompressorErrorGeneric = 1,
    LUrlDownloaderCompressorErrorInvalidParams = 2,
    
    LUrlDownloaderCompressorErrorCompression = 5,
    
    LUrlDownloaderCompressorErrorIO = 10
    
} LUrlDownloaderCompressorError;

@interface LUrlDownloaderCompressor : NSObject

@property (assign, readonly) BOOL streamReady;

// Convenience constructor will call setupStream for you
+ (id)compressor;

// Compress the passed chunk of data
// Passing YES for shouldFinish will finalize the deflated data - you must pass YES when you are on the last chunk of data
- (NSData *)compressBytes:(Bytef *)bytes length:(NSUInteger)length error:(NSError **)err shouldFinish:(BOOL)shouldFinish;

// Convenience method - pass it some data, and you'll get deflated data back
+ (NSData *)compressData:(NSData*)uncompressedData error:(NSError **)err;

// Convenience method - pass it a file containing the data to compress in sourcePath, and it will write deflated data to destinationPath
+ (BOOL)compressDataFromFile:(NSString *)sourcePath toFile:(NSString *)destinationPath error:(NSError **)err;

// Sets up zlib to handle the inflating. You only need to call this yourself if you aren't using the convenience constructor 'compressor'
- (NSError *)setupStream;

// Tells zlib to clean up. You need to call this if you need to cancel deflating part way through
// If deflating finishes or fails, this method will be called automatically
- (NSError *)closeStream;

@end
