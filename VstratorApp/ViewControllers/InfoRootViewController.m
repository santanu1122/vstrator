//
//  InfoRootViewController.m
//  VstratorApp
//
//  Created by Mac on 12.03.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "InfoRootViewController.h"

#import "AccountController2.h"
#import "FeedbackViewController.h"
#import "FlurryLogger.h"
#import "InfoAboutViewController.h"
#import "ProfileViewController.h"
#import "ShareViewController.h"
#import "TutorialViewController.h"
#import "UploadQualitySelectorView.h"
#import "UploadOptionsSelectorView.h"
#import "UploadQueueViewController.h"
#import "VstratorExtensions.h"
#import "VstratorStrings.h"
#import "WebViewController.h"
#import "UIImage+Resizable.h"

#import <QuartzCore/QuartzCore.h>

@interface InfoRootViewController()

@property (weak, nonatomic) IBOutlet UIView *buttonsView;
@property (weak, nonatomic) IBOutlet UIButton *viewAccountInfoButton;
@property (weak, nonatomic) IBOutlet UIButton *aboutThisAppButton;
@property (weak, nonatomic) IBOutlet UIButton *rateThisAppButton;
@property (weak, nonatomic) IBOutlet UIButton *tutorialButton;
@property (weak, nonatomic) IBOutlet UIButton *feedbackButton;
@property (weak, nonatomic) IBOutlet UIButton *logoutButton;
@property (weak, nonatomic) IBOutlet UIButton *uploadQueueButton;
@property (weak, nonatomic) IBOutlet UploadQualitySelectorView *uploadQualityButton;
@property (weak, nonatomic) IBOutlet UploadOptionsSelectorView *uploadOptionsButton;
@property (weak, nonatomic) IBOutlet UIButton *supportSiteButton;
@property (weak, nonatomic) IBOutlet UIButton *inviteFriends;

@end


@implementation InfoRootViewController

#pragma mark - Business Logic

- (IBAction)viewAccountInfoButtonPressed:(id)sender
{
    __block __weak InfoRootViewController *blockSelf = self;
    [self.loginManager login:LoginQuestionTypeDialog callback:^(NSError *error, BOOL userIdentityChanged) {
        if (error == nil) {
            UIViewController *vc = [[ProfileViewController alloc] initWithNibName:NSStringFromClass(ProfileViewController.class) bundle:nil];
            [blockSelf presentViewController:vc animated:YES completion:nil];
        }
    }];
}

- (IBAction)aboutThisAppButtonPressed:(id)sender
{
    UIViewController *vc = [[InfoAboutViewController alloc] initWithNibName:NSStringFromClass(InfoAboutViewController.class) bundle:nil];
    [self presentViewController:vc animated:NO completion:nil];
}

- (IBAction)rateThisAppButtonPressed:(id)sender
{
    if (![UIApplication.sharedApplication openURL:VstratorConstants.AppStoreRateThisAppURL])
        [UIAlertViewWrapper alertString:VstratorStrings.ErrorUnableToOpenSafariWithURL];
}

- (IBAction)tutorialButtonPressed:(id)sender
{
    TutorialViewController *vc = [[TutorialViewController alloc] initWithNibName:NSStringFromClass(TutorialViewController.class) bundle:nil];
    [self presentViewController:vc animated:NO completion:nil];
    [FlurryLogger logTypedEvent:FlurryEventTypeSettingsTutorialScreen];
}

- (IBAction)feedbackButtonPressed:(id)sender
{
    __block __weak InfoRootViewController *blockSelf = self;
    [self.loginManager login:LoginQuestionTypeDialog callback:^(NSError *error, BOOL userIdentityChanged) {
        if (error == nil) {
            UIViewController *vc = [[FeedbackViewController alloc] initWithNibName:NSStringFromClass(FeedbackViewController.class) bundle:nil];
            [blockSelf presentViewController:vc animated:YES completion:nil];
            [FlurryLogger logTypedEvent:FlurryEventTypeSettingsFeedbackScreen];
        }
    }];
}

- (IBAction)logoutButtonPressed:(id)sender
{
    [self showBGActivityIndicator:VstratorStrings.UserLoginLoggingOutActivityTitle];
    [AccountController2.sharedInstance logoutWithCallback:[self hideBGActivityCallback:^(NSError *error) {
        [FlurryLogger logTypedEvent:FlurryEventTypeLogout];
        [self updateLogoutButtonVisibility];
    }]];
}

- (IBAction)uploadQueueButtonPressed:(id)sender {
    UploadQueueViewController *vc = [[UploadQueueViewController alloc] initWithNibName:NSStringFromClass(UploadQueueViewController.class) bundle:nil];
    [self presentViewController:vc animated:NO completion:nil];
    [FlurryLogger logTypedEvent:FlurryEventTypeSettingsUploadQueueScreen];
}

- (IBAction)supportSiteButtonPressed:(id)sender
{
    WebViewController *vc = [[WebViewController alloc] initWithNibName:NSStringFromClass(WebViewController.class) bundle:nil];
    vc.url = VstratorConstants.VstratorWwwSupportSiteURL;
    [self presentViewController:vc animated:NO completion:nil];
//    if (![UIApplication.sharedApplication openURL:VstratorConstants.VstratorWwwSupportSiteURL])
//        [UIAlertViewWrapper alertString:VstratorStrings.ErrorUnableToOpenSafariWithURL];
    [FlurryLogger logTypedEvent:FlurryEventTypeSettingsSupportSiteScreen];
}

- (IBAction)inviteFriendsPressed:(id)sender {
    ShareViewController *vc = [[ShareViewController alloc] initWithNibName:NSStringFromClass(ShareViewController.class) bundle:nil];
    vc.shareType = ShareTypeInviteFriends;
    vc.messageParameter = VstratorConstants.AppStoreWebAppURL.absoluteString;
    [self presentModalViewController:vc animated:NO];
}

- (void)updateLogoutButtonVisibility
{
    self.logoutButton.hidden = !AccountController2.sharedInstance.userLoggedIn;
}

#pragma mark - Localization

- (void)setLocalizableStrings
{
    // Buttons
    [self.viewAccountInfoButton setTitle:VstratorStrings.UserInfoViewAccountInfoButtonTitle forState:UIControlStateNormal];
    [self.aboutThisAppButton setTitle:VstratorStrings.UserInfoAboutThisAppButtonTitle forState:UIControlStateNormal];
    [self.rateThisAppButton setTitle:VstratorStrings.UserInfoRateThisAppButtonTitle forState:UIControlStateNormal];
    [self.tutorialButton setTitle:VstratorStrings.UserInfoTutorialButtonTitle forState:UIControlStateNormal];
    [self.feedbackButton setTitle:VstratorStrings.UserInfoGetHelpButtonTitle forState:UIControlStateNormal];
    [self.logoutButton setTitle:VstratorStrings.UserInfoLogoutButtonTitle forState:UIControlStateNormal];
    [self.uploadQueueButton setTitle:VstratorStrings.UserInfoUploadQueueButtonTitle forState:UIControlStateNormal];
    [self.uploadQualityButton setTitle:VstratorStrings.UserInfoUploadQualityButtonTitle forState:UIControlStateNormal];
    [self.uploadOptionsButton setTitle:VstratorStrings.UserInfoUploadOptionButtonTitle forState:UIControlStateNormal];
    [self.supportSiteButton setTitle:VstratorStrings.UserInfoSupportSiteButtonTitle forState:UIControlStateNormal];
    [self.inviteFriends setTitle:VstratorStrings.UserInfoInviteFriendsButtonTitle forState:UIControlStateNormal];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setLocalizableStrings];
    self.buttonsView.layer.borderWidth = 1.0;
    self.buttonsView.layer.borderColor = UIColor.blackColor.CGColor;
    self.buttonsView.layer.cornerRadius = 5.0;
    self.buttonsView.layer.shadowColor = [UIColor colorWithWhite:0 alpha:0.5].CGColor;
    self.buttonsView.layer.shadowOffset = CGSizeMake(0, 1);
    [self.logoutButton setBackgroundImage:[UIImage resizableImageNamed:@"bt-grey-n-black-h69"] forState:UIControlStateNormal];
    [self.logoutButton setBackgroundImage:[UIImage resizableImageNamed:@"bt-black-01"] forState:UIControlStateHighlighted];
    [FlurryLogger logTypedEvent:FlurryEventTypeSettingsScreen];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateLogoutButtonVisibility];
}

- (void)viewDidUnload
{
    // Release any retained subviews of the main view.
    self.buttonsView = nil;
    self.viewAccountInfoButton = nil;
    self.aboutThisAppButton = nil;
    self.rateThisAppButton = nil;
    self.tutorialButton = nil;
    self.feedbackButton = nil;
    self.supportSiteButton = nil;
    self.uploadQueueButton = nil;
    self.uploadQualityButton = nil;
    self.logoutButton = nil;
    self.inviteFriends = nil;
    // Super
    [super viewDidUnload];
}

@end
