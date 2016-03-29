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
 * @changed $Id: LAdvancedTableViewCell.m 161 2011-11-03 17:47:20Z mkovachev $
 * @author $Author: mkovachev $
 * @version $Revision: 161 $
 */

#import "LAdvancedTableViewCell.h"

@implementation LAdvancedTableViewCell

@synthesize
data,
options,
threadData;

#pragma mark -
#pragma mark Initialization / Finalization

- (id)init {
    self = [super init];
    if (self)
    {
        data = nil;
        options = nil;
        cellIndexPath = nil;
        cellLoadingDelegate = nil;
        threadData = nil;
    }
    return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    return [self initWithOptions:style reuseIdentifier:reuseIdentifier options:nil];
}

- (id)initWithOptions:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier options:(NSDictionary*)someOptions {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) 
    {
        options = [someOptions retain];
        
        // call setupCell
        [(LAdvancedTableViewCell<LAdvancedTableViewCellViewRequirements>*)self setup];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    cellLoadingDelegate = nil;
    
    L_RELEASE(data);
    L_RELEASE(options);
    L_RELEASE(threadData);
    L_RELEASE(cellIndexPath);
  
    [super dealloc];
}

- (void)setThreadData_:(NSDictionary*)threadData_ {
    if (threadData != threadData_)
    {
        [threadData release];
        threadData = [threadData_ retain];
    }
    
    if (!threadData)
    {
        threadData = [[NSDictionary dictionary] retain];
    }
}

#pragma mark -
#pragma mark UITableViewCell methods

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (void)layoutSubviews {
    [super layoutSubviews];
    // Configure the cell's layout
}

#pragma mark -
#pragma mark Notifications

- (void)notificationLowMemory:(NSNotification*)notification {
    
    [self removeCaches];
}

#pragma mark -
#pragma mark Other

- (void)becameVisible {
    //LogDebug(@"Cell became visible: %@");
    
}

- (void)setup {
    //LogDebug(@"Cell setup");
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(notificationLowMemory:)
                   name:UIApplicationDidReceiveMemoryWarningNotification
                 object:nil];
}

- (void)reload {
    //LogDebug(@"Cell data reload");
}

- (void)removeCaches {
    //LogDebug(@"Cell cache removed");
}

#pragma mark -
#pragma mark NSOperation

- (NSOperation*)cellThreadedOperation:(id<LCellLoadingDelegate>)loadingDelegate_ indexPath:(NSIndexPath*)indexPath_ {
   // LogDebug(@"Cell fire operation");
    
    if (cellLoadingDelegate) return nil;
    
    cellLoadingDelegate = loadingDelegate_;
    
    if (cellIndexPath != indexPath_)
    {
        [cellIndexPath release];
        cellIndexPath = [indexPath_ retain];
    }
    
    LCellThreadingOperation* op = [[LCellThreadingOperation alloc] init];
    op.delegate = self;
    
    return [op autorelease];
}

- (void)didFinishOperation:(id)returnedObject {
    
    if (cellLoadingDelegate)
    {
        [cellLoadingDelegate didFinishLoading:cellIndexPath returnedObject:returnedObject];
    }
    
    L_RELEASE(cellIndexPath);
    cellLoadingDelegate = nil;
}

@end
