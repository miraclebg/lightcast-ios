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
 * @changed $Id: LVirtualFile.h 292 2013-08-29 14:11:56Z mkovachev $
 * @author $Author: mkovachev $
 * @version $Revision: 292 $
 */

#import <Foundation/Foundation.h>

@interface LVirtualFile : NSObject {
    
    NSInteger fileId;
    NSString *fileName;
    
    NSString *pathToVfs;
    NSString *dirHash;
    NSString *fileHash;
    
    NSString *fileType;
    
    long long filesize;
    
    NSDate *createdOn;
	
	NSString *fullPath; // only a stub - to compile in 32-bit mode
}

@property (nonatomic) NSInteger fileId;
@property (nonatomic, retain) NSString * fileName;
@property (nonatomic, retain) NSString * pathToVfs;
@property (nonatomic, retain) NSString * dirHash;
@property (nonatomic, retain) NSString * fileHash;
@property (nonatomic, retain) NSString * fileType;
@property (nonatomic) long long filesize;
@property (nonatomic, retain) NSDate *createdOn;
@property (nonatomic, readonly, getter=fullFileName) NSString* fullPath;
@property (nonatomic, readonly,getter=getFileData) NSData * fileData;

@end
