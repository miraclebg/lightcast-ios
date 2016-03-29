//
//  NSWindow+Additions.m
//  Lightcast
//
//  Created by Martin N. Kovachev on 04.02.13.
//  Copyright (c) 2013 г. Nimasystems Ltd. All rights reserved.
//

#import "NSWindow+Additions.h"

@implementation NSWindow(Additions)

- (void)displayError:(NSError*)error
{
    NSString *errMsg = error && ![NSString isNullOrEmpty:[error localizedDescription]] ? [error localizedDescription] : LightcastLocalizedString(@"Unknown Error");
    
    [self displayAlert:LightcastLocalizedString(@"Error") description:errMsg];
}

- (void)displayError:(NSError*)error description:(NSString*)description
{
    NSString *errMsg = error && ![NSString isNullOrEmpty:[error localizedDescription]] ? [error localizedDescription] : LightcastLocalizedString(@"Unknown Error");
    
    [self displayAlert:description description:errMsg];
}

- (void)displayAlert:(NSString*)title description:(NSString*)description
{
    [GeneralUtils displayMessage:title description:description style:NSWarningAlertStyle];
}

@end
