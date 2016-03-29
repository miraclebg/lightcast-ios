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
 * @changed $Id: GeneralUtils.m 235 2013-03-15 14:08:45Z mkovachev $
 * @author $Author: mkovachev $
 * @version $Revision: 235 $
 */

#import "GeneralUtils.h"
#import <CommonCrypto/CommonDigest.h>

@implementation GeneralUtils

+ (NSString *)sha1:(NSString *)str {	
	unsigned char hashedChars[20];
	
	CC_SHA1([str UTF8String],
			(int)[str lengthOfBytesUsingEncoding:NSUTF8StringEncoding], 
			hashedChars);
	
	NSData * hashedData = [NSData dataWithBytes:hashedChars length:20];
	
	// may be a more optimized way to do this?xwwwxwwwww
	NSMutableString * tmp = [[NSMutableString stringWithFormat:@"%@", [hashedData description]] retain];
	[tmp replaceOccurrencesOfString:@" " withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [tmp length])];
	[tmp deleteCharactersInRange:NSMakeRange([tmp length]-1, 1)];
	[tmp deleteCharactersInRange:NSMakeRange(0, 1)];
	
	return [tmp autorelease];
}

#ifdef TARGET_IOS	// iOS Target

+ (void)displayMessage:(NSString *)title description:(NSString *)description buttonTitle:(NSString *)buttonTitle delegate:(id)delegate {
	
	UIAlertView * errorAlert = [[[UIAlertView alloc] initWithTitle:(![NSString isNullOrEmpty:title] ? title : @"")
														  message:(![NSString isNullOrEmpty:description] ? description : @"")
														 delegate:delegate 
												cancelButtonTitle:(![NSString isNullOrEmpty:buttonTitle] ? buttonTitle : @"OK")
                                                 otherButtonTitles:nil] autorelease];
	[errorAlert show];
}

+ (void)displayMessage:(NSString *)title description:(NSString *)description delegate:(id)delegate {
	[GeneralUtils displayMessage:title description:description buttonTitle:LightcastLocalizedString(@"Close") delegate:delegate];
}

+ (BOOL)isSimulator {
	
	NSString *deviceType = [UIDevice currentDevice].model;
	
	if([deviceType isEqualToString:@"iPad Simulator"] || [deviceType isEqualToString:@"iPhone Simulator"])
	{
		return YES;
	}
	
	return NO;
}

+ (BOOL)isIPad {
	
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
	{
		return YES;
	}
	
	return NO;
}

+ (BOOL)isIPhone {
	
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
	{
		return YES;
	}
	
	return NO;
}

+ (void)displayMessage:(NSString *)title description:(NSString *)description
{
	[GeneralUtils displayMessage:title description:description buttonTitle:LightcastLocalizedString(@"Close") delegate:nil];
}

#endif // end of iOS Target

#ifdef TARGET_OSX // MAC-OSX Target

#ifdef HAS_APPKIT
+ (void)displayMessage:(NSString *)title description:(NSString *)description style:(NSAlertStyle)alertStyle
{
	// show an error message to the user for friendliness :)
	NSAlert * alert = [[[NSAlert alloc] init] autorelease];
	
    [alert setAlertStyle:alertStyle];
	[alert setInformativeText:description];
    [alert setMessageText:title];
    [alert runModal];
}
#endif

+ (void)displayMessage:(NSString *)title description:(NSString *)description
{
	[self displayMessage:title description:description style:NSInformationalAlertStyle];
}

+ (void)displayError:(NSError*)error
{
	if (!error) return;
	
	NSAlert *alert = [NSAlert alertWithError:error];
	[alert runModal];
}

#endif

@end
