//
//  LAppUpgrades.m
//  Lightcast
//
//  Created by Martin N. Kovachev on 21.12.12.
//  Copyright (c) 2012 г. Nimasystems Ltd. All rights reserved.
//

#import "LAppUpgrades.h"

NSString *const LAppUpgradesErrorDomain = @"com.nimasystems.lightcast.lapp_upgrades";

@implementation LAppUpgrades

@synthesize
resourcePath,
documentsPath,
temporaryPath,
lastError;

#pragma mark - Initialization  Finalization

- (id)init
{
    self = [super init];
    if (self)
    {
        //
    }
    return self;
}

- (void)dealloc
{
    L_RELEASE(resourcePath);
    L_RELEASE(documentsPath);
    L_RELEASE(temporaryPath);
    L_RELEASE(lastError);
    
    [super dealloc];
}

#pragma mark - Methods to be overriden by subclassers

- (NSInteger)currentVersion
{
    return 0;
}

- (BOOL)shouldRunUpgrade:(NSInteger)fromVersion toVersion:(NSInteger)toVersion
{
    return YES;
}

// this method must be overriden by subclassers!
- (NSDictionary*)upgradeSchemaForBuilds
{
    // deprecated
    lassert(false);
    return nil;
}

- (BOOL)runBeforeExecute:(NSError**)error
{
    return YES;
}

- (BOOL)runAfterExecute:(NSError**)error
{
    return YES;
}

- (BOOL)runBeforeExecuteUpgrade:(NSString*)method toVersion:(NSInteger)toVersion error:(NSError**)error
{
    return YES;
}

- (BOOL)runAfterExecuteUpgrade:(NSString*)method toVersion:(NSInteger)toVersion error:(NSError**)error
{
    return YES;
}

#pragma mark - Upgrader methods

- (BOOL)runUpgrades:(NSInteger)fromVersion toVersion:(NSInteger)toVersion reachedVersion:(NSInteger*)reachedVersion error:(NSError**)error
{
    if (error != NULL)
    {
        *error = nil;
    }
    
    if (reachedVersion != NULL)
    {
        *reachedVersion = 0;
    }
    
    self.lastError = nil;
    
    toVersion = toVersion ? toVersion : [self currentVersion];
    
    if (!toVersion || toVersion < fromVersion)
    {
        lassert(false);
        return NO;
    }
    
    if (fromVersion == toVersion)
    {
        // equal versions
        if (reachedVersion != NULL)
        {
            *reachedVersion = toVersion;
        }
        
        return YES;
    }
    
    // check if we should do this
    BOOL ret = [self shouldRunUpgrade:fromVersion toVersion:toVersion];
    
    if (!ret)
    {
        LogInfo(@"AppUpgrades will not run as upgrader object said so!");
        return YES;
    }
    
    BOOL res = NO;
    
    // run beforeExecute
    @try
    {
        res = [self runBeforeExecute:error];
        
        if (!res)
        {
            lassert(false);
            return NO;
        }
    }
    @catch (NSException *e)
    {
        if (error != NULL)
        {
            *error = [NSError errorWithDomainAndDescription:LAppUpgradesErrorDomain
                                                  errorCode:LAppUpgradesErrorGeneral localizedDescription:LightcastLocalizedString(@"Unhandled exception while running beforeExecute upgrades")];
        }
        
        lassert(false);
        return NO;
    }
    
    LogInfo(@"Running sequential upgrades...");
    
    NSInteger counter = 0;
    
    for(counter=fromVersion; counter<=toVersion-1; counter++)
    {
        NSInteger currentVer = counter+1;
        
        NSString *method = [NSString stringWithFormat:@"runUpgradeTo_%d", (int)currentVer];
        lassert(![NSString isNullOrEmpty:method]);
        
        // run custom schema updates (method based)
        SEL selector = NSSelectorFromString(method);
        
        if (![self respondsToSelector:selector])
        {
            continue;
        }
        
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:
                                    [[self class] instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:self];
        
        @try
        {
            [invocation invoke];
        }
        @catch (NSException *e)
        {
            LogError(@"Unhandled exception while upgrading to version: %d: %@", (int)currentVer, e);
            
            if (error != NULL)
            {
                *error = [NSError errorWithDomainAndDescription:LAppUpgradesErrorDomain
                                                      errorCode:LAppUpgradesErrorGeneral localizedDescription:[NSString stringWithFormat:LightcastLocalizedString(@"Unhandled exception while running upgradeTo: %d: %@"), currentVer, e.reason]];
            }
            
            lassert(false);
            return NO;
        }
        
        [invocation getReturnValue:&res];
        
        if (!res)
        {
            LogError(@"Upgrade to build %d has failed: %@", (int)currentVer, self.lastError);
            
            if (error != NULL)
            {
                *error = [NSError errorWithDomainAndDescription:LAppUpgradesErrorDomain
                                                      errorCode:LAppUpgradesErrorGeneral localizedDescription:[NSString stringWithFormat:LightcastLocalizedString(@"Upgrade to build %d has failed: %@"), currentVer, (self.lastError ? [self.lastError localizedDescription] : LightcastLocalizedString(@"Unknown Error"))]];
            }
            
            lassert(false);
            return NO;
        }
        
        // update the reached version
        if (reachedVersion != NULL)
        {
            *reachedVersion = currentVer;
        }
    }
    
    // run afterExecute
    @try
    {
        res = [self runAfterExecute:error];
        
        if (!res)
        {
            lassert(false);
            return NO;
        }
    }
    @catch (NSException *e)
    {
        if (error != NULL)
        {
            *error = [NSError errorWithDomainAndDescription:LAppUpgradesErrorDomain
                                                  errorCode:LAppUpgradesErrorGeneral localizedDescription:LightcastLocalizedString(@"Unhandled exception while running afterExecute upgrades")];
        }
        
        lassert(false);
        return NO;
    }
    
    return YES;
}

@end
