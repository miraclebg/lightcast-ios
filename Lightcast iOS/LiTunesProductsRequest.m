//
//  LiTunesProductsRequest.m
//  StampiiApp
//
//  Created by Martin N. Kovachev on 16.01.13.
//
//

#import "LiTunesProductsRequest.h"

NSString *LiTunesProductsRequestErrorDomain = @"com.lightcast.iTunesProductsRequest";

@implementation LiTunesProductsRequest {
    
    SKProductsRequest *_request;
}

@synthesize
productIds,
iTunesProducts,
invalidITunesProducts,
delegate,
state;

#pragma mark - Initialization / Finalization

- (id)initWithProducts:(NSArray*)productIds_
{
    self = [super init];
    if (self)
    {
        if (!productIds_ || ![productIds_ count])
        {
            L_RELEASE(self);
            lassert(false);
            return nil;
        }
        
        productIds = [productIds_ retain];
        iTunesProducts = nil;
        invalidITunesProducts = nil;
    }
    return self;
}

- (void)dealloc
{
    delegate = nil;
    
    if (_request)
    {
        _request.delegate = nil;
        [_request cancel];
        L_RELEASE(_request);
    }
    
    L_RELEASE(productIds);
    L_RELEASE(iTunesProducts);
    L_RELEASE(invalidITunesProducts);
    
    [super dealloc];
}

#pragma mark - SKProductsRequestDelegate methods

- (void)requestDidFinish:(SKRequest *)request {
    if (request == _request) {
        
        if (_request) {
            _request.delegate = nil;
            [_request cancel];
            L_RELEASE(_request);
        }
        
        if (delegate && [delegate respondsToSelector:@selector(requestDidFinish:)])
        {
            [delegate requestDidFinish:self];
        }
    }
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
    if (request == _request)
    {
        state = LiTunesProductsRequestStateError;

        if (delegate && [delegate respondsToSelector:@selector(request:didFailReceivingProductsWithError:)])
        {
            [delegate request:self didFailReceivingProductsWithError:error];
        }
        
        if (_request) {
            _request.delegate = nil;
            [_request cancel];
            L_RELEASE(_request);
        }
        
        if (delegate && [delegate respondsToSelector:@selector(requestDidFinish:)])
        {
            [delegate requestDidFinish:self];
        }
    }
}

// Sent immediately before -requestDidFinish:
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    if (request == _request)
    {
        if (!response)
        {
            state = LiTunesProductsRequestStateError;

            // inform the delegate
            if (delegate)
            {
                NSError *err = [NSError errorWithDomainAndDescription:LiTunesProductsRequestErrorDomain
                                                            errorCode:LiTunesProductsRequestErrorInvalidResponse
                                                 localizedDescription:LightcastLocalizedString(@"Invalid (null) response")];
                
                [delegate request:self didFailReceivingProductsWithError:err];
            }
            
            return;
        }
        
        NSArray *products = response.products;
        NSArray *invalidProducts = response.invalidProductIdentifiers;
        
        // check the products
        if (!products || ![products count])
        {
            state = LiTunesProductsRequestStateError;
            
            // inform the delegate
            if (delegate)
            {
                NSError *err = [NSError errorWithDomainAndDescription:LiTunesProductsRequestErrorDomain
                                                            errorCode:LiTunesProductsRequestErrorNoProductsReturned
                                                 localizedDescription:LightcastLocalizedString(@"No products returned")];
                
                [delegate request:self didFailReceivingProductsWithError:err];
            }
            
            return;
        }
        
        // set ids
        if (products != iTunesProducts)
        {
            L_RELEASE(iTunesProducts);
            iTunesProducts = [products copy];
        }
        
        if (invalidProducts != invalidITunesProducts)
        {
            L_RELEASE(invalidITunesProducts);
            invalidITunesProducts = [invalidProducts copy];
        }
        
        state = LiTunesProductsRequestStateSuccess;
        
        // inform the delegate
        if (delegate)
        {
            [delegate request:self didReceiveProducts:iTunesProducts invalidProductIdentifiers:invalidITunesProducts];
        }
    }
}

#pragma mark - Request

- (BOOL)makeRequest:(NSError**)error
{
    lassert([NSThread isMainThread]);
    
    if (error != NULL)
    {
        *error = nil;
    }
    
    // check if already running
    if (state == LiTunesProductsRequestStatePending)
    {
        if (error != NULL)
        {
            *error = [NSError errorWithDomainAndDescription:LiTunesProductsRequestErrorDomain
                                                  errorCode:LiTunesProductsRequestErrorGeneric
                                       localizedDescription:LightcastLocalizedString(@"Request is already running")];
        }
        
        return NO;
    }
    
    // compile products
    NSSet *set = [NSSet setWithArray:productIds];
    
    if (!set || ![set count])
    {
        if (error != NULL)
        {
            *error = [NSError errorWithDomainAndDescription:LiTunesProductsRequestErrorDomain
                                                  errorCode:LiTunesProductsRequestErrorInvalidParams
                                       localizedDescription:LightcastLocalizedString(@"Invalid payment IDs")];
        }
        
        return NO;
    }
    
    // check if store is enabled
    BOOL canMakePayments = [SKPaymentQueue canMakePayments];
    
    if (!canMakePayments)
    {
        if (error != NULL)
        {
            *error = [NSError errorWithDomainAndDescription:LiTunesProductsRequestErrorDomain
                                                  errorCode:LiTunesProductsRequestErrorCannotMakePayments
                                       localizedDescription:LightcastLocalizedString(@"Cannot make payments. Make sure that In-App-Purchases are enabed in the Settings app")];
        }
        
        return NO;
    }
    
    state = LiTunesProductsRequestStatePending;
    
    // inform the delegate
    if (delegate && [delegate respondsToSelector:@selector(request:willBeginRequest:)])
    {
        [delegate request:self willBeginRequest:productIds];
    }
    
    _request = [[SKProductsRequest alloc] initWithProductIdentifiers:set];
    _request.delegate = self;
    [_request start];
    
    return YES;
}

- (void)cancel {
    if (state != LiTunesProductsRequestStatePending) {
        return;
    }
    
    if (!_request) {
        return;
    }
    
    [_request cancel];
}

@end