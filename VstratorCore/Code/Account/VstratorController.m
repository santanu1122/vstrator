//
//  VstratorController.m
//  VstratorApp
//
//  Created by Mac on 07.05.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "VstratorController.h"
#import "AccountInfo.h"
#import "Issue.h"
#import "Reachability.h"
#import "RegistrationInfo.h"
#import "ServiceFactory.h"
#import "VstratorExtensions.h"
#import "VstratorStrings.h"


@interface VstratorController()

@property (strong, nonatomic, readonly) id<UsersService> usersService;

@end


@implementation VstratorController

#pragma mark - Shared Instance

static VstratorController * _sharedInstance = nil;

+ (VstratorController *)sharedInstance
{
    if (_sharedInstance == nil) {
        _sharedInstance = [[self.class alloc] init];
    }
    return _sharedInstance;
}

#pragma mark - Instance Properties

@synthesize usersService = _usersService;

- (id<UsersService>)usersService
{
    if (_usersService == nil) {
        _usersService = [[ServiceFactory sharedInstance] createUsersService];
    }
    return _usersService;
}

#pragma mark - Internal Logic

- (void)reloadAccount:(AccountInfo *)account
            loadImage:(BOOL)loadImage
             fallback:(BOOL)fallback
             callback:(AccountInfoCallback)callback
{
    AccountInfo *newAccount = [AccountInfo accountWithAccount:account];
    // authentication
    if (account.accountType == UserAccountTypeVstrator) {
        [[ServiceFactory sharedInstance] setVstratorAuthWithEmail:account.email password:account.password];
    } else if (account.accountType == UserAccountTypeFacebook) {
        [[ServiceFactory sharedInstance] setFacebookAuthWithIdentity:account.facebookIdentity accessToken:account.facebookAccessToken];
    } else {
        if (callback) callback([NSError errorWithText:VstratorStrings.ErrorUnknownAccountTypeText], newAccount);
        return;
    }
    // reload user from online if possible
    if (Reachability.reachabilityForInternetConnection.isReachable) {
        [self.usersService getUserInfo:^(VstratorUserInfo *info, NSError *error) {
            if (error) {
                // fallback with offline, if error is network-related
                if (error.isURLTransferError) {
                    newAccount.syncState = UserSyncStateFallback;
                    newAccount.syncSummary = error.localizedDescription;
                    if (callback) callback(nil, newAccount);
                }
                // failure
                else {
                    newAccount.syncState = UserSyncStateFail;
                    newAccount.syncSummary = error.localizedDescription;
                    if (callback) callback(error, newAccount);
                }
            } else {
                newAccount.syncState = UserSyncStateSuccess;
                newAccount.syncSummary = nil;
                if (loadImage) {
                    [self.usersService getPicture:^(UIImage *image, NSError *dontUsedError) {
                        if (error) {
                            [newAccount updateWithVstratorUserInfo:info];
                        } else {
                            [newAccount updateWithVstratorUserInfo:info image:image];
                        }
                        if (callback) callback(nil, newAccount);
                    }];
                } else {
                    [newAccount updateWithVstratorUserInfo:info];
                    if (callback) callback(nil, newAccount);
                }
            }
        }];
    }
    // fallback with offline
    else if (fallback) {
        newAccount.syncState = UserSyncStateFallback;
        newAccount.syncSummary = VstratorStrings.ErrorVstratorApiIsUnreachableText;
        if (callback) callback(nil, newAccount);
    }
    // failure
    else {
        newAccount.syncState = UserSyncStateFail;
        newAccount.syncSummary = VstratorStrings.ErrorVstratorApiIsUnreachableText;
        if (callback) callback([NSError errorWithText:newAccount.syncSummary], newAccount);
    }
}

#pragma mark - Business Logic

- (void)logout
{
    [[ServiceFactory sharedInstance] clearAuth];
}

- (void)loginWithAccount:(AccountInfo *)account
                fallback:(BOOL)fallback
                callback:(AccountInfoCallback)callback
{
    [self reloadAccount:account loadImage:YES fallback:fallback callback:callback];
}

- (void)loginWithEmail:(NSString *)email
              password:(NSString *)password
              callback:(AccountInfoCallback)callback
{
    // make an account
    AccountInfo *account = [AccountInfo accountWithAccountType:UserAccountTypeVstrator];
    account.email = email;
    account.password = password;
    // perform
    [self loginWithAccount:account fallback:NO callback:callback];
}

- (void)registerWithFirstName:(NSString *)firstName
                     lastName:(NSString *)lastName
                        email:(NSString *)email
                     password:(NSString *)password
             primarySportName:(NSString *)primarySportName
                     callback:(AccountInfoCallback)callback
{
    // create account copy
    AccountInfo *account = [AccountInfo accountWithAccountType:UserAccountTypeVstrator];
    account.firstName = firstName;
    account.lastName = lastName;
    account.email = email;
    account.password = password;
    account.primarySportName = primarySportName;
    // register
    [self registerAccount:account callback:callback];
}

- (void)registerAccount:(AccountInfo *)account
               callback:(AccountInfoCallback)callback
{
    // online only
    if (!Reachability.reachabilityForInternetConnection.isReachable) {
        if (callback) callback([NSError errorWithText:VstratorStrings.ErrorVstratorApiIsUnreachableText], nil);
        return;
    }
    // perform
    RegistrationInfo* info = [[RegistrationInfo alloc] initWithEmail:account.email
                                                    facebookIdentity:account.facebookIdentity
                                                           firstName:account.firstName
                                                            lastName:account.lastName
                                                            password:account.password
                                                    primarySportName:account.primarySportName];
    [self.usersService registerUser:info callback:^(NSError *error) {
        if (error) {
            if (callback) callback(error, nil);
        } else {
            [self reloadAccount:account loadImage:YES fallback:NO callback:callback];
        }
    }];
}

- (void)changeAccountPassword:(AccountInfo *)account
              fromOldPassword:(NSString *)oldPassword
                toNewPassword:(NSString *)newPassword
                     callback:(AccountInfoCallback)callback
{
    // online only
    if (!Reachability.reachabilityForInternetConnection.isReachable) {
        NSError *error = [NSError errorWithText:VstratorStrings.ErrorVstratorApiIsUnreachableText];
        if (callback) callback(error, nil);
        return;
    }
    // perform
    if ([(oldPassword == nil ? @"" : oldPassword) isEqualToString:account.password]) {
        [self.usersService changeUserPassword:oldPassword toNewPassword:newPassword callback:^(NSError *error) {
            if (error) {
                if (callback) callback(error, nil);
            } else {
                account.password = newPassword;
                [self reloadAccount:account loadImage:NO fallback:NO callback:callback];
            }
        }];
    } else {
        if (callback) callback([NSError errorWithText:VstratorStrings.ErrorOldPasswordIsNotValidText], nil);
    }
}

- (void)updateAccount:(AccountInfo *)account
        withFirstName:(NSString *)firstName
             lastName:(NSString *)lastName
     primarySportName:(NSString *)primarySportName
                image:(NSData *)image
             callback:(AccountInfoCallback)callback
{
    // create account copy
    AccountInfo *newAccount = [AccountInfo accountWithAccount:account];
    newAccount.firstName = firstName;
    newAccount.lastName = lastName;
    if (primarySportName != nil) {
        newAccount.primarySportName = primarySportName;
    }
    if (image != nil) {
        newAccount.picture = image;
    }
    // update it
    [self updateAccount:newAccount callback:callback];
}

- (void)updateAccount:(AccountInfo *)account
             callback:(AccountInfoCallback)callback
{
    if (!Reachability.reachabilityForInternetConnection.isReachable) {
        NSError *error = [NSError errorWithText:VstratorStrings.ErrorVstratorApiIsUnreachableText];
        if (callback) callback(error, nil);
        return;
    }
    VstratorUserInfo *info = [[VstratorUserInfo alloc] initWithEmail:account.email
                                                    facebookIdentity:account.facebookIdentity
                                                           firstName:account.firstName
                                                            lastName:account.lastName
                                                          pictureUrl:account.pictureUrl
                                                    primarySportName:account.primarySportName
                                                    vstratorIdentity:account.vstratorIdentity
                                                    vstratorUserName:account.vstratorUserName];
    [self.usersService changeUserInfo:info callback:^(NSError* error) {
        if (error) {
            if (callback) callback(error, nil);
        } else {
            if (account.picture == nil) {
                [self reloadAccount:account loadImage:YES fallback:NO callback:callback];
            } else {
                [self.usersService changePicture:account.picture withFormat:pngImageFormat callback:^(NSError* dontUsedError) {
                    [self reloadAccount:account loadImage:YES fallback:NO callback:callback];
                }];
            }
        }
    }];
}

- (void)reloadAccount:(AccountInfo *)account
             fallback:(BOOL)fallback
             callback:(AccountInfoCallback)callback
{
    [self reloadAccount:account loadImage:YES fallback:fallback callback:callback];
}

- (void)sendIssueFromAccount:(AccountInfo *)account
                    withType:(IssueTypeKey)issueType
                 description:(NSString *)description
                    callback:(ErrorCallback)callback
{
    if (Reachability.reachabilityForInternetConnection.isReachable) {
        [self.usersService sendIssue:[[Issue alloc] initWithIssueType:issueType andDescription:description]
                            callback:^(NSError* error) { if(callback) callback(error); }];
    } else {
        if (callback) callback([NSError errorWithText:VstratorStrings.ErrorVstratorApiIsUnreachableText]);
    }
}

@end
