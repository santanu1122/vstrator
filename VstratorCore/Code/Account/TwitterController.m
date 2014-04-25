//
//  TwitterController.m
//  VstratorApp
//
//  Created by Mac on 16.05.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "TwitterController.h"
#import <Accounts/ACAccount.h>
#import <Accounts/ACAccountStore.h>
#import <Accounts/ACAccountType.h>
#import <Twitter/TWRequest.h>

#import "ActionSheetSelector.h"
#import "VstratorExtensions.h"
#import "VstratorStrings.h"

@interface TwitterController()

@property (strong, nonatomic) TwitterController *selfKeeper;

@property (strong, nonatomic, readonly) ActionSheetSelector *actionSheetSelector;

@property (strong, nonatomic) NSArray *accounts;
@property (copy, nonatomic) IdentityCallback accountCallback;

// Forwards
- (void)initWithAccounts:(NSArray *)accounts inView:(UIView *)view callback:(IdentityCallback)callback;

@end

@implementation TwitterController

#pragma mark Properties

@synthesize selfKeeper = _selfKeeper;

@synthesize actionSheetSelector = _actionSheetSelector;
@synthesize accounts = _accounts;
@synthesize accountCallback = _accountCallback;

- (ActionSheetSelector *)actionSheetSelector
{
	if (_actionSheetSelector == nil) {
        _actionSheetSelector = [[ActionSheetSelector alloc] init];
        _actionSheetSelector.delegate = self;
    }
	return _actionSheetSelector;
}

#pragma mark Internal Helpers

+ (void)listTwitterAccounts:(GetItemsCallback)callback
{
    ACAccountStore *store = [[ACAccountStore alloc] init];
    ACAccountType *twitterAccountType = [store accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    [store requestAccessToAccountsWithType:twitterAccountType withCompletionHandler:^(BOOL granted, NSError *error) {
        NSArray *twitterAccounts = granted ? [store accountsWithAccountType:twitterAccountType] : nil;
        if (!granted)
            error = [NSError errorWithError:error text:VstratorStrings.ErrorAccessToTwitterAccountsDeniedText];
        if (callback)
            dispatch_async(dispatch_get_main_queue(), ^{ callback(error, twitterAccounts); });
    }];
}

+ (void)findTwitterAccount:(NSString *)accountIdentity callback:(ACAccountCallback)callback
{
    [self listTwitterAccounts:^(NSError *error, NSArray *result) {
        if (error) {
            kItemCallbackIf(callback, error, nil);
        } else {
            ACAccount *resultAccount = nil;
            if (accountIdentity != nil && result.count > 0) {
                for (ACAccount * twitterAccount in result) {
                    if ([twitterAccount.identifier isEqualToString:accountIdentity]) {
                        resultAccount = twitterAccount;
                        break;
                    }
                }
            }
            kItemCallbackIf(callback, error, resultAccount);
        }
    }];
}

#pragma mark Business Logic

+ (BOOL)availableTwitterFramework
{
    return (nil != NSClassFromString(@"TWTweetComposeViewController"));
}

+ (void)checkAccessToAccount:(NSString *)accountIdentity callback:(IdentityCallback)callback
{
    if ([self.class availableTwitterFramework]) {
        [self.class findTwitterAccount:accountIdentity callback:^(NSError *error, ACAccount *accountInfo) {
            kItemCallbackIf(callback, error, accountInfo == nil ? nil : accountInfo.identifier);
        }];
    } else {
        kItemCallbackIf(callback, [NSError errorWithText:VstratorStrings.ErrorTwitterUnderDevelopmentForIOS4Text], nil);
    }
}

+ (void)selectAccountInView:(UIView *)view callback:(IdentityCallback)callback
{
    if ([self.class availableTwitterFramework]) {
        [self.class listTwitterAccounts:^(NSError *error, NSArray *result) {
            if (error != nil) {
                kItemCallbackIf(callback, error, nil);
            } else if (result == nil) {
                kItemCallbackIf(callback, [NSError errorWithText:VstratorStrings.ErrorTwitterAccountsNotFoundText], nil);
            } else {
                [[TwitterController alloc] initWithAccounts:result inView:view callback:callback];
            }
        }];
    } else {
        kItemCallbackIf(callback, [NSError errorWithText:VstratorStrings.ErrorTwitterUnderDevelopmentForIOS4Text], nil);
    }
}

+ (void)tweet:(NSString *)tweet account:(NSString *)accountIdentity callback:(ErrorCallback)callback
{
    if ([self.class availableTwitterFramework]) {
        [self.class findTwitterAccount:accountIdentity callback:^(NSError *error0, ACAccount *accountInfo) {
            if (error0 != nil) {
                kCallbackIf(callback, error0);
            } else if (accountInfo == nil) {
                kCallbackIf(callback, [NSError errorWithText:VstratorStrings.ErrorTwitterAccountsNotFoundText]);
            } else {
                // Build a twitter request
                NSURL *twitterURL = [NSURL URLWithString:@"http://api.twitter.com/1/statuses/update.json"];
                NSDictionary *tweetParams =  @{@"status": tweet};
                TWRequest *postRequest = [[TWRequest alloc] initWithURL:twitterURL parameters:tweetParams requestMethod:TWRequestMethodPOST];
                // Post the request
                [postRequest setAccount:accountInfo];
                // Block handler to manage the response
                [postRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error1) {
                    kCallbackIf(callback, nil);
                }];
            }
        }];
    } else {
        kCallbackIf(callback, [NSError errorWithText:VstratorStrings.ErrorTwitterUnderDevelopmentForIOS4Text]);
    }
}

- (void)initWithAccounts:(NSArray *)accounts inView:(UIView *)view callback:(IdentityCallback)callback
{
    self.selfKeeper = self; //NOTE: save ourselfs
    self.accounts = accounts;
    self.accountCallback = callback;
    [self.actionSheetSelector showInView:view selectedIndex:-1];
}

#pragma mark ActionSheetSelectorDelegate

- (NSInteger)actionSheetSelectorItemsCount:(ActionSheetSelector *)sender
{
    return self.accounts.count;
}

- (NSString *)actionSheetSelector:(ActionSheetSelector *)sender itemTitleAtIndex:(NSInteger)index
{
    ACAccount *account = (self.accounts)[index];
    return account.accountDescription;
}

- (void)actionSheetSelector:(ActionSheetSelector *)sender didSelectItemAtIndex:(NSInteger)index
{
    ACAccount *account = nil;
    if (index >= 0 && index < self.accounts.count)
        account = self.accounts[index];
    if (self.accountCallback) self.accountCallback(nil, account.identifier);
    self.selfKeeper = nil; //NOTE: release ourselfs
}

- (void)actionSheetSelectorDidCancel:(ActionSheetSelector *)sender
{
    if (self.accountCallback) self.accountCallback(nil, nil);
    self.selfKeeper = nil; //NOTE: release ourselfs
}

@end
