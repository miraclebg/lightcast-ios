//
//  LiTunesProductsRequestDelegate.h
//  StampiiApp
//
//  Created by Martin N. Kovachev on 16.01.13.
//
//

#import <Foundation/Foundation.h>

@class LiTunesProductsRequest;

@protocol LiTunesProductsRequestDelegate <NSObject>

@required

- (void)request:(LiTunesProductsRequest*)request didReceiveProducts:(NSArray*)products invalidProductIdentifiers:(NSArray*)invalidProductIdentifiers;
- (void)request:(LiTunesProductsRequest*)request didFailReceivingProductsWithError:(NSError*)error;

@optional

- (void)request:(LiTunesProductsRequest*)request willBeginRequest:(NSArray*)productIds;
- (void)requestDidFinish:(LiTunesProductsRequest*)request;

@end