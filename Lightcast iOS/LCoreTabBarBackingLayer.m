//
//  LCoreTabBarBackingLayer.m
//  Lightcast
//
//  Created by Martin N. Kovachev on 18.01.13.
//  Copyright (c) 2013 г. Nimasystems Ltd. All rights reserved.
//

#import "LCoreTabBarBackingLayer.h"

@implementation LCoreTabBarBackingLayer

@synthesize
gradientLayer;

#pragma mark - Initialization / Finalization

-(id)init;
{
    self = [super init];
    if (self)
    {
        gradientLayer = [[[CAGradientLayer alloc] init] autorelease];
        UIColor * startColor = [UIColor colorWithHex:0x282928];
        UIColor * endColor = [UIColor colorWithHex:0x4a4b4a];
        //gradientLayer.frame = CGRectMake(0, 0, 1024, 60);
        gradientLayer.frame = self.bounds;
        gradientLayer.colors = [NSArray arrayWithObjects:(id)[startColor CGColor], (id)[endColor CGColor], nil];
        [self insertSublayer:gradientLayer atIndex:0];
    }
    return self;
}

- (void)layoutSublayers
{
    gradientLayer.frame = self.bounds;
}

@end
