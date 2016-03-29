//
//  UIView+CoreAnimation.h
//  CoreAnimationPlayGround
//
//  Created by Daniel Tavares on 27/03/2013.
//  Copyright (c) 2013 Daniel Tavares. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^ViewExplodeAnimationEnded)();

@interface UIView (Explode)

- (void)runExplodeAnimation;
- (void)runExplodeAnimation:(ViewExplodeAnimationEnded)ended;

@end
