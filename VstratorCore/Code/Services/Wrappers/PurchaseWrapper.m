//
//  PurchaseWrapper.m
//  VstratorCore
//
//  Created by akupr on 14.02.13.
//  Copyright (c) 2013 OnTarget. All rights reserved.
//

#import <StoreKit/StoreKit.h>
#import "PurchaseWrapper.h"

@interface PurchaseWrapper() {
    SKProduct* theProduct;
}

@end

@implementation PurchaseWrapper

-(void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    theProduct = response.products.lastObject;
    if (theProduct)     {
        NSLog(@"Product title: %@" , theProduct.localizedTitle);
        NSLog(@"Product description: %@" , theProduct.localizedDescription);
        NSLog(@"Product price: %@" , theProduct.price);
        NSLog(@"Product id: %@" , theProduct.productIdentifier);
    }
    
    for (NSString *invalidProductId in response.invalidProductIdentifiers)     {
        NSLog(@"Invalid product id: %@" , invalidProductId);
    }
}

-(void)requestDidFinish:(SKRequest *)request
{
    self.callbackAndReleaseSelf(theProduct);
}

-(void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
    self.errorCallbackAndReleaseSelf(error);
}

@end
