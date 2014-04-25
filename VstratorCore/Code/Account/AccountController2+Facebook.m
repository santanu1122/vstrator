//
//  AccountController2+Facebook.m
//  VstratorApp
//
//  Created by Mac on 25.07.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "AccountController2+Facebook.h"
#import "FacebookService.h"
#import "MediaService.h"
#import "Reachability.h"
#import "VstratorController.h"
#import "VstratorExtensions.h"
#import "VstratorStrings.h"

@interface AccountController2 () <FacebookServiceDelegate>

@end

#pragma mark -

@implementation AccountController2 (Facebook)

#pragma mark Properties

ErrorCallback _facebookLoginCallback;
FacebookService *_facebookService;
FacebookUserInfo *_fallbackUserInfo;

- (FacebookService *)facebookService
{
    if (_facebookService == nil) {
        _facebookService = [[FacebookService alloc] initWithDelegate:self];
    }
    return _facebookService;
}

#pragma mark Business Logic

- (void)loginFacebook:(ErrorCallback)callback
{
    [self loginFacebookWithAccount:nil callback:callback];
}

- (void)loginFacebookWithAccount:(AccountInfo *)account callback:(ErrorCallback)callback
{
    _facebookLoginCallback = callback;
    // fallback info
    BOOL accountAllowsFallback = (account != nil && ![NSString isNilOrEmpty:account.facebookIdentity] && ![NSString isNilOrEmpty:account.facebookAccessToken]);
    _fallbackUserInfo = nil;
    if (accountAllowsFallback) {
        _fallbackUserInfo = [[FacebookUserInfo alloc] initWithEmail:account.email facebookIdentity:account.facebookIdentity firstName:account.firstName lastName:account.lastName];
    }
    // online part
    if (Reachability.reachabilityForInternetConnection.isReachable || !accountAllowsFallback) {
        if (self.facebookService.loggedIn) {
            [self fbDidLogin];
        } else {
            [self.facebookService authorize];
        }
    }
    // offline login
    else {
        self.facebookService.accessToken = account.facebookAccessToken;
        self.facebookService.expirationDate = account.facebookExpirationDate;
        [self fbDidLogin];
    }
}

- (void)logoutFacebook
{
    [self updateUserWithFacebookAccessToken:nil expirationDate:nil];
    [self.facebookService logout];
}

- (void)postOnFacebookWall:(NSString *)message callback:(ErrorCallback)callback
{
    [self loginFacebook:^(NSError *error0) {
        if (error0 == nil) {
            [self.facebookService postStatus:message callback:^(NSError *error1) {
                kCallbackIf_GCD(callback, error1);
            }];
        } else {
            kCallbackIf_GCD(callback, error0);
        }
    }];
}

- (void)handleFacebookDidBecomeActive
{
    [self.facebookService handleDidBecomeActive];
}

- (BOOL)handleFacebookOpenURL:(NSURL *)url
{
    return [self.facebookService handleOpenURL:url];
}

#pragma mark FacebookService Logic

- (void)finishFacebookLogin:(NSError *)error withValidSession:(BOOL)sessionValid
{
    ErrorCallback callback = _facebookLoginCallback;
    // flush internal state
    _facebookLoginCallback = nil;
    _fallbackUserInfo = nil;
    // callback in main thread
    kCallbackIf_GCD(callback, error);
}

- (void)processFacebookInfo:(FacebookUserInfo *)info callback:(ErrorCallback)callback
{
    // pre-condition: user is not logged in here
    
    // blocks
    AccountInfoCallback accountInfoCallback = [self createOrUpdateUserAccountCallback:callback];
    AccountInfoCallback loginOrRegisterCallback = [^(NSError *error, AccountInfo *account) {
        account.facebookIdentity = info.facebookIdentity;
        account.facebookAccessToken = self.facebookService.accessToken;
        account.facebookExpirationDate = self.facebookService.expirationDate;
        [account updateWithFacebookUserInfo:info];
        // try to login or register the user in the Vstrator
        [VstratorController.sharedInstance reloadAccount:account fallback:NO callback:^(NSError *error1, AccountInfo *accountReloaded) {
            if (error1 != nil && error1.code == VstratorConstants.VstratorUnauthorizedRequestErrorCode) {
                [VstratorController.sharedInstance logout];
                [VstratorController.sharedInstance registerAccount:account callback:accountInfoCallback];
            } else {
                accountInfoCallback(error1, accountReloaded);
            }
        }];
    } copy];
    
    // if user is registered, we should try to find somebody with this facebook identity
    if (self.userRegistered) {
        [MediaService.mainThreadInstance findUserWithFacebookIdentity:info.facebookIdentity callback:^(NSError *error0, User *user) {
            // user not found - try to login or register with Vstrator
            if (user == nil) {
                AccountInfo *account = [AccountInfo accountWithAccountType:UserAccountTypeFacebook];
                loginOrRegisterCallback(nil, account);
            }
            // user is found
            else {
                AccountInfo *account = nil;
                BOOL allowFallbackOnReloadAccount = NO;
                // ...this is current user - replace its FB auth
                if ([user.identity isEqualToString:self.userIdentity]) {
                    allowFallbackOnReloadAccount = YES;
                    account = [AccountInfo accountWithAccountType:UserAccountTypeFacebook account:self.userAccount];
                }
                // ...this is other user - switch the record
                else {
                    account = [AccountInfo accountWithAccountType:UserAccountTypeFacebook user:user];
                }
                // update account information
                account.facebookIdentity = info.facebookIdentity;
                account.facebookAccessToken = self.facebookService.accessToken;
                account.facebookExpirationDate = self.facebookService.expirationDate;
                // proceed with Vstrator: ...login only
                [VstratorController.sharedInstance reloadAccount:account fallback:allowFallbackOnReloadAccount callback:accountInfoCallback];
            }
        }];
    }
    // if user is not registered (first authentication)
    else {
        AccountInfo *account = [AccountInfo accountWithAccountType:UserAccountTypeFacebook account:self.userAccount];
        loginOrRegisterCallback(nil, account);
    }
}

- (void)updateUserWithFacebookAccessToken:(NSString *)accessToken
                           expirationDate:(NSDate *)expirationDate
{
    AccountInfo *userCopy = self.userAccount; // avoid multiple locks with @synchronize
    if ([userCopy.facebookAccessToken isEqualToString:accessToken] && [userCopy.facebookExpirationDate isEqualToDate:expirationDate])
        return;
    [self updateUserLocally:^(NSError *error, AccountInfo *accountInfo) {
        accountInfo.facebookAccessToken = accessToken;
        accountInfo.facebookExpirationDate = expirationDate;
    } andSaveWithCallback:nil];
}

- (void)updateUserWithFacebookIdentity:(NSString *)identity
                              callback:(ErrorCallback)callback
{
    AccountInfo *userCopy = self.userAccount; // avoid multiple locks with @synchronize
    if ([userCopy.facebookIdentity isEqualToString:identity]) {
        kCallbackIf_GCD(callback, nil)
    } else if (self.userLoggedIn) {
        [VstratorController.sharedInstance updateAccount:userCopy callback:[self createOrUpdateUserAccountCallback:callback]];
    } else {
        kCallbackIf_GCD(callback, [NSError errorWithText:VstratorStrings.ErrorUserNotLoggedInText]);
    }
}

#pragma mark FacebookServiceDelegate

- (void)fbDidLogin
{
    // if user is logged in, just update its data with FB info
    if (self.userLoggedIn) {
        [self updateUserWithFacebookAccessToken:self.facebookService.accessToken expirationDate:self.facebookService.expirationDate];
        if (self.userAccountType == UserAccountTypeFacebook) {
            [self finishFacebookLogin:nil withValidSession:YES];
        } else {
            [self.facebookService getUserInfo:^(NSError *error0, FacebookUserInfo *info) {
                if (error0 == nil && ![self.userAccount.facebookIdentity isEqualToString:info.facebookIdentity]) {
                    [self updateUserWithFacebookIdentity:info.facebookIdentity callback:^(NSError *error1) {
                        [self finishFacebookLogin:error1 withValidSession:YES];
                    }];
                } else {
                    [self finishFacebookLogin:error0 withValidSession:YES];
                }
            }];
        }
    }
    // if user is not logged in
    else {
        [self.facebookService getUserInfo:^(NSError *error0, FacebookUserInfo *info) {
            if (error0 == nil) {
                [self processFacebookInfo:info callback:^(NSError *error1) {
                    [self finishFacebookLogin:error1 withValidSession:YES];
                }];
            } else if (error0.isURLTransferError && _fallbackUserInfo != nil) {
                // offline error
                [self processFacebookInfo:_fallbackUserInfo callback:^(NSError *error1) {
                    [self finishFacebookLogin:error1 withValidSession:YES];
                }];
            } else {
                [self finishFacebookLogin:error0 withValidSession:YES];
            }
        }];
    }
}

- (void)fbDidLogout
{
    [self updateUserWithFacebookAccessToken:nil expirationDate:nil];
}

- (void)fbLoginFailed
{
    NSError *error = [NSError errorWithText:VstratorStrings.ErrorLoginCanceled];
    [self finishFacebookLogin:error withValidSession:NO];
}

- (void)fbDidExtendToken:(NSString*)accessToken
               expiresAt:(NSDate*)expiresAt
{
    [self updateUserWithFacebookAccessToken:accessToken expirationDate:expiresAt];
}

@end
