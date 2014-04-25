//
//  PurchaseManager.m
//  VstratorCore
//
//  Created by akupr on 11.02.13.
//  Copyright (c) 2013 OnTarget. All rights reserved.
//

#import <StoreKit/StoreKit.h>
#import "ContentSet+Extensions.h"
#import "MediaService.h"
#import "NSError+Extensions.h"
#import "PurchaseManager.h"
#import "PurchaseWrapper.h"
#import "ServiceFactory.h"

static PurchaseManager* SharedInstance;

@interface PurchaseManager() <SKPaymentTransactionObserver>

@property (nonatomic, readonly) id<DownloadService> downloadService;
@property (nonatomic, readonly) MediaService* mediaService;

@end

@implementation PurchaseManager

#pragma mark - Properties

@synthesize downloadService = _downloadService;
@synthesize mediaService = _mediaService;

+(PurchaseManager *)sharedInstance
{
    return SharedInstance ? SharedInstance : (SharedInstance = [PurchaseManager new]);
}

-(id<DownloadService>)downloadService
{
    return _downloadService ? _downloadService : (_downloadService = [[ServiceFactory sharedInstance] createDownloadService]);
}

-(MediaService *)mediaService
{
	return _mediaService ? _mediaService : (_mediaService = [MediaService new]);
}

#pragma mark - Ctor/Dtor

-(id)init
{
    self = [super init];
    if (self) {
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    }
    return self;
}

-(void)dealloc
{
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}

#pragma mark -

-(void)purchaseContentSet:(ContentSet *)set callback:(ErrorCallback)callback
{
    if (set.isPurchased || !set.inAppPurchaseID) {
        [set downloadAll];
        callback(nil);
        return;
    }
    NSSet *identifiers = [NSSet setWithObject:set.inAppPurchaseID];
    SKProductsRequest* request = [[SKProductsRequest alloc] initWithProductIdentifiers:identifiers];
    PurchaseWrapper* wrapper = [PurchaseWrapper wrapperWithCallback:^(SKProduct* product) {
        if (!product) {
            callback([NSError errorWithText:[NSString stringWithFormat:@"Cannot get purchase with identifier '%@'", identifiers.anyObject]]);
        } else {
            [[SKPaymentQueue defaultQueue] addPayment:[SKPayment paymentWithProduct:product]];
            callback(nil);
        }
    } errorCallback:^(NSError* error) {
        callback(error);
    }];
    request.delegate = wrapper;
    [request start];
}

#pragma mark - SKPaymentTransactionObserver

-(void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
                break;
            default:
                break;
        }
    }
}

#pragma mark - Helpers

//
// removes the transaction from the queue and posts a notification with the transaction result
//
- (void)finishTransaction:(SKPaymentTransaction *)transaction withError:(NSError*)error
{
    // remove the transaction from the payment queue.
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:!error ?
        kInAppPurchaseManagerTransactionSucceededNotification : kInAppPurchaseManagerTransactionFailedNotification
                                                        object:self
                                                      userInfo:@{@"transaction" : transaction }];
    if (!error) {
        [self.mediaService contentSetByProductID:transaction.payment.productIdentifier callback:^(ContentSet *contentSet, NSError *fetchError) {
            if (fetchError) {
                NSLog(@"Cannot fetch content set. Error: %@", fetchError);
            } else if (!contentSet) {
                NSLog(@"Cannot fetch content set with identity '%@'", transaction.payment.productIdentifier);
            } else {
                for (DownloadContent* content in contentSet.contents) {
                    if (content.status.intValue < DownloadContentStatusRequested)
                        [content addToDownloadQueue];
                }
                [self.mediaService saveChangesSync];
            }
        }];
    } else {
        NSLog(@"Cannot download content set. Error: %@", error);
    }
}

//
// called when the transaction was successful
//
- (void)completeTransaction:(SKPaymentTransaction *)transaction
{
    [self provideContent:transaction callback:^(NSError *error) {
        [self finishTransaction:transaction withError:error];
    }];
}

//
// called when a transaction has been restored and and successfully completed
//
- (void)restoreTransaction:(SKPaymentTransaction *)transaction
{
    [self provideContent:transaction.originalTransaction callback:^(NSError *error) {
        [self finishTransaction:transaction withError:error];
    }];
}

//
// called when a transaction has failed
//
- (void)failedTransaction:(SKPaymentTransaction *)transaction
{
    if (transaction.error.code != SKErrorPaymentCancelled) {
        // error!
        [self finishTransaction:transaction withError:transaction.error];
    } else {
        // this is fine, the user just cancelled, so don’t notify
        [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    }
}

//
// saves a record of the transaction by storing the receipt to disk
//
- (void)provideContent:(SKPaymentTransaction *)transaction callback:(ErrorCallback)callback
{
    NSString* identifier = transaction.payment.productIdentifier;
    [self.mediaService contentSetByProductID:identifier callback:^(ContentSet* set, NSError* getContentError){
        __block NSError* error = getContentError;
        if (set) {
            __block NSDictionary* updatedContentSet = nil;
            dispatch_semaphore_t ds = dispatch_semaphore_create(0);
            [self.downloadService validateReceipt:transaction.transactionReceipt
                            forContentSetIdentity:set.identity
                                         callback:^(NSDictionary *object, NSError *validateError)
             {
                 error = validateError;
                 updatedContentSet = object;
                 dispatch_semaphore_signal(ds);
             }];
            dispatch_semaphore_wait(ds, DISPATCH_TIME_FOREVER);
            dispatch_release(ds);
            if (!error) {
                [set updateWithObject:updatedContentSet];
                [set downloadAll];
                [self.mediaService saveChangesSync];
            }
        } else if (!getContentError) {
            error =  [NSError errorWithText:[NSString stringWithFormat:@"Cannot find content set with product identifier \'%@\'", identifier]];
        }
        callback(error);
    }];
}

@end
