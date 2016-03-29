//
//  LArchiver.m
//  Zipping
//
//  Created by Georgi Petrov on 7/25/11.
//  Copyright 2011 Nimasystems Ltd. All rights reserved.
//

#import "LArchiver.h"
#import "ZipFile.h"
#import "ZipException.h"
#import "ZipWriteStream.h"
#import "ZipReadStream.h"
#import "FileInZipInfo.h"

@implementation LArchiver

+ (BOOL)archiveContent:(NSString *)filePath withArchiveName:(NSString *)zipName andDestination:(NSString *)destinationPath error:(NSError **)error {
    
    if (!filePath)
    {
        LogDebug(@"No such file to archive");
        
        if (error != NULL)
        {
            NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
            [errorDetails setValue:@"No content for archiving. (LArchiver error code 1)" forKey:NSLocalizedDescriptionKey];
            
            *error = [NSError errorWithDomain:LARCHIVER_ERROR_DOMAIN code:LARCHIVER_ERROR_CODE_NO_FILE userInfo:errorDetails];
        }
        
        return NO;
    }
    
    if (!zipName)
    {
        LogDebug(@"No archive name");
        
        if (error != NULL)
        {
            NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
            [errorDetails setValue:@"No archive name was set. (LArchiver error code 2)" forKey:NSLocalizedDescriptionKey];
            
            *error = [NSError errorWithDomain:LARCHIVER_ERROR_DOMAIN code:LARCHIVER_ERROR_CODE_NO_ARCHIVE_NAME userInfo:errorDetails];
        }
        
        return NO;
    }
    
    if (!destinationPath)
    {
        LogDebug(@"No destination path");
        
        if (error != NULL)
        {
            NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
            [errorDetails setValue:@"No destination path was specified. (LArchiver error code 3)" forKey:NSLocalizedDescriptionKey];
            
            *error = [NSError errorWithDomain:LARCHIVER_ERROR_DOMAIN code:LARCHIVER_ERROR_CODE_NO_DESTIONATION_PATH userInfo:errorDetails];
        }
        
        return NO; 
    }
    
    // Check if the zipName has .zip extention and if not add it
    if (![[zipName substringFromIndex:[zipName length] - 4] isEqualToString:@".zip"]) 
    {
        zipName = [zipName stringByAppendingFormat:@".zip"];
        LogDebug(@"Archive extention doesn't mach adding correct one - %@", zipName);
    }
    
    @try 
    {
        // Check if destination folder exists and if not create it
        NSFileManager * fileManager = [[[NSFileManager alloc] init] autorelease];
        BOOL isDirectory = YES;
        
        if (![fileManager fileExistsAtPath:destinationPath isDirectory:&isDirectory]) 
        {            
            NSError * err = nil;
            
            if (![fileManager createDirectoryAtPath:destinationPath withIntermediateDirectories:YES attributes:nil error:&err])
            {
                LogDebug(@"Can not create destination folder: %@", [err description]);
                
                if (error != NULL)
                {
                    *error = err;
                }
                
                return NO;
            }
            
            LogDebug(@"Destination folder created at: %@", destinationPath);
        }
        
        // Creating archive to destination path
        NSString * archiveName = [NSString stringWithFormat:@"%@/%@", destinationPath, zipName];
        ZipFile * archive = [[[ZipFile alloc] initWithFileName:archiveName mode:ZipFileModeCreate] autorelease];
        
        LogDebug(@"Archive with name \n\t\"%@\"\tcrated", archiveName);
        
        /*// Index of the first letter after the last / in the filePath string
        int nameFirstLetter = 0;
        
        for (int i = 1; i < [filePath length]; i++)
        {
            if ([[filePath substringWithRange:NSMakeRange([filePath length] - i, 1)] isEqualToString:@"/"])
            {
                nameFirstLetter = i - 1;
                break;
            }
        }*/
    
        // Create direcotry enumeration to loop all sub folders recursively and get their content
        NSDirectoryEnumerator * dirEnum = [fileManager enumeratorAtPath:filePath];
        
        for (NSString *	fileName in dirEnum)
        {
            // Get the full path of each file
            NSString * fullPath = [NSString stringWithFormat:@"%@/%@", filePath, fileName];
            
            // Get the file atributes of each file
            NSDictionary * atributes = [fileManager attributesOfItemAtPath:fullPath error:nil];
            
            // If the file is not Directory add it to the Archive
            if ([atributes fileType] != NSFileTypeDirectory)
            {
                ZipWriteStream * stream = [archive writeFileInZipWithName:fileName  compressionLevel:ZipCompressionLevelBest];
                
                LogDebug(@"Stream with name \n\t\"%@\"\t created", fileName);
                
                [stream writeData:[NSData dataWithContentsOfFile:fullPath]];
                
                LogDebug(@"Content added from path: \n\t%@", fullPath);
                
                [stream finishedWriting];
            }
        }
        
        [archive close];
    }
    @catch (ZipException * exception) 
    {
        LogDebug(@"ZipException caught: %d - %@", (int)exception.error, [exception reason]);
        
        if (error != NULL)
        {
            NSMutableDictionary * archivingExceptionInfo = [NSMutableDictionary dictionary];
            [archivingExceptionInfo setObject:[NSString stringWithFormat:@"Exception error: %d\n Reason: %@", (int)exception.error, [exception reason]] forKey:NSLocalizedDescriptionKey];
            
            *error = [NSError errorWithDomain:LARCHIVER_ERROR_DOMAIN 
                                         code:LARCHIVER_ERROR_CODE_ARCHIVING_EXCEPTION 
                                     userInfo:archivingExceptionInfo];
        }
        
        return  NO;
    }
    
    return YES;
}

+ (BOOL) unarchiveContent:(NSString *)filePath toPatht:(NSString *)destinationPath error:(NSError **)error {
    if (!filePath)
    {
        LogDebug(@"No such file to unarchive");
        
        if (error != NULL)
        {
            NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
            [errorDetails setValue:@"No content for unarchiving. (LArchiver error code 1)" forKey:NSLocalizedDescriptionKey];
            
            *error = [NSError errorWithDomain:LARCHIVER_ERROR_DOMAIN code:LARCHIVER_ERROR_CODE_NO_FILE userInfo:errorDetails];
        }
        
        return NO;
    }
        
    if (!destinationPath)
    {
        LogDebug(@"No destination path");
        
        if (error != NULL)
        {
            NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
            [errorDetails setValue:@"No destination path was specified. (LArchiver error code 3)" forKey:NSLocalizedDescriptionKey];
            
            *error = [NSError errorWithDomain:LARCHIVER_ERROR_DOMAIN code:LARCHIVER_ERROR_CODE_NO_DESTIONATION_PATH userInfo:errorDetails];
        }
        
        return NO; 
    }
        
    @try 
    {
        // Check if destination folder exists and if not create it
        NSFileManager *fileManager = [[[NSFileManager alloc] init] autorelease];
        BOOL isDirectory = YES;
        
        if (![fileManager fileExistsAtPath:destinationPath isDirectory:&isDirectory]) 
        {            
            NSError *err = nil;
            
            if (![fileManager createDirectoryAtPath:destinationPath withIntermediateDirectories:YES attributes:nil error:&err])
            {
                LogDebug(@"Can not create destination folder: %@", [err description]);
                
                if (error != NULL)
                {
                    *error = err;
                }
                
                return NO;
            }
            
            LogDebug(@"Destination folder created at: %@", destinationPath);
        }
        
        ZipFile *unzipFile = [[ZipFile alloc] initWithFileName:filePath mode:ZipFileModeUnzip];
        NSArray *infos = [unzipFile listFileInZipInfos];
        
        for (FileInZipInfo *info in infos) 
        {
            LogDebug(@"- %@ %@ %ld (%" NSUINT ")", info.name, info.date, (long)info.size, (NSUInteger)info.level);
            
            // Get the full path without the last path component
            NSString *dirPath = [info.name substringToIndex:[info.name length] - [[info.name lastPathComponent] length]];
            
            // If it does not exists create it to prevent data loses after unarchiving
            BOOL isDirecotry = YES;
            if (![fileManager fileExistsAtPath:[destinationPath stringByAppendingPathComponent:dirPath] isDirectory:&isDirecotry])
            {
                NSError *createDirError = nil;
                [fileManager createDirectoryAtPath:[destinationPath stringByAppendingPathComponent:dirPath] withIntermediateDirectories:YES attributes:nil error:&createDirError];
                
                if (createDirError)
                {
                    LogError(@"Error while creating dirs %@", [createDirError description]);
                }
            }
            
            // Locate the file in the zip
            [unzipFile locateFileInZip:info.name];
            
            // Expand the file in memory
            ZipReadStream *read = [unzipFile readCurrentFileInZip];
            
            NSMutableData *data = [[NSMutableData alloc] initWithLength:info.length];
            
            NSUInteger bytesRead = [read readDataWithBuffer:data];
            
            if (bytesRead > 0)
            {
                LogDebug(@"%@", [destinationPath stringByAppendingPathComponent:info.name]);
                [data writeToFile:[destinationPath stringByAppendingPathComponent:info.name] atomically:YES];
            }
            
            [read finishedReading];
            [data release];
        }
        
    }
    @catch (ZipException *exception) 
    {
        LogDebug(@"ZipException caught: %d - %@", (int)exception.error, [exception reason]);
        
        if (error != NULL)
        {
            NSMutableDictionary * archivingExceptionInfo = [NSMutableDictionary dictionary];
            [archivingExceptionInfo setObject:[NSString stringWithFormat:@"Exception error: %d\n Reason: %@", (int)exception.error, [exception reason]] forKey:NSLocalizedDescriptionKey];
            
            *error = [NSError errorWithDomain:LARCHIVER_ERROR_DOMAIN 
                                         code:LARCHIVER_ERROR_CODE_UNARCHIVING_EXCEPTION 
                                     userInfo:archivingExceptionInfo];
        }
        
        return  NO;
    }
    
    return YES;
}

@end