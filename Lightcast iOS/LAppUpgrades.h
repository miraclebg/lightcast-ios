//
//  LAppUpgrades.h
//  Lightcast
//
//  Created by Martin N. Kovachev on 21.12.12.
//  Copyright (c) 2012 г. Nimasystems Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const LAppUpgradesErrorDomain;

typedef enum
{
    LAppUpgradesErrorUnknown = 0,
    LAppUpgradesErrorGeneral = 1,
    LAppUpgradesErrorInvalidParams = 2,
    LAppUpgradesErrorInvalidSubclasser = 3,
    LAppUpgradesErrorIO = 10,
    LAppUpgradesErrorVersionMismatch = 20
} LAppUpgradesError;

@interface LAppUpgrades : NSObject

@property (nonatomic, copy) NSString *resourcePath;
@property (nonatomic, copy) NSString *documentsPath;
@property (nonatomic, copy) NSString *temporaryPath;

@property (nonatomic, copy) NSError *lastError;

- (BOOL)runUpgrades:(NSInteger)fromVersion toVersion:(NSInteger)toVersion reachedVersion:(NSInteger*)reachedVersion error:(NSError**)error;

// this method MUST be overriden by subclassers!
- (NSInteger)currentVersion;

// these methods may be overriden by subclassers!
- (BOOL)shouldRunUpgrade:(NSInteger)fromVersion toVersion:(NSInteger)toVersion;
- (BOOL)runBeforeExecute:(NSError**)error;
- (BOOL)runAfterExecute:(NSError**)error;
- (BOOL)runBeforeExecuteUpgrade:(NSString*)method toVersion:(NSInteger)toVersion error:(NSError**)error;
- (BOOL)runAfterExecuteUpgrade:(NSString*)method toVersion:(NSInteger)toVersion error:(NSError**)error;

@end
