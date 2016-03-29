//
//  LCalendarGridView.h
//  Lightcast
//
//  Created by Martin N. Kovachev on 05.08.13.
//  Copyright (c) 2013 г. Nimasystems Ltd. All rights reserved.
//

#import <Lightcast/LView.h>

@interface LCalendarGridView : LView

@property (nonatomic, assign) BOOL cellBorderToVisibleCellsOnly;
@property (nonatomic, assign) CGFloat cellBorderWidth;
@property (nonatomic, retain) UIColor *cellBorderColor;

@property (nonatomic, assign) CGSize cellSize;
@property (nonatomic, retain) NSArray *cells;

@end
