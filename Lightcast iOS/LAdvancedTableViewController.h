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
 * @changed $Id: LAdvancedTableViewController.h 357 2015-04-16 06:29:29Z mkovachev $
 * @author $Author: mkovachev $
 * @version $Revision: 357 $
 */

#import <Foundation/Foundation.h>
#import <Lightcast/LViewController.h>
#import <Lightcast/LTableViewController.h>
#import <Lightcast/LLabel.h>
#import <Lightcast/LCellLoadingDelegate.h>
#import <Lightcast/LCellThreadingOperation.h>

@class LAdvancedTableViewController;

@protocol LAdvancedTableViewControllerDelegate <NSObject>

@optional

- (void)LAdvancedTableViewController:(LAdvancedTableViewController*)LAdvancedTableViewController provideDataInThread:(NSArray**)data;
- (void)LAdvancedTableViewController:(LAdvancedTableViewController*)LAdvancedTableViewController dataChanged:(NSArray*)newData;

- (void)LAdvancedTableViewController:(LAdvancedTableViewController*)LAdvancedTableViewController didSelectCellWithData:(NSDictionary*)data;
- (void)LAdvancedTableViewController:(LAdvancedTableViewController*)LAdvancedTableViewController didDeselectCellWithData:(NSDictionary*)data;

@end

@interface LAdvancedTableViewController : LTableViewController<UITableViewDataSource,UITableViewDelegate,LCellLoadingDelegate> {
    
    CGRect frm_;
    
    LLabel* noData;
    
    NSArray* tableItems;
    
    NSString * cellClassName;
    Class cellClass;
    
    NSDictionary* cellOptions;
    NSMutableDictionary* cellThreadData;
    
    UIActivityIndicatorView *progressView;
    
    NSOperationQueue* queue;
    
    id<LAdvancedTableViewControllerDelegate> delegate;
    
    BOOL searchIndexEnabled;
}

@property (nonatomic, retain, setter = setTableItemsInternal:) NSArray* tableItems;
@property (nonatomic, assign) id<LAdvancedTableViewControllerDelegate> delegate;
@property (nonatomic, retain, readonly) NSDictionary* cellOptions;
@property (nonatomic, assign, setter = setSearchIndexEnabled:) BOOL searchIndexEnabled;

- (id)initWithFrame:(CGRect)frm;
- (id)initWithFrame:(CGRect)frm cellClassName:(NSString*)aCellClassName;
- (id)initWithFrame:(CGRect)frm cellClassName:(NSString*)aCellClassName cellOptions:(NSDictionary*)someCellOptions;

- (id)initWithItems:(NSArray*)someItems frame:(CGRect)frm;
- (id)initWithItems:(NSArray*)someItems frame:(CGRect)frm cellClassName:(NSString*)aCellClassName;
- (id)initWithItems:(NSArray*)someItems frame:(CGRect)frm cellClassName:(NSString*)aCellClassName cellOptions:(NSDictionary*)someCellOptions;

- (void)reloadData;

- (void)reloadDataFromThread;

@end
