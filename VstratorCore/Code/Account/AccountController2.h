//
//  AccountController2.h
//  VstratorApp
//
//  Created by Mac on 07.05.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AccountInfo.h"
#import "Callbacks.h"
#import "IssueType.h"

extern NSString * const VAUploadOptionsChangedNotification;

@interface AccountController2 : NSObject

#pragma mark Shared Instance

+ (AccountController2 *)sharedInstance;

#pragma mark Properties

@property (atomic, readonly, copy) AccountInfo *userAccount;
@property (atomic, readonly) UserAccountType userAccountType;
@property (atomic, readonly, copy) NSString *userIdentity;

@property (atomic, readonly) BOOL userHasRecentLogin;
@property (atomic, readonly) BOOL userLoggedIn;
@property (atomic, readonly) BOOL userRegistered;

#pragma mark Initialize

+ (void)initialize:(ErrorCallback)callback;

#pragma mark Registration/Login/Logout

- (void)loginAsRecent:(ErrorCallback)callback;

- (void)registerVstratorWithFirstName:(NSString *)firstName 
                             lastName:(NSString *)lastName 
                                email:(NSString *)email
                             password:(NSString *)password 
                     primarySportName:(NSString *)primarySportName
                             callback:(ErrorCallback)callback;
- (void)loginVstratorWithEmail:(NSString *)email
                      password:(NSString *)password
                      callback:(ErrorCallback)callback;
- (void)logoutWithCallback:(ErrorCallback)callback;

#pragma mark User Management

- (void)changeUserPassword:(NSString *)oldPassword
             toNewPassword:(NSString *)newPassword
                  callback:(ErrorCallback)callback;

- (void)updateUserWithFirstName:(NSString *)firstName 
                       lastName:(NSString *)lastName 
               primarySportName:(NSString *)primarySportName
                       callback:(ErrorCallback)callback;
- (void)updateUserWithFirstName:(NSString *)firstName 
                       lastName:(NSString *)lastName 
               primarySportName:(NSString *)primarySportName
                          image:(NSData *)image
                       callback:(ErrorCallback)callback;

- (void)updateUserLocally:(AccountInfoCallback)updateBlock
      andSaveWithCallback:(ErrorCallback)callback;

#pragma mark Misc

- (void)sendIssueWithType:(IssueTypeKey)issueType
              description:(NSString *)description
                 callback:(ErrorCallback)callback;

#pragma mark Twitter

- (void)tweet:(NSString *)tweet inView:(UIView *)view callback:(ErrorCallback)callback;

#pragma mark System (DO NOT USE!)

- (AccountInfoCallback)createOrUpdateUserAccountCallback:(ErrorCallback)callback;
- (AccountInfoCallback)createOrUpdateUserAccountCallback:(ErrorCallback)callback
                                     updateLoggedInState:(BOOL)updateLoggedInState;

@end


extern NSString * const VAUserIdentityChangedNotification;
extern NSString * const VAUserLoggedInChangedNotification;
