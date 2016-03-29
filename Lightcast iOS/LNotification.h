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
 * @changed $Id: LNotification.h 357 2015-04-16 06:29:29Z mkovachev $
 * @author $Author: mkovachev $
 * @version $Revision: 357 $
 */

#import <Foundation/Foundation.h>

@interface LNotification : NSObject {
    
    NSString* name;
    id object;
    id returnValue;
    BOOL handled;
}

@property (nonatomic, retain, readonly) NSString* name;
@property (nonatomic, retain, readonly) id object;
@property (nonatomic, retain, retain) id returnValue;
@property (nonatomic) BOOL handled;

+ (id)notificationWithName:(NSString*)aName;
+ (id)notificationWithName:(NSString*)aName object:(id)anObject;

@end