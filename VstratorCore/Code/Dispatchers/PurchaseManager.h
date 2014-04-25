//
//  PurchaseManager.h
//  VstratorCore
//
//  Created by akupr on 11.02.13.
//  Copyright (c) 2013 OnTarget. All rights reserved.
//

#import "Callbacks.h"
#import <Foundation/Foundation.h>

// add a couple notifications sent out when the transaction completes
#define kInAppPurchaseManagerTransactionFailedNotification @"kInAppPurchaseManagerTransactionFailedNotification"
#define kInAppPurchaseManagerTransactionSucceededNotification @"kInAppPurchaseManagerTransactionSucceededNotification"

@class ContentSet;

@interface PurchaseManager : NSObject

-(void)purchaseContentSet:(ContentSet *)set callback:(ErrorCallback)callback;

+(PurchaseManager*)sharedInstance;

@end
