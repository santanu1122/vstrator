//
//  AccountInfo.m
//  VstratorApp
//
//  Created by Mac on 07.05.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "AccountInfo.h"
#import "Sport.h"
#import "User.h"
#import "VstratorUserInfo.h"
#import "VstratorConstants.h"

@implementation AccountInfo

#pragma mark - Properties

@synthesize accountType = _accountType;
@synthesize syncState = _syncState;
@synthesize syncSummary = _syncSummary;

@synthesize facebookAccessToken = _facebookAccessToken;
@synthesize facebookExpirationDate = _facebookExpirationDate;
@synthesize identity = _identity;
@synthesize password = _password;
@synthesize picture = _picture;
@synthesize tipCamera = _tipCamera;
@synthesize tipSession = _tipSession;
@synthesize tipWelcome = _tipWelcome;
@synthesize twitterIdentity = _twitterIdentity;

- (UIImage *)pictureImage
{
    return self.picture == nil ? nil : [[UIImage alloc] initWithData:self.picture];
}

#pragma mark - Static Ctor

+ (AccountInfo *)accountWithAccount:(AccountInfo *)account
{
    NSParameterAssert(account != nil);
    return [[AccountInfo alloc] initWithAccount:account];
}

+ (AccountInfo *)accountWithAccountType:(UserAccountType)accountType account:(AccountInfo *)account
{
    NSParameterAssert(account != nil);
    return [[AccountInfo alloc] initWithAccountType:accountType account:account];
}

+ (AccountInfo *)accountWithAccountType:(UserAccountType)accountType user:(User *)user
{
    NSParameterAssert(user != nil);
    return [[AccountInfo alloc] initWithAccountType:accountType user:user];
}

+ (AccountInfo *)accountWithAccountType:(UserAccountType)accountType
{
    return [[AccountInfo alloc] initWithAccountType:accountType];
}

#pragma mark - Ctor

- (id)init
{
    self = [super init];
    if (self) {
        _accountType = UserAccountTypeVstrator;
        self.identity = [[NSProcessInfo processInfo] globallyUniqueString];
        self.tipCamera = @YES;
        self.tipSession = @YES;
        self.tipWelcome = @YES;
        self.uploadQuality = UploadQualityHigh;
        self.uploadOptions = UploadOnlyOnWiFi;
    }
    return self;
}

- (id)initWithAccount:(AccountInfo *)account
{
    return [self initWithAccountType:account.accountType account:account];
}

- (id)initWithAccountType:(UserAccountType)accountType account:(AccountInfo *)account
{
    self = [self initWithAccountType:accountType];
    if (self) {
        self.syncState = account.syncState;
        self.syncSummary = account.syncSummary;
        self.email = account.email;
        self.facebookAccessToken = account.facebookAccessToken;
        self.facebookExpirationDate = account.facebookExpirationDate;
        self.facebookIdentity = account.facebookIdentity;
        self.firstName = account.firstName;
        self.identity = account.identity;
        self.lastName = account.lastName;
        self.password = account.password;
        self.picture = account.picture;
        self.pictureUrl = account.pictureUrl;
        self.primarySportName = account.primarySportName;
        self.tipCamera = account.tipCamera;
        self.tipSession = account.tipSession;
        self.tipWelcome = account.tipWelcome;
        self.twitterIdentity = account.twitterIdentity;
        self.uploadQuality = account.uploadQuality;
        self.uploadOptions = account.uploadOptions;
        self.vstratorIdentity = account.vstratorIdentity;
        self.vstratorUserName = account.vstratorUserName;
    }
    return self;
}

- (id)initWithAccountType:(UserAccountType)accountType user:(User *)user
{
    self = [self initWithAccountType:accountType];
    if (self) {
        self.email = user.email;
        self.facebookAccessToken = user.facebookAccessToken;
        self.facebookExpirationDate = user.facebookExpirationDate;
        self.facebookIdentity = user.facebookIdentity;
        self.firstName = user.firstName;
        self.identity = user.identity;
        self.lastName = user.lastName;
        self.password = user.password;
        self.picture = user.picture;
        self.pictureUrl = user.pictureUrl;
        self.primarySportName = user.primarySport == nil ? nil : user.primarySport.name;
        self.tipCamera = user.tipCamera;
        self.tipSession = user.tipSession;
        self.tipWelcome = user.tipWelcome;
        self.twitterIdentity = user.twitterIdentity;
        self.uploadQuality = user.uploadQuality.intValue;
        self.uploadOptions = user.uploadOptions.intValue;
        self.vstratorIdentity = user.vstratorIdentity;
        self.vstratorUserName = user.vstratorUserName;
    }
    return self;
}

- (id)initWithAccountType:(UserAccountType)accountType
{
    self = [self init];
    if (self) {
        _accountType = accountType;
    }
    return self;
}

#pragma mark - Methods

- (void)updateWithFacebookUserInfo:(FacebookUserInfo *)info
{
    self.email = info.email;
    self.facebookIdentity = info.facebookIdentity;
    self.firstName = info.firstName;
    self.lastName = info.lastName;
}

- (void)updateWithVstratorUserInfo:(VstratorUserInfo *)info
{
    [self updateWithVstratorUserInfo:info image:nil password:nil];
}

- (void)updateWithVstratorUserInfo:(VstratorUserInfo *)info image:(UIImage *)image
{
    [self updateWithVstratorUserInfo:info image:image password:nil];
}

- (void)updateWithVstratorUserInfo:(VstratorUserInfo *)info image:(UIImage *)image password:(NSString *)password;
{
    // parent
    [self updateWithFacebookUserInfo:info];
    // child
    self.pictureUrl = info.pictureUrl;
    self.vstratorIdentity = info.vstratorIdentity;
    self.vstratorUserName = info.vstratorUserName;
    if (info.primarySportName != nil)
        self.primarySportName = info.primarySportName;
    // custom
    if (image != nil)
        self.picture = UIImageJPEGRepresentation(image, VstratorConstants.UserPictureJPEGQuality);
    if (password != nil)
        self.password = password;
}

@end
