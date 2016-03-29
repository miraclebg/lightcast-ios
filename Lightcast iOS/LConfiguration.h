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
 * @changed $Id: LConfiguration.h 357 2015-04-16 06:29:29Z mkovachev $
 * @author $Author: mkovachev $
 * @version $Revision: 357 $
 */

#import <Foundation/Foundation.h>

#define LC_CONFIG_HOLDER_DEEP_CFG_SEPARATOR @"."

@interface LConfiguration : NSObject {
    NSString * name;
    NSMutableDictionary * values;
    NSMutableArray * subnodes;
	
	NSInteger subnodesCount; // only a stub - to compile in 32-bit mode
}

@property (nonatomic, retain, readonly) NSString * name;
@property (nonatomic, retain, retain) NSMutableDictionary * values;
@property (nonatomic, readonly, getter = getValuesCount) NSInteger valuesCount;
@property (nonatomic, retain) NSMutableArray * subnodes;
@property (nonatomic, readonly, getter = getSubnodesCount) NSInteger subnodesCount;


- (id)initWithName:(NSString*)aName;
- (id)initWithName:(NSString*)aName values:(NSDictionary*)someValues;

- (void)addSubnode:(LConfiguration*)subnode;
- (BOOL)removeSubnodeWithName:(NSString*)aName;

- (LConfiguration*)subnodeWithName:(NSString*)aName createIfMissing:(BOOL)shouldCreateIfMissing;
- (LConfiguration*)subnodeWithName:(NSString*)aName;
- (BOOL)hasSubnodeWithName:(NSString*)aName;

- (void)setMany:(NSDictionary *)someValues;
- (void)set:(id)value forKey:(NSString*)key;
- (void)set:(id)value key:(NSString*)key;
- (void)setObject:(id)value forKey:(NSString*)key;
- (id)get:(NSString*)key;
- (void)remove:(NSString*)key;

- (id)initWithNameAndDeepValues:(NSString*)configName deepValues:(NSDictionary*)deepValues;

@end