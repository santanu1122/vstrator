//
//  PurchaseWrapper.h
//  VstratorCore
//
//  Created by akupr on 14.02.13.
//  Copyright (c) 2013 OnTarget. All rights reserved.
//

#import <StoreKit/StoreKit.h>
#import "CallbackWrapper.h"

@interface PurchaseWrapper : CallbackWrapper<SKProductsRequestDelegate>

@end
