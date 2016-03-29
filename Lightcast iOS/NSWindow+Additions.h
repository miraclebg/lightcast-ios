//
//  NSWindow+Additions.h
//  Lightcast
//
//  Created by Martin N. Kovachev on 04.02.13.
//  Copyright (c) 2013 г. Nimasystems Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSWindow(Additions)

- (void)displayError:(NSError*)error;
- (void)displayError:(NSError*)error description:(NSString*)description;
- (void)displayAlert:(NSString*)title description:(NSString*)description;

@end
