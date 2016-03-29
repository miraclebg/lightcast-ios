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
 * @changed $Id: LiTunesImportExportPlugin.m 344 2014-10-03 07:45:12Z mkovachev $
 * @author $Author: mkovachev $
 * @version $Revision: 344 $
 */

#import "LiTunesImportExportPlugin.h"
#import <Lightcast/LSQLiteDatabaseAdapter.h>
#import "LArchiver.h"

@interface LiTunesImportExportPlugin (Private)

- (BOOL) createBackupBundleFromPath:(NSString*)fromPath toPath:(NSString*)toPath error:(NSError**)error;
- (BOOL) archiveBackupBundle:(NSString*)path toPath:(NSString*)toPath withName:(NSString*)name deleteContent:(BOOL)deleteContent error:(NSError**)error;
- (BOOL) deleteContentAtPath:(NSString*)path matchingString:(NSArray*)keyWords excludingContentsWithName:(NSString*)excludeName error:(NSError**)error;
- (NSString *) genereteBundleNameWithPrefix:(NSString*)prefix andHostName:(BOOL)host error:(NSError**)error;
- (BOOL) copyAllItemsAtPath:(NSString*)path toNewBundleNamed:(NSString*)bundleName excludingFilesWithName:(NSString*)name error:(NSError**)error;

- (NSMutableArray*) validateBundlesWithoutLocal:(NSString*)localBundleName;
- (NSArray*) localBundleName;
- (BOOL) mergeBundle:(NSString*)bundle inNewBundle:(NSString*)mainBundle error:(NSError**)mergeError;
- (BOOL) copyFile:(NSString*)atPath toNewPath:(NSString*)toPath fileName:(NSString*)fileName;

- (void) showImporterAlert:(NSNotification*)notification;
- (BOOL) merge:(NSError**)error;
- (BOOL) replace:(NSError**)error;
- (BOOL) changeNewLocalNameInDocs:(NSString*)docDir andLocalPath:(NSArray*)localBundlePath error:(NSError**)error;

- (BOOL) archiveExportWithItem:(NSString*)itemName error:(NSError**)error;
- (BOOL) findArchivedBundlesAtPathAndUnarchive:(NSString*)path error:(NSError**)error;

@end

@implementation LiTunesImportExportPlugin

@synthesize 
delegate;

#pragma mark -
#pragma mark Initialization / Finalization

- (id)init {
    self = [super init];
    if (self)
    {
        fileManager = [[NSFileManager alloc] init];
        delegate = nil;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showImporterAlert:) name:@"kShowImporterAlert" object:nil];
    }
    return self;
}

- (void)dealloc {
    delegate = nil;
    L_RELEASE(fileManager);
    L_RELEASE(configuration);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

#pragma mark -
#pragma mark LPlugin Protocl

- (NSString *)version {
    return @"1.0.0.0";
}

- (LConfiguration*)defaultConfiguration {
    return [[[LConfiguration alloc] initWithNameAndDeepValues:
                                                  @"itunes_config" deepValues:
                                                  [NSDictionary dictionaryWithObjectsAndKeys:
                                                   @"visual_planner", @"bundle_prefix_name",
                                                   [NSNumber numberWithBool:YES], @"process_files",
                                                   [NSNumber numberWithBool:YES], @"process_databases",
                                                   [NSArray arrayWithObjects:
                                                    [NSDictionary dictionaryWithObjectsAndKeys:
                                                     @"./base/database.sqlite", @"connection_string",
                                                     [NSArray arrayWithObjects:
                                                      @"filesystem",
                                                      @"av_category",
                                                      @"av_item",
                                                      @"av_item_file",
                                                      @"activity_category",
                                                      @"activity",
                                                      @"activity_item",
                                                      @"event",
                                                      @"event_activity_item",
                                                      @"event_activity_completed",
                                                      @"note",
                                                      nil], @"tables",
                                                     [NSArray arrayWithObjects:
                                                      [NSArray arrayWithObjects:@"", nil],
                                                      [NSArray arrayWithObjects:@"", nil],
                                                      [NSArray arrayWithObjects:@"av_category", nil],
                                                      [NSArray arrayWithObjects:@"av_item", nil],
                                                      [NSArray arrayWithObjects:@"", nil],
                                                      [NSArray arrayWithObjects:@"activity_category", @"av_item", nil],
                                                      [NSArray arrayWithObjects:@"activity", @"av_item", nil],
                                                      [NSArray arrayWithObjects:@"av_item", nil],
                                                      [NSArray arrayWithObjects:@"event", @"activity", nil],
                                                      [NSArray arrayWithObjects:@"activity", @"event", @"event_activity_item", nil],
                                                      [NSArray arrayWithObjects:@"", nil],
                                                      nil], @"tablesUpdate",
                                                     nil],
                                                    nil], @"databases",
                                                   nil]] autorelease];
}

- (BOOL)checkPluginRequirements:(NSString**)minLightcastVer
                maxLightcastVer:(NSString**)maxLightcastVer
             pluginRequirements:(NSArray**)pluginRequirements {
    
    return NO;
}

- (BOOL)initialize:(LCAppConfiguration*)aConfiguration notificationDispatcher:(LNotificationDispatcher*)aDispatcher error:(NSError**)error {
    
    if ([super initialize:aConfiguration notificationDispatcher:aDispatcher error:error])
    {
        // aConfiguration - will be set to 'self.configuration' if not nil
        // otherwise - self.configuration = [self defaultConfiguration]
        // and you can use it after this line
        
        if (aConfiguration)
        {
            configuration = [aConfiguration retain];
        }
  
        delegate = [self.configuration get:@"delegate"];
        
        LogDebug(@"Current Configuration: %@", self.configuration);
                
        NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
        NSError * pluginError = nil;
        NSString * bundleName = nil;
        NSString * backupBundleName = nil;
        
        NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString * docDir = [paths objectAtIndex:0];
        
        // Generating bundle name
        bundleName = [self genereteBundleNameWithPrefix:[self.configuration get:@"bundle_prefix_name"] andHostName:YES error:&pluginError];
        
        if (pluginError)
        {
            LogError(@"Error generating bundle name %@", [pluginError description]);
            
            if (error != NULL)
            {
                *error = pluginError;
            }
            
            return NO;
        }
                
        // Generating backup name
        backupBundleName = [NSString stringWithFormat:@"backup-%@", bundleName];
        
        NSString * backupFolder = [NSHomeDirectory() stringByAppendingFormat:@"/tmp/%@", backupBundleName];
        
        if (![defaults boolForKey:@"bundle_exists"]) // Old structure - executing logic for creating the new structure
        {
            // Creating of archived backup content
            if (![self createBackupBundleFromPath:docDir toPath:backupFolder error:&pluginError])
            {
                LogError(@"Creating bundle from %@ to %@ filed", 
                         backupFolder, 
                         docDir);
                
                if (error != NULL)
                {
                    *error = pluginError;
                }
                
                [fileManager removeItemAtPath:backupFolder error:nil];
                            
                return NO;
            }
            
            // Deleting all bundles which has -import-export.bundle in their names
            if (![self deleteContentAtPath:docDir matchingString:[NSArray arrayWithObject:@"-import-export.bundle"] excludingContentsWithName:@"backup" error:&pluginError])
            {
                LogError(@"Deleting of all bundles at %@ failed", 
                         backupFolder);
                
                if (error != NULL) 
                {
                    *error = pluginError;
                }
                
                return NO;
            }
            
            // Get a list of all content
            NSError * err = nil;
            NSArray * docContentWithOldStrucure = [fileManager contentsOfDirectoryAtPath:docDir error:&err];
                        
            // Archiving the backup content and then deleting the backup bundle
            if (![self archiveBackupBundle:backupFolder toPath:[docDir stringByAppendingFormat:@"/Backups"] withName:backupBundleName deleteContent:YES error:&pluginError])
            {
                LogError(@"Archiving of bundle %@ from %@ to %@ filed", 
                         backupBundleName, 
                         backupFolder, 
                         [docDir stringByAppendingFormat:@"/Backups"]);

                if (error != NULL) 
                {
                    *error = pluginError;
                }
                
                [fileManager removeItemAtPath:[docDir stringByAppendingFormat:@"/Backups"] error:nil];
                return NO;
            }
            
            // Creating new bundle
            if (![self copyAllItemsAtPath:docDir toNewBundleNamed:[docDir stringByAppendingFormat:@"/%@", bundleName] excludingFilesWithName:@"backup" error:&pluginError])
            {
                LogError(@"Creating of new structure (bundle) from %@ with name %@ failed", 
                         docDir, 
                         bundleName);
                
                if (error != NULL)
                {
                    *error = pluginError;
                }
                                
                return NO;
            }
            
            // Set bundle name, path and existance
            [defaults setBool:YES forKey:@"bundle_exists"];
            [defaults setObject:bundleName forKey:@"bundle_name"];
            [defaults setObject:[NSString stringWithFormat:@"%@/%@", docDir, bundleName] forKey:@"bundle_path"];
            [defaults synchronize];
            
            // Set the new documents path
            if (delegate)
            {
                if ([delegate respondsToSelector:@selector(modifyDocumentsPathWithPath:)])
                {
                    if (![delegate modifyDocumentsPathWithPath:[NSString stringWithFormat:@"%@/%@", docDir, bundleName]])
                    {
                        LogError(@"The new structure path was not updated");
                        
                        if (error != NULL)
                        {
                            *error = pluginError;
                        }
                        
                        return NO;
                    }
                }
            }
            
            // Remove all previous content when done with migrating to new strucuture
            if (!err)
            {
                if (docContentWithOldStrucure)
                {
                    if (![self deleteContentAtPath:docDir matchingString:docContentWithOldStrucure excludingContentsWithName:@"backup" error:&pluginError])
                    {
                        LogError(@"Content from the previous structure was not deleted");
                        
                        if (error != NULL)
                        {
                            *error = pluginError;
                        }
                        
                        return NO;
                    }
                }
            }
        }
        else // Correct structure
        {
            if (delegate)
            {
                if ([delegate respondsToSelector:@selector(modifyDocumentsPathWithPath:)])
                {
                    if (![delegate modifyDocumentsPathWithPath:[[NSUserDefaults standardUserDefaults] objectForKey:@"bundle_path"]])
                    {
                        LogError(@"The new structure path was not updated");
                        
                        if (error != NULL)
                        {
                            *error = pluginError;
                        }
                        
                        return NO;
                    }
                }
            }
        }
    }
    
    return YES;
}

- (BOOL) shouldPerformMergeReplaceLogic {
    
    NSArray * array = nil;
    NSArray * localBundlePath = nil;
    localBundlePath = [self localBundleName]; // localBUndlePath objectAtIndex:0 - Name of the Local Bundle, objectAtIndex:1 - path to the local bundle
    
    LogDebug(@"LocalBUndle %@", localBundlePath);
    
    if (![[localBundlePath objectAtIndex:0] isEqualToString:@""])
    {
        if ([self validateBundlesWithoutLocal:[localBundlePath objectAtIndex:0]]) 
        {
            array = [self validateBundlesWithoutLocal:[localBundlePath objectAtIndex:0]];
            
            LogDebug(@"All Valid Bundles: %@", array);
            
            if ([array count])
            {
                return YES;
            }
        }
    }
    
    return NO;
}

- (BOOL) findArchivedBundles {
    NSError *archivedContentError = nil;
    
    if (![self findArchivedBundlesAtPathAndUnarchive:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] error:&archivedContentError])
    {
        LogError(@"Error while finding archived bundles %@", [archivedContentError description]);
        
        return NO;
    }
    
    return YES;
}

- (BOOL) performMerge:(NSError **)error {
    NSError * mergerErr = nil;
    
    if (![self merge:&mergerErr])
    {
        if (error != NULL)
        {
            *error = mergerErr;
        }
        
        return NO;
    }
    
    return YES;
}

- (BOOL) performReplace:(NSError **)error {
    NSError * replaceErr = nil;
    
    if (![self replace:&replaceErr])
    {
        if (error != NULL)
        {
            *error = replaceErr;
        }
        
        return NO;
    }
    
    return YES;
}

- (BOOL) performArchiveExportForItem:(NSString *)itemName error:(NSError **)error {
    
    if (!itemName)
    {
        if (error != NULL) 
        {
            *error = [NSError errorWithDomain:LITUNESIMPORTEXPORTPLUGIN_ERROR_DOMAIN code:PLUGIN_ERROR_CODE_NIL_PARAMETERS userInfo:[NSDictionary dictionaryWithObject:@"Item to export name must not be nil" forKey:NSLocalizedDescriptionKey]];
        }
        
        return NO;
    }
    
    NSError *archiveExportError = nil;
    
    if (![self archiveExportWithItem:itemName error:&archiveExportError])
    {
        if (error != NULL)
        {
            *error = archiveExportError;
        }
        
        return NO;
    }
    
    return YES;
}

@end

@implementation LiTunesImportExportPlugin (Private)

- (void)showImporterAlert:(NSNotification*)notification {
    
    NSArray * array = nil;
    NSArray * localBundlePath = nil;
    localBundlePath = [self localBundleName]; // localBUndlePath objectAtIndex:0 - Name of the Local Bundle, objectAtIndex:1 - path to the local bundle
    
    LogDebug(@"LocalBUndle %@", localBundlePath);
    if (![[localBundlePath objectAtIndex:0] isEqualToString:@""])
    {
        if ([self validateBundlesWithoutLocal:[localBundlePath objectAtIndex:0]]) 
        {
            array = [self validateBundlesWithoutLocal:[localBundlePath objectAtIndex:0]];
            LogDebug(@"All Valid Bundles: %@", array);
            if ([array count])
            {
                NSString * message = nil;
                if ([array count] == 1)
                {
                    message = [NSString stringWithFormat:@"There is bundle for import, choose action."];
                }
                else
                {
                    message = [NSString stringWithFormat:@"There are bundles for import, choose action."];
                }
                
                UIAlertView * importerAlert = [[UIAlertView alloc] initWithTitle:@"Warning!" message:message delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Merge", @"Replace", nil];
                importerAlert.delegate = self;
                [importerAlert show];
                [importerAlert release];
            }
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0)
    {
        // Cancel
        LogInfo(@"Operation Cancel was tapped.");
    }
    
    if (buttonIndex == 1)
    {
        // Merge
        LogInfo(@"Operation Merge was tapped.");
        
        NSError * mergeError = nil;
        if (![self merge:&mergeError])
        {
            LogError(@"Error occured in merging: %@", [mergeError description]);
        }
    }
    
    if (buttonIndex == 2)
    {
        // Replace
        LogInfo(@"Operation Replace was tapped.");
        
        NSError * replaceError;
        if (![self replace:&replaceError]) 
        {
            LogError(@"Error occured in replacing: %@", [replaceError description]);
        }
    }
}

- (BOOL)merge:(NSError **)error {
    NSArray * array = nil;
    NSArray * localBundlePath = nil;
    localBundlePath = [self localBundleName]; // localBUndlePath objectAtIndex:0 - Name of the Local Bundle, objectAtIndex:1 - path to the local bundle
    
    LogDebug(@"LocalBUndle %@", localBundlePath);
    if (![[localBundlePath objectAtIndex:0] isEqualToString:@""])
    {
        if ([self validateBundlesWithoutLocal:[localBundlePath objectAtIndex:0]]) 
        {
            array = [self validateBundlesWithoutLocal:[localBundlePath objectAtIndex:0]];
            LogDebug(@"All Valid Bundles: %@", array);
            if ([array count])
            {
                
                NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString * docDir = [paths objectAtIndex:0];
                NSString * backupBundlename = [self genereteBundleNameWithPrefix:[self.configuration get:@"bundle_prefix_name"] andHostName:YES error:nil];
                backupBundlename = [NSString stringWithFormat:@"backup-%@", backupBundlename];
                
                NSError * archiveError = nil;
                [self archiveBackupBundle:[localBundlePath objectAtIndex:1] toPath:[docDir stringByAppendingFormat:@"/Backups"] withName:backupBundlename deleteContent:NO error:&archiveError];
                
                if (archiveError)
                {
                    if (error != NULL)
                    {
                        *error = archiveError;
                    }

                    return NO;
                }
                
                for (int i = 0; i < [array count]; i++) 
                {
                    if ([delegate willImportBundle:[array objectAtIndex:i]]) 
                    {
                        NSError * errorMerge = nil;
                        
                        if (![self mergeBundle:[array objectAtIndex:i] inNewBundle:[localBundlePath objectAtIndex:1] error:&errorMerge]) 
                        {
                            if (error != NULL)
                            {
                                *error = errorMerge;
                            }
                            
                            LogError(@"Error in merging: %@", [errorMerge description]);
                            return NO;
                        }
                    }
                }
                
                for (int j = 0; j < [array count]; j++)
                {
                    NSError * err = nil;
                    
                    [fileManager removeItemAtPath:[array objectAtIndex:j] error:&err];
                    if (err)
                    {
                        LogError(@"Error occured while deleting bundle after merging: %@", [err description]);
                    }
                }
            }
            else
            {
                LogInfo(@"No Operation selected.");
            }
        }
    }
    
    return YES;
}

- (BOOL)replace:(NSError **)error {
    NSArray * array = nil;
    NSArray * localBundlePath = nil;
    localBundlePath = [self localBundleName]; // localBUndlePath objectAtIndex:0 - Name of the Local Bundle, objectAtIndex:1 - path to the local bundle
    
    LogDebug(@"LocalBUndle %@", localBundlePath);
    if (![[localBundlePath objectAtIndex:0] isEqualToString:@""])
    {
        if ([self validateBundlesWithoutLocal:[localBundlePath objectAtIndex:0]]) 
        {
            array = [self validateBundlesWithoutLocal:[localBundlePath objectAtIndex:0]];
            LogDebug(@"All Valid Bundles: %@", array);
            
            if ([array count])
            {
                NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString * docDir = [paths objectAtIndex:0];
                NSError * nameError = nil;
                NSString * backupBundlename = [self genereteBundleNameWithPrefix:[self.configuration get:@"bundle_prefix_name"] andHostName:YES error:&nameError];
                
                if (nameError)
                {
					if (error != NULL)
					{
						*error = nameError;
					}
                    
                    return NO;
                }
                
                backupBundlename = [NSString stringWithFormat:@"backup-%@", backupBundlename];
                
                NSError * archiveError = nil;
                
                [self archiveBackupBundle:[localBundlePath objectAtIndex:1] toPath:[docDir stringByAppendingFormat:@"/Backups"] withName:backupBundlename deleteContent:NO error:&archiveError];
                
                if (archiveError)
                {
                    if (error != NULL)
                    {
                        *error = archiveError;
                    }
                    
                    return NO;
                }
                
                if ([array count] > 1)
                {
                    
                    for (int i = 0; i < [array count] - 1; i++) 
                    {
                        if ([delegate willImportBundle:[array objectAtIndex:i]]) 
                        {
                            NSError * errorMerge = nil;
                            if (![self mergeBundle:[array objectAtIndex:i+1] inNewBundle:[array objectAtIndex:0] error:&errorMerge]) 
                            {
                                if (error != NULL)
                                {
                                    *error = errorMerge;
                                }
                                
                                LogError(@"Error in merging: %@", [errorMerge description]);
                                return NO;
                            }
                        }
                    }
                    
                    for (int j = 1; j < [array count]; j++)
                    {
                        NSError * err = nil;
                        
                        [fileManager removeItemAtPath:[array objectAtIndex:j] error:&err];
                        if (err)
                        {
                            LogError(@"Error occured while deleting bundle after merging: %@", [err description]);
                        }
                    }
                    
                    NSError * err1 = nil;
                    NSError * err2 = nil;
                    
                    [fileManager removeItemAtPath:[localBundlePath objectAtIndex:1] error:&err1];
                    if (err1)
                    {
                        LogError(@"Error occured while deleting bundle after merging: %@", [err1 description]);
                    }
                    
                    [fileManager moveItemAtPath:[array objectAtIndex:0] toPath:[docDir stringByAppendingFormat:@"/%@", [localBundlePath objectAtIndex:0]] error:&err2];
                    if (err2)
                    {
                        LogError(@"Error occured while renaming bundle: %@", [err2 description]);
                    }

                    NSError * changeNameError = nil;
                    
                    if (![self changeNewLocalNameInDocs:docDir andLocalPath:localBundlePath error:&changeNameError])
                    {
                        LogError(@"Error occred while changing the name of the bundle after replace: %@", [changeNameError description]);
                    }
                }
                else
                {
                    //remove local, rename the imported with the name of the replaced.
                    NSError * err = nil;
                    NSError * err1 = nil;
                    
                    [fileManager removeItemAtPath:[localBundlePath objectAtIndex:1] error:&err];
                    if (err)
                    {
                        LogError(@"Error occured while deleting bundle after merging: %@", [err description]);
                    }
                    
                    [fileManager moveItemAtPath:[array objectAtIndex:0] toPath:[docDir stringByAppendingFormat:@"/%@", [localBundlePath objectAtIndex:0]] error:&err1];
                    if (err1)
                    {
                        LogError(@"Error occured while renaming bundle: %@", [err1 description]);
                    }

                    NSError * changeNameError = nil;
                    if (![self changeNewLocalNameInDocs:docDir andLocalPath:localBundlePath error:&changeNameError])
                    {
                        LogError(@"Error occred while changing the name of the bundle after replace: %@", [changeNameError description]);
                    }
                }
                
                if (delegate) 
                {
                    if ([delegate respondsToSelector:@selector(modifyDocumentsPathWithPath:)]) 
                    {
                        [delegate modifyDocumentsPathWithPath:[docDir stringByAppendingFormat:@"/%@", [localBundlePath objectAtIndex:0]]];
                    }
                }
            }
            else
            {
                LogInfo(@"No Operation selected.");
            }
        }
    }
    
    return YES;
}

- (BOOL)changeNewLocalNameInDocs:(NSString*)docDir andLocalPath:(NSArray*)localBundlePath error:(NSError **)error {
    
    NSString * newLocalBundle = [docDir stringByAppendingFormat:@"/%@", [localBundlePath objectAtIndex:0]];
    NSError * erroList = nil;
    NSError * err = nil;
    
    NSArray * fileList = [fileManager contentsOfDirectoryAtPath:newLocalBundle error:&erroList];
    if (erroList)
    {
        if (error != NULL)
        {
            *error = erroList;
        }
        
        LogError(@"Error occured while getting all Files in newLocaBundle folder: %@", [erroList description]);
        return NO;
    }
    
    LogDebug(@"All Files in newLocaBundle folder: %@", fileList);
    for (NSString * tmpNewLocal in fileList)
    {
        LogDebug(@"%@", tmpNewLocal);
        
        NSRange fileNameRange = [[tmpNewLocal lowercaseString] rangeOfString:@".dat"];
        
        if (fileNameRange.location != NSNotFound)
        {
            [fileManager removeItemAtPath:[newLocalBundle stringByAppendingFormat:@"/%@", tmpNewLocal] error:&err];
            if (err)
            {
                LogError(@"Error occured while renaming .dat file: %@", [err description]);
            }
            
            // Create hashed name of the bundle
            //NSString * hashedName = [GeneralUtils sha1:[GeneralUtils sha1:[GeneralUtils sha1:[newLocalBundle lastPathComponent]]]];
            NSString * hashedName = [[[[newLocalBundle lastPathComponent] sha1Hash] sha1Hash] sha1Hash];
            NSData * hashedData = [hashedName dataUsingEncoding:NSUTF8StringEncoding];
            
            // Add it to the bundle
            NSString * fullPath = [newLocalBundle stringByAppendingFormat:@"/%@.dat", hashedName]; 
            
            NSError * err1 = nil;
            if (![hashedData writeToFile:fullPath options:NSDataWritingAtomic error:&err1])
            {
                if (error != NULL)
                {
                    *error = err1;
                }
                
                LogError(@"The .dat file with hashed data was not created. Error: \n%@", [err1 description]);
                return NO;
            }
            else
            {
                LogInfo(@"File with name \n%@ and .dat extention was created", hashedName);
            }
        }
    }
    
    return YES;
}

- (BOOL) archiveExportWithItem:(NSString *)itemName error:(NSError **)error {    
    /** Description in task #4503*/
    
    /** Checking for itemName == nil is not needed because it is done in the caller moethod*/
    
    // Get the tmp dir path
    NSString *tmpPath = NSTemporaryDirectory();
    
    // Get the app nema
    NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];
    
    // Compose the app version
    NSString *bundleVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString *revision = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    NSString *appVersion = [NSString stringWithFormat:@"%@.%@", bundleVersion, revision];

    NSDateFormatter *dateFomratter = [[NSDateFormatter alloc] init];
    [dateFomratter setDateFormat:@"yyyy-MM-dd-HH-mm"];
        
    // Get the date
    NSString *dateString = [dateFomratter stringFromDate:[NSDate date]];
    [dateFomratter release];
    
    // Create the archive name
    NSString *archiveName = [NSString stringWithFormat:@"%@_%@_%@_backup", appName, appVersion, dateString];
    
    // Get previously crated achive name (if any)
    NSString *archiveNamePrevious = [[NSUserDefaults standardUserDefaults] objectForKey:@"iTunesArchiveName"];
    
    // Save the newly created archive name
    [[NSUserDefaults standardUserDefaults] setObject:archiveName forKey:@"iTunesArchiveName"];
    
    NSFileManager *fManager = [NSFileManager defaultManager];
    
    // Clear all previous contents if needed
    if (archiveNamePrevious)
    {
        NSError *getContentsError = nil;
        NSArray *tmpDirItems = [fManager contentsOfDirectoryAtPath:[tmpPath stringByAppendingPathComponent:archiveNamePrevious] error:&getContentsError];
                                
        if (!getContentsError)
        {
            for (NSString *item in tmpDirItems)
            {
                NSError *err = nil;
                [fManager removeItemAtPath:[[tmpPath stringByAppendingPathComponent:archiveNamePrevious] stringByAppendingPathComponent:item] error:&err];
                
                if (err)
                {
                    LogError(@"Removing previous content error %@", [err description]);
                }
            }
        }
    }
    
    // Create the archive dir
    NSError *createArchiveDirError = nil;
    if (![fManager createDirectoryAtPath:[tmpPath stringByAppendingPathComponent:archiveName] withIntermediateDirectories:YES attributes:nil error:&createArchiveDirError])
    {
        if (error != NULL)
        {
            *error = createArchiveDirError;
        }
        
        return NO;
    }
    
    // Create the .app file in the archive dir
    NSError *createArchiveAPPFile = nil;
    if (![archiveName writeToFile:[[tmpPath stringByAppendingPathComponent:archiveName] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.app", archiveName]] atomically:YES encoding:NSUTF8StringEncoding error:&createArchiveAPPFile])
    {
        if (error != NULL)
        {
            *error = createArchiveAPPFile;
        }
        
        return NO;
    }
    
    // Copy the current app bundle to the archive folder
    NSError *copyAppBundleError = nil;
    NSString *documentsDirPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    if (![fManager copyItemAtPath:[documentsDirPath stringByAppendingPathComponent:itemName] toPath:[[tmpPath stringByAppendingPathComponent:archiveName] stringByAppendingPathComponent:itemName] error:&copyAppBundleError])
    {
        if (error != NULL)
        {
            *error = copyAppBundleError;
        }
        
        return NO;
    }
    
    // Clear archived content dir in the app Doc folder
    NSError *clearArchiveDocDirError = nil;
    if (![fManager removeItemAtPath:[documentsDirPath stringByAppendingPathComponent:@"iTunes Export ZIP"] error:&clearArchiveDocDirError])
    {
        LogError(@"Error removing iTunes Export ZIP dir %@", [clearArchiveDocDirError description]);
    }
    
    // Create the archived content dir in the Documents
    NSError *archiveDocDirError = nil;
    if (![fManager createDirectoryAtPath:[documentsDirPath stringByAppendingPathComponent:@"iTunes Export ZIP"] withIntermediateDirectories:YES attributes:nil error:&archiveDocDirError])
    {
        if (error != NULL)
        {
            *error = archiveDocDirError;
        }
        
        return NO;
    }
    
    // Archive the content
    NSError *archiveError = nil;
    if (![LArchiver archiveContent:[tmpPath stringByAppendingPathComponent:archiveName] withArchiveName:archiveName andDestination:[documentsDirPath stringByAppendingPathComponent:@"iTunes Export ZIP"] error:&archiveError])
    {
        if (error != NULL)
        {
            *error = archiveError;
        }
        
        return NO;
    }
    
    // Delete the copied bundle and the .app file
    NSError *cleanUpError = nil;
    [fManager removeItemAtPath:[[tmpPath stringByAppendingPathComponent:archiveName] stringByAppendingPathComponent:itemName] error:&cleanUpError];
    
    if (cleanUpError)
    {
        LogError(@"Error while removing copied bundle %@", [cleanUpError description]);
    }
    
    // Delete the .app file
    cleanUpError = nil;
    [fManager removeItemAtPath:[[tmpPath stringByAppendingPathComponent:archiveName] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.app", archiveName]] error:&cleanUpError];
    
    if (cleanUpError)
    {
        LogError(@"Error while removing .app bundle %@", [cleanUpError description]);
    }
    
    return YES;
    
}

- (BOOL)createBackupBundleFromPath:(NSString *)fromPath toPath:(NSString *)toPath error:(NSError **)error {
    
    if (!fromPath || !toPath)
    {
        LogError(@"Paths should not be nil");
        
        if (error != NULL)
        {
            NSMutableDictionary * errorInfo = [NSMutableDictionary dictionary];
            [errorInfo setValue:@"Paths parameters must not be nil (Plguin error code 1)" forKey:NSLocalizedDescriptionKey];
            *error = [NSError errorWithDomain:LITUNESIMPORTEXPORTPLUGIN_ERROR_DOMAIN code:PLUGIN_ERROR_CODE_NIL_PARAMETERS userInfo:errorInfo];
        }
        
        return NO;
    }
    
    NSError * err = nil;
    
    if (![fileManager copyItemAtPath:fromPath toPath:toPath error:&err]) 
    {
        LogError(@"Backup bundle was not created: %@", [err description]);
        
        if (error != NULL)
        {
            *error = err;
        }
        
        return NO;
    }
    
    return YES;
}

- (BOOL) findArchivedBundlesAtPathAndUnarchive:(NSString *)path error:(NSError **)error {    
    NSFileManager *fManager = [NSFileManager defaultManager];
    
    if (!path)
    {
        if (error != NULL)
        {
            NSMutableDictionary *errorInfo = [NSMutableDictionary dictionary];
            [errorInfo setValue:@"Path parameter must not be nil (Plugin error code 1)" forKey:NSLocalizedDescriptionKey];
            *error = [NSError errorWithDomain:LITUNESIMPORTEXPORTPLUGIN_ERROR_DOMAIN code:PLUGIN_ERROR_CODE_NIL_PARAMETERS userInfo:errorInfo];
        }
        
        return NO;
    }
    
    if (![fManager fileExistsAtPath:path])
    {
        if (error != NULL)
        {
            NSMutableDictionary *errorInfo = [NSMutableDictionary dictionary];
            [errorInfo setValue:@"Item do not exists at the specified path (Plugin error code 1)" forKey:NSLocalizedDescriptionKey];
            *error = [NSError errorWithDomain:LITUNESIMPORTEXPORTPLUGIN_ERROR_DOMAIN code:PLUGIN_ERROR_CODE_NIL_PARAMETERS userInfo:errorInfo];
        }
        
        return NO;
    }
    
    // Get the tmp/ path
    NSString *tmpDirPath = NSTemporaryDirectory();
    
    // Get the Documents path
    NSString *docDirPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    // Crate the tmp unarchive directory named /tmpUnarchived
    NSString *tmpUnarchivedDir = [tmpDirPath stringByAppendingPathComponent:@"tmpUnarchived"];
    
    // Check if there are any old contents in the tmp folder
    NSError *tmpUnarchivedContentsError = nil;
    NSArray *tmpUnarchivedContents = [fManager contentsOfDirectoryAtPath:tmpUnarchivedDir error:&tmpUnarchivedContentsError];
    
    if (!tmpUnarchivedContentsError)
    {
        for (NSString *tmpUnarchivedItem in tmpUnarchivedContents)
        {
            NSError *err = nil;
            
            [fManager removeItemAtPath:[tmpUnarchivedDir stringByAppendingPathComponent:tmpUnarchivedItem] error:&err];
            
            if (err)
            {
                LogError(@"Error while removing item %@", [err description]);
            }
        }
    }
    
    // Get the contents of the specified folder
    NSError *contentsError = nil;
    NSArray *contents = [fManager contentsOfDirectoryAtPath:path error:&contentsError];
    
    if (contentsError)
    {
        if (error != NULL)
        {
            *error = contentsError;
        }
        
        return NO;
    }
    
    // Iterate through all items in the specified path
    for (NSString *currentItem in contents)
    {
        // Check if the current item ends with _backup.zip
        if ([currentItem length] > 11)
        {
            NSInteger checkIndex = [currentItem length] - [@"_backup.zip" length];
            
            if ([[currentItem substringFromIndex:checkIndex] isEqualToString:@"_backup.zip"])
            {
                // Create the new item name
                NSString *currentItemName = [currentItem substringToIndex:[currentItem length] - 4];
                
                NSError *unarchiveError = nil;
                if ([LArchiver unarchiveContent:[path stringByAppendingPathComponent:currentItem] toPatht:[tmpUnarchivedDir stringByAppendingPathComponent:currentItemName] error:&unarchiveError])
                {
                    NSString *currentUnarchivedItemPath = [tmpUnarchivedDir stringByAppendingPathComponent:currentItemName];
                    
                    NSError *tmpUnarchivedItemContentsError = nil;
                    NSArray *tmpUnarchivedItemContents = [fManager contentsOfDirectoryAtPath:currentUnarchivedItemPath error:&tmpUnarchivedItemContentsError];
                    
                    if (!tmpUnarchivedItemContentsError)
                    {
                        for (NSString *tmpUnarchivedContentsItem in tmpUnarchivedItemContents)
                        {
                            // Check if there is .app file and if so check if it match the item name
                            if ([tmpUnarchivedContentsItem length] > 4)
                            {
                                if ([[tmpUnarchivedContentsItem substringFromIndex:[tmpUnarchivedContentsItem length] - 4] isEqualToString:@".app"])
                                {
                                    if ([currentItemName isEqualToString:[tmpUnarchivedContentsItem substringToIndex:[tmpUnarchivedContentsItem length] - 4]])
                                    {
                                        // All check passed copy the bundle to the Doc dir
                                        NSError *bundleContentsError = nil;
                                        NSArray *bundleContents = [fManager contentsOfDirectoryAtPath:currentUnarchivedItemPath error:&bundleContentsError];
                                        
                                        if (!bundleContentsError)
                                        {
                                            for (NSString *bundleItem in bundleContents)
                                            {
                                                if ([bundleItem length] > [@".bundle" length])
                                                {
                                                    if ([[bundleItem substringFromIndex:[bundleItem length] - [@".bundle" length]] isEqualToString:@".bundle"])
                                                    {
                                                        //Move the .bundle item
                                                        NSError *moveBundleError = nil;
                                                        if (![fManager moveItemAtPath:[currentUnarchivedItemPath stringByAppendingPathComponent:bundleItem] toPath:[docDirPath stringByAppendingPathComponent:bundleItem] error:&moveBundleError])
                                                        {
                                                            LogError(@"Error while moving the unarchived bundle %@", [moveBundleError description]);
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                else
                {
                    LogError(@"Error while unarchiving item %@ - error - %@", currentItem, [unarchiveError description]);
                }
                
                NSError *removeError = nil;
                [fManager removeItemAtPath:[path stringByAppendingPathComponent:currentItem] error:&removeError];
                
                if (removeError)
                {
                    LogError(@"Error while removing item %@ - error - %@", currentItem, [removeError description]);
                }
            }
        }
    }
    
    return YES;
}

- (BOOL)archiveBackupBundle:(NSString *)path toPath:(NSString *)toPath withName:(NSString *)name deleteContent:(BOOL)deleteContent error:(NSError **)error {
    
    if (!path || !toPath || !name)
    {
        LogError(@"Parameters must not be nil");
        
        if (error != NULL) 
        {
            NSMutableDictionary * errorInfo = [NSMutableDictionary dictionary];
            [errorInfo setValue:@"Method parameters must not be nil (Plguin error code 1)" forKey:NSLocalizedDescriptionKey];
            *error = [NSError errorWithDomain:LITUNESIMPORTEXPORTPLUGIN_ERROR_DOMAIN code:PLUGIN_ERROR_CODE_NIL_PARAMETERS userInfo:errorInfo];
        }
        
        return  NO;
    }
    
    //!TODO correct the LArchiver archiving method to wotk as class method
    NSError * archivingError = nil;
    
    if (![LArchiver archiveContent:path withArchiveName:name andDestination:toPath error:&archivingError])
    {
        LogError(@"Error while archiving: %@", [archivingError localizedDescription]);
        
        if (error != NULL)
        {
            *error = archivingError;
        }
        
        NSError * er = nil;
        
        [fileManager removeItemAtPath:path error:&er];
        
        if (er)
        {
            LogError(@"The back up bundle at %@ was not deleted", path);
        }
        
        return NO;
    }
    
    if (deleteContent)
    {
        NSError * err = nil;
        
        if (![fileManager removeItemAtPath:path error:&err])
        {
            LogError(@"Error deleting the not archived bundle: %@", [err description]);
            
            if (error != NULL)
            {
                *error = err;
            }
            
            err = nil;
            
            if ([fileManager removeItemAtPath:[toPath stringByAppendingFormat:@"/%@", name] error:&err])
            {
                LogInfo(@"The archived bundle was deleted");
            }
            
            return NO;
            
        }  
    }
    
    return YES;
}

- (BOOL) deleteContentAtPath:(NSString*)path matchingString:(NSArray *)keyWords excludingContentsWithName:(NSString *)excludeName error:(NSError **)error {
    
    if (!path || !keyWords || !excludeName)
    {
        LogInfo(@"No path to remove from");
        
        if (error != NULL)
        {
            NSMutableDictionary * errorInfo = [NSMutableDictionary dictionary];
            [errorInfo setValue:@"Method parameters must not be nil (Plguin error code 1)" forKey:NSLocalizedDescriptionKey];
            *error = [NSError errorWithDomain:LITUNESIMPORTEXPORTPLUGIN_ERROR_DOMAIN code:PLUGIN_ERROR_CODE_NIL_PARAMETERS userInfo:errorInfo];
        }
        
        return NO;
    }
        
    NSError * err = nil;
    NSArray * content = [fileManager contentsOfDirectoryAtPath:path error:&err];
    
    if (err)
    {
        LogError(@"Error getting content %@", [err description]);
        
        if (error != NULL)
        {
            *error = err;
        }
    }
    
    for (int i = 0; i < [content count]; i++)
    {
        NSString * fileName = [content objectAtIndex:i];
        NSString * fullPath = [NSString stringWithFormat:@"%@/%@", path, fileName];
        
        for (int j = 0; j < [keyWords count]; j++)
        {
            NSRange fileNameRange = [[fileName lowercaseString] rangeOfString:[[keyWords objectAtIndex:j] lowercaseString]];
            
            if (fileNameRange.location != NSNotFound)
            {
                NSError * err = nil;
                
                NSRange excludeContentRange = [[fileName lowercaseString] rangeOfString:[excludeName lowercaseString]];
                
                if (excludeContentRange.location == NSNotFound)
                {
                    if ([fileManager removeItemAtPath:fullPath error:&err])
                    {
                        LogInfo(@"Bundle from path: \n\"%@\" deleted", fullPath);
                    }
                    else
                    {
                        LogError(@"Error deleting bundle \n\"%@\"\t - %@\n", fileName, [err description]);
                    }
                }
            }
        }
    }

    // The code below runs through all the content within the specified folder recursiviely
    // Since it is too deep it may cause (will cause) deletion of files which should not be deleted
    
    /*NSDirectoryEnumerator * dirEnum = [fileManager enumeratorAtPath:path];
    
    for (NSString *	fileName in dirEnum)
    {
        NSString * fullPath = [NSString stringWithFormat:@"%@/%@", path, fileName];
        
        NSError * attrErr = nil;
        NSDictionary * attributes = [[NSDictionary alloc] init];
        attributes = [fileManager attributesOfItemAtPath:fullPath error:&attrErr];
        
        if (attrErr)
        {
            LogError(@"Error getting attributes at path %@, %@", fullPath, attrErr);
            [attributes release];
            return NO;
        }
        
        for (int j = 0; j < [keyWords count]; j++)
        {
            NSRange fileNameRange = [[fileName lowercaseString] rangeOfString:[[keyWords objectAtIndex:j] lowercaseString]];
            
            if (fileNameRange.location != NSNotFound)
            {
                NSError * err = nil;
                
                if ([fileManager removeItemAtPath:fullPath error:&err])
                {
                    LogInfo(@"Bundle from path \"%@\" deleted", fullPath);
                }
                else
                {
                    LogError(@"Error deleting bundle \"%@\" - %@", fileName, [err description]);
                }
            }
        }
        
        [attributes release];
    }*/
    
    return YES;
}

- (NSString *)genereteBundleNameWithPrefix:(NSString *)prefix andHostName:(BOOL)host error:(NSError **)error {
        
    if (!prefix)
    {
        LogError(@"The prefix should not be nil");
        
        if (error != NULL)
        {
            NSMutableDictionary * errorInfo = [NSMutableDictionary dictionary];
            [errorInfo setValue:@"Prefix must not be nil (Plguin error code 1)" forKey:NSLocalizedDescriptionKey];
            *error = [NSError errorWithDomain:LITUNESIMPORTEXPORTPLUGIN_ERROR_DOMAIN code:PLUGIN_ERROR_CODE_NIL_PARAMETERS userInfo:errorInfo];
        }
        
        return nil;
    }
    
    NSString * bundleName = nil;
    
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init]; //[prefix]-[host name]-21_07_2011-14_33_33-import-export.bundle
    [dateFormatter setDateFormat:@"dd_MM_yyyy-HH_mm_ss"];
    
    NSString * dateString = [dateFormatter stringFromDate:[NSDate date]];
    
    [dateFormatter release];
    
    NSString * hostNameString = nil;
    
    if (host) 
    {
        hostNameString = [[[UIDevice currentDevice] name] stringByReplacingSubstring:@" " withString:@"_"];
        
        bundleName = [NSString stringWithFormat:@"%@-%@-%@-import-export.bundle", prefix, hostNameString, dateString];
    }
    else
    {
        bundleName = [NSString stringWithFormat:@"%@-%@-import-export.bundle", prefix, dateString];
    }
    
    LogInfo(@"Bundle name - \n\"%@\" created", bundleName);
    return bundleName;
}

- (BOOL)copyAllItemsAtPath:(NSString *)path toNewBundleNamed:(NSString *)bundleName excludingFilesWithName:(NSString *)name error:(NSError **)error {
    
    if (!path || !bundleName || !name)
    {
        LogError(@"Method parameters must not be nil");
        
        if (error != NULL)
        {
            NSMutableDictionary * errorInfo = [NSMutableDictionary dictionary];
            [errorInfo setValue:@"Method parameters must not be nil (Plguin error code 1)" forKey:NSLocalizedDescriptionKey];
            *error = [NSError errorWithDomain:LITUNESIMPORTEXPORTPLUGIN_ERROR_DOMAIN code:PLUGIN_ERROR_CODE_NIL_PARAMETERS userInfo:errorInfo];
        }
        
        return NO;
    }
    
    NSError * err = nil;
    NSArray * pathContents = [fileManager contentsOfDirectoryAtPath:path error:&err];
    
    if (err)
    {
        LogError(@"Error getting contents at path: %@", path);
        
        if (error != NULL) 
        {
            *error = err;
        }
        
        return NO;
    }
    
    // Check if destination folder exists and if not create it
    BOOL isDirectory = YES;
    
    err = nil;
    
    if (![fileManager fileExistsAtPath:bundleName isDirectory:&isDirectory]) 
    {         
        if (![fileManager createDirectoryAtPath:bundleName withIntermediateDirectories:NO attributes:nil error:&err])
        {
            LogDebug(@"Can not create destination folder: %@", [err description]);
            
            if (error != NULL)
            {
                *error = err;
            }
            
            return NO;
        }
        
        LogDebug(@"Destination folder created at: \n%@", bundleName);
    }
    
    err = nil;
        
    // Copy all items excluding ones with specified name
    for (int i = 0; i < [pathContents count]; i++)
    {
        NSString * contentName = [pathContents objectAtIndex:i];
        
        NSRange contentRange = [[contentName lowercaseString] rangeOfString:[name lowercaseString]];
        
        if(contentRange.location == NSNotFound)
        {
            err = nil;
            
            NSString * fullPath = [NSString stringWithFormat:@"%@/%@", path, contentName];
            NSString * destinationFullPath = [bundleName stringByAppendingFormat:@"/%@", contentName];
            
            if (![fileManager copyItemAtPath:fullPath toPath:destinationFullPath error:&err])
            {
                LogInfo(@"Content with name \n%@\n was not copied to the new bundle. Error: \n%@", contentName, [err description]);
                
                if (error != NULL)
                {
                    *error = err;
                }
                
                return NO;
            }
        }
        else
        {
            LogInfo(@"Skipping content with name %@", contentName);
        }
    }
    
    // Create hashed name of the bundle
    NSString * hashedName = [[[[bundleName lastPathComponent] sha1Hash] sha1Hash] sha1Hash];
    NSData * hashedData = [hashedName dataUsingEncoding:NSUTF8StringEncoding];
    
    // Add it to the bundle
    NSString * fullPath = [bundleName stringByAppendingFormat:@"/%@.dat", hashedName]; 
    
    if (![hashedData writeToFile:fullPath options:NSDataWritingAtomic error:&err])
    {
        LogError(@"The .dat file with hashed data was not created. Error: \n%@", [err description]);
        
        if (error != NULL)
        {
            *error = err;
        }
        
        return NO;
    }
    else
    {
        LogInfo(@"File with name \n%@ and .dat extention was created", hashedName);
    }

    return YES;
}

- (NSMutableArray*)validateBundlesWithoutLocal:(NSString*)localBundleName {
    NSMutableArray * validBundles = [NSMutableArray array];
    
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 
    NSString * documentsDirectory = [paths objectAtIndex:0];
    
    NSError * error = nil;
    
    NSArray * fileList = [fileManager contentsOfDirectoryAtPath:documentsDirectory error:&error];
    if (error)
    {
        LogError(@"Error occured while getting files: %@", [error description]);
    }
    
    LogDebug(@"All in Documents folder: %@", fileList);
    
    for (NSString * bundle in fileList)
    {
        LogDebug(@"Current file: %@", bundle);
        LogDebug(@"Local Bundle Name: %@", localBundleName);
        LogDebug(@"Current bundle substring: %@", [bundle substringToIndex:6]);
        
        if (![bundle isEqualToString:localBundleName] /*&& (![[bundle substringToIndex:6] isEqualToString:@"backup"])*/) 
        {
            NSInteger length = [bundle length];
            if((length > 20) && ([[bundle substringFromIndex:length-21] isEqualToString:@"-import-export.bundle"]))
            {
                LogDebug(@"Valid bundles %@", bundle);
                LogDebug(@"suffix: %@", [bundle substringFromIndex:length-21]);
                
                NSString * destinationPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", bundle]];  
                if (destinationPath) 
                {   
                    //bundle = [bundle substringToIndex:length-7]; // Uncomment to get only the name of the bundle without the extention.
                    LogDebug(@"%@", bundle);
                    
                    // Check if the bundle is from backup archive and add it to the array with valide bundles
                    if ([[bundle substringToIndex:6] isEqualToString:@"backup"])
                    {
                        [validBundles addObject:destinationPath];
                        
                        continue;
                    }
                    
                    //bundle = [GeneralUtils sha1:[GeneralUtils sha1:[GeneralUtils sha1:bundle]]];
                    bundle = [[[bundle sha1Hash] sha1Hash] sha1Hash];
                    LogDebug(@"SHA1 Bundle: %@", bundle);
                    
                    NSArray * list = [fileManager contentsOfDirectoryAtPath:destinationPath error:&error];
                    for (NSString * fileName in list)
                    {
                        LogDebug(@"The file name is: %@", fileName);
                        NSInteger fileLength = [fileName length];
                        if (fileLength > 4)
                        {
                            fileName = [fileName substringToIndex:fileLength-4];
                            LogDebug(@"File name without dat: %@", fileName);
                        }
                        
                        if ([fileName isEqualToString:bundle])
                        {
                            LogDebug(@"The bundle is valid");
                            [validBundles addObject:destinationPath];
                        }
                        else
                        {
                            LogInfo(@"The bundle is invalid");
                        }
                    }
                }  
            }
            else
            {
                LogInfo(@"The bundle is invalid");
            }
        }
        else
        {
            LogInfo(@"The bundle is invalid");
        }
    }
    return validBundles;
}

- (NSArray*)localBundleName {
    NSMutableArray * localBundleName = [NSMutableArray array];
    
    /*NSString * deviceName = [[[UIDevice currentDevice] name] stringByReplacingSubstring:@" " withString:@"_"];
    LogDebug(@"deviceName: %@", deviceName);
    
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 
    NSString * documentsDirectory = [paths objectAtIndex:0];
    LogDebug(@"documentsDirectory: %@", documentsDirectory);
    
    NSError * error = nil;
    
    NSArray * fileList = [fileManager contentsOfDirectoryAtPath:documentsDirectory error:&error];
    if (error)
    {
        LogError(@"Error occured while getting files: %@", [error description]);
    }
    
    LogDebug(@"File List: %@", fileList);
    
    for (NSString * bundle in fileList)
    {
        //NSString * tmpBundle = [bundle substringWithRange:NSMakeRange(14, [deviceName length])];
        NSRange contentRange = [bundle rangeOfString:deviceName];
        
        // Check if the current file is the database.
        if((contentRange.location != NSNotFound) && (![[bundle substringToIndex:6] isEqualToString:@"backup"]))
        {
            LogDebug(@"TMP Bundle: %@", bundle);
            [localBundleName addObject:bundle];
            [localBundleName addObject:[documentsDirectory stringByAppendingFormat:@"/%@", bundle]];
            LogDebug(@"%@", localBundleName);
        }
    }
    
    LogDebug(@"%@", localBundleName);
    
    if (!localBundleName)
    {
        localBundleName = nil;
    }*/
    
    [localBundleName addObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"bundle_name"]];
    [localBundleName addObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"bundle_path"]];
    
    if (!localBundleName)
    {
        localBundleName = nil;
    }
    
    return localBundleName;
}

- (BOOL)mergeBundle:(NSString*)bundle inNewBundle:(NSString*)mainBundle error:(NSError **)mergeError {
    NSError * error = nil;
    
    LSQLiteDatabaseAdapter * sqlAdapter = nil;
    LSQLiteDatabaseAdapter * sqlAdapterMerged = nil;
    
    NSArray * fileList = [fileManager contentsOfDirectoryAtPath:bundle error:&error];
    
    if (error)
    {
        if (mergeError != NULL)
        {
            *mergeError = error;
        }
        
        return NO;
    }

    for (NSString * tmpBundle in fileList)
    {
        NSRange contentRange = [[tmpBundle lowercaseString] rangeOfString:@".sqlite"];
        NSRange contentRange1 = [[tmpBundle lowercaseString] rangeOfString:@".sqlite~"];
        
        // Check if the current file is the database.
        LogDebug(@"%@", tmpBundle);
        if(contentRange.location != NSNotFound && contentRange1.location == NSNotFound)
        {
            // Getting the path to the database in the new bundle (the bundle wgich is going to be imported).
            NSString * databasePath = [bundle stringByAppendingFormat:@"/Database.sqlite"];
            sqlAdapter = [[LSQLiteDatabaseAdapter alloc] initWithConnectionString:databasePath];
            LogDebug(@"Database path: %@", databasePath);
            
            if (![sqlAdapter open:mergeError])
            {
                return NO;
            }
            
            // Getting the path to the database in the Local bundle.
            NSString * databasePathMerged = [mainBundle stringByAppendingFormat:@"/Database.sqlite"];
            sqlAdapterMerged = [[LSQLiteDatabaseAdapter alloc] initWithConnectionString:databasePathMerged];
            LogDebug(@"Database path: %@", databasePathMerged);
            
            if (![sqlAdapterMerged open:mergeError])
            {
                return NO;
            }
            
            @try 
            {
                /*NSString * tables = @"SELECT name FROM sqlite_master WHERE type IN ('table','view') AND name NOT LIKE 'sqlite_%' UNION ALL SELECT name FROM sqlite_temp_master WHERE type IN ('table','view') ORDER BY 1";
                NSArray * result = [sqlAdapter executeQuery:tables];                
                LogDebug(@"Table Names: %@", result);*/
                
                NSMutableArray * tables = [self.configuration get: @"databases"];
                tables = [[tables objectAtIndex:0] objectForKey:@"tables"];
                LogDebug(@"All tables from the configuration: %@", tables);
                
                NSMutableArray * tablesUpdate = [[[self.configuration get:@"databases"] objectAtIndex:0] objectForKey:@"tablesUpdate"];
                LogDebug(@"%@", [self.configuration get: @"databases"]);
                
                for (int i = 0; i < [tables count]; i++)
                {
                    LogDebug(@"%i", i);
                    LogDebug(@"%d", (int)[tables count]);
                    NSString * primaryKeyQuery = [NSString stringWithFormat:@"SELECT rowid FROM %@", [tables objectAtIndex:i]];
                    LogDebug(@"Current table: %@", [tables objectAtIndex:i]);
                    NSArray * primaryKeys = [sqlAdapter executeQuery:primaryKeyQuery];
                    LogDebug(@"Primary Keys: %@", primaryKeys);
                    
                    NSMutableArray * primaryKey = [NSMutableArray array];
                    
                    for (int j = 0; j < [primaryKeys count]; j++)
                    {
                        [primaryKey addObject:[[primaryKeys objectAtIndex:j] allKeys]];
                    }
                    LogDebug(@"Primary Key: %@", primaryKey);
                    
                    NSArray * newData = nil;
                    NSArray * rowNames = nil;
                    
                    NSString * newDataSelect = [NSString stringWithFormat:@"SELECT * FROM %@", [tables objectAtIndex:i]];
                    LogDebug(@"Current table: %@", [tables objectAtIndex:i]);

                    LogDebug(@"%@", [sqlAdapter executeQuery:newDataSelect]);
                    newData = [sqlAdapter executeQuery:newDataSelect];
                    if ([newData count])
                    {
                        rowNames = [[newData objectAtIndex:0] allKeys];
                        LogDebug(@"New Data for merge: %@", newData);
                        LogDebug(@"Row Names: %@", rowNames);
                    }
                    
                    // This is the select for oldValues of the imported bundle and the same data but with new primary keys.
                    NSMutableArray * oldValues = [NSMutableArray array];
                    NSMutableArray * mergedData = [NSMutableArray array];
                    
                    LogDebug(@"Count of Updated Tables: %@", tablesUpdate);
                    LogDebug(@"Count of Updated Tables: %ld", (long)[[tablesUpdate objectAtIndex:i] count]);
                    
                    if ([[tablesUpdate objectAtIndex:i] count] == 1) 
                    {
                        // Select from the new bundle.
                        NSString * oldValuesSelect = [NSString stringWithFormat:@"SELECT * FROM %@", [tablesUpdate objectAtIndex:i]];
                        oldValuesSelect = [oldValuesSelect stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                        oldValuesSelect = [oldValuesSelect stringByReplacingOccurrencesOfString:@"(    \"" withString:@""];
                        oldValuesSelect = [oldValuesSelect stringByReplacingOccurrencesOfString:@"\")" withString:@""];
                        [oldValues addObject:[sqlAdapter executeQuery:oldValuesSelect]];
                        
                        NSString * oldValuesCountSelect = [NSString stringWithFormat:@"SELECT COUNT(*) AS count FROM %@", [tablesUpdate objectAtIndex:i]];
                        oldValuesCountSelect = [oldValuesCountSelect stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                        oldValuesCountSelect = [oldValuesCountSelect stringByReplacingOccurrencesOfString:@"(    \"" withString:@""];
                        oldValuesCountSelect = [oldValuesCountSelect stringByReplacingOccurrencesOfString:@"\")" withString:@""];
                        NSInteger oldValuesCount = [[[[sqlAdapter executeQuery:oldValuesCountSelect] objectAtIndex:0] objectForKey:@"count"] intValue];
                        
                        NSString * primaryKeyQuery1 = [NSString stringWithFormat:@"SELECT rowid FROM %@", [tablesUpdate objectAtIndex:i]];
                        primaryKeyQuery1 = [primaryKeyQuery1 stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                        primaryKeyQuery1 = [primaryKeyQuery1 stringByReplacingOccurrencesOfString:@"(    \"" withString:@""];
                        primaryKeyQuery1 = [primaryKeyQuery1 stringByReplacingOccurrencesOfString:@"\")" withString:@""];
                        NSArray * primaryKeys1 = [sqlAdapter executeQuery:primaryKeyQuery1];
                        
                        if ([primaryKeys1 count])
                        {
                            NSArray * updateKeys = [[primaryKeys1 objectAtIndex:0] allKeys];
                            primaryKeys1 = [updateKeys objectAtIndex:0];
                            LogDebug(@"Primary Key: %@", primaryKeys1);
                            
                            // Select from the local bundle.
                            // SELECT * FROM filesystem WHERE file_id >  ((SELECT MAX(file_id) FROM filesystem) - 10)
                            NSString * mergedDataSelect = nil;
                            mergedDataSelect = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ > ((SELECT MAX(%@) FROM %@) - %d)", [tablesUpdate objectAtIndex:i], primaryKeys1, primaryKeys1, [tablesUpdate objectAtIndex:i], (int)oldValuesCount];
                            mergedDataSelect = [mergedDataSelect stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                            mergedDataSelect = [mergedDataSelect stringByReplacingOccurrencesOfString:@"(    \"" withString:@""];
                            mergedDataSelect = [mergedDataSelect stringByReplacingOccurrencesOfString:@"\")" withString:@""];
                            [mergedData addObject:[sqlAdapterMerged executeQuery:mergedDataSelect]];
                        }
                        else
                        {
                            // Commented to prevent merging stop
                            //break;
                        }
                    }
                    
                    if ([[tablesUpdate objectAtIndex:i] count] > 1)
                    {
                        for (int tu = 0; tu < [[tablesUpdate objectAtIndex:i] count]; tu++) 
                        {                            
                            // Select from the new bundle.
                            LogDebug(@"%@", [[tablesUpdate objectAtIndex:i] objectAtIndex:tu]);
                            NSString * oldValuesSelect = [NSString stringWithFormat:@"SELECT * FROM %@", [[tablesUpdate objectAtIndex:i] objectAtIndex:tu]];
                            oldValuesSelect = [oldValuesSelect stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                            oldValuesSelect = [oldValuesSelect stringByReplacingOccurrencesOfString:@"(    \"" withString:@""];
                            oldValuesSelect = [oldValuesSelect stringByReplacingOccurrencesOfString:@"\")" withString:@""];
                            [oldValues addObject:[sqlAdapter executeQuery:oldValuesSelect]];
                            
                            NSString * oldValuesCountSelect = [NSString stringWithFormat:@"SELECT COUNT(*) AS count FROM %@", [[tablesUpdate objectAtIndex:i] objectAtIndex:tu]];
                            oldValuesCountSelect = [oldValuesCountSelect stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                            oldValuesCountSelect = [oldValuesCountSelect stringByReplacingOccurrencesOfString:@"(    \"" withString:@""];
                            oldValuesCountSelect = [oldValuesCountSelect stringByReplacingOccurrencesOfString:@"\")" withString:@""];
                            NSInteger oldValuesCount = [[[[sqlAdapter executeQuery:oldValuesCountSelect] objectAtIndex:0] objectForKey:@"count"] intValue];
                            
                            NSString * primaryKeyQuery2 = [NSString stringWithFormat:@"SELECT rowid FROM %@", [[tablesUpdate objectAtIndex:i] objectAtIndex:tu]];
                            primaryKeyQuery2 = [primaryKeyQuery2 stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                            primaryKeyQuery2 = [primaryKeyQuery2 stringByReplacingOccurrencesOfString:@"(    \"" withString:@""];
                            primaryKeyQuery2 = [primaryKeyQuery2 stringByReplacingOccurrencesOfString:@"\")" withString:@""];
                            NSArray * primaryKeys2 = [sqlAdapter executeQuery:primaryKeyQuery2];
                            
                            if ([primaryKeys2 count]) 
                            {
                                NSArray * updateKeys2 = [[primaryKeys2 objectAtIndex:0] allKeys];
                                primaryKeys2 = [updateKeys2 objectAtIndex:0];
                                LogDebug(@"Primary Key: %@", primaryKeys2);
                                
                                // Select from the local bundle.
                                LogDebug(@"%@", [[tablesUpdate objectAtIndex:i] objectAtIndex:tu]);
                                LogDebug(@"%@", primaryKeys2);
                                LogDebug(@"%ld", (long)oldValuesCount);
                                NSString * mergedDataSelect = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ > ((SELECT MAX(%@) FROM %@) - %d)", [[tablesUpdate objectAtIndex:i] objectAtIndex:tu], primaryKeys2, primaryKeys2, [[tablesUpdate objectAtIndex:i] objectAtIndex:tu], (int)oldValuesCount];
                                LogDebug(@"%@", mergedDataSelect);
                                mergedDataSelect = [mergedDataSelect stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                                mergedDataSelect = [mergedDataSelect stringByReplacingOccurrencesOfString:@"(    \"" withString:@""];
                                mergedDataSelect = [mergedDataSelect stringByReplacingOccurrencesOfString:@"\")" withString:@""];
                                [mergedData addObject:[sqlAdapterMerged executeQuery:mergedDataSelect]];
                                LogDebug(@"%@", mergedData);
                            }
                            else
                            {
                                // Commented to prevent merging stop
                                //break;
                            }
                        }
                    }
                                    
                    if ([primaryKey count])
                    {
                        if ([[primaryKey objectAtIndex:0] count])
                        {
                            LogDebug(@"Main Bundle: %@", mainBundle);
                            LogDebug(@"Database: %@", bundle);
                            LogDebug(@"Table Name: %@", [tables objectAtIndex:i]);
                            LogDebug(@"Primary Key: %@", [[primaryKey objectAtIndex:0] objectAtIndex:0]);
                            LogDebug(@"Row Names: %@", rowNames);
                            LogDebug(@"New Data: %@", newData);
                            LogDebug(@"Merged Data: %@", mergedData);
                            
                            if ([delegate willUpdateDatabaseData:mainBundle database:bundle tableName:[tables objectAtIndex:i] primaryKey:[[primaryKey objectAtIndex:0] objectAtIndex:0] rowNames:rowNames newData:&newData mergedData:&mergedData oldValues:&oldValues])
                            {
                                // the operatoin of merging databases is compeleted.
                                LogInfo(@"The merging was succesful");
                            }
                            else
                            {
                                LogError(@"The merging failed");
                                
                                if (mergeError != NULL)
                                {
                                    NSMutableDictionary * errorDescription = [NSMutableDictionary dictionary];
                                    [errorDescription setValue:@"Error in merging databases (Plugin error code: 2)" forKey:NSLocalizedDescriptionKey];
                                    *mergeError = [NSError errorWithDomain:LITUNESIMPORTEXPORTPLUGIN_ERROR_DOMAIN code:PLUGIN_ERROR_CODE_MERGE_DATABASE_ERROR userInfo:errorDescription];
                                }
                                
                                return NO;
                            }
                        }
                    }
                    else
                    {                        
                        if ([delegate willUpdateDatabaseData:mainBundle database:bundle tableName:[tables objectAtIndex:i] primaryKey:nil rowNames:rowNames newData:&newData mergedData:&mergedData oldValues:&oldValues])
                        {
                            // the operatoin of merging databases is compeleted.
                            LogInfo(@"The merging was succesful");
                        }
                        else
                        {
                            LogError(@"The merging failed");
                            
                            if (mergeError != NULL)
                            {
                                NSMutableDictionary * errorDescription = [NSMutableDictionary dictionary];
                                [errorDescription setValue:@"Error in merging databases (Plugin error code: 2)" forKey:NSLocalizedDescriptionKey];
                                *mergeError = [NSError errorWithDomain:LITUNESIMPORTEXPORTPLUGIN_ERROR_DOMAIN code:PLUGIN_ERROR_CODE_MERGE_DATABASE_ERROR userInfo:errorDescription];
                            }
                            
                            return NO;
                        }

                    }
                }
            }
            @catch (NSException *exception) 
            {
                LogError(@"Merging failed: %@", [exception description]);
                
                if (mergeError != NULL)
                {
                    NSMutableDictionary * errorDescription = [NSMutableDictionary dictionary];
                    [errorDescription setValue:[NSString stringWithFormat:@"Error in merging databases (Plugin error code: 2) %@", [exception description]] forKey:NSLocalizedDescriptionKey];
                    *mergeError = [NSError errorWithDomain:LITUNESIMPORTEXPORTPLUGIN_ERROR_DOMAIN code:PLUGIN_ERROR_CODE_MERGE_DATABASE_ERROR userInfo:errorDescription];
                }
                
                return NO;
            }
            @finally 
            {
                L_RELEASE(sqlAdapter);
                L_RELEASE(sqlAdapterMerged);
            }
        }
        else
        {
            if ([tmpBundle isEqualToString:@"vfs"])
            {
                bundle = [bundle stringByAppendingString:@"/vfs/data/"];
                NSArray * fileList = [fileManager contentsOfDirectoryAtPath:bundle error:&error];
                if (error)
                {
                    if (mergeError != NULL)
                    {
                        *mergeError = error;
                    }
                }
                
                LogDebug(@"PWD: %@", bundle);
                for (NSString * tmpFilePath in fileList)
                {
                    LogDebug(@"tmpFilePath: %@", tmpFilePath);
                    //Folders should be processed here.
                    NSString * filePath = [bundle stringByAppendingFormat:@"%@", tmpFilePath];
                    
                    LogDebug(@"File Path: %@", filePath);
                    LogDebug(@"Local Bundle Path: %@", mainBundle);
                    
                    [self copyFile:filePath toNewPath:mainBundle fileName:tmpFilePath];
                }
            }
        }
    }
    
    return YES;
}

- (BOOL)copyFile:(NSString*) atPath toNewPath:(NSString*) toPath fileName:(NSString*)fileName {
    NSError * err = nil;
    NSError * errorDir1 = nil;
    NSError * errorDir2 = nil;
    NSString * vfsPath = [toPath stringByAppendingString:@"/vfs"];
    toPath = [toPath stringByAppendingFormat:@"/vfs/data/%@/", fileName];
    
    LogDebug(@"Copy From Path: %@", atPath);
    LogDebug(@"To Path: %@", toPath);
    
    // Creating /vfs/data if not created.
    [fileManager createDirectoryAtPath:vfsPath withIntermediateDirectories:NO attributes:nil error:&errorDir1];
    [fileManager createDirectoryAtPath:[vfsPath stringByAppendingString:@"/data"] withIntermediateDirectories:NO attributes:nil error:&errorDir2];
    if (errorDir1)
    {
        LogError(@"Error occured while creating folder for vfs data %@", [errorDir1 description]);
    }
    if (errorDir2)
    {
        LogError(@"Error occured while creating folder for vfs data %@", [errorDir2 description]);
    }
    
    // Copying the files.
    [fileManager copyItemAtPath:atPath toPath:toPath error:&err];
    
    if (!err)
    {
        LogInfo(@"Files from %@ were succesfully copied to %@", atPath, toPath);
        return YES;
    }
    else
    {
        LogError(@"Error occured in copying file to the Lcal Bundle: %@", [err description]);
        return NO;
    }
}

@end