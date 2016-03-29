//
//  UITableView+Additons.m
//  Lightcast
//
//  Created by Martin Kovachev on 02.02.14.
//  Copyright (c) 2014 г. Nimasystems Ltd. All rights reserved.
//

#import "UITableView+Additons.h"

@implementation UITableView(Additons)

- (void)reloadData:(BOOL)animated
{
    [self reloadData];
    
    if (animated) {
        
        CATransition *animation = [CATransition animation];
        [animation setType:kCATransitionPush];
        [animation setSubtype:kCATransitionFade];
        [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        [animation setFillMode:kCAFillModeBoth];
        [animation setDuration:.3];
        [[self layer] addAnimation:animation forKey:@"UITableViewReloadDataAnimationKey"];
        
    }
}

@end
