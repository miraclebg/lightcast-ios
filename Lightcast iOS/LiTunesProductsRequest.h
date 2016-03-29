//
//  LiTunesProductsRequest.h
//  StampiiApp
//
//  Created by Martin N. Kovachev on 16.01.13.
//
//

#import <StoreKit/StoreKit.h>
#import <Foundation/Foundation.h>
#import <LightcastiTunes/LiTunesProductsRequestDelegate.h>

extern NSString *LiTunesProductsRequestErrorDomain;

typedef enum
{
    LiTunesProductsRequestErrorUnknown = 0,
    LiTunesProductsRequestErrorGeneric = 1,
    LiTunesProductsRequestErrorInvalidParams = 2,
    LiTunesProductsRequestErrorCannotMakePayments = 3,
    LiTunesProductsRequestErrorInvalidResponse = 4,
    LiTunesProductsRequestErrorNoProductsReturned = 5
    
} LiTunesProductsRequestError;

typedef enum
{
    LiTunesProductsRequestStateUnknown = 0,
    LiTunesProductsRequestStateSuccess = 1,
    LiTunesProductsRequestStateError = 2,
    LiTunesProductsRequestStatePending = 3
    
} LiTunesProductsRequestState;

@interface LiTunesProductsRequest : NSObject <SKProductsRequestDelegate>

@property (readonly) NSArray *productIds;
@property (readonly) LiTunesProductsRequestState state;

@property (readonly) NSArray *iTunesProducts;
@property (readonly) NSArray *invalidITunesProducts;

@property (assign) id<LiTunesProductsRequestDelegate> delegate;

- (id)initWithProducts:(NSArray*)productIds_;

- (BOOL)makeRequest:(NSError**)error;
- (void)cancel;

@end