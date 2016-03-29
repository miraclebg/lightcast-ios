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
 * @changed $Id: LVirtualFSPlugin.m 346 2014-10-08 12:54:30Z mkovachev $
 * @author $Author: mkovachev $
 * @version $Revision: 346 $
 */

#import "LVirtualFSPlugin.h"
#import "NSFileManager+Additions.h"
#import "LVirtualFile.h"
#import "LC.h"
#import "LVirtualFSSchema.h"

NSString *const LVirtualFSPluginErrorDomain = LERR_DOMAIN_VIRTUALFS;

@interface LVirtualFSPlugin(Private)

- (BOOL)initFS:(NSError**)error;
- (NSString *)randomHash;
- (NSString *)fullFileNameFromHashes:(NSString*)dirHash fileHash:(NSString*)fileHash fileType:(NSString*)fileType;
- (void)initCurrentDirAndCounters;

@end

@implementation LVirtualFSPlugin

@synthesize 
basePath;

#pragma mark -
#pragma mark Initialization / Finalization

- (id)init
{
    self = [super init];
    if (self)
    {
        filesCountInCurrentDir = 0;
        basePath = nil;
        currentDir = nil;
        db = nil;
    }
    return self;
}

- (void)dealloc
{
    L_RELEASE(basePath);
    L_RELEASE(currentDir);
    L_RELEASE(db);
    [super dealloc];
}

- (BOOL)initialize:(LCAppConfiguration*)aConfiguration notificationDispatcher:(LNotificationDispatcher*)aDispatcher error:(NSError**)error {
    
    if ([super initialize:aConfiguration notificationDispatcher:aDispatcher error:error])
    {
        // set the default config
        L_RELEASE(configuration);
        
        if (aConfiguration)
        {
            configuration = [aConfiguration retain];
        }
      
        // check the database
        db = [[LC sharedLC].db retain];
        
        if (!db)
        {
            if (error != NULL)
			{
				NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
				[errorDetail setValue:LightcastLocalizedString(@"VFS requires a database") forKey:NSLocalizedDescriptionKey];
				*error = [NSError errorWithDomain:LERR_DOMAIN_PLUGINS code:LERR_PLUGINS_CANT_INITIALIZE userInfo:errorDetail];
			}
			
            return NO;
        }
        
        // set the base path
        L_RELEASE(basePath);
        //NSString * rPath = [[NSFileManager defaultManager] documentsPath]; old logic with documents path
        
        NSString * rPath = [LC sharedLC].documentsPath;
        rPath = [rPath stringByAppendingPathComponent:[self.configuration get:@"path"]];
        basePath = [rPath retain];
        
        if (![self initFS:error])
        {
            return NO;
        }
        
        LogInfo(@"VFS module started with base path: %@", basePath);
    }
	
    return YES;
}

#pragma mark -
#pragma mark LPlugin Protocl

- (NSString *)version
{
    return @"1.0.0.0";
}

- (LConfiguration*)defaultConfiguration
{
    return [[[LConfiguration alloc] initWithNameAndDeepValues:
             self.pluginName deepValues:
             [NSDictionary dictionaryWithObjectsAndKeys:
              VFS_DEFAULT_BASE_PATH_NAME, @"path",
              [NSNumber numberWithInt:VFS_DEFAULT_FILES_PER_FOLDER], @"files_per_dir",
              nil]] autorelease];
}

- (BOOL)checkPluginRequirements:(NSString**)minLightcastVer
                maxLightcastVer:(NSString**)maxLightcastVer
             pluginRequirements:(NSArray**)pluginRequirements
{
    /**minLightcastVer = @"1.0";
    *maxLightcastVer = @"1.0";
    *pluginRequirements = [NSArray arrayWithObjects:
                           [NSDictionary dictionaryWithObjectsAndKeys:
                            @"non_existing_module", @"name",
                            @"1.3", @"min",
                            @"4.4.4.1", @"max"
                            , nil]
                           , nil];*/

    return NO;
}

- (id<LDatabaseSchemaProtocol>)databaseSchemaInstance
{
	return [[[LVirtualFSSchema alloc] init] autorelease];
}

#pragma mark -
#pragma mark File Operations

- (LVirtualFile *)importFileWithData:(NSData*)data
                            filename:(NSString*)filename
						   extension:(NSString*)extension
                      resourceValues:(NSDictionary*)resourceValues
                               error:(NSError**)error
{
    if (error != NULL)
    {
        *error = nil;
    }
    
    LVirtualFile * lvFile = nil;
    
    if (!data || ![data length])
    {
        if (error != NULL)
        {
            *error = [NSError errorWithDomainAndDescription:LVirtualFSPluginErrorDomain
                                                  errorCode:LVirtualFSPluginErrorInvalidParams
                                       localizedDescription:LLocalizedString(@"No data passed")];
        }
        lassert(false);
        return nil;
    }
    
    if ([NSString isNullOrEmpty:filename])
    {
        if (error != NULL)
        {
            *error = [NSError errorWithDomainAndDescription:LVirtualFSPluginErrorDomain
                                                  errorCode:LVirtualFSPluginErrorInvalidParams
                                       localizedDescription:LLocalizedString(@"No filename")];
        }
        lassert(false);
        return nil;
    }
    
    if ([NSString isNullOrEmpty:extension])
    {
        if (error != NULL)
        {
            *error = [NSError errorWithDomainAndDescription:LVirtualFSPluginErrorDomain
                                                  errorCode:LVirtualFSPluginErrorInvalidParams
                                       localizedDescription:LLocalizedString(@"No extension set")];
        }
        lassert(false);
        return nil;
    }
    
    NSFileManager * fileManager = [NSFileManager defaultManager];
    
    NSInteger fileSize = [data length];
    
    // get a random hash for the file
    NSString * fileHash = [self randomHash];
    lassert(![NSString isNullOrEmpty:fileHash]);
    
    // obtain the file type
    NSString * tmpName = filename;
    
    // get the extension
    NSString * fileType = [NSString stringWithFormat:@".%@", extension];
    
    // check if we have reached the maximum files per folder
    if (filesCountInCurrentDir >= [[self.configuration get:@"files_per_dir"] intValue])
    {
        LogDebug(@"File per dir limit reached - changing folder");
        
        NSString *randHash = [self randomHash];
        
        if (randHash != currentDir)
        {
            L_RELEASE(currentDir);
            currentDir = [randHash retain];
        }
        
        filesCountInCurrentDir = 0;
    }
    
    // this is where we have to write to
    NSString * fullFPath = [self fullFileNameFromHashes:currentDir
                                               fileHash:fileHash
                                               fileType:fileType];
    
    lassert(![NSString isNullOrEmpty:fullFPath]);
    
    @try
    {
        lvFile = [[[LVirtualFile alloc] init] autorelease];
        
        lvFile.fileId = 0;
        lvFile.fileName = tmpName;
        lvFile.dirHash = currentDir;
        lvFile.fileHash = fileHash;
        lvFile.fileType = fileType;
        lvFile.filesize = fileSize;
        //lvFile.pathToVfs = basePath;
        lvFile.pathToVfs = [[LC sharedLC].documentsPath stringByAppendingString:@"/vfs/data"];
        
        // try to create the dir
        NSString * directoryName = [fullFPath stringByDeletingLastPathComponent];
        
        if (![fileManager createDirectoryAtPath:directoryName withIntermediateDirectories:YES attributes:nil error:error])
        {
            [NSException raise:@"Exception" format:LightcastLocalizedString(@"Error"), nil];
        }
        
        // copy to remote path
        if (![data writeToFile:fullFPath options:NSDataWritingAtomic error:error])
        {
            [NSException raise:@"Exception" format:LightcastLocalizedString(@"Error"), nil];
        }
        
        // apply resource values
        if (resourceValues && resourceValues.count)
        {
            NSURL *furl = [NSURL fileURLWithPath:fullFPath];
            
            if (furl)
            {
                [furl setResourceValues:resourceValues error:nil];
            }
        }
        
        BOOL ret = [db executeTransactionalBlock:^BOOL(LDatabaseAdapter *adapter, NSError **error) {
            
            // insert in database
            NSString * cSQL = [NSString stringWithFormat:@"INSERT INTO filesystem (filename,\
                               filetype,\
                               filesize,\
                               created_on,\
                               dir_hash,\
                               file_hash)\
                               VALUES (%@, %@, %lld, %@, %@, %@)",
                               [lvFile.fileName sqlString],
                               [lvFile.fileType sqlString],
                               lvFile.filesize,
                               [[NSDate date] sqlDate],
                               [lvFile.dirHash sqlString],
                               [lvFile.fileHash sqlString]
                               ];
            BOOL res = [db executeStatement:error sql:cSQL];
            
            if (!res) {
                return NO;
            }
            
            lvFile.fileId = [db lastInsertId];
            
            return YES;
        } error:error];
        
        if (!ret) {
            return nil;
        }
        
        filesCountInCurrentDir++;
        
        LogInfo(@"Virtual file created: %@", lvFile);
    }
    @catch (NSException* e)
    {
        // cleanup
        [fileManager removeItemAtPath:fullFPath error:nil];
        
        LogError(@"Unhandled exception while trying to import file: %@", e);
        lassert(false);
        
        if (error != NULL)
        {
            *error = [NSError errorWithDomainAndDescription:LVirtualFSPluginErrorDomain
                                                  errorCode:LVirtualFSPluginErrorGeneric
                                       localizedDescription:[NSString stringWithFormat:LLocalizedString(@"Unhandled exception: %@"), [e reason]]];
        }
        
        return nil;
    }
    
    return lvFile;
}

- (LVirtualFile *)importFileWithData:(NSData*)data
                            filename:(NSString*)filename 
						   extension:(NSString*)extension
                               error:(NSError**)error
{
    return [self importFileWithData:data filename:filename extension:extension resourceValues:nil error:error];
}

- (LVirtualFile*)appendFileDataToVFSFile:(NSInteger)vfsFileId sourceFile:(NSString*)sourceFilePath createIfMissing:(BOOL)createIfMissing error:(NSError**)error
{
    if (error != NULL)
    {
        *error = nil;
    }
    
    if (!vfsFileId || !sourceFilePath)
    {
        lassert(false);
        return nil;
    }
    
    // fetch the file first
    LVirtualFile *file = [self fileById:vfsFileId error:error];
    
    if (!file)
    {
        if (createIfMissing)
        {
            file = [self importFileAtPath:sourceFilePath error:error];
            return file;
        }
        
        return nil;
    }
    
    NSFileHandle *fh1 = nil;
    NSFileHandle *fh2 = nil;
    
    @try
    {
        // open the original file and position to zero
        fh1 = [NSFileHandle fileHandleForReadingAtPath:sourceFilePath];
        
        if (!fh1)
        {
            lassert(false);
            return nil;
        }
        
        [fh1 seekToFileOffset:0];
        
        // open the second file and position to the end
        fh2 = [NSFileHandle fileHandleForWritingAtPath:file.fullFileName];
        
        if (!fh2)
        {
            lassert(false);
            return nil;
        }
        
        [fh2 seekToEndOfFile];
        
        // using a small buffer - copy the data from the source to the destination
        NSInteger bufferSize = 65536; // 64k
        
        NSInteger bytesRead = 0;
        NSInteger totalBytesRead = 0;
        
        do
        {
            @autoreleasepool
            {
                // read into the buffer
                NSData *dataRead = [fh1 readDataOfLength:bufferSize];
                bytesRead = dataRead.length;
                totalBytesRead += bytesRead;
                
                if (bytesRead)
                {
                    // write the data to the receiver - it also advances the position!
                    [fh2 writeData:dataRead];
                }
            }
            
        } while (bytesRead > 0);
        
        // if all is ok - update the VFS file metadata
        file.filesize = file.filesize + totalBytesRead;
        
        // update into the database
        NSString * cSQL = [NSString stringWithFormat:@"UPDATE filesystem \
                           SET \
                           filesize = %lld \
                           WHERE \
                           file_id = %ld",
                           file.filesize,
                           (long)file.fileId
                           ];
        [db exec:cSQL];
        
        // everything is OK
    }
    @catch(NSException *e)
    {
        if (error != NULL)
        {
            *error = [NSError errorWithDomainAndDescription:LERR_DOMAIN_VIRTUALFS
                                                  errorCode:LERR_PLUGIN_VFS_FILE_APPEND_ERROR
                                       localizedDescription:[NSString stringWithFormat:@"%@: %@",
                                                             LightcastLocalizedString(@"Unhandled exception while appending data to VFS file"),
                                                             [e reason]
                                                             ]];
        }
        
        lassert(false);
        
        return nil;
    }
    @finally
    {
        // close the files
        if (fh1)
        {
            [fh1 closeFile];
        }
        
        if (fh2)
        {
            [fh2 closeFile];
        }
    }
    
    return file;
}

- (LVirtualFile *)importFileAtPath:(NSString *)pathToFile
                          filename:(NSString*)filename
                    resourceValues:(NSDictionary*)resourceValues
                             error:(NSError**)error
{
    LVirtualFile* lvFile = nil;
    
    if (!pathToFile) return nil;
    
    @try
    {
        NSFileManager* f = [NSFileManager defaultManager];
        
        // check the file
        if (![f isReadableFileAtPath:pathToFile])
        {
            [NSException raise:@"Exception" format:LightcastLocalizedString(@"Cannot open file for reading"),nil];
        }
        
        NSInteger fSize = [NSFileManager filesize:pathToFile];
        
        // get a random hash for the file
        NSString * fHash = [self randomHash];
        
        // obtain the file type
        NSString * tmpName = filename ? filename : [pathToFile lastPathComponent];
        
        // get the extension
        NSString * fType = filename ? [NSString stringWithFormat:@".%@", [filename fileExtension]] : [NSFileManager fileExtension:pathToFile];
        
        // check if we have reached the maximum files per folder
        NSInteger configMax = [[self.configuration get:@"files_per_dir"] intValue];
        lassert(configMax);
        
        if (filesCountInCurrentDir >= configMax)
        {
            LogDebug(@"File per dir limit reached - changing folder");
            
            L_RELEASE(currentDir);
            currentDir = [[self randomHash] retain];
            filesCountInCurrentDir = 0;
        }
        
        // this is where we have to write to
        NSString * fullFPath = [self fullFileNameFromHashes:currentDir fileHash:fHash fileType:fType];
        
        // try to create the dir
        NSString * dName = [fullFPath stringByDeletingLastPathComponent];
        
        if (![f createDirectoryAtPath:dName withIntermediateDirectories:YES attributes:nil error:error])
        {
            [NSException raise:@"Exception" format:LightcastLocalizedString(@"Error"),nil];
        }
        
        // copy to remote path
        if (![f copyItemAtPath:pathToFile toPath:fullFPath error:error])
        {
            [NSException raise:@"Exception" format:LightcastLocalizedString(@"Error"),nil];
        }
        
        // apply resource values
        if (resourceValues && resourceValues.count)
        {
            NSURL *furl = [NSURL fileURLWithPath:fullFPath];
            
            if (furl)
            {
                [furl setResourceValues:resourceValues error:nil];
            }
        }
        
        lvFile = [[[LVirtualFile alloc] init] autorelease];
        
        lvFile.fileId = 0;
        lvFile.fileName = tmpName;
        lvFile.dirHash = currentDir;
        lvFile.fileHash = fHash;
        lvFile.fileType = fType;
        lvFile.filesize = fSize;
        
        BOOL ret = [db executeTransactionalBlock:^BOOL(LDatabaseAdapter *adapter, NSError **error) {
            
            // insert in database
            NSString * cSQL = [NSString stringWithFormat:@"INSERT INTO filesystem (filename,\
                               filetype,\
                               filesize,\
                               created_on,\
                               dir_hash,\
                               file_hash)\
                               VALUES(%@, %@, %lld, %@, %@, %@)",
                               [lvFile.fileName sqlString],
                               [lvFile.fileType sqlString],
                               lvFile.filesize,
                               [[NSDate date] sqlDate],
                               [lvFile.dirHash sqlString],
                               [lvFile.fileHash sqlString]
                               ];
            
            BOOL res = [db executeDirectStatement:error sql:cSQL];
            
            if (!res) {
                return NO;
            }
            
            // get the autoinc id
            lvFile.fileId = [db lastInsertId];
            lassert(lvFile.fileId);
            
            return YES;
        } error:error];
        
        if (!ret)
        {
            return nil;
        }
        
        filesCountInCurrentDir++;
        
        LogInfo(@"Virtual file created: %@", lvFile);
    }
    @catch (NSException * e)
    {
        lassert(false);
        
        if (error != NULL)
		{
			NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
			[errorDetail setValue:[NSString stringWithFormat:@"%@: %@ (%@)", LightcastLocalizedString(@"Cannot create file:"),
								   [e description], pathToFile] forKey:NSLocalizedDescriptionKey];
			*error = [NSError errorWithDomain:LERR_DOMAIN_VIRTUALFS code:LERR_PLUGIN_VFS_FILE_CREATE_ERROR userInfo:errorDetail];
		}
		
        return nil;
    }
    
    return lvFile;
}

- (LVirtualFile *)importFileAtPath:(NSString *)pathToFile
                    resourceValues:(NSDictionary*)resourceValues
                             error:(NSError**)error
{
    return [self importFileAtPath:pathToFile filename:nil resourceValues:resourceValues error:error];
}

- (LVirtualFile *)importFileAtPath:(NSString *)pathToFile
                             error:(NSError**)error
{
    return [self importFileAtPath:pathToFile resourceValues:nil error:error];
}

- (LVirtualFile *)fileById:(NSInteger)fileId
                     error:(NSError**)error {
    
    // find the vfile in the database
    // fill the object and return it
    
    if (!db) return nil;
	if (!fileId) return nil;
    
    LVirtualFile * f = nil;
    
    @try 
    {
        NSString* sql = [NSString stringWithFormat:@"SELECT filesystem.* FROM filesystem WHERE file_id = %d",
                         (int)fileId];
        NSArray * res = [db executeQuery:sql];
        
        if (![res count])
        {
			if (error != NULL)
			{
				NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
				[errorDetail setValue:LightcastLocalizedString(@"File not found") forKey:NSLocalizedDescriptionKey];
				*error = [NSError errorWithDomain:LERR_DOMAIN_VIRTUALFS code:LERR_PLUGIN_VFS_FILE_NOT_FOUND userInfo:errorDetail];
			}
            
            return nil;
        }
        
        // create a temp holder
        f = [[[LVirtualFile alloc] init] autorelease];
        
        NSDictionary * itm = [res objectAtIndex:0];
        
        f.fileId = [itm intFromSql:@"file_id"];
        f.fileName = [itm stringFromSql:@"filename"];
        f.dirHash = [itm stringFromSql:@"dir_hash"];
        f.fileHash = [itm stringFromSql:@"file_hash"];
        f.fileType = [itm stringFromSql:@"filetype"];
        f.filesize = [itm intFromSql:@"filesize"];
        //f.pathToVfs = basePath;
        f.pathToVfs = [[LC sharedLC].documentsPath stringByAppendingString:@"/vfs/data"];
        f.createdOn = [LDateTimeUtils dateFromString:[itm objectForKey:@"created_on"] dateFormat:SQL_DATETIME_FORMAT];
    }
    @catch (NSException * e)
    {
        if (error != NULL)
		{
			NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
			[errorDetail setValue:[NSString stringWithFormat:@"%@: %@", LightcastLocalizedString(@"Cannot load file:"), [e description]] forKey:NSLocalizedDescriptionKey];
			*error = [NSError errorWithDomain:LERR_DOMAIN_VIRTUALFS code:LERR_PLUGIN_VFS_FILE__LOAD_ERROR userInfo:errorDetail];
		}
		
        return nil;
    }
    
    return f;
}

- (BOOL)removeFileById:(NSInteger)fileId
                 error:(NSError**)error {
    
    if (error != NULL)
    {
        *error = nil;
    }
    
    if (!fileId)
    {
        lassert(false);
        return NO;
    }
    
    @try 
    {
        // fetch it first
        LVirtualFile* f = [self fileById:fileId error:error];
        
        if (!f)
        {
            return NO;
        }
        
        // delete from database
        NSString * sql = [NSString stringWithFormat:@"DELETE FROM filesystem WHERE file_id = %d", (int)fileId];
        [db exec:sql];
        
        // @todo - affected rows???
        
        // remove it from the local filesystem
        NSFileManager* fs = [NSFileManager defaultManager];
        
        if ([fs fileExistsAtPath:f.fullPath])
        {
            BOOL removed = [fs removeItemAtPath:f.fullPath error:error];
            
            if (!removed)
            {
                return NO;
            }
        }
    }
    @catch (NSException* e) 
    {
        if (error != NULL)
		{
			NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
			[errorDetail setValue:[NSString stringWithFormat:@"%@: %@", LightcastLocalizedString(@"Cannot remove file:"), [e description]] forKey:NSLocalizedDescriptionKey];
			*error = [NSError errorWithDomain:LERR_DOMAIN_VIRTUALFS code:LERR_PLUGIN_VFS_FILE__REMOVE_ERROR userInfo:errorDetail];
		}
		
		return NO;
    }
    
    return YES;
}

- (NSDictionary *)vfsStats {
    
    NSString * sql = @"SELECT \
    (SELECT Count(filesystem.file_id) FROM filesystem) AS total_files,\
    (SELECT SUM(filesystem.filesize) FROM filesystem) AS total_filesize";

    NSArray * res = [db executeQuery:sql];
    
    if (![res count]) return nil;
    
    id totalFiles = [[res objectAtIndex:0] objectForKey:@"total_files"];
    id totalFilesize = [[res objectAtIndex:0] objectForKey:@"total_filesize"];
    
    NSDictionary * ret = [NSDictionary dictionaryWithObjectsAndKeys:
                          [NSNumber numberWithInt:([totalFiles isEqual:[NSNull null]] ? 0 : [totalFiles intValue])],
                          @"total_files",
                          [NSNumber numberWithInt:([totalFilesize isEqual:[NSNull null]] ? 0 : [totalFilesize intValue])],
                          @"total_filesize",
                          nil];
    
    return ret;
}

#pragma mark -
#pragma mark Private Methods

- (BOOL)initFS:(NSError**)error {
    
    if (!db) return NO;
    
    // find the next dir to write in
    
    
    // create the base folder, skip if already there
    NSFileManager * fm = [NSFileManager defaultManager];
    
    //BOOL res = [fm createDirectoryAtPath:basePath withIntermediateDirectories:YES attributes:nil error:error];
    BOOL res = [fm createDirectoryAtPath:[[LC sharedLC].documentsPath stringByAppendingString:@"/vfs/data"] withIntermediateDirectories:YES attributes:nil error:error];
    
    if (!res)
    {
        LogError(@"Cannot initialize VFS: %@", [*error description]);
        return NO;
    }
    
    [self initCurrentDirAndCounters];
    
    return YES;
}

- (void)initCurrentDirAndCounters {
    
    L_RELEASE(currentDir);
    filesCountInCurrentDir = 0;
    
    // fetch the last file's dir hash
    NSString * sql = [NSString stringWithFormat:@"SELECT dir_hash FROM filesystem ORDER BY file_id DESC LIMIT 1"];
    NSArray * res = [db executeQuery:sql];
    
    NSString* currentHash = nil;
    NSInteger currentCount = 0;
    
    // there is at least one file with a hash
    if ([res count]) 
    {
        currentHash = [[res objectAtIndex:0] objectForKey:@"dir_hash"];
        
        if (!currentHash || [currentHash isEqual:[NSNull null]] || [currentHash length] < 1)
        {
            currentHash = nil;
            currentCount = 0;
        }
        else 
        {
            // check if we need to get a new hash if filecount will pass the limit
            sql = [NSString stringWithFormat:@"SELECT Count(filesystem.file_id) AS counted FROM filesystem WHERE dir_hash = %@",
                   [currentHash sqlString]];
            res = [db executeQuery:sql];
            
            if ([res count])
            {
                currentCount = [[[res objectAtIndex:0] objectForKey:@"counted"] intValue];
                
                if (currentCount+1 > [[self.configuration get:@"files_per_dir"] intValue])
                {
                    currentHash = nil;
                    currentCount = 0;
                }
            }
            else 
            {
                currentHash = nil;
                currentCount = 0;
            }
        }
    }
    
    // get a new hash
    if (!currentHash)
    {
        currentHash = [self randomHash];
    }
    
    currentDir = [currentHash retain];
    filesCountInCurrentDir = currentCount;
    
    LogDebug(@"Current dir: %@ (%d)", currentDir, (int)filesCountInCurrentDir);
}

- (NSString *)randomHash {
    
	//long seed = (long) [[NSDate date] timeIntervalSince1970];
	//float ref1 = (((seed= 1664525*seed + 1013904223)>>16) / (float)0x10000);
	//float ref2 = (((seed= 1664525*seed + 1013904223)>>16) / (float)0x10000);
	//float randNum1 = ref1 * 74;
	//float randNum2 = ref2 * 74;
	
	int randNum1 = arc4random();
	int randNum2 = arc4random();
	
	NSString * str = [NSString stringWithFormat:@"%d-%d", randNum1, randNum2];
    str = str.md5Hash;
    
    return str;
}

- (NSString *)fullFileNameFromHashes:(NSString*)dirHash fileHash:(NSString*)fileHash fileType:(NSString*)fileType {
    
    if (!dirHash || !fileHash || !fileType) return nil;
    
    //NSString * p = [NSString stringWithString:basePath];
    NSString * p = [NSString stringWithString:[[LC sharedLC].documentsPath stringByAppendingString:@"/vfs/data"]];
    p = [p stringByAppendingPathComponent:dirHash];
    p = [p stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@", fileHash, fileType]];
    
    return p;
}

@end
