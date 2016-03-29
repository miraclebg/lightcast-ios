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
 * @changed $Id: NSFileManager+Additions.m 341 2014-08-28 05:21:47Z mkovachev $
 * @author $Author: mkovachev $
 * @version $Revision: 341 $
 */

#import "NSFileManager+Additions.h"

@implementation NSFileManager(LAdditions)

+ (NSString*)combinePaths:(NSString*)path, ...
{
    NSString *str1 = [NSString string];
    va_list args;
    va_start(args, path);
    
    for (NSString *arg = path; arg != nil; arg = va_arg(args, NSString*))
    {
        str1 = [str1 stringByAppendingPathComponent:arg];
    }
    va_end(args);
    
    return str1;
}

+ (NSInteger)filesize:(NSString*)filename {
    NSFileManager * f = [NSFileManager defaultManager];
    
    NSInteger fsize = 0;
    
    NSDictionary * attr = [f attributesOfItemAtPath:filename error:nil];
    
    if (attr)
    {
        fsize = [[attr objectForKey:NSFileSize] intValue];
    }
    
    return fsize;
}

+ (NSString*)fileExtension:(NSString*)filename {
    if (!filename) return nil;
    NSString * tmp = [filename lastPathComponent];
    
    if (!tmp) return nil;
    
    NSArray * cmp = [tmp componentsSeparatedByString:@"."];
    
    if ([cmp count] > 1)
    {
        return [NSString stringWithFormat:@".%@", [cmp objectAtIndex:[cmp count]-1]];
    }
    else
    {
        return @"";
    }
}

- (NSString*)documentsPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsPath = [paths objectAtIndex:0];
    return documentsPath;
}

- (NSString*)libraryPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
	NSString *libraryPath = [paths objectAtIndex:0];
    return libraryPath;
}

- (NSString*)cachesPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSString *libraryPath = [paths objectAtIndex:0];
    return libraryPath;
}

- (NSString*)resourcePathForClass:(Class)classname
{
    NSString *resourcePath = [[NSBundle bundleForClass:classname] resourcePath];
    return resourcePath;
}

- (NSString*)resourcePath {
	return [[NSBundle mainBundle] resourcePath];
}

- (NSString *)temporaryPath {
	
#ifdef TARGET_OSX
	// an alternative to the NSTemporaryDirectory
	NSString * path = nil;
	NSArray * paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	
	if ([paths count]) 
	{
		NSString * bundleName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
        
        path = [[[paths objectAtIndex:0] stringByAppendingPathComponent:bundleName] stringByAppendingString:@"/"];
	}
    
    return path;
#endif
    
#ifdef TARGET_IOS
    NSString * path = NSTemporaryDirectory();
    return path;
#endif
    
    return nil;
}

- (NSString*)appLibraryPath
{
    NSString *path = [[[self libraryPath] stringByAppendingPathComponent:@"Application Support"]
                      stringByAppendingPathComponent:[LApplicationUtils bundleIdentifier]];
    return path;
}

- (NSString*)randomFilename:(NSInteger)length
{
    return [NSString randomString:length];
}

- (BOOL)internalRemoveFolderWithRecursion:(NSString *)folderName error:(NSError**)error {
	
    if (error != NULL)
    {
        *error = nil;
    }
    
	BOOL res = YES;
	
	NSArray * items = [self contentsOfDirectoryAtPath:folderName error:error];
	
	if ([items count])
	{
		for (NSString * k in items) 
		{
			if (error != NULL)
            {
                *error = nil;
            }
            
            NSString * fname = [folderName stringByAppendingPathComponent:k];
            NSDictionary * attribs = [self attributesOfItemAtPath:fname error:error];
            
            // NSFileType
            // NSFileTypeDirectory
            // NSFileTypeRegular
            
            if (attribs)
            {
                NSString * t = [attribs objectForKey:NSFileType];
                
                // if it's a subfolder, recurse inside
                if ([t isEqualToString:NSFileTypeDirectory])
                {
                    if (error != NULL)
                    {
                        *error = nil;
                    }
                    
                    BOOL resIn = [self internalRemoveFolderWithRecursion:fname error:error];
                    
                    if (!resIn)
                    {
                        return NO;
                    }
                    
                    if (error != NULL)
                    {
                        *error = nil;
                    }
                    
                    // remove the folder itself
                    res = [self removeItemAtPath:fname error:error];
                    
                    if (!res)
                    {
                        return NO;
                    }
                }
                else
                    // if it's a file delete it
                {
                    if (error != NULL)
                    {
                        *error = nil;
                    }
                    
                    res = [self removeItemAtPath:fname error:error];
                    
                    if (!res)
                    {
                        return NO;
                    }
                }
            }
			
			if (!res) break;
		}
	}
    
	return res;
}

- (BOOL)folderExists:(NSString*)folder
{
    BOOL isDir = NO;
    
    BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:folder isDirectory:&isDir];
    
    BOOL ret = (exists && isDir);
    
    return ret;
}

- (BOOL)removeFolderRecursively:(NSString *)folderName emptyTopFolder:(BOOL)onlyEmptyTopFolder error:(NSError**)error {
    
    if (error != NULL)
    {
        *error = nil;
    }
    
    if (folderName == nil) return NO;
	
	BOOL res = [self internalRemoveFolderWithRecursion:folderName error:error];
	
	if (!res)
	{
		return NO;
	}
	
	// delete the folder itself, if NOT empty
	if (!onlyEmptyTopFolder)
	{
        if (error != NULL)
        {
            *error = nil;
        }
        
		res = [self removeItemAtPath:folderName error:error];
		
		if (!res)
		{
			return NO;
		}
	}
	
	return res;
}

- (BOOL)removeFolderRecursively:(NSString *)folderName emptyTopFolder:(BOOL)onlyEmptyTopFolder {
	return [self removeFolderRecursively:folderName emptyTopFolder:onlyEmptyTopFolder error:nil];
}

- (NSString*)formattedFileSize:(NSInteger)fileSize {
	NSString * str = nil;
	
	if (fileSize < 1) str = @""; else
		if (fileSize < 1024) str = [NSString stringWithFormat:LightcastLocalizedString(@"%d bytes"), fileSize]; else
			if ((fileSize > 1024) && (fileSize < 1048576)) str = [NSString stringWithFormat:LightcastLocalizedString(@"%d KB"), fileSize/1024]; else
				if (fileSize > 1048576) str = [NSString stringWithFormat:LightcastLocalizedString(@"%d MB"), fileSize/1048576];
	
	return str;
}

+ (NSString*)folderContentsDescription:(NSString*)pathToFolder
{
    if ([NSString isNullOrEmpty:pathToFolder])
    {
        lassert(false);
        return nil;
    }
    
    NSString *dir = pathToFolder;
    NSMutableArray *gc = [NSMutableArray array];
    
    NSMutableSet *contents = [[[NSMutableSet alloc] init] autorelease];
    NSFileManager *fm = [NSFileManager defaultManager];
    
    BOOL isDir = NO;
    
    NSString *fn = nil;
    NSDictionary *fattrs = nil;
    
    if (dir && ([fm fileExistsAtPath:dir isDirectory:&isDir] && isDir))
    {
        if (![dir hasSuffix:@"/"])
        {
            dir = [dir stringByAppendingString:@"/"];
        }
        
        // this walks the |dir| recurisively and adds the paths to the |contents| set
        NSDirectoryEnumerator *de = [fm enumeratorAtPath:dir];
        NSString *f;
        NSString *fqn;
        
        while ((f = [de nextObject]))
        {
            // make the filename |f| a fully qualifed filename
            fqn = [dir stringByAppendingString:f];
            
            if ([fm fileExistsAtPath:fqn isDirectory:&isDir] && isDir)
            {
                // append a / to the end of all directory entries
                fqn = [fqn stringByAppendingString:@"/"];
            }
            
            [contents addObject:fqn];
        }
        
        fn = nil;
        
        // here we sort the |contents| before we display them
        for (fn in [[contents allObjects] sortedArrayUsingSelector:@selector(compare:)])
        {
            fattrs = [fm attributesOfItemAtPath:fn error:NULL];
            UInt64 fsize = [fattrs fileSize];
            
            NSString *fname1 = [NSString stringWithFormat:@"%@: %@", fn, [fm formattedFileSize:fsize]];
            
            [gc addObject:fname1];
        }
    }
    else
    {
        return nil;
    }
    
    NSString *c = [gc componentsJoinedByString:@"\n"];
    
    return c;
}

- (BOOL)markNoICloudArchiving:(NSString*)path error:(NSError**)error
{
    if (error != NULL)
    {
        *error = nil;
    }

#ifdef TARGET_IOS
    if (!SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"5.1")) {
        return YES;
    }
#endif
    
    NSURL *url = [NSURL fileURLWithPath:path];
    
    if (!url)
    {
        return NO;
    }
    
    BOOL success = [url setResourceValue:[NSNumber numberWithBool:YES]
                                  forKey:NSURLIsExcludedFromBackupKey error:error];
    return success;
}

@end
