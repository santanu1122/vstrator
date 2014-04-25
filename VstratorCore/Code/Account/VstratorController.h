//
//  VstratorController.h
//  VstratorApp
//
//  Created by Mac on 07.05.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Callbacks.h"
#import "IssueType.h"

@class AccountInfo;

@interface VstratorController : NSObject

+ (VstratorController *)sharedInstance;

- (void)logout;

- (void)loginWithAccount:(AccountInfo *)account
                fallback:(BOOL)fallback
                callback:(AccountInfoCallback)callback;
- (void)loginWithEmail:(NSString *)email
              password:(NSString *)password
              callback:(AccountInfoCallback)callback;

- (void)registerWithFirstName:(NSString *)firstName 
                     lastName:(NSString *)lastName 
                        email:(NSString *)email
                     password:(NSString *)password 
             primarySportName:(NSString *)primarySportName
                     callback:(AccountInfoCallback)callback;
- (void)registerAccount:(AccountInfo *)account
               callback:(AccountInfoCallback)callback;

- (void)changeAccountPassword:(AccountInfo *)account
              fromOldPassword:(NSString *)oldPassword
                toNewPassword:(NSString *)newPassword
                     callback:(AccountInfoCallback)callback;

- (void)updateAccount:(AccountInfo *)account
        withFirstName:(NSString *)firstName 
             lastName:(NSString *)lastName 
     primarySportName:(NSString *)primarySportName
                image:(NSData *)image
             callback:(AccountInfoCallback)callback;

- (void)updateAccount:(AccountInfo *)account
             callback:(AccountInfoCallback)callback;
- (void)reloadAccount:(AccountInfo *)account
             fallback:(BOOL)fallback
             callback:(AccountInfoCallback)callback;

- (void)sendIssueFromAccount:(AccountInfo *)account
                    withType:(IssueTypeKey)issueType
                 description:(NSString *)description
                    callback:(ErrorCallback)callback;

@end
