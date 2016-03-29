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
 * @changed $Id: LAlertPrompt.h 141 2011-08-16 06:17:58Z mkovachev $
 * @author $Author: mkovachev $
 * @version $Revision: 141 $
 */

/**
 *	@brief Customized UIAlertView with text input
 *
 *	@author Martin Kovachev (miracle@nimasystems.com), Nimasystems Ltd
 */
@interface LAlertPrompt : UIAlertView
{
    UITextField *textField;
}

@property (nonatomic, retain) UITextField *textField;
@property (nonatomic, readonly) NSString *enteredText;

/** Initializes and shows the alert with the specified options
 *	@param NSString title The title of the alert
 *	@param id delegate The delegated object which should receive an event when any of the buttons have been pressed (along with the typed in text)
 *	@param NSString cancelButtonTitle The title of the CANCEL button
 *	@param NSString okButtonTitle The title of the OK button
 *	@return Returns the initialized alert box
 */
- (id)initWithTitle:(NSString*)title message:(NSString*)message delegate:(id)delegate cancelButtonTitle:(NSString*)cancelButtonTitle okButtonTitle:(NSString*)okButtonTitle;

@end