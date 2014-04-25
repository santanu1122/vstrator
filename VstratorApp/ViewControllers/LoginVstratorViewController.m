//
//  LoginVstratorViewController.m
//  VstratorApp
//
//  Created by Mac on 26.02.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "LoginVstratorViewController.h"
#import "AccountController2.h"
#import "FlurryLogger.h"
#import "RegisterVstratorViewController.h"
#import "WebViewController.h"
#import "VstratorExtensions.h"
#import "VstratorStrings.h"

@interface LoginVstratorViewController() <UITextFieldDelegate, LoginViewControllerDelegate> {
    BOOL _viewDidAppearOnce;
}

@property (nonatomic, weak) IBOutlet UIImageView *backgroundImageView;
@property (nonatomic, weak) IBOutlet UILabel *userEmailAddressLabel;
@property (nonatomic, weak) IBOutlet UITextField *userEmailAddressTextField;
@property (nonatomic, weak) IBOutlet UILabel *userPasswordLabel;
@property (nonatomic, weak) IBOutlet UITextField *userPasswordTextField;
@property (nonatomic, weak) IBOutlet UIButton *rememberButton;
@property (nonatomic, weak) IBOutlet UIButton *loginVstratorButton;
@property (nonatomic, weak) IBOutlet UIButton *forgotPasswordButton;
@property (nonatomic, weak) IBOutlet UIButton *registerVstratorButton;
@property (nonatomic, weak) IBOutlet UILabel *registerVstratorLabel;

@property (nonatomic) BOOL recentRememberMe;

@end

#pragma mark -

@implementation LoginVstratorViewController

#pragma mark Constants and Defines

#define kVARecentRememberMeKey @"RecentRememberMeKey"

#pragma mark Properties

- (BOOL)recentRememberMe
{
    NSNumber *value = [NSUserDefaults.standardUserDefaults objectForKey:kVARecentRememberMeKey];
    return (value == nil ? YES : value.boolValue);
}

- (void)setRecentRememberMe:(BOOL)recentRememberMe
{
    NSNumber *value = @(recentRememberMe);
    [NSUserDefaults.standardUserDefaults setObject:value forKey:kVARecentRememberMeKey];
    [NSUserDefaults.standardUserDefaults synchronize];
}

#pragma mark Dismiss Actions

- (void)dismissWithLogin
{
    [self dismissViewControllerAnimated:NO completion:^{
        if ([self.delegate respondsToSelector:@selector(loginViewControllerDidLogin:)])
            [self.delegate loginViewControllerDidLogin:self];
    }];
}

#pragma mark LoginViewControllerDelegate

- (void)loginViewControllerDidLogin:(BaseViewController *)sender
{
    [self dismissWithLogin];
}

#pragma mark Business Logic

- (void)loadRecentUser:(BOOL)loginIfCan
{
    if (AccountController2.sharedInstance.userRegistered) {
        AccountInfo *userCopy = AccountController2.sharedInstance.userAccount; // avoid multiple locks with @synchronize
        self.userEmailAddressTextField.text = userCopy.email;
        if (loginIfCan && userCopy.accountType == UserAccountTypeVstrator) {
            self.userPasswordTextField.text = userCopy.password;
            NSString *errorMessage = nil;
            if ([self userFieldsValidate:&errorMessage])
                [self loginVstratorAction:self.loginVstratorButton];
        }
    }
}

- (BOOL)userFieldsValidate:(NSString **)outputString
{
    // preprocess input
    self.userEmailAddressTextField.text = [NSString trimmedStringOrNil:self.userEmailAddressTextField.text];
    // validate
    return [ValidationHelper validateEmailAddress:self.userEmailAddressTextField.text outputString:outputString] && [ValidationHelper validatePassword:self.userPasswordTextField.text outputString:outputString];
}

- (IBAction)rememberAction:(id)sender
{
    self.rememberButton.selected = !self.rememberButton.selected;
}

- (IBAction)loginVstratorAction:(id)sender
{
    NSString *errorString = nil;
    if ([self userFieldsValidate:&errorString]) {
        [self showBGActivityIndicator:VstratorStrings.UserLoginLoggingInActivityTitle];
        self.recentRememberMe = self.rememberButton.selected;
        [AccountController2.sharedInstance loginVstratorWithEmail:self.userEmailAddressTextField.text
                                                         password:self.userPasswordTextField.text
                                                         callback:[self hideBGActivityCallback:^(NSError *error) {
            if (error == nil) {
                [FlurryLogger logTypedEvent:FlurryEventTypeLoginWithVstrator];
                [self dismissWithLogin];
            }
        }]];
    } else {
        [UIAlertViewWrapper alertInvalidInputString:errorString];
    }
}

- (IBAction)forgotPasswordAction:(id)sender
{
    WebViewController *vc = [[WebViewController alloc] initWithNibName:NSStringFromClass(WebViewController.class) bundle:nil];
    vc.url = VstratorConstants.VstratorWwwForgotPasswordURL;
    [self presentViewController:vc animated:NO completion:nil];
    //if (![UIApplication.sharedApplication openURL:VstratorConstants.VstratorWwwForgotPasswordURL])
    //    [UIAlertViewWrapper alertString:VstratorStrings.ErrorUnableToOpenSafariWithURL];
}

- (IBAction)registerVstratorAction:(id)sender
{
    RegisterVstratorViewController *vc = [[RegisterVstratorViewController alloc] initWithNibName:NSStringFromClass(RegisterVstratorViewController.class) bundle:nil];
    vc.delegate = self;
    [self presentViewController:vc animated:NO completion:nil];
}

#pragma mark UITextFieldDelegate

- (void)setupTextFieldPopupView:(TextFieldPopupView *)textFieldPopupView
{
    [super setupTextFieldPopupView:textFieldPopupView];
    textFieldPopupView.backgroundImage = self.backgroundImageView.image;
    textFieldPopupView.titleColor = self.userEmailAddressLabel.textColor;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [self.textFieldPopupView showWithTextField:textField inView:self.view];
    return NO;
}

#pragma mark Localization

- (void)setLocalizableStrings
{
    // Buttons
    [self.loginVstratorButton setTitle:VstratorStrings.UserLoginLoginButtonTitle forState:UIControlStateNormal];
    [self.forgotPasswordButton setTitle:VstratorStrings.UserLoginForgotYourPasswordButtonTitle forState:UIControlStateNormal];
    [self.registerVstratorButton setTitle:VstratorStrings.UserLoginSignupButtonTitle forState:UIControlStateNormal];
    // TextField
    [self.userEmailAddressTextField setPlaceholder:VstratorStrings.UserLoginEmailAddressField];
    [self.userPasswordTextField setPlaceholder:VstratorStrings.UserLoginPasswordField];
    // Labels
    [self.userEmailAddressLabel setText:[NSString stringWithFormat:@"%@:", VstratorStrings.UserLoginEmailAddressField]];
    [self.userPasswordLabel setText:[NSString stringWithFormat:@"%@:", VstratorStrings.UserLoginPasswordField]];
    [self.registerVstratorLabel setText:VstratorStrings.UserLoginDoNotHaveAccountLabelText];
    [self.rememberButton setTitle:[NSString stringWithFormat:@"  %@", VstratorStrings.UserLoginRememberMeButtonTitle] forState:UIControlStateNormal];
}

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setLocalizableStrings];
    [self setResizableImages];
    self.navigationBarView.title = self.title = VstratorStrings.TitleLogin;
    self.rememberButton.selected = self.recentRememberMe;
}

- (void)setResizableImages
{
    UIImage *btGreyNBlackh69 = [UIImage resizableImageNamed:@"bt-grey-n-black-h69"];
    UIImage *btBlack01 = [UIImage resizableImageNamed:@"bt-black-01"];
    
    [self.loginVstratorButton setBackgroundImage:btGreyNBlackh69 forState:UIControlStateNormal];
    [self.loginVstratorButton setBackgroundImage:btBlack01 forState:UIControlStateHighlighted];
    
    [self.registerVstratorButton setBackgroundImage:btGreyNBlackh69 forState:UIControlStateNormal];
    [self.registerVstratorButton setBackgroundImage:btBlack01 forState:UIControlStateHighlighted];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // Launch following processing only once
    if (_viewDidAppearOnce)
        return;
    _viewDidAppearOnce = YES;
    // Auto Login
    dispatch_async(dispatch_get_main_queue(), ^{
        [self loadRecentUser:NO]; //self.recentRememberMe];
    });
}

- (void)viewDidUnload
{
    // Release any retained subviews of the main view.
    self.backgroundImageView = nil;
    self.userEmailAddressLabel = nil;
    self.userEmailAddressTextField = nil;
    self.userPasswordLabel = nil;
    self.userPasswordTextField = nil;
    self.rememberButton = nil;
    self.loginVstratorButton = nil;
    self.forgotPasswordButton = nil;
    self.registerVstratorLabel = nil;
    self.registerVstratorButton = nil;
    // Super
    [super viewDidUnload];
}

@end
