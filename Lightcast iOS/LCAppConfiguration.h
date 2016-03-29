//
//  LCAppConfiguration.h
//  Lightcast
//
//  Created by Martin N. Kovachev on 21.12.12.
//  Copyright (c) 2012 г. Nimasystems Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Lightcast/LConfiguration.h>

@interface LCAppConfiguration : LConfiguration

@property (nonatomic, copy) NSString *resourcesPath;
@property (nonatomic, copy) NSString *documentsPath;
@property (nonatomic, copy) NSString *temporaryPath;
@property (nonatomic, copy) NSString *libraryPath;
@property (nonatomic, copy) NSString *cachesPath;

- (id)initWithPaths:(NSString*)aResourcesPath documentsPath:(NSString*)aDocumentsPath temporaryPath:(NSString*)aTemporaryPath;
- (id)initWithPaths:(NSString*)aResourcesPath documentsPath:(NSString*)aDocumentsPath temporaryPath:(NSString*)aTemporaryPath libraryPath:(NSString*)aLibraryPath;
- (id)initWithPaths:(NSString*)aResourcesPath documentsPath:(NSString*)aDocumentsPath temporaryPath:(NSString*)aTemporaryPath libraryPath:(NSString*)aLibraryPath cachesPath:(NSString*)aCachesPath;

@end
