//
//  FacebookService.h
//  VstratorApp
//
//  Created by Mac on 15.05.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Callbacks.h"


@protocol FacebookServiceDelegate;


@interface FacebookService : NSObject

@property (nonatomic, weak, readonly) id<FacebookServiceDelegate> delegate;

@property (nonatomic, copy) NSString *accessToken;
@property (nonatomic, copy) NSDate *expirationDate;
@property (nonatomic, readonly) BOOL loggedIn;

- (id)initWithDelegate:(id<FacebookServiceDelegate>)delegate;

// delegate-based methods
- (void)authorize;
- (void)logout;

// callback-based methods
- (void)getUserInfo:(FacebookUserInfoCallback)callback;
- (void)postStatus:(NSString *)message callback:(ErrorCallback)callback;

// system methods to service
- (void)handleDidBecomeActive;
- (BOOL)handleOpenURL:(NSURL *)url;

@end



@protocol FacebookServiceDelegate

@optional
- (void)fbDidLogin;
- (void)fbDidLogout;
- (void)fbLoginFailed;
- (void)fbDidExtendToken:(NSString*)accessToken expiresAt:(NSDate*)expiresAt;

@end
