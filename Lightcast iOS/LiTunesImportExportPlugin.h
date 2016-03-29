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
 * @changed $Id: LiTunesImportExportPlugin.h 171 2012-03-14 15:08:47Z gpetrov $
 * @author $Author: gpetrov $
 * @version $Revision: 171 $
 */

#import "LPlugin.h"
#import <Lightcast/LPlugin.h>
#import <Lightcast/LPluginBehaviour.h>
#import <Lightcast/LiTunesImportExportPluginDelegate.h>

#define LITUNESIMPORTEXPORTPLUGIN_ERROR_DOMAIN              @"com.nimasystems.lightcast-ios.litunesimportexportplugin"
#define PLUGIN_ERROR_CODE_NIL_PARAMETERS                    1
#define PLUGIN_ERROR_CODE_MERGE_DATABASE_ERROR              2
#define PLIGIN_ERROR_CODE_ARCHIVE_EXPORT                    3

@interface LiTunesImportExportPlugin : LPlugin<LPluginBehaviour, UIAlertViewDelegate> {

    id<LiTunesImportExportPluginDelegate> delegate;
    
    NSFileManager * fileManager;

}
    
@property (nonatomic, retain) id<LiTunesImportExportPluginDelegate> delegate;

- (BOOL)shouldPerformMergeReplaceLogic;
- (BOOL)findArchivedBundles;
- (BOOL)performMerge:(NSError**)error;
- (BOOL)performReplace:(NSError **)error;
- (BOOL)performArchiveExportForItem:(NSString*)itemName error:(NSError**)error;

@end