//
//  LoginMethodsViewController.m
//  VstratorApp
//
//  Created by Mac on 26.02.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "LoginMethodsViewController.h"

#import "AccountController2+Facebook.h"
#import "LoginVstratorViewController.h"
#import "FlurryLogger.h"
#import "TipLegalView.h"
#import "VstratorStrings.h"
#import "WebViewController.h"

@interface LoginMethodsViewController() <LoginViewControllerDelegate, TipViewDelegate> {
    BOOL _viewWillAppearOnce;
}

@property (nonatomic, weak) IBOutlet UIButton *loginFacebookButton;
@property (nonatomic, weak) IBOutlet UIButton *loginVstratorButton;
@property (nonatomic, weak) IBOutlet UIButton *continueOfflineButton;
@property (nonatomic, weak) IBOutlet UIImageView *backgroundImage;
@property (nonatomic, weak) IBOutlet UIImageView *logoImage;
@property (nonatomic, weak) IBOutlet UILabel *dialogLabel;

@property (nonatomic) BOOL termsOfUseAgreed;

@end

#pragma mark -

@implementation LoginMethodsViewController

#pragma mark Defines

#define kVATermsOfUseAgreedKey @"TermsOfUseAgreedKey"

#pragma mark Properties

- (BOOL)termsOfUseAgreed
{
    NSNumber *value = [NSUserDefaults.standardUserDefaults objectForKey:kVATermsOfUseAgreedKey];
    return (value == nil ? NO : value.boolValue);
}

- (void)setTermsOfUseAgreed:(BOOL)termsOfUseAgreed
{
    [NSUserDefaults.standardUserDefaults setObject:@(termsOfUseAgreed) forKey:kVATermsOfUseAgreedKey];
    [NSUserDefaults.standardUserDefaults synchronize];
}

#pragma mark Dismiss Actions

- (void)dismissWithCancel
{
    [self dismissViewControllerAnimated:NO completion:^{
        if ([self.delegate respondsToSelector:@selector(loginViewControllerDidCancel:)])
            [self.delegate loginViewControllerDidCancel:self];
    }];
}

- (void)dismissWithLogin
{
    [self dismissViewControllerAnimated:NO completion:^{
        if ([self.delegate respondsToSelector:@selector(loginViewControllerDidLogin:)])
            [self.delegate loginViewControllerDidLogin:self];
    }];
}

#pragma mark Actions

- (IBAction)loginFacebookAction:(id)sender
{
    [self showBGActivityIndicator:VstratorStrings.UserLoginMethodsLoggingInFacebookActivityTitle];
    [AccountController2.sharedInstance loginFacebook:[self hideBGActivityCallback:^(NSError *error) {
        if (error == nil) {
            [FlurryLogger logTypedEvent:FlurryEventTypeLoginWithFacebook];
            [self dismissWithLogin];
        }
    }]];
}

- (IBAction)loginVstratorAction:(id)sender
{
    LoginVstratorViewController *vc = [[LoginVstratorViewController alloc] initWithNibName:NSStringFromClass(LoginVstratorViewController.class) bundle:nil];
    vc.delegate = self;
    [self presentViewController:vc animated:NO completion:nil];
}

- (IBAction)continueOfflineAction:(id)sender
{
    [FlurryLogger logTypedEvent:FlurryEventTypeLoginContinueOffline];
    [self dismissWithCancel];
}

#pragma mark LoginViewControllerDelegate

- (void)loginViewControllerDidLogin:(BaseViewController *)sender
{
    [self dismissWithLogin];
}

#pragma mark - TipViewDelegate

- (void)showTipLegalView
{
    TipLegalView *tipLegalView = [[TipLegalView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    tipLegalView.delegate = self;
    [self.view addSubview:tipLegalView];
}

- (void)tipViewDidFinish:(UIView *)sender tipFlag:(BOOL)tipFlag
{
    // hide tip view
    if (sender && sender.superview)
        [sender removeFromSuperview];
    // exit if not agreed
    if (!tipFlag)
        exit(0);
    // set as shown
    self.termsOfUseAgreed = YES;
}

- (void)tipView:(UIView *)sender didSelectURL:(NSURL *)url
{
    WebViewController *vc = [[WebViewController alloc] initWithNibName:NSStringFromClass(WebViewController.class) bundle:nil];
    vc.url = url;
    [self presentViewController:vc animated:NO completion:nil];
}

#pragma mark Localization

- (void) setLocalizableStrings
{
    [self.loginFacebookButton setTitle:VstratorStrings.UserLoginMethodsLoginWithFacebookButtonTitle forState:UIControlStateNormal];
    [self.loginVstratorButton setTitle:VstratorStrings.UserLoginMethodsLoginButtonTitle forState:UIControlStateNormal];
    [self.continueOfflineButton setTitle:VstratorStrings.UserLoginMethodsContinueOfflineButtonTitle forState:UIControlStateNormal];
    self.dialogLabel.text = VstratorStrings.UserLoginMethodsDialogText;
}

#pragma mark View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setLocalizableStrings];
    [self setResizableImages];
    self.navigationBarView.title = self.title = VstratorStrings.TitleLogin;
    self.navigationBarView.hidden = YES;
    if (self.dialogMode) {
        self.logoImage.hidden = YES;
        self.dialogLabel.hidden = NO;
    }
}

- (void)setResizableImages
{
    [self.loginFacebookButton setBackgroundImage:[UIImage resizableImageNamed:@"bt-grey-n-black-h69"] forState:UIControlStateNormal];
    [self.loginFacebookButton setBackgroundImage:[UIImage resizableImageNamed:@"bt-black-01"] forState:UIControlStateHighlighted];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // Launch following processing only once
    if (_viewWillAppearOnce)
        return;
    _viewWillAppearOnce = YES;
    // TipLegalView
    if (!self.termsOfUseAgreed)
        [self showTipLegalView];
}

- (void)viewDidUnload
{
    // Release any retained subviews of the main view.
    self.loginFacebookButton = nil;
    self.loginVstratorButton = nil;
    self.continueOfflineButton = nil;
    self.backgroundImage = nil;
    self.logoImage = nil;
    self.dialogLabel = nil;
    // Super
    [super viewDidUnload];
}

@end
