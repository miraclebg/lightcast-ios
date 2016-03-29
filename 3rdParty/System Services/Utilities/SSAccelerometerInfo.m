//
//  SSAccelerometerInfo.m
//  SystemServicesDemo
//
//  Created by Kramer on 9/20/12.
//  Copyright (c) 2012 Shmoopi LLC. All rights reserved.
//

#import "SSAccelerometerInfo.h"

@implementation SSAccelerometerInfo

// Accelerometer Information

// Device Orientation
+ (UIInterfaceOrientation)DeviceOrientation {
    // Get the device's current orientation
    @try {
        // Device orientation
        UIInterfaceOrientation Orientation = [[UIApplication sharedApplication] statusBarOrientation];
        
        // Successful
        return Orientation;
    }
    @catch (NSException *exception) {
        // Error
        return -1;
    }
}

// Accelerometer X Value
/*+ (float)AccelerometerXValue {
    // Get the accelerometer X value
    @try {
        // Set up the accelerometer
        UIAcceleration *Accelerometer = [UIAcceleration alloc];
        // Get the X value
        float CurrentAccelerationXValue = Accelerometer.x;
        // Successful
        return CurrentAccelerationXValue;
    }
    @catch (NSException *exception) {
        // Error
        return -1;
    }
}

// Accelerometer Y Value
+ (float)AccelerometerYValue {
    // Get the accelerometer Y value
    @try {
        // Set up the accelerometer
        UIAcceleration *Accelerometer = [UIAcceleration alloc];
        // Get the Y value
        float CurrentAccelerationYValue = Accelerometer.y;
        // Successful
        return CurrentAccelerationYValue;
    }
    @catch (NSException *exception) {
        // Error
        return -1;
    }
}

// Accelerometer Z Value
+ (float)AccelerometerZValue {
    // Get the accelerometer Z value
    @try {
        // Set up the accelerometer
        UIAcceleration *Accelerometer = [UIAcceleration alloc];
        // Get the Z value
        float CurrentAccelerationZValue = Accelerometer.z;
        // Successful
        return CurrentAccelerationZValue;
    }
    @catch (NSException *exception) {
        // Error
        return -1;
    }
}*/

@end
