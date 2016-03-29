//
//  LWeakRefObject.h
//  Lightcast
//
//  Created by Martin Kovachev on 27.12.13.
//  Copyright (c) 2013 г. Nimasystems Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LWeakRefObject : NSObject {
    __weak id nonretainedObjectValue;
    __unsafe_unretained id originalObjectValue;
}

+ (LWeakRefObject*)weakReferenceWithObject:(id) object;

- (id)nonretainedObjectValue;
- (void*)originalObjectValue;

@end