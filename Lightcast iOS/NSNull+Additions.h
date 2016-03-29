//
//  NSNull+Additions.h
//  Lightcast
//
//  Created by Martin N. Kovachev on 21.05.13.
//  Copyright (c) 2013 г. Nimasystems Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSNull(Additions)

/** Returns a valid SQL value string (escaped) or 'NULL' string if the string is empty or NIL
 *	@param id aKey The input string
 *	@return NSString Returns the escaped string
 */
- (NSString *)getStrWithNullValue:(id)aKey;

- (NSString *)sqlString:(id)aKey;

/** Returns the integer representation of the 'aKey' object
 *	@param id aKey An object
 *	@return int Returns the integer value of the object
 */
- (int)sqlInt:(id)aKey;

/** Returns the float representation of the 'aKey' object
 *	@param id aKey An object
 *	@return int Returns the float value of the object
 */
- (float)sqlFloat:(id)aKey;

/** Returns a properly escaped date string
 *	@param id aKey The date, datetime string
 *	@return NSString Returns the properly escaped datetime string
 */
- (NSString *)sqlDate:(id)aKey;

- (int)intFromSql:(id)aKey;
- (float)floatFromSql:(id)aKey;
- (NSString*)stringFromSql:(id)aKey;

- (id)nilifiedObjectForKey:(NSString*)key;
- (NSInteger)intForKey:(NSString*)key;
- (BOOL)boolForKey:(NSString*)key;
- (double)doubleForKey:(NSString*)key;
- (NSDate*)dateForKey:(NSString*)key format:(NSString*)dateFormat;

- (NSString *)addSlashes;
- (NSString *)stripSlashes;

- (NSString *)getStrWithNullValue;
- (NSString *)sqlString;
- (int)sqlInt;
- (float)sqlFloat;
- (NSString *)sqlDate;

@end
