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
 * @changed $Id: SQLParser.m 75 2011-07-16 15:47:22Z mkovachev $
 * @author $Author: mkovachev $
 * @version $Revision: 75 $
 */

#import "SQLParser.h"

@implementation SQLParser

@synthesize
sqlItems;

#pragma mark -
#pragma mark Initialization / Finalization

- (id)init
{
    return [self initWithContentsOfFile:nil];
}

- (id)initWithContentsOfFile:(NSString*)filename {
    self = [super init];
    if (self) 
    {
        sqlItems = nil;
        
        if (filename)
        {
            NSData* data = [NSData dataWithContentsOfFile:filename];
            
            if (data)
            {
                // convert into lines
                // TODO - decide what to do with \n escape sequences - they are BROKEN right now!
                NSString* string = [[NSString alloc] initWithBytes:[data bytes]
                                                             length:[data length] 
                                                           encoding:NSUTF8StringEncoding];
                
                @try 
                {
                    //split the string around newline characters to create an array
                    NSString* delimiter = @"\n";
                    NSArray* arr = [string componentsSeparatedByString:delimiter];
                    
                    if (arr)
                    {
                        sqlItems = [arr retain];
                    }
                }
                @finally 
                {
                    [string release];
                }
            }
        }
    }
    return self;
}

- (void)dealloc
{
    L_RELEASE(sqlItems);
    [super dealloc];
}

+ (id)sqlParserWithFileContents:(NSString*)filename {
    
    id parser = [[SQLParser alloc] initWithContentsOfFile:filename];
    
    return [parser autorelease];
}

@end
