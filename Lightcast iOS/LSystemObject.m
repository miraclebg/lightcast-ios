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
 * @changed $Id: LSystemObject.m 341 2014-08-28 05:21:47Z mkovachev $
 * @author $Author: mkovachev $
 * @version $Revision: 341 $
 */

#import "LSystemObject.h"
#import "LC.h"

@implementation LSystemObject

@synthesize
configuration,
dispatcher=nd,
defaultConfiguration;

#pragma mark - 
#pragma mark Initialization / Finalization

- (id)init {
    self = [super init];
    if (self)
    {
        //
    }
    return self;
}

- (void)dealloc {
    
    L_RELEASE(configuration);
    L_RELEASE(nd);
    [super dealloc];
}

- (BOOL)initialize:(LCAppConfiguration*)aConfiguration notificationDispatcher:(LNotificationDispatcher*)aDispatcher error:(NSError**)error {
	
    LogDebug(@"LSystemObject: initialize: %@", NSStringFromClass([self class]));
    
    if (aConfiguration)
    {
        L_RELEASE(configuration);
        configuration = [aConfiguration retain];
    }

    if (aDispatcher)
    {
        L_RELEASE(nd);
        nd = [aDispatcher retain];
    }
	
#ifdef TARGET_IOS	// iOS Target
	
	// register to receive low memory notifications
	[nd addObserver:self selector:@selector(didReceiveLowMemoryNotification:) name:lnLightcastApplicationDidReceiveMemoryWarning object:nil];

#endif
	
    return YES;
}
             
#pragma mark -
#pragma mark Configuration
             
- (LConfiguration*)defaultConfiguration {
    return [[[LConfiguration alloc] init] autorelease];
}

#pragma mark - Memory Notifications

- (void)didReceiveLowMemoryNotification:(LNotification*)notification {
	
	NSDictionary *object = [NSDictionary dictionaryWithObjectsAndKeys:
							(notification.object ? notification.object : [NSNull null]), @"object",
							nil];
	[self didReceiveMemoryWarning:object];
}

- (void)didReceiveMemoryWarning:(NSDictionary*)additionalInformation {
	
	// do nothing
}

#pragma mark - 
#pragma mark Class Factory

+ (id)classFactory:(NSString*)objectName suffix:(NSString*)suffix subclassOf:(Class)subclass {
   
    if (!objectName) return nil;
    
    NSString * className = [NSString stringWithFormat:@"L%@%@", objectName, suffix];
    
    Class class = NSClassFromString(className);
    
    if (![class isSubclassOfClass:[subclass class]])
    {
        return nil;
    }
    
    id instance = [[class alloc] init];
    
    return [instance autorelease];
}

@end
