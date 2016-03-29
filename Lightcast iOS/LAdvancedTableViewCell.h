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
 * @changed $Id: LAdvancedTableViewCell.h 357 2015-04-16 06:29:29Z mkovachev $
 * @author $Author: mkovachev $
 * @version $Revision: 357 $
 */

#import <UIKit/UIKit.h>
#import <Lightcast/LCellThreadingOperation.h>
#import <Lightcast/LCellLoadingDelegate.h>

@protocol LAdvancedTableViewCellViewRequirements <NSObject>

@optional

- (void)setup;
- (UIColor*)backgroundColor;
- (void)removeCaches;

@required

- (void)reload;

@end

@interface LAdvancedTableViewCell : UITableViewCell<LCellThreadingOperationDelegate> {
    
    NSDictionary* data;
    NSDictionary* options;
    NSDictionary* threadData;
    
    id<LCellLoadingDelegate>cellLoadingDelegate;
    NSIndexPath* cellIndexPath;
}

@property (nonatomic, retain) NSDictionary* data;
@property (nonatomic, retain) NSDictionary* options;
@property (nonatomic, retain, setter = setThreadData_:) NSDictionary* threadData;

- (id)initWithOptions:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier options:(NSDictionary*)someOptions;

- (void)setup;
- (void)reload;
- (void)removeCaches;
- (NSOperation*)cellThreadedOperation:(id<LCellLoadingDelegate>)loadingDelegate_ indexPath:(NSIndexPath*)indexPath_;

@end
