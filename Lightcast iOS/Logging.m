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
 * @changed $Id: Logging.m 319 2014-01-03 09:23:06Z mkovachev $
 * @author $Author: mkovachev $
 * @version $Revision: 319 $
 */

#import "Logging.h"

NSInteger const kMaxSystemLogFileSize = 3; // in MB

void openSystemLog(NSInteger maxLogFileSize, NSString *path) {
	// file logging
    
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	maxLogFileSize = maxLogFileSize ? maxLogFileSize : kMaxSystemLogFileSize;
	
	@try 
	{
		NSString *logFileName = nil;
		NSString *logFolderName = nil;
		
		if (!path)
		{
			// default is in documents folder
			NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 
			NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
			
			logFolderName = [documentsDirectory stringByAppendingPathComponent:@"Logs"];
			logFileName = [logFolderName stringByAppendingPathComponent:
									  [NSString stringWithFormat: @"%@.log", [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleName"]]];
		} else
		{
			logFolderName = [path stringByExpandingTildeInPath];
			logFileName = [logFolderName stringByAppendingPathComponent:
						   [NSString stringWithFormat: @"%@.log", [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleName"]]];
		}
		
		NSFileManager * fileManager = [NSFileManager defaultManager];
		
		NSError *error = nil;
		
		// check and create the log
		BOOL res = [fileManager createDirectoryAtPath:logFolderName withIntermediateDirectories:YES attributes:nil error:&error];
		
		if (!res) 
		{
			LogCError(@"Could not create logs directory: %@", error);
			return;
		}
		
		// check the size of the file - if it is larger than kStCocoaMaxLogFilesize 
		// truncate it
		NSDictionary * attrs = [fileManager attributesOfItemAtPath:logFileName error:&error];
		
		if (attrs)
		{
			NSNumber * fileSize = [attrs objectForKey:NSFileSize];
			
			if (fileSize)
			{
				if ([fileSize intValue] > maxLogFileSize * 1024 * 1024)
				{
					// truncate the file
					[fileManager removeItemAtPath:logFileName error:&error];
				}
			}
		}
		
		freopen([logFileName fileSystemRepresentation], "a", stderr);
		
		LogCInfo(@"Log attached at path: %@", logFileName);
	}
	@finally
	{
		[pool release];  
	}
}