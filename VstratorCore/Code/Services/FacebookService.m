//
//  FacebookService.m
//  VstratorApp
//
//  Created by Mac on 15.05.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "FacebookService.h"
#import "FacebookUserInfo.h"
#import "VstratorExtensions.h"
#import "VstratorStrings.h"
#import <FacebookSDK/FacebookSDK.h>

@implementation FacebookService

#pragma mark - Properties

- (NSString *)accessToken
{
    return [NSString stringWithStringOrNil:FBSession.activeSession.accessTokenData.accessToken];
}

- (NSDate *)expirationDate
{
    return FBSession.activeSession.accessTokenData.expirationDate == nil ? nil : [FBSession.activeSession.accessTokenData.expirationDate copy];
}


- (BOOL)loggedIn
{
    return FBSession.activeSession.isOpen;
}

#pragma mark - Ctor

- (id)initWithDelegate:(id<FacebookServiceDelegate>)delegate
{
    self = [super init];
    if (self) {
        _delegate = delegate;
    }
    return self;
}

#pragma mark - Authentication

- (void)authorize
{
    [FBSession openActiveSessionWithReadPermissions:@[@"user_about_me", @"email"]
                                       allowLoginUI:YES
                                  completionHandler:^(FBSession *session,
                                                      FBSessionState state,
                                                      NSError *error) {
                                      [self sessionStateChanged:session
                                                          state:state
                                                          error:error];
                                  }];
}

- (void)sessionStateChanged:(FBSession *)session
                      state:(FBSessionState) state
                      error:(NSError *)error
{
    switch (state) {
        case FBSessionStateOpen: {
            // Handle the logged in scenario
            [self.delegate fbDidLogin];
            break;
        }
        case FBSessionStateClosed: {
            // Handle the logged out scenario
            // Close the active session
            [FBSession.activeSession closeAndClearTokenInformation];
            [self.delegate fbDidLogout];
            break;
        }
        case FBSessionStateClosedLoginFailed: {
            [FBSession.activeSession closeAndClearTokenInformation];
            [self.delegate fbLoginFailed];
            break;
        }
        case FBSessionStateOpenTokenExtended: {
            [self.delegate fbDidExtendToken:self.accessToken expiresAt:self.expirationDate];
            break;
        }
        default:
            break;
    }
    
    if (error) {
        // Handle authentication errors
        NSLog(@"%@", error.localizedDescription);
    }
}

- (void)logout
{
    [FBSession.activeSession close];
}

#pragma mark - Graph API

+ (FacebookUserInfo *)createUserInfoWithResponse:(id)response error:(NSError **)error
{
    NSAssert(error != nil, VstratorConstants.AssertionErrorPointerIsNil);
    *error = nil;
    // perform
    NSString *facebookIdentity = response[@"id"];
    NSString *firstName = response[@"first_name"];
    NSString *lastName = response[@"last_name"];
    NSString *email = response[@"email"];
    // check
    if ([NSString isNilOrWhitespace:facebookIdentity] || [NSString isNilOrWhitespace:firstName] || [NSString isNilOrWhitespace:lastName] || [NSString isNilOrWhitespace:email]) {
        *error = [NSError errorWithText:VstratorStrings.ErrorFacebookResponseNotContainRequiredDataText];
        return nil;
    }
    // over
    return [[FacebookUserInfo alloc] initWithEmail:email facebookIdentity:facebookIdentity firstName:firstName lastName:lastName];
}

- (void)getUserInfo:(FacebookUserInfoCallback)callback
{
    [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (error) {
            kItemCallbackIf(callback, error, nil);
        } else {
            NSError *error2 = nil;
            FacebookUserInfo *info = [self.class createUserInfoWithResponse:result error:&error2];
            kItemCallbackIf(callback, error2, info);
        }
    }];
}

- (void)postStatus:(NSString *)message callback:(ErrorCallback)callback
{
    Callback0 postBlock = ^{
        [FBRequestConnection startForPostWithGraphPath:@"/me/feed"
                                           graphObject:[FBGraphObject graphObjectWrappingDictionary:@{ @"message": message }]
                                     completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                                         kCallbackIf(callback, error);
                                     }];
    };
    if ([FBSession.activeSession.permissions containsObject:@"publish_actions"]) {
        postBlock();
    } else {
        [FBSession.activeSession requestNewPublishPermissions:@[@"publish_actions"]
                                              defaultAudience:FBSessionDefaultAudienceFriends
                                            completionHandler:^(FBSession *session, NSError *error) {
                                                if (error == nil)
                                                    postBlock();
                                                //else if (error.fberrorShouldNotifyUser)
                                                //    kCallbackIf(callback, error);
                                                else
                                                    kCallbackIf(callback, error);
                                            }];
    }
}

#pragma mark - Sessions

- (void)handleDidBecomeActive;
{
    [FBSession.activeSession handleDidBecomeActive];
}

- (BOOL)handleOpenURL:(NSURL *)url
{
    return [FBSession.activeSession handleOpenURL:url];
}

@end
