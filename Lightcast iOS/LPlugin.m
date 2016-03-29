/*
 * Lightcast for iOS Framework
 * Copyright (C) 2007-2011 Nimasystems Ltd
 *
 * This program is NOT free software; you cannot redistribute and/or modify
 * it's sources under any circumstances without the explicit knowledge and
 * agreement of the rightful owner of the software - Nimasystems Ltd.
 *
 * This program is distributed WITHOUT ANY WARRANTY; without even the
 * implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
 * PURPOSE.  See the LICENSE.txt file for more information.
 *
 * You should have received a copy of LICENSE.txt file along with this
 * program; if not, write to:
 * NIMASYSTEMS LTD 
 * Plovdiv, Bulgaria
 * ZIP Code: 4000
 * Address: 95 "Kapitan Raycho" Str., 6th Floor
 * General E-Mail: info@nimasystems.com
 * Tel./Fax: +359 32 395 282
 * Mobile: +359 896 610 876
 */

/**
 * File Description
 * @package File Category
 * @subpackage File Subcategory
 * @changed $Id: LPlugin.m 189 2012-12-21 10:37:46Z mkovachev $
 * @author $Author: mkovachev $
 * @version $Revision: 189 $
 */

#import "LPlugin.h"
#import "LPluginBehaviour.h"

// TODO: Create a separate configuration node for plugins

@implementation LPlugin

@synthesize
pluginName;

#pragma mark - 
#pragma mark Initialization / Finalization

- (id)init {
    self = [super init];
    if (self)
    {
        // abstract class protection
        if (![self conformsToProtocol:@protocol(LPluginBehaviour)])
        {
            [self doesNotRecognizeSelector:_cmd];
            L_RELEASE(self);
            return nil;
        }
        
        // init
        NSString * clName = NSStringFromClass([self class]);
        clName = [clName substringWithRange:NSMakeRange(1, 
                                                        [clName length]-7
                                                        )];
        pluginName = [clName retain];
    }
    return self;
}

- (void)dealloc {
    L_RELEASE(pluginName);
    [super dealloc];
}

#pragma mark - 
#pragma mark LSystemObject Derived

- (NSString*)description {
    return pluginName;
}

#pragma mark - 
#pragma mark Class Factory

+ (BOOL)pluginExists:(NSString*)pluginName {
    
    if (!pluginName) return NO;
    
    NSString * className = [NSString stringWithFormat:@"L%@Plugin", pluginName];
    
    Class class = NSClassFromString(className);
    
    if (![class isSubclassOfClass:[LPlugin class]])
    {
        return NO;
    }
    
    return YES;
}

+ (LPlugin*)pluginFactory:(NSString*)pluginName {
    
    // plugin name consists of 'L[plugin_name]Plugin'
    // what should be passed to this method is only: [plugin_name]
    
    if (![LPlugin pluginExists:pluginName])
    {
        LogError(@"pluginFactory: plugin not found: %@", pluginName);
        return nil;
    }
    
    NSString * className = [NSString stringWithFormat:@"L%@Plugin", pluginName];
    Class class = NSClassFromString(className);
    
    LPlugin<LPluginBehaviour> * instance = [[class alloc] init];
    
    @try 
    {
        NSString * name = instance.pluginName;
        NSString * ver = [instance version];
        
        // validate
        if (!name || ![name length] || !ver || ![ver length])
        {
            LogError(@"pluginFactory: Invalid plugin definitions: %@", pluginName);
            return nil;
        }
    }
    @finally 
    {
        [instance autorelease];
    }
    
    return instance;
}

#pragma mark - LPluginBehaviour Protocol


- (NSString *)version {
	return nil;
}

- (BOOL)checkPluginRequirements:(NSString**)minLightcastVer
                maxLightcastVer:(NSString**)maxLightcastVer
             pluginRequirements:(NSArray**)pluginRequirements {
	
	return NO;
}


@end
