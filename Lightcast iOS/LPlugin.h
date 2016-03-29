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
 * @changed $Id: LPlugin.h 357 2015-04-16 06:29:29Z mkovachev $
 * @author $Author: mkovachev $
 * @version $Revision: 357 $
 */

#import <Foundation/Foundation.h>
#import <Lightcast/LSystemObject.h>
#import <Lightcast/LPluginBehaviour.h>

#define LERR_DOMAIN_PLUGINS @"plugins.lightcast-ios.nimasystems.com"
#define LERR_PLUGINS_CANT_LOAD 201
#define LERR_PLUGINS_CANT_INITIALIZE 202
#define LERR_PLUGINS_REQUIREMENTS_NOT_MET 203

#define LERR_PLUGINS_USER 301

@interface LPlugin : LSystemObject<LPluginBehaviour> {
    
@private
    
    /** cached version of the name
     */
    NSString * pluginName;
}

@property (nonatomic, retain, readonly) NSString * pluginName;
@property (nonatomic, retain, readonly, getter = version) NSString * version;

+ (BOOL)pluginExists:(NSString*)pluginName;
+ (LPlugin*)pluginFactory:(NSString*)pluginName;

@end
