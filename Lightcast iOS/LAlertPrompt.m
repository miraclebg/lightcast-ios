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
 * @changed $Id: LAlertPrompt.m 341 2014-08-28 05:21:47Z mkovachev $
 * @author $Author: mkovachev $
 * @version $Revision: 341 $
 */

#import "LAlertPrompt.h"

@implementation LAlertPrompt

@synthesize 
textField;

#pragma mark - Initialization / Finalization

- (id)initWithTitle:(NSString*)title message:(NSString*)message delegate:(id)delegate cancelButtonTitle:(NSString*)cancelButtonTitle okButtonTitle:(NSString*)okayButtonTitle
{
    // necessary to shift the buttons a bit down (below the text input)
	self = [super initWithTitle:title message:[NSString stringWithFormat:@"%@\n", message] delegate:delegate cancelButtonTitle:cancelButtonTitle otherButtonTitles:okayButtonTitle, nil];
    if (self)
    {
        if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
        {
            self.alertViewStyle = UIAlertViewStylePlainTextInput;
            self.textField = [self textFieldAtIndex:0];
        }
        else
        {
            UITextField *theTextField = [[[UITextField alloc] initWithFrame:CGRectMake(12.0, 45.0, 260.0, 25.0)] autorelease];
            [theTextField setBackgroundColor:[UIColor whiteColor]];
            [self addSubview:theTextField];
            self.textField = theTextField;
        }
        

        //CGAffineTransform myTransform = CGAffineTransformMakeScale(1.0, 0.5f);
        //[self setTransform:myTransform];
    }
    return self;
}

- (void)dealloc
{
    L_RELEASE(textField);
    
    [super dealloc];
}

#pragma mark -
#pragma mark Actions

- (void)show
{
	textField.textAlignment = UITextAlignmentCenter;
    //[textField becomeFirstResponder];
	
	[super show];
}

- (BOOL)canBecomeFirstResponder
{
    return [textField canBecomeFirstResponder];
}

- (BOOL)becomeFirstResponder
{
    return [textField becomeFirstResponder];
}

- (BOOL)canResignFirstResponder
{
    return [textField canResignFirstResponder];
}

- (BOOL)resignFirstResponder
{
    [super resignFirstResponder];
    
    return [textField resignFirstResponder];
}

- (BOOL)isFirstResponder
{
    return [textField isFirstResponder];
}

#pragma mark -
#pragma mark Getters / Setters

- (NSString *)enteredText
{
    return textField.text;
}

@end