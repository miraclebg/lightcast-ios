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
 * @changed $Id: NSImage+Additions.m 228 2013-02-21 05:57:26Z mkovachev $
 * @author $Author: mkovachev $
 * @version $Revision: 228 $
 */

#import "NSImage+Additions.h"
#import "CTGradient.h"

@implementation NSImage(Additions)

- (CGImageRef)CGImage __deprecated
{
#ifndef __clang_analyzer__
	return [self newCGImage];
#endif
}

- (CGImageRef)newCGImage
{
    // data - pass NULL to let CG allocate the memory
	CGContextRef context = CGBitmapContextCreate(NULL,
												 [self size].width,
												 [self size].height,
												 8,
												 0,
												 [[NSColorSpace genericRGBColorSpace] CGColorSpace],
												 kCGBitmapByteOrder32Host|kCGImageAlphaPremultipliedFirst);
	
	[NSGraphicsContext saveGraphicsState];
	[NSGraphicsContext setCurrentContext:[NSGraphicsContext graphicsContextWithGraphicsPort:context flipped:NO]];
	[self drawInRect:NSMakeRect(0,0, [self size].width, [self size].height) fromRect:NSZeroRect operation:NSCompositeCopy fraction:1.0];
	[NSGraphicsContext restoreGraphicsState];
	
	CGImageRef cgImage = CGBitmapContextCreateImage(context);
	CGContextRelease(context);
	
	return cgImage;
}

+ (NSImage *)reflectedImage:(NSImage *)sourceImage amountReflected:(float)fraction
{	
	NSImage *reflection = [[NSImage alloc] initWithSize:[sourceImage size]];
	
	@try
	{
		[reflection setFlipped:NO];
		
		NSRect reflectionRect = NSMakeRect(0, 0, [sourceImage size].width, [sourceImage size].height*fraction);
		
		[reflection lockFocus];
		CTGradient *fade = [CTGradient gradientWithBeginningColor:[NSColor colorWithCalibratedWhite:1.0 alpha:0.5] endingColor:[NSColor clearColor]];
		[fade fillRect:reflectionRect angle:90.0];
		[sourceImage drawAtPoint:NSMakePoint(0,0) fromRect:reflectionRect operation:NSCompositeSourceIn fraction:1.0];
		[reflection unlockFocus];
	}
	@finally 
	{
		reflection = [reflection autorelease];
	}
	
	return reflection;
}


@end
