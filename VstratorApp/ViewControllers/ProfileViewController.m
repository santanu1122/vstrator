//
//  ProfileViewController.m
//  VstratorApp
//
//  Created by Mac on 26.02.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "ProfileViewController.h"
#import "AccountController2.h"
#import "MediaSourceSelector.h"
#import "VstratorExtensions.h"
#import "VstratorConstants.h"
#import "UIImage+Extensions.h"
#import "VstratorStrings.h"

#import <MobileCoreServices/UTCoreTypes.h>

@interface ProfileViewController() <UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate,  MediaSourceSelectorDelegate> {
    BOOL _userImageChanged;
}

@property (strong, nonatomic) MediaSourceSelector *mediaSourceSelector;

@property (nonatomic, weak) IBOutlet UIImageView *backgroundImageView;

@property (nonatomic, strong) IBOutlet UIView *userPropertiesView;
@property (nonatomic, strong) IBOutlet UIView *userPasswordView;
@property (nonatomic, weak) IBOutlet UIView *userContainerView;

@property (nonatomic, weak) IBOutlet UIImageView *userImage;
@property (nonatomic, weak) IBOutlet UILabel *userFirstNameLabel;
@property (nonatomic, weak) IBOutlet UITextField *userFirstNameTextField;
@property (nonatomic, weak) IBOutlet UILabel *userLastNameLabel;
@property (nonatomic, weak) IBOutlet UITextField *userLastNameTextField;
@property (nonatomic, weak) IBOutlet UILabel *userEmailAddressLabel;
@property (nonatomic, weak) IBOutlet UILabel *userEmailAddressTextLabel;
@property (nonatomic, weak) IBOutlet UILabel *userCurrentPasswordLabel;
@property (nonatomic, weak) IBOutlet UITextField *userCurrentPasswordTextField;
@property (nonatomic, weak) IBOutlet UILabel *userNewPassword1Label;
@property (nonatomic, weak) IBOutlet UITextField *userNewPassword1TextField;
@property (nonatomic, weak) IBOutlet UILabel *userNewPassword2Label;
@property (nonatomic, weak) IBOutlet UITextField *userNewPassword2TextField;
@property (nonatomic, weak) IBOutlet UIButton *changePictureButton;
@property (nonatomic, weak) IBOutlet UIButton *updateButton;
@property (nonatomic, weak) IBOutlet UIButton *showChangePasswordButton;
@property (nonatomic, weak) IBOutlet UIButton *changePasswordButton;

@end

@implementation ProfileViewController

#pragma mark - NavigationBar

- (void)navigationBarView:(NavigationBarView *)sender action:(NavigationBarViewAction)action
{
    if (action == NavigationBarViewActionBack) {
        if (self.userPasswordView.superview != nil) {
            [self userPasswordClearFields];
            [self.userContainerView switchViews:self.userPropertiesView];
            return;
        }
    }
    [super navigationBarView:sender action:action];
}

#pragma mark - User Properties

- (BOOL)userPropertiesValidate:(NSString **)outputString
{
    // preprocess input
    self.userFirstNameTextField.text = [NSString trimmedStringOrNil:self.userFirstNameTextField.text replaceMultipleSpaces:YES];
    self.userLastNameTextField.text = [NSString trimmedStringOrNil:self.userLastNameTextField.text replaceMultipleSpaces:YES];
    // validate
    return [ValidationHelper validateFirstName:self.userFirstNameTextField.text outputString:outputString] && [ValidationHelper validateSecondName:self.userLastNameTextField.text outputString:outputString];
}

- (void)userPropertiesShowInViews
{
    // update values
    AccountInfo *userCopy = AccountController2.sharedInstance.userAccount; // avoid multiple locks with @synchronize
    self.userFirstNameTextField.text = userCopy.firstName;
    self.userLastNameTextField.text = userCopy.lastName;
    self.userEmailAddressTextLabel.text = userCopy.email;
    self.userImage.image = userCopy.pictureImage;
}

- (void)userPropertiesReportUpdateAndSwitchView:(UIView *)newView
{
    [self userPropertiesReportUpdate:VstratorStrings.UserInfoViewAccountInfoProfileUpdatedMessage
                           withTitle:VstratorStrings.UserInfoViewAccountInfoProfileUpdatedMessageTitle
                       andSwitchView:newView];
}

- (void)userPropertiesReportUpdate:(NSString *)message withTitle:(NSString *)title andSwitchView:(UIView *)newView
{
    Callback switchViewsCallback = ^(id result) { if (newView != nil) [self.userContainerView switchViews:newView]; };
    UIAlertViewWrapper *wrapper = [UIAlertViewWrapper wrapperWithCallback:switchViewsCallback];
    [wrapper alertString:message
                   title:title];
}

- (IBAction)userPropertiesUpdateButtonPressed:(id)sender
{
    NSString *errorString = nil;
    if ([self userPropertiesValidate:&errorString]) {
        [self showBGActivityIndicator:VstratorStrings.UserInfoViewAccountInfoChangePictureUpdatingProfileActivityTitle];
        NSData *userImageData = _userImageChanged ? UIImageJPEGRepresentation([self.userImage.image rotateAndScaleFromCameraWithMaxSize:VstratorConstants.UserPictureMaxSize], VstratorConstants.UserPictureJPEGQuality) : nil;
        [AccountController2.sharedInstance updateUserWithFirstName:self.userFirstNameTextField.text
                                                          lastName:self.userLastNameTextField.text
                                                  primarySportName:AccountController2.sharedInstance.userAccount.primarySportName
                                                             image:userImageData
                                                          callback:[self hideBGActivityCallback:^(NSError *error) {
            [self userPropertiesShowInViews];
            if (error == nil)
                [self userPropertiesReportUpdateAndSwitchView:nil];
        }]];
        _userImageChanged = NO;
    } else {
        [UIAlertViewWrapper alertInvalidInputString:errorString];
    }
}

- (IBAction)userPropertiesChangePasswordButtonPressed:(id)sender
{
    [self.userContainerView switchViews:self.userPasswordView];
}

- (IBAction)userPropertiesChangePictureButtonPressed:(id)sender
{
    [self.mediaSourceSelector showWithPreferable:MediaSourcePreferableNon];
}

#pragma mark - User Image

- (NSArray *)imagePickerControllerRequiredMediaTypes
{
    return @[(NSString *)kUTTypeImage];
}

- (void)mediaSourceSelector:(MediaSourceSelector *)sender selected:(BOOL)selected type:(UIImagePickerControllerSourceType)sourceType
{
    if (!selected)
        return;
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.sourceType = sourceType;
    picker.allowsEditing = YES;
    picker.mediaTypes = [self imagePickerControllerRequiredMediaTypes];
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    UIViewController *pvc = picker.parentViewController == nil ? picker.presentingViewController : picker.parentViewController;
    [pvc dismissModalViewControllerAnimated:NO];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    // save
    _userImageChanged = YES;
    self.userImage.image = [info valueForKey:UIImagePickerControllerEditedImage];
    // dismiss
    UIViewController *pvc = picker.parentViewController == nil ? picker.presentingViewController : picker.parentViewController;
    [pvc dismissModalViewControllerAnimated:NO];
}

#pragma mark - Change Password

- (void)userPasswordClearFields
{
    self.userCurrentPasswordTextField.text = nil;
    self.userNewPassword1TextField.text = nil;
    self.userNewPassword2TextField.text = nil;
}

- (BOOL)userPasswordValidate:(NSString **)outputString
{
    return [ValidationHelper validatePassword:self.userCurrentPasswordTextField.text outputString:outputString] && [ValidationHelper validatePasswords:self.userNewPassword1TextField.text withConfirm:self.userNewPassword2TextField.text outputString:outputString];
}

- (IBAction)userPasswordUpdateButtonPressed:(id)sender
{
    NSString *errorString = nil;
    if ([self userPasswordValidate:&errorString]) {
        [self showBGActivityIndicator:VstratorStrings.UserInfoViewAccountInfoChangePasswordUpdatingPasswordActivityTitle];
        NSString *oldPassword = [NSString stringWithString:self.userCurrentPasswordTextField.text];
        NSString *newPassword = [NSString stringWithString:self.userNewPassword1TextField.text];
        [AccountController2.sharedInstance changeUserPassword:oldPassword
                                                toNewPassword:newPassword
                                                     callback:[self hideBGActivityCallback:^(NSError *error) {
            if (error == nil) {
                [self userPasswordClearFields];
                [self userPropertiesShowInViews];
                [self userPropertiesReportUpdate:VstratorStrings.UserInfoViewAccountInfoPasswordUpdatedMessage
                                       withTitle:VstratorStrings.UserInfoViewAccountInfoPasswordUpdatedMessageTitle
                                   andSwitchView:self.userPropertiesView];
            }
        }]];
    } else {
        [UIAlertViewWrapper alertInvalidInputString:errorString];
    }
}

#pragma mark - UITextFieldDelegate

- (void)setupTextFieldPopupView:(TextFieldPopupView *)textFieldPopupView
{
    [super setupTextFieldPopupView:textFieldPopupView];
    textFieldPopupView.backgroundImage = self.backgroundImageView.image;
    textFieldPopupView.titleColor = self.userEmailAddressLabel.textColor;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField.enabled && textField.userInteractionEnabled)
        [self.textFieldPopupView showWithTextField:textField inView:self.view];
    return NO;
}

#pragma mark - Localization

- (void)setLocalizableStrings
{
    // Buttons
    [self.updateButton setTitle:VstratorStrings.UserInfoViewAccountInfoUpdateButtonTitle forState:UIControlStateNormal];
    [self.showChangePasswordButton setTitle:VstratorStrings.UserInfoViewAccountInfoChangePasswordButtonTitle forState:UIControlStateNormal];
    [self.changePasswordButton setTitle:VstratorStrings.UserInfoViewAccountInfoChangePasswordChangePasswordButtonTitle forState:UIControlStateNormal];
    [self.changePictureButton setTitle:VstratorStrings.UserInfoViewAccountInfoChangePictureButtonTitle forState:UIControlStateNormal];
    // Text
    [self.userFirstNameTextField setPlaceholder:VstratorStrings.UserRegistrationFirstNameField];
    [self.userLastNameTextField setPlaceholder:VstratorStrings.UserRegistrationLastNameField];
    [self.userCurrentPasswordTextField setPlaceholder:VstratorStrings.UserInfoViewAccountInfoChangePasswordCurrentPasswordField];
    [self.userNewPassword1TextField setPlaceholder:VstratorStrings.UserInfoViewAccountInfoChangePasswordNewPasswordField];
    [self.userNewPassword2TextField setPlaceholder:VstratorStrings.UserInfoViewAccountInfoChangePasswordConfirmNewPasswordField];
    // Labels
    [self.userFirstNameLabel setText:[NSString stringWithFormat:@"%@:", VstratorStrings.UserRegistrationFirstNameField]];
    [self.userLastNameLabel setText:[NSString stringWithFormat:@"%@:", VstratorStrings.UserRegistrationLastNameField]];
    [self.userEmailAddressLabel setText:[NSString stringWithFormat:@"%@:", VstratorStrings.UserRegistrationEmailAddressField]];
    [self.userCurrentPasswordLabel setText:[NSString stringWithFormat:@"%@:", VstratorStrings.UserInfoViewAccountInfoChangePasswordCurrentPasswordField]];
    [self.userNewPassword1Label setText:[NSString stringWithFormat:@"%@:", VstratorStrings.UserInfoViewAccountInfoChangePasswordNewPasswordField]];
    [self.userNewPassword2Label setText:[NSString stringWithFormat:@"%@:", VstratorStrings.UserInfoViewAccountInfoChangePasswordConfirmNewPasswordField]];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.mediaSourceSelector = [[MediaSourceSelector alloc] initWithDelegate:self mediaTypes:[self imagePickerControllerRequiredMediaTypes]];
    [self setLocalizableStrings];
    [self userPropertiesShowInViews];
    [self.userContainerView switchViews:self.userPropertiesView];
}

- (void)viewDidUnload
{
    // Release any retained subviews of the main view.
    [self.userContainerView switchViews:nil];
    self.backgroundImageView = nil;
    self.userPropertiesView = nil;
    self.userPasswordView = nil;
    self.userContainerView = nil;
    self.userImage = nil;
    self.userFirstNameLabel = nil;
    self.userFirstNameTextField = nil;
    self.userLastNameLabel = nil;
    self.userLastNameTextField = nil;
    self.userEmailAddressLabel = nil;
    self.userEmailAddressTextLabel = nil;
    self.userCurrentPasswordLabel = nil;
    self.userCurrentPasswordTextField = nil;
    self.userNewPassword1Label = nil;
    self.userNewPassword1TextField = nil;
    self.userNewPassword2Label = nil;
    self.userNewPassword2TextField = nil;
    self.showChangePasswordButton = nil;
    self.changePictureButton = nil;
    self.changePasswordButton = nil;
    self.updateButton = nil;
    // Super
    [super viewDidUnload];
}

@end
