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
 * @changed $Id: LAppDatabaseInstance.h 189 2012-12-21 10:37:46Z mkovachev $
 * @author $Author: mkovachev $
 * @version $Revision: 189 $
 */

#import <Foundation/Foundation.h>
#import <Lightcast/LDatabaseSchemaProtocol.h>
#import <Lightcast/LDatabaseAdapter.h>
#import <Lightcast/LCAppConfiguration.h>

@protocol LAppDatabaseInstance <NSObject,LDatabaseSchemaProtocol>

@property (nonatomic,readonly,getter = identifier) NSString *identifier;
@property (nonatomic,readonly,getter = adapterType) NSString *adapterType;
@property (nonatomic,readonly,getter = connectionString) NSString *connectionString;
@property (nonatomic,readonly,getter = dbURL) NSURL *dbURL;

@required

- (NSString*)identifier;
- (NSString*)adapterType;
- (NSString*)connectionString;

- (NSURL*)dbURL;

@optional

- (NSURL*)initialTemplateURL;

- (void)setDatabaseAdapter:(LDatabaseAdapter*)adapter;
- (LDatabaseAdapter*)getDatabaseAdapter;

- (void)setConfiguration:(LCAppConfiguration*)configuration;
- (NSString*)getConfiguration;

@end
