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
 * @changed $Id: LAdvancedTableViewController.m 311 2013-11-30 10:44:13Z mkovachev $
 * @author $Author: mkovachev $
 * @version $Revision: 311 $
 */

#import "LAdvancedTableViewController.h"
#import "LAdvancedTableViewCell.h"

#define LC_ATVC_DEFAULT_CELL_CLASS_NAME @"LDefaultTableViewCell"
#define LC_ADVTBL_CACHED_OBJECTS 100
#define LC_ROW_HEIGHT_IN_OPTIONS_KEY @"row_height"
#define LC_DEFAULT_ROW_HEIGHT 50
#define LC_CELL_SEPARATOR_STYLE_KEY @"cell_separator"

@interface LAdvancedTableViewController(Private)

- (void)setTableNoData;
- (void)setTableDataExists;
- (void)firstInit;

- (void)loadDataInThread1;
- (void)loadDataInThread_;

- (void)showProgressView;
- (void)hideProgressView;

- (void)reloadVisible;

- (void)informVisibleCells;

@end

@implementation LAdvancedTableViewController

@synthesize
tableItems,
delegate,
cellOptions,
searchIndexEnabled;

#pragma mark -
#pragma mark Initialization / Finalization

- (id)init {
    return [self initWithItems:nil frame:CGRectNull cellClassName:nil];
}

- (id)initWithItems:(NSArray*)someItems frame:(CGRect)frm {
    return [self initWithItems:someItems frame:frm cellClassName:LC_ATVC_DEFAULT_CELL_CLASS_NAME];
}

- (id)initWithItems:(NSArray*)someItems frame:(CGRect)frm cellClassName:(NSString*)aCellClassName cellOptions:(NSDictionary*)someCellOptions {
    self = [super init];
    if (self)
    {
        queue = [[NSOperationQueue alloc] init];
        cellThreadData = [[NSMutableDictionary alloc] init];
        
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self
                   selector:@selector(notificationLowMemory:)
                       name:UIApplicationDidReceiveMemoryWarningNotification
                     object:nil];
        
        frm_ = frm;
        tableItems = [someItems retain];
        cellOptions = [someCellOptions retain];
        
        if (!aCellClassName)
        {
            LogError(@"LAdvancedTableViewController requires a valid CellClassName which it will use to display the cells with! Crashing now :)");
            
            [self doesNotRecognizeSelector:_cmd];
            L_RELEASE(self);
			return nil;
        }
        else 
        {
            // validate
            Class tmpClass = NSClassFromString(aCellClassName);
            
            if (![tmpClass isSubclassOfClass:[LAdvancedTableViewCell class]] || ![tmpClass conformsToProtocol:@protocol(LAdvancedTableViewCellViewRequirements)])
            {
                LogError(@"LAdvancedTableViewController requires a valid CellClassName - descendant of LAdvancedTableViewCell and conforming to LAdvancedTableViewCellDescendant! Crashing now :)");
                
                [self doesNotRecognizeSelector:_cmd];
                L_RELEASE(self);
				return nil;
            }
			else
			{
				cellClassName = [aCellClassName retain];
				cellClass = [tmpClass retain];
				
				//LogDebug(@"LAdvancedTableViewController: with cell class: %@ and items: %d", cellClassName, tableItems ? [tableItems count] : 0);
			}
        }
    }
    return self;
}

- (id)initWithItems:(NSArray*)someItems frame:(CGRect)frm cellClassName:(NSString*)aCellClassName {
    return [self initWithItems:someItems frame:frm cellClassName:aCellClassName cellOptions:nil];
}

- (id)initWithFrame:(CGRect)frm {
    return [self initWithFrame:frm cellClassName:LC_ATVC_DEFAULT_CELL_CLASS_NAME];
}

- (id)initWithFrame:(CGRect)frm cellClassName:(NSString*)aCellClassName cellOptions:(NSDictionary*)someCellOptions {
    return [self initWithItems:nil frame:frm cellClassName:aCellClassName cellOptions:someCellOptions];
}

- (id)initWithFrame:(CGRect)frm cellClassName:(NSString*)aCellClassName {
    return [self initWithItems:nil frame:frm cellClassName:aCellClassName];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    L_RELEASE(cellThreadData);
    L_RELEASE(queue);
    L_RELEASE(cellOptions);
    L_RELEASE(cellClassName);
    L_RELEASE(cellClass);
    L_RELEASE(noData);
    L_RELEASE(tableItems);
    L_RELEASE(progressView);
    [super dealloc];
}

#pragma mark -
#pragma mark Class Methods

- (void)setSearchIndexEnabled:(BOOL)isEnabled {
    // TODO
}

#pragma mark -
#pragma mark View Related

- (void)viewDidLoad {
  
    [super viewDidLoad];
    
    self.view.frame = frm_;

    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    // init table view
    self.tableView = [[[UITableView alloc] initWithFrame:self.view.bounds] autorelease];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    // set row height from options
    NSNumber * rowHeight = [self.cellOptions objectForKey:LC_ROW_HEIGHT_IN_OPTIONS_KEY];
	
    if (rowHeight)
    {
        if (![rowHeight isKindOfClass:[NSNull class]])
        {
            self.tableView.rowHeight = [rowHeight floatValue];
        }
    }
    else
    {
        self.tableView.rowHeight = LC_DEFAULT_ROW_HEIGHT;
    }
    
    // set the cell separator style if any
    NSNumber * separatorStyle = [self.cellOptions objectForKey:LC_CELL_SEPARATOR_STYLE_KEY];
    if (separatorStyle)
    {
        if ([separatorStyle intValue] > -1 && [separatorStyle intValue] < 3)
        {
            self.tableView.separatorStyle = [separatorStyle intValue];
        }
    }
    
    // no data label
    noData = [[LLabel alloc] init];
    noData.text = LightcastLocalizedString(@"No Data");
    [noData sizeToFit];

    // progress view init
    progressView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [progressView sizeToFit];
    
    [self setTableItemsInternal:tableItems];
    
    // fetch data from thread if provided
    [self loadDataInThread1];
}

- (void)showProgressView {
    
	if (noData)
	{
		[noData removeFromSuperview];
	}
	
	if (progressView)
	{
		[self.tableView addSubview:progressView];
		progressView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |
		UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
		
		[progressView setFrame:CGRectMake(round(self.tableView.frame.size.width / 2 - progressView.frame.size.width / 2),
										  round(self.tableView.frame.size.height / 2 - progressView.frame.size.height / 2),
										  progressView.frame.size.width,
										  progressView.frame.size.height)];
		[progressView startAnimating];
	}
}

- (void)hideProgressView {
    
	if (progressView)
	{
		[progressView removeFromSuperview];
		[progressView stopAnimating];
		progressView = nil;
	}
	
	// if there is no data show the 'noData' label again
	[self reloadVisible];
}

#pragma mark -
#pragma mark Notifications

- (void)notificationLowMemory:(NSNotification*)notification {
    
    // cancel all current operations
    /*[queue cancelAllOperations];
    [cellThreadData removeAllObjects];
    
    [self informVisibleCells];*/
}

#pragma mark -
#pragma mark Working with data

- (void)reloadDataFromThread {
    [self loadDataInThread1];
}

- (void)loadDataInThread1 {
  
    @synchronized(self)
	{
		// check if provider gives us such data
		if (delegate && [delegate respondsToSelector:@selector(LAdvancedTableViewController: provideDataInThread:)])
		{
			[NSThread detachNewThreadSelector:@selector(loadDataInThread_:) toTarget:self withObject:self];
		}
	}
}

- (void)loadDataInThread_:(LAdvancedTableViewController*)tableViewController {
    
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	//LogDebug(@"LAdvancedTableViewController: started data load thread");
	
	[self performSelectorOnMainThread:@selector(showProgressView) withObject:nil waitUntilDone:YES];
	
	@try 
	{
		NSArray * data = nil;
		[delegate LAdvancedTableViewController:self provideDataInThread:&data];
		
		//LogDebug(@"LAdvancedTableViewController: DELEGATE: Provider returned %d items of data", data ? [data count] : 0);
		
		[tableViewController performSelectorOnMainThread:@selector(setTableItemsInternal:) withObject:data waitUntilDone:YES];
		
		//LogDebug(@"LAdvancedTableViewController: finished data load thread");
	}
	@finally 
	{
		[self performSelectorOnMainThread:@selector(hideProgressView) withObject:nil waitUntilDone:YES];
		
		[pool drain];
	}
}

- (void)reloadData {
    NSMutableArray * tmp = [tableItems copy];
    
	@synchronized(tableItems)
	{
		@try 
		{
			L_RELEASE(tableItems);
			
			[self setTableItemsInternal:tmp];
		}
		@finally 
		{
			[tmp release];
		}
	}
}

- (void)reloadVisible {
   
	NSString * reloadVisible = [NSString string];
	
	@synchronized(reloadVisible)
	{
		if (tableItems)
		{
			[self setTableDataExists];
		}
		else
		{
			[self setTableNoData];
		}
		
		if ([tableItems count] == 0)
		{
			[self setTableNoData];
		}
		
		[self informVisibleCells];
		[self.tableView reloadData];
	}
}

- (void)setTableItemsInternal:(NSArray*)someItems {
    
    @synchronized(someItems)
    {
        if (tableItems != someItems)
        {
            // clear all objects, flush and reload table
            L_RELEASE(tableItems);
            tableItems = [someItems retain];
        }
        
        [self reloadVisible];
        
        if (delegate && [delegate respondsToSelector:@selector(LAdvancedTableViewController: dataChanged:)])
        {
            //LogDebug(@"LAdvancedTableViewController: DELEGATE: dataChanged");
            [delegate LAdvancedTableViewController:self dataChanged:tableItems];
        } 
    }
}

#pragma mark -
#pragma mark Private methods

- (void)setTableNoData {
    
    // label when no data is shown
	@synchronized(noData)
	{
		noData.autoresizingMask = 
		UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |
		UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
		[noData setFrame:CGRectMake(round(self.tableView.frame.size.width / 2 - noData.frame.size.width / 2),
									round(self.tableView.frame.size.height / 2 - noData.frame.size.height / 2),
									noData.frame.size.width, noData.frame.size.height)];
		[self.tableView addSubview:noData];
	}
}

- (void)setTableDataExists {
    
    // label when no data is shown
	@synchronized(noData)
	{
		if (noData)
		{
			[noData removeFromSuperview];
		}
	}
}

- (void)informVisibleCells {
    @try
    {
        NSArray * rows = [self.tableView indexPathsForVisibleRows];
        
        for (NSIndexPath * idx in rows)
        {
            LAdvancedTableViewCell<LAdvancedTableViewCellViewRequirements>* c = (LAdvancedTableViewCell<LAdvancedTableViewCellViewRequirements>*)[self.tableView cellForRowAtIndexPath:idx];
            
            NSOperation* operation = [c cellThreadedOperation:self indexPath:idx];
            
            if (operation)
            {
                [queue addOperation:operation];
            }
        }
    }
    @catch (NSException * e)
    {
        LogError(@"Error during informVisibleCells : %@", [e description]);
    }
}

#pragma mark -
#pragma mark LCellLoadingDelegate

- (void)didFinishLoading:(NSIndexPath*)indexPath returnedObject:(id)returnedObject {
    
    //LogDebug(@"didfinishloading");
    
    if (returnedObject)
    {
        [cellThreadData setObject:returnedObject forKey:indexPath];
    }
    else
    {
        [cellThreadData removeObjectForKey:indexPath];
    }
    
    LAdvancedTableViewCell* cell = (LAdvancedTableViewCell*)[self.tableView cellForRowAtIndexPath:indexPath];
    cell.threadData = [cellThreadData objectForKey:indexPath];
    
    [cell reload];
    
    // check cache
    if ([cellThreadData count] >= LC_ADVTBL_CACHED_OBJECTS)
    {
        LogWarn(@"Table cache reached %d - will flush all temporal objects", LC_ADVTBL_CACHED_OBJECTS);
        
        [cellThreadData removeAllObjects];
        [self informVisibleCells];
    }
}

#pragma mark -
#pragma mark UITableViewDataSource delegate methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return tableItems ? [tableItems count] : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *kCustomCellID = @"AdvancedCellID";
    //NSString *kCustomCellID = [NSString stringWithFormat:@"%@_%d", @"AdvancedCellID", indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCustomCellID];
	
	if (cell == nil)
	{
        cell = [[[cellClass alloc] initWithOptions:UITableViewCellStyleDefault reuseIdentifier:kCustomCellID options:cellOptions] autorelease];
    }
    
    ((LAdvancedTableViewCell*)cell).data = [tableItems objectAtIndex:indexPath.row];
    ((LAdvancedTableViewCell*)cell).threadData = [cellThreadData objectForKey:indexPath];
   
    [((LAdvancedTableViewCell*)cell) reload];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // custom background color
    if ([((LAdvancedTableViewCell*)cell) respondsToSelector:@selector(backgroundColor)])
    {
        UIColor* bgColor = [((LAdvancedTableViewCell*)cell) backgroundColor];
        
        if (bgColor)
        {
            cell.backgroundColor = bgColor;
        }
    }
}

#pragma mark - UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (delegate && [delegate respondsToSelector:@selector(LAdvancedTableViewController:didSelectCellWithData:)])
    {
        LAdvancedTableViewCell * cell = (LAdvancedTableViewCell*)[self tableView:tableView cellForRowAtIndexPath:indexPath];
        NSDictionary * cellData = cell.data;
        
        if (cell)
        {
            [delegate LAdvancedTableViewController:self didSelectCellWithData:cellData];
        }
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (delegate && [delegate respondsToSelector:@selector(LAdvancedTableViewController:didDeselectCellWithData:)])
    {
        LAdvancedTableViewCell * cell = (LAdvancedTableViewCell*)[self tableView:tableView cellForRowAtIndexPath:indexPath];
        NSDictionary * cellData = cell.data;

        if (cell)
        {
            [delegate LAdvancedTableViewController:self didDeselectCellWithData:cellData];
        }
    }
}

#pragma mark - UIScrollViewDelegate methods

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    // cancel all previous
    //[queue cancelAllOperations];
}

/** Reloads the currently visible images on screen - after a scroll end event
 *	@param UIScrollView scrollView The scroll view from which the event came
 *	@param BOOL decelerate Returns TRUE if the scroll view is decelerating
 *	@return void
 */
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	
	if (!tableItems) return;
	
	//LogDebug(@"scrollViewDidEndDragging");
	
    if (!decelerate)
    {
        [self informVisibleCells]; 
    }
}

/** Reloads the currently visible images on screen - after a scroll end event
 *	@param UIScrollView scrollView The scroll view from which the event came
 *	@return void
 */
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	
	if (!tableItems) return;
	
	//LogDebug(@"scrollViewDidEndDecelerating");
	
	[self informVisibleCells];
}

@end
