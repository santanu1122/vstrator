//
//  AccountInfo.h
//  VstratorApp
//
//  Created by Mac on 07.05.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VstratorUserInfo.h"
#import "User+Extensions.h"

typedef enum {
    UserAccountTypeVstrator,
    UserAccountTypeFacebook
} UserAccountType;

typedef enum {
    UserSyncStateFail = 0,
    UserSyncStateFallback,
    UserSyncStateSuccess
} UserSyncState;


@interface AccountInfo : VstratorUserInfo

#pragma mark - Properties

@property (nonatomic, readonly) UserAccountType accountType;
@property (nonatomic) UserSyncState syncState;
@property (nonatomic, copy) NSString * syncSummary;

@property (nonatomic, copy) NSString * facebookAccessToken;
@property (nonatomic, copy) NSDate * facebookExpirationDate;
@property (nonatomic, copy) NSString * identity;
@property (nonatomic, copy) NSString * password;
@property (nonatomic, strong) NSData * picture;
@property (nonatomic, strong, readonly) UIImage * pictureImage;
@property (nonatomic, strong) NSNumber * tipCamera;
@property (nonatomic, strong) NSNumber * tipSession;
@property (nonatomic, strong) NSNumber * tipWelcome;
@property (nonatomic, copy) NSString * twitterIdentity;
@property (nonatomic) UploadQuality uploadQuality;
@property (nonatomic) UploadOptions uploadOptions;

#pragma mark - Methods

+ (AccountInfo *)accountWithAccount:(AccountInfo *)account;
+ (AccountInfo *)accountWithAccountType:(UserAccountType)accountType account:(AccountInfo *)account;
+ (AccountInfo *)accountWithAccountType:(UserAccountType)accountType user:(User *)user;
+ (AccountInfo *)accountWithAccountType:(UserAccountType)accountType;

- (id)initWithAccount:(AccountInfo *)account;
- (id)initWithAccountType:(UserAccountType)accountType account:(AccountInfo *)account;
- (id)initWithAccountType:(UserAccountType)accountType user:(User *)user;
- (id)initWithAccountType:(UserAccountType)accountType;

- (void)updateWithFacebookUserInfo:(FacebookUserInfo *)info;
- (void)updateWithVstratorUserInfo:(VstratorUserInfo *)info image:(UIImage *)image password:(NSString *)password;
- (void)updateWithVstratorUserInfo:(VstratorUserInfo *)info image:(UIImage *)image;
- (void)updateWithVstratorUserInfo:(VstratorUserInfo *)info;

@end
