//
//  LCalendarGridView.m
//  Lightcast
//
//  Created by Martin N. Kovachev on 05.08.13.
//  Copyright (c) 2013 г. Nimasystems Ltd. All rights reserved.
//

#import "LCalendarGridView.h"

@implementation LCalendarGridView

@synthesize
cellBorderColor,
cellBorderWidth,
cellBorderToVisibleCellsOnly,
cellSize,
cells;

#pragma mark - Initialization / Finalization

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        cellBorderToVisibleCellsOnly = NO;
        self.cellBorderColor = [UIColor grayColor];
        self.cellBorderWidth = 0.2;
    }
    return self;
}

- (void)dealloc
{
    L_RELEASE(cellBorderColor);
    L_RELEASE(cells);
    
    [super dealloc];
}

#pragma mark - Getters / Setters
- (void)setCells:(NSArray *)cells_
{
    if (cells != cells_)
    {
        L_RELEASE(cells);
        cells = [cells_ retain];
        
        [self removeAllSubviews];
        
        for(UIView *v in cells)
        {
            [self addSubview:v];
        }
    }
}

- (void)setCellBorderColor:(UIColor *)cellBorderColor_
{
    if (cellBorderColor != cellBorderColor_)
    {
        L_RELEASE(cellBorderColor);
        cellBorderColor = [cellBorderColor_ retain];
        
        [self setNeedsDisplay];
    }
}

- (void)setCellBorderWidth:(CGFloat)cellBorderWidth_
{
    if (cellBorderWidth != cellBorderWidth_)
    {
        cellBorderWidth = cellBorderWidth_;
        
        [self setNeedsDisplay];
    }
}

- (void)setCellBorderToVisibleCellsOnly:(BOOL)cellBorderToVisibleCellsOnly_
{
    if (cellBorderToVisibleCellsOnly != cellBorderToVisibleCellsOnly_)
    {
        cellBorderToVisibleCellsOnly = cellBorderToVisibleCellsOnly_;
        
        [self setNeedsDisplay];
    }
}

- (void)setCellSize:(CGSize)cellSize_
{
    if (cellSize_.width != cellSize.width || cellSize_.height != cellSize.height)
    {
        cellSize = cellSize_;
        
        [self setNeedsDisplay];
    }
}

#pragma mark - View Related

- (void)drawRect:(CGRect)rect
{
    // draw grid / cell borders
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // paint border for cells
    if (self.cellBorderWidth && self.cellBorderColor)
    {
        CGContextSetStrokeColorWithColor(context, self.cellBorderColor.CGColor);
        CGContextSetLineWidth(context, self.cellBorderWidth);
        
        if (self.cellBorderToVisibleCellsOnly)
        {
            // only to visible cells
            for(UIView *cell in cells)
            {
                CGRect r = cell.frame;
                CGContextStrokeRect(context, r);
            }
        }
        else if (cellSize.width && cellSize.height)
        {
            CGRect r;
            CGFloat nextX = 0.0;
            CGFloat nextY = 0.0;
            
            // matrix borders
            for(NSInteger i=0;i<7;i++)
            {
                nextX = i * cellSize.width;
                
                for(NSInteger j=0;j<5;j++)
                {
                    nextY = j * cellSize.height;
                    
                    r = CGRectMake(nextX,
                                   nextY,
                                   cellSize.width,
                                   cellSize.height
                    );
                    
                    CGContextStrokeRect(context, r);
                }
            }
        }
    }
}

@end
