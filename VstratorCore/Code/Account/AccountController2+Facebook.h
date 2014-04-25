//
//  AccountController2+Facebook.h
//  VstratorApp
//
//  Created by Mac on 25.07.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AccountController2.h"

@interface AccountController2 (Facebook)

- (void)loginFacebook:(ErrorCallback)callback;
- (void)loginFacebookWithAccount:(AccountInfo *)account callback:(ErrorCallback)callback;
- (void)logoutFacebook;

- (void)postOnFacebookWall:(NSString *)message callback:(ErrorCallback)callback;

- (void)handleFacebookDidBecomeActive;
- (BOOL)handleFacebookOpenURL:(NSURL *)url;

@end
