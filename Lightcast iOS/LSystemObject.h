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
 * @changed $Id: LSystemObject.h 189 2012-12-21 10:37:46Z mkovachev $
 * @author $Author: mkovachev $
 * @version $Revision: 189 $
 */

#import <Foundation/Foundation.h>
#import <Lightcast/LCAppConfiguration.h>
#import <Lightcast/LNotificationDispatcher.h>

@interface LSystemObject : NSObject {
    
@protected
    
    LCAppConfiguration * configuration;
    LNotificationDispatcher* nd;
	
	LConfiguration* defaultConfiguration; // only a stub - to compile in 32-bit mode
}

@property (nonatomic, retain) LConfiguration* configuration;
@property (nonatomic, retain) LNotificationDispatcher* dispatcher;
@property (nonatomic, readonly, getter = getDefaultConfiguration) LConfiguration* defaultConfiguration;

- (BOOL)initialize:(LConfiguration*)aConfiguration notificationDispatcher:(LNotificationDispatcher*)aDispatcher error:(NSError**)error;

+ (id)classFactory:(NSString*)objectName suffix:(NSString*)suffix subclassOf:(Class)subclassName;

- (LConfiguration*)defaultConfiguration;

- (void)didReceiveMemoryWarning:(NSDictionary*)additionalInformation;

@end

extern NSString *const lnSystemObjectInitialized;