//
//  RegisterVstratorViewController.m
//  VstratorApp
//
//  Created by Mac on 26.02.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "RegisterVstratorViewController.h"
#import "AccountController2.h"
#import "FlurryLogger.h"
#import "VstratorExtensions.h"
#import "VstratorStrings.h"

@interface RegisterVstratorViewController() <UITextFieldDelegate> //, TutorialResponderDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UILabel *userFirstNameLabel;
@property (weak, nonatomic) IBOutlet UITextField *userFirstNameTextField;
@property (weak, nonatomic) IBOutlet UILabel *userLastNameLabel;
@property (weak, nonatomic) IBOutlet UITextField *userLastNameTextField;
@property (weak, nonatomic) IBOutlet UILabel *userEmailAddressLabel;
@property (weak, nonatomic) IBOutlet UITextField *userEmailAddressTextField;
@property (weak, nonatomic) IBOutlet UILabel *userPassword1Label;
@property (weak, nonatomic) IBOutlet UITextField *userPassword1TextField;
@property (weak, nonatomic) IBOutlet UILabel *userPassword2Label;
@property (weak, nonatomic) IBOutlet UITextField *userPassword2TextField;
@property (weak, nonatomic) IBOutlet UIButton *registerVstratorButton;

@property (copy, nonatomic) NSString *currentUserEmail;

@end

#pragma mark -

@implementation RegisterVstratorViewController

#pragma mark Dismiss Actions

- (void)dismissWithLogin
{
    [self dismissViewControllerAnimated:NO completion:^{
        if ([self.delegate respondsToSelector:@selector(loginViewControllerDidLogin:)])
            [self.delegate loginViewControllerDidLogin:self];
    }];
}

#pragma mark User Registration

- (BOOL)userRegistrationFieldsValidate:(NSString **)outputString
{
    // preprocess input
    self.userFirstNameTextField.text = [NSString trimmedStringOrNil:self.userFirstNameTextField.text replaceMultipleSpaces:YES];
    self.userLastNameTextField.text = [NSString trimmedStringOrNil:self.userLastNameTextField.text replaceMultipleSpaces:YES];
    self.userEmailAddressTextField.text = [NSString trimmedStringOrNil:self.userEmailAddressTextField.text];
    // validate
    return [ValidationHelper validateFirstName:self.userFirstNameTextField.text outputString:outputString] && [ValidationHelper validateSecondName:self.userLastNameTextField.text outputString:outputString] && [ValidationHelper validateEmailAddress:self.userEmailAddressTextField.text outputString:outputString] && [ValidationHelper validatePasswords:self.userPassword1TextField.text withConfirm:self.userPassword2TextField.text outputString:outputString];
}

- (IBAction)registerVstratorAction:(id)sender
{
    NSString *errorString = nil;
    if ([self userRegistrationFieldsValidate:&errorString]) {
        [self showBGActivityIndicator:VstratorStrings.UserRegistrationRegisteringUserActivityTitle];
        [AccountController2.sharedInstance registerVstratorWithFirstName:self.userFirstNameTextField.text
                                                                lastName:self.userLastNameTextField.text
                                                                   email:self.userEmailAddressTextField.text
                                                                password:self.userPassword1TextField.text
                                                        primarySportName:VstratorConstants.DefaultSportName
                                                                callback:[self hideBGActivityCallback:^(NSError *error) {
            if (error == nil) {
                [FlurryLogger logTypedEvent:FlurryEventTypeRegisterWithVstrator];
                [self dismissWithLogin];
            }
        }]];
    } else {
        [UIAlertViewWrapper alertInvalidInputString:errorString];
    }
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
    [self.registerVstratorButton setTitle:VstratorStrings.UserRegistrationJoinVstratorButtonTitle forState:UIControlStateNormal];
    // TextField
    [self.userFirstNameTextField setPlaceholder:VstratorStrings.UserRegistrationFirstNameField];
    [self.userLastNameTextField setPlaceholder:VstratorStrings.UserRegistrationLastNameField];
    [self.userEmailAddressTextField setPlaceholder:VstratorStrings.UserRegistrationEmailAddressField];
    [self.userPassword1TextField setPlaceholder:VstratorStrings.UserRegistrationPasswordField];
    [self.userPassword2TextField setPlaceholder:VstratorStrings.UserRegistrationConfirmPasswordField];
    // Labels
    [self.userFirstNameLabel setText:[NSString stringWithFormat:@"%@:", VstratorStrings.UserRegistrationFirstNameField]];
    [self.userLastNameLabel setText:[NSString stringWithFormat:@"%@:", VstratorStrings.UserRegistrationLastNameField]];
    [self.userEmailAddressLabel setText:[NSString stringWithFormat:@"%@:", VstratorStrings.UserRegistrationEmailAddressField]];
    [self.userPassword1Label setText:[NSString stringWithFormat:@"%@:", VstratorStrings.UserRegistrationPasswordField]];
    [self.userPassword2Label setText:[NSString stringWithFormat:@"%@:", VstratorStrings.UserRegistrationConfirmPasswordField]];
}

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setLocalizableStrings];
    [self setResizableImages];
    self.navigationBarView.title = self.title = VstratorStrings.TitleRegistration;
}

- (void)setResizableImages
{
    [self.registerVstratorButton setBackgroundImage:[UIImage resizableImageNamed:@"bt-grey-n-black-h69"] forState:UIControlStateNormal];
    [self.registerVstratorButton setBackgroundImage:[UIImage resizableImageNamed:@"bt-black-01"] forState:UIControlStateHighlighted];
}

- (void)viewDidUnload
{
    // Release any retained subviews of the main view.
    self.backgroundImageView = nil;
    self.userFirstNameLabel = nil;
    self.userFirstNameTextField = nil;
    self.userLastNameLabel = nil;
    self.userLastNameTextField = nil;
    self.userEmailAddressLabel = nil;
    self.userEmailAddressTextField = nil;
    self.userPassword1Label = nil;
    self.userPassword1TextField = nil;
    self.userPassword2Label = nil;
    self.userPassword2TextField = nil;
    self.registerVstratorButton = nil;
    // Super
    [super viewDidUnload];
}

@end
