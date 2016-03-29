//
//  NSBundle+Additions.h
//  Lightcast
//
//  Created by Martin N. Kovachev on 12.02.13.
//  Copyright (c) 2013 г. Nimasystems Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSBundle(Additions)

- (BOOL)loadNibNamedL:(NSString *)nibName owner:(id)owner topLevelObjects:(NSArray **)topLevelObjects;

@end
