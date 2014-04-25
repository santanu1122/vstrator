//
//  LoginManager.m
//  VstratorApp
//
//  Created by Virtualler on 25.12.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "LoginManager.h"
#import "AccountController2.h"
#import "LoginMethodsViewController.h"
#import "NSError+Extensions.h"
#import "UIAlertViewWrapper.h"
#import "VstratorStrings.h"

@interface LoginManager() <LoginViewControllerDelegate>

@property (nonatomic, strong) LoginManagerCallback loginCallback;
@property (nonatomic, strong) NSString *userIdentityBeforeLogin;

@end

@implementation LoginManager

#pragma mark Business Logic

- (void)login:(LoginQuestionType)questionType callback:(LoginManagerCallback)callback
{
    // already logged in and not relogin mode
    if (AccountController2.sharedInstance.userLoggedIn) {
        kItemCallbackIf(callback, nil, NO);
        return;
    }
    // save state
    self.loginCallback = callback;
    self.userIdentityBeforeLogin = AccountController2.sharedInstance.userIdentity;
    // login without confirmation if relogin mode
    LoginMethodsViewController *vc = [[LoginMethodsViewController alloc] initWithNibName:NSStringFromClass(LoginMethodsViewController.class) bundle:nil];
    vc.delegate = self;
    vc.dialogMode = (questionType == LoginQuestionTypeDialog);
    [self.viewController presentViewController:vc animated:NO completion:nil];
}

#pragma mark LoginMethodsViewControllerDelegate

- (void)loginViewControllerDidCancel:(BaseViewController *)sender
{
    NSError *error = [NSError errorWithText:VstratorStrings.ErrorLoginCanceled];
    [self loginViewControllerDidFinish:sender error:error];
}

- (void)loginViewControllerDidLogin:(BaseViewController *)sender
{
    [self loginViewControllerDidFinish:sender error:nil];
}

- (void)loginViewControllerDidFinish:(BaseViewController *)sender error:(NSError *)error
{
    BOOL userIdentityChanged = ![self.userIdentityBeforeLogin isEqualToString:AccountController2.sharedInstance.userIdentity];
    LoginManagerCallback loginCallback = self.loginCallback;
    self.loginCallback = nil;
    self.userIdentityBeforeLogin = nil;
    kItemCallbackIf(loginCallback, error, userIdentityChanged);
}

@end
