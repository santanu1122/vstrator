//
//  AccountController2.m
//  VstratorApp
//
//  Created by Mac on 07.05.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "AccountController2.h"
#import "AccountController2+Facebook.h"
#import "MediaService.h"
#import "TwitterController.h"
#import "VstratorController.h"
#import "VstratorExtensions.h"
#import "ServiceFactory.h"
#import "VstratorStrings.h"

NSString * const VAUploadOptionsChangedNotification = @"VAUploadOptionsChangedNotification";

#pragma mark -

@implementation AccountController2

#pragma mark Constants and Defines

NSString * const VAUserIdentityChangedNotification = @"VAUserIdentityChangedNotification";
NSString * const VAUserLoggedInChangedNotification = @"VAUserLoggedInChangedNotification";

//NOTE: DO NOT CHANGE following defines to keep background compatibility on updates
#define kVAUserAccountTypeKey @"RecentUserAccountTypeKey"
#define kVAUserIdentityKey @"RecentUserIdentityKey"
#define kVAUserHasRecentLoginKey @"UserHasRecentLoginKey"
#define kVAUserRegisteredKey @"UserRegisteredKey"

#pragma mark Shared Instance

static AccountController2 * _sharedInstance = nil;

+ (AccountController2 *)sharedInstance
{
    NSParameterAssert(_sharedInstance != nil);
    return _sharedInstance;
}

#pragma mark Properties

@synthesize userAccount = _userAccount;
@synthesize userLoggedIn = _userLoggedIn;

- (AccountInfo *)userAccount
{
    @synchronized(self) {
        NSParameterAssert(_userAccount != nil);
        return [AccountInfo accountWithAccount:_userAccount];
    }
}

- (void)setUserAccount:(AccountInfo *)userAccount
{
    NSParameterAssert(userAccount != nil);
    // save existing identity
    BOOL userAccountTypeChanged = NO, userIdentityChanged = NO, userRegisteredChanged = NO;
    // update properties
    @synchronized(self) {
        // ...userAccount
        _userAccount = [AccountInfo accountWithAccount:userAccount];
        // ...userAccountType
        UserAccountType userAccountTypeValue = [NSUserDefaults.standardUserDefaults integerForKey:kVAUserAccountTypeKey];
        userAccountTypeChanged = (userAccountTypeValue != userAccount.accountType);
        if (userAccountTypeChanged)
            [NSUserDefaults.standardUserDefaults setInteger:userAccount.accountType forKey:kVAUserAccountTypeKey];
        // ...userIdentity
        NSString *userIdentityValue = [NSUserDefaults.standardUserDefaults objectForKey:kVAUserIdentityKey];
        userIdentityChanged = ![userIdentityValue isEqualToString:userAccount.identity];
        if (userIdentityChanged)
            [NSUserDefaults.standardUserDefaults setObject:userAccount.identity forKey:kVAUserIdentityKey];
        // ...userRegistered (fix for FB login issue when upgrading from RB R/U1 to Latest)
        userRegisteredChanged = ![NSString isNilOrWhitespace:userAccount.vstratorIdentity] && [NSUserDefaults.standardUserDefaults objectForKey:kVAUserRegisteredKey] == nil;
        if (userRegisteredChanged)
            [NSUserDefaults.standardUserDefaults setBool:YES forKey:kVAUserRegisteredKey];
    }
    // persistent save
    if (userIdentityChanged || userAccountTypeChanged || userRegisteredChanged)
        [NSUserDefaults.standardUserDefaults synchronize];
    // post notification
    if (userIdentityChanged)
        [NSNotificationCenter.defaultCenter postNotificationName:VAUserIdentityChangedNotification object:nil];
}

- (UserAccountType)userAccountType
{
    //NOTE: this value is set in setUserAccount: method
    @synchronized(self) {
        return [NSUserDefaults.standardUserDefaults integerForKey:kVAUserAccountTypeKey];
    }
}

- (NSString *)userIdentity
{
    //NOTE: this value is set in setUserAccount: method
    @synchronized(self) {
        return [NSUserDefaults.standardUserDefaults objectForKey:kVAUserIdentityKey];
    }
}

- (BOOL)userHasRecentLogin
{
    //NOTE: the value is set in setUserLoggedIn: method
    @synchronized(self) {
        return [NSUserDefaults.standardUserDefaults boolForKey:kVAUserHasRecentLoginKey];
    }
}

- (BOOL)userLoggedIn
{
    @synchronized(self) {
        return _userLoggedIn;
    }
}

- (void)setUserLoggedIn:(BOOL)userLoggedIn
{
    BOOL userLoggedInChanged = NO;
    // update property
    @synchronized(self) {
        userLoggedInChanged = _userLoggedIn != userLoggedIn;
        if (userLoggedInChanged) {
            _userLoggedIn = userLoggedIn;
            [NSUserDefaults.standardUserDefaults setBool:userLoggedIn forKey:kVAUserHasRecentLoginKey];
            if (userLoggedIn)
                [NSUserDefaults.standardUserDefaults setBool:YES forKey:kVAUserRegisteredKey];
        }
    }
    // related staff
    if (userLoggedInChanged) {
        // ...persistent save
        [NSUserDefaults.standardUserDefaults synchronize];
        // ...post notification
        [NSNotificationCenter.defaultCenter postNotificationName:VAUserLoggedInChangedNotification object:nil];
    }
}

- (BOOL)userRegistered
{
    //NOTE: the value is set in setUserLoggedIn: method
    @synchronized(self) {
        return [NSUserDefaults.standardUserDefaults boolForKey:kVAUserRegisteredKey];
    }
}

#pragma mark Ctors/Dtors

+ (void)initialize:(ErrorCallback)callback
{
    AccountController2 *sharedInstance = [[self.class alloc] init];
    [sharedInstance findRecentOrCreateNewUser:^(NSError *error, User *user) {
        if (error == nil) {
            _sharedInstance = sharedInstance;
            _sharedInstance.userAccount = [AccountInfo accountWithAccountType:_sharedInstance.userAccountType user:user];
        }
        kCallbackIf_GCD(callback, error);
    }];
}

- (id)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didReceivedFaultNotification:)
                                                     name:[VstratorConstants FaultNotification]
                                                   object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:[VstratorConstants FaultNotification]
                                                  object:nil];
}

#pragma mark Notifications

-(void)didReceivedFaultNotification:(NSNotification*)notification
{
    NSLog(@"Notification %@ received", notification);
    //Fault* fault = notification.object;
    //TODO: parse fault
}

#pragma mark Internal Logic

- (void)createOrUpdateUserAccount:(AccountInfo *)account
              updateLoggedInState:(BOOL)updateLoggedInState
                         callback:(ErrorCallback)callback
{
    [MediaService.mainThreadInstance findOrCreateUserWithIdentity:account.identity andUpdateWithAccountInfo:account callback:^(NSError *error0, User *user) {
        if (error0 == nil) {
            [MediaService.mainThreadInstance saveChanges:^(NSError *error1) {
                if (error1 == nil) {
                    self.userAccount = account;
                    if (updateLoggedInState)
                        self.userLoggedIn = (account.syncState == UserSyncStateFallback || account.syncState == UserSyncStateSuccess);
                    kCallbackIf(callback, nil);
                } else {
                    kCallbackIf(callback, error1);
                }
            }];
        } else {
            kCallbackIf(callback, error0);
        }
    }];
}

- (AccountInfoCallback)createOrUpdateUserAccountCallback:(ErrorCallback)callback
{
    return [self createOrUpdateUserAccountCallback:callback updateLoggedInState:YES];
}

- (AccountInfoCallback)createOrUpdateUserAccountCallback:(ErrorCallback)callback
                                     updateLoggedInState:(BOOL)updateLoggedInState
{
    __block __weak AccountController2 *blockSelf = self;
    return [^(NSError *error, AccountInfo *account) {
        if (error == nil) {
            [blockSelf createOrUpdateUserAccount:account
                             updateLoggedInState:updateLoggedInState
                                        callback:callback];
        } else {
            kCallbackIf_GCD(callback, error);
        }
    } copy];
}

#pragma mark Registration

- (void)registerVstratorWithFirstName:(NSString *)firstName
                             lastName:(NSString *)lastName
                                email:(NSString *)email
                             password:(NSString *)password
                     primarySportName:(NSString *)primarySportName
                             callback:(ErrorCallback)callback
{
    if (self.userLoggedIn) {
        kCallbackIf_GCD(callback, [NSError errorWithText:VstratorStrings.ErrorUserIsLoggedInText]);
    } else {
        [[ServiceFactory sharedInstance] clearAuth];
        AccountInfo *account = self.userRegistered ? [AccountInfo accountWithAccountType:UserAccountTypeVstrator] : [AccountInfo accountWithAccountType:UserAccountTypeVstrator account:self.userAccount];
        account.firstName = firstName;
        account.lastName = lastName;
        account.email = email;
        account.password = password;
        account.primarySportName = primarySportName;
        [VstratorController.sharedInstance registerAccount:account
                                                  callback:[self createOrUpdateUserAccountCallback:callback]];
    }
}

#pragma mark Login/Logout

- (void)loginAsRecent:(ErrorCallback)callback
{
    // autologin
    if (self.userHasRecentLogin) {
        AccountInfo *userCopy = self.userAccount; // avoid multiple locks with @synchronize
        UserAccountType userAccountType = self.userAccountType;
        if (userAccountType == UserAccountTypeVstrator) {
            [self loginVstratorWithEmail:userCopy.email password:userCopy.password callback:callback];
        } else if (userAccountType == UserAccountTypeFacebook) {
            [self loginFacebookWithAccount:userCopy callback:callback];
        }  else {
            kCallbackIf_GCD(callback, [NSError errorWithText:VstratorStrings.ErrorUnknownAccountTypeText]);
        };
    }
    // do nothing if recent user missing
    else {
        kCallbackIf_GCD(callback, [NSError errorWithText:VstratorStrings.ErrorUserNotFoundText]);
    }
}

- (void)loginVstratorWithEmail:(NSString *)email
                      password:(NSString *)password
                      callback:(ErrorCallback)callback
{
    // user already logged in
    if (self.userLoggedIn && self.userAccountType == UserAccountTypeVstrator) {
        kCallbackIf_GCD(callback, [NSError errorWithText:VstratorStrings.ErrorUserIsLoggedInText]);
    }
    // first authentication
    else if (!self.userRegistered) {
        AccountInfo *account = [AccountInfo accountWithAccountType:UserAccountTypeVstrator account:self.userAccount];
        account.email = email;
        account.password = password;
        [VstratorController.sharedInstance loginWithAccount:account
                                                   fallback:NO
                                                   callback:[self createOrUpdateUserAccountCallback:callback]];
    }
    // current account is used
    else if ([self.userAccount.email caseInsensitiveCompare:email] == NSOrderedSame) {
        AccountInfo *account = [AccountInfo accountWithAccountType:UserAccountTypeVstrator account:self.userAccount];
        BOOL credsMatch = [account.password isEqualToString:password];
        account.password = password;
        [VstratorController.sharedInstance loginWithAccount:account
                                                   fallback:credsMatch
                                                   callback:[self createOrUpdateUserAccountCallback:callback]];
    }
    // new or other existing account
    else {
        [MediaService.mainThreadInstance findUserWithEmail:email callback:^(NSError *error, User *user) {
            if (user) {
                AccountInfo *account = [AccountInfo accountWithAccountType:UserAccountTypeVstrator user:user];
                BOOL credsMatch = [user.password isEqualToString:password];
                account.password = password;
                [VstratorController.sharedInstance loginWithAccount:account
                                                           fallback:credsMatch
                                                           callback:[self createOrUpdateUserAccountCallback:callback]];
            } else {
                [VstratorController.sharedInstance loginWithEmail:email
                                                         password:password
                                                         callback:[self createOrUpdateUserAccountCallback:callback]];
            }
        }];
    }
}

- (void)logoutWithCallback:(ErrorCallback)callback
{
    if (self.userLoggedIn) {
        // if user is logged in, check for incomplete network activity
        NSArray *authorIdentities = @[ VstratorConstants.ProUserIdentity, self.userIdentity ];
        // uploads
        [MediaService.mainThreadInstance uploadRequestWithStatus:UploadRequestStatusInProgress authorIdentities:authorIdentities callback:^(NSError *error0, UploadRequest *result) {
            if (error0 != nil) {
                kCallbackIf_GCD(callback, [NSError errorWithError:error0 text:VstratorStrings.ErrorDatabaseSelectText]);
            } else if (result != nil) {
                kCallbackIf_GCD(callback, [NSError errorWithText:VstratorStrings.ErrorLogoutCanceledDueIncompleteUploadsText]);
            } else {
                // logout: ...Vstrator
                [VstratorController.sharedInstance logout];
                [self updateUserLocally:^(NSError *error1, AccountInfo *accountInfo) {
                    accountInfo.password = nil;
                } andSaveWithCallback:^(NSError *error1) {
                    // ...Facebook
                    [self logoutFacebook];
                    // set as logged out (triggers notifications)
                    self.userLoggedIn = NO;
                    // over
                    kCallbackIf_GCD(callback, nil);
                }];
            }
        }];
    } else {
        // error if not logged out
        kCallbackIf_GCD(callback, [NSError errorWithText:VstratorStrings.ErrorCurrentUserNotFoundText]);
    }
}

#pragma mark Account Management

- (void)changeUserPassword:(NSString *)oldPassword
             toNewPassword:(NSString *)newPassword
                  callback:(ErrorCallback)callback;
{
    [VstratorController.sharedInstance changeAccountPassword:self.userAccount
                                             fromOldPassword:oldPassword
                                               toNewPassword:newPassword
                                                    callback:[self createOrUpdateUserAccountCallback:callback]];
}

- (void)updateUserWithFirstName:(NSString *)firstName
                       lastName:(NSString *)lastName
               primarySportName:(NSString *)primarySportName
                       callback:(ErrorCallback)callback
{
    [self updateUserWithFirstName:firstName
                         lastName:lastName
                 primarySportName:primarySportName
                            image:nil
                         callback:callback];
}

- (void)updateUserWithFirstName:(NSString *)firstName
                       lastName:(NSString *)lastName
               primarySportName:(NSString *)primarySportName
                          image:(NSData *)image
                       callback:(ErrorCallback)callback
{
    [VstratorController.sharedInstance updateAccount:self.userAccount
                                       withFirstName:firstName
                                            lastName:lastName
                                    primarySportName:primarySportName
                                               image:image
                                            callback:[self createOrUpdateUserAccountCallback:callback]];
}

- (void)updateUserLocally:(AccountInfoCallback)updateBlock
      andSaveWithCallback:(ErrorCallback)callback
{
    AccountInfo *userCopy = self.userAccount; // avoid multiple locks with @synchronize
    kItemCallbackIf(updateBlock, nil, userCopy);
    [self createOrUpdateUserAccount:userCopy updateLoggedInState:NO callback:callback];
}

#pragma mark Misc

- (void)sendIssueWithType:(IssueTypeKey)issueType
              description:(NSString *)description
                 callback:(ErrorCallback)callback
{
    [VstratorController.sharedInstance sendIssueFromAccount:self.userAccount
                                                   withType:issueType
                                                description:description
                                                   callback:^(NSError *error) {
                                                       kCallbackIf_GCD(callback, error);
                                                   }];
}

#pragma mark Twitter

- (void)twitterCheckAccess:(IdentityCallback)callback
{
    [TwitterController checkAccessToAccount:self.userAccount.twitterIdentity callback:callback];
}

- (void)twitterSelectAccountInView:(UIView *)view callback:(ErrorCallback)callback
{
    [TwitterController selectAccountInView:view callback:^(NSError *error0, NSString *identity) {
        if (error0) {
            kCallbackIf(callback, error0);
        } else if (identity == nil) {
            NSError *error = [NSError errorWithText:VstratorStrings.ErrorTwitterAccountNotSelectedText];
            kCallbackIf(callback, error);
        } else {
            [self updateUserLocally:^(NSError *error1, AccountInfo *accountInfo) {
                accountInfo.twitterIdentity = identity;
            } andSaveWithCallback:callback];
        }
    }];
}

- (void)tweet:(NSString *)tweet inView:(UIView *)view callback:(ErrorCallback)callback
{
    [self twitterCheckAccess:^(NSError *error0, NSString *identity) {
        if (error0 != nil) {
            kCallbackIf(callback, error0);
        } else if (identity == nil) {
            [self twitterSelectAccountInView:view callback:^(NSError *error1) {
                if (error1 != nil) {
                    kCallbackIf(callback, error1);
                } else {
                    [TwitterController tweet:tweet account:self.userAccount.twitterIdentity callback:callback];
                }
            }];
        } else {
            [TwitterController tweet:tweet account:self.userAccount.twitterIdentity callback:callback];
        }
    }];
}

#pragma mark AppUser

- (void)findRecentOrCreateNewUser:(GetAuthorCallback)callback
{
    NSParameterAssert(callback != nil);
    // copy user identity
    NSString *userIdentity = self.userIdentity;
    // block to find user with most recent activity or create new user
    Callback0 findUserWithMostRecentActivityOrCreateUserAccountBlock = [^{
        [MediaService.mainThreadInstance findUserWithMostRecentActivity:^(NSError *error, User *existingUser) {
            if (error == nil && existingUser == nil) {
                AccountInfo *account = [AccountInfo new];
                if (userIdentity != nil)
                    account.identity = userIdentity;
                account.firstName = @"User";
                account.lastName = @"-";
                account.email = @"user@email";
                account.primarySportName = VstratorConstants.DefaultSportName;
                [MediaService.mainThreadInstance findOrCreateUserWithIdentity:userIdentity andUpdateWithAccountInfo:account callback:^(NSError *error1, User *newUser) {
                    if (error1 == nil) {
                        [MediaService.mainThreadInstance saveChanges:^(NSError *error2) {
                            kItemCallbackIf(callback, error2, newUser);
                        }];
                    } else {
                        kItemCallbackIf(callback, error1, newUser);
                    }
                }];
            } else {
                kItemCallbackIf(callback, error, existingUser);
            }
        }];
    } copy];
    // find existing user or create the new one
    if (userIdentity == nil) {
        findUserWithMostRecentActivityOrCreateUserAccountBlock();
    } else {
        [MediaService.mainThreadInstance findUserWithIdentity:userIdentity callback:^(NSError *error, User *existingUser) {
            if (error == nil && existingUser == nil) {
                findUserWithMostRecentActivityOrCreateUserAccountBlock();
            } else {
                kItemCallbackIf(callback, error, existingUser);
            }
        }];
    }
}

@end
