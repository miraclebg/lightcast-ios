//
//  LUrlDownloaderPostFile.h
//  Lightcast
//
//  Created by Martin N. Kovachev on 04.01.13.
//  Copyright (c) 2013 г. Nimasystems Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const LUrlDownloaderPostFileDefaultMimetype;

@interface LUrlDownloaderPostFile : NSObject

@property (retain, readonly) NSString *filename;
@property (retain, readonly) NSData *data;

@property (retain, readonly, getter = getMimetype) NSString *mimetype;
@property (readonly, getter = getDataSize) long long dataSize;
@property (retain, readonly, getter = getActualData) NSData *actualData;

- (id)initWithFilename:(NSString*)aFilename;
- (id)initWithData:(NSData*)someData;

- (NSData*)getActualData;

@end
