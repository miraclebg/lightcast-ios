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
 * @changed $Id: LThreadedImageViewCell.m 75 2011-07-16 15:47:22Z mkovachev $
 * @author $Author: mkovachev $
 * @version $Revision: 75 $
 */

#import "LThreadedImageViewCell.h"

NSString *const lnThreadedImageCellImageKey = @"constant.lnThreadedImageCellImageKey";
NSString *const lnThreadedImageCellDefaultLocalImageKey = @"constant.lnThreadedImageCellDefaultLocalImageKey";

@implementation LThreadedImageViewCell

#pragma mark -
#pragma mark Initialization / Finalization

- (void)dealloc {
    
    //L_RELEASE(lbl);
    L_RELEASE(progressView);
    [super dealloc];
}

- (UIImage*)defaultImage {
    
    id defaultImage = [self.options objectForKey:lnThreadedImageCellDefaultLocalImageKey];
    UIImage* img = nil;
    
    if (defaultImage)
    {
        img = [UIImage imageWithContentsOfFile:defaultImage];
    }
    
    return img;
}

#pragma mark -
#pragma mark LAdvancedTableViewCell Descendant

- (void)setup {
    
    [super setup];
    
    //imageView = [[LImageView alloc] init];
    //[self.contentView addSubview:imageView];
    //[imageView release];
    
    // label 
    //lbl = [[UILabel alloc] init];
    //[self.contentView addSubview:lbl];
}

/*
- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect contentRect = self.contentView.bounds;
    CGFloat boundsX = contentRect.origin.x;
    CGRect frame;
    
    frame= CGRectMake(boundsX+10 ,0, 50, 50);
    imageView.frame = frame;
    
    frame = CGRectMake(frame.origin.x + frame.size.width + 2, 0, 100, 50);
    lbl.frame = frame;
}*/

- (void)reload {
    
    [super reload];
    
    self.textLabel.text = [NSString stringWithFormat:@"%@", [data objectForKey:@"a_key"]];
    
    UIImage* img = [self.threadData objectForKey:@"image"];
    self.imageView.image = img ? img : [self defaultImage];
}

- (void)removeCaches {
    
    [super removeCaches];
    
    self.imageView.image = nil;
    
    [self setNeedsDisplay];
}

/*
- (void)showProgressView {
    
    UIActivityIndicatorView* activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [activityView sizeToFit];
    activityView.tag = 2000;
    [self.imageView addSubview:activityView];
    [activityView startAnimating];
    [activityView release];
}

- (void)hideProgressView {
    [[imageView viewWithTag:2000] removeFromSuperview];
}*/

- (id)loadInOperation {
    
    if (!self.options) return nil;
    
    NSMutableDictionary* d = [NSMutableDictionary dictionaryWithDictionary:self.threadData];
    
    //[self performSelectorOnMainThread:@selector(showProgressView) withObject:nil waitUntilDone:NO];
    
    //int r = rand() % 3;
    //LogDebug(@"sleeping for: %d", r);
    //sleep(r);
    
    // load and cache the image
    if (![self.threadData objectForKey:@"image"])
    {
        id input = [self.options objectForKey:lnThreadedImageCellImageKey];
        
        NSURL* url = nil;
        NSString* path = nil;
        
        if (input)
        {
            input = [self.data objectForKey:input];
            
            if (input)
            {
                if ([input isKindOfClass:[NSURL class]])
                {
                    url = input;
                }
                else 
                    if ([input isKindOfClass:[NSString class]])
                    {
                        path = input;
                    } 
            }
        }
        
        if (!url && !path)
        {
            LogWarn(@"No url or path set to load any image");
            return nil;
        }
        
        UIImage* img = nil;
        
        if (url)
        {
            @try 
            {
                NSData * dta = [NSData dataWithContentsOfURL:url];
                img = [UIImage imageWithData:dta];
            }
            @catch (NSException* e) 
            {
                img = nil;
            }
        }
        else 
            if (path)
            {
                img = [UIImage imageWithContentsOfFile:path];
            }
        
        if (img)
        {
            [d setObject:img forKey:@"image"];
        }
    }
    
    //[self performSelectorOnMainThread:@selector(hideProgressView) withObject:nil waitUntilDone:NO];
    
    
    return d;
}

@end
