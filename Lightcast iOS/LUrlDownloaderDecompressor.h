//
//  LUrlDownloaderDecompressor.h
//  Lightcast
//
//  Created by Martin N. Kovachev on 03.04.13.
//  Copyright (c) 2013 г. Nimasystems Ltd. All rights reserved.
//

// Copied and converted from ASIHTTPRequest

#import <Foundation/Foundation.h>
#import <zlib.h>

extern NSInteger const kLUrlDownloaderDecompressorDataChunkSize;
extern NSString *const LUrlDownloaderDecompressorErrorDomain;

typedef enum
{
    LUrlDownloaderDecompressorErrorUnknown = 0,
    LUrlDownloaderDecompressorErrorGeneric = 1,
    LUrlDownloaderDecompressorErrorInvalidParams = 2,
    
    LUrlDownloaderCompressorErrorDecompression = 5,
    
    LUrlDownloaderDecompressorErrorIO = 10
    
} LUrlDownloaderDecompressorError;

@interface LUrlDownloaderDecompressor : NSObject

@property (assign, readonly) BOOL streamReady;

// Convenience constructor will call setupStream for you
+ (id)decompressor;

// Uncompress the passed chunk of data
- (NSData *)uncompressBytes:(Bytef *)bytes length:(NSUInteger)length error:(NSError **)err;

// Convenience method - pass it some deflated data, and you'll get inflated data back
+ (NSData *)uncompressData:(NSData*)compressedData error:(NSError **)err;

// Convenience method - pass it a file containing deflated data in sourcePath, and it will write inflated data to destinationPath
+ (BOOL)uncompressDataFromFile:(NSString *)sourcePath toFile:(NSString *)destinationPath error:(NSError **)err;

// Sets up zlib to handle the inflating. You only need to call this yourself if you aren't using the convenience constructor 'decompressor'
- (NSError *)setupStream;

// Tells zlib to clean up. You need to call this if you need to cancel inflating part way through
// If inflating finishes or fails, this method will be called automatically
- (NSError *)closeStream;

@end
