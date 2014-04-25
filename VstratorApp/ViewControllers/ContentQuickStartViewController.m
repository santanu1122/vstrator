//
//  ContentQuickStartViewController.m
//  VstratorApp
//
//  Created by Mac on 18.05.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "ContentQuickStartViewController.h"
#import "AccountController2.h"
#import "JoinCommunityViewController.h"
#import "MediaService.h"
#import "Notification.h"
#import "NotificationViewController.h"
#import "TutorialViewController.h"
#import "VstratorExtensions.h"
#import "VstratorStrings.h"

@interface ContentQuickStartViewController() <TutorialViewControllerDelegate>
{
    BOOL _viewDidAppearOnce;
    BOOL _showLogin;
    BOOL _showTutorial;
}

@property (nonatomic, weak) IBOutlet UIImageView *logoImageView;
@property (nonatomic, weak) IBOutlet UIButton *vstrateButton;
@property (nonatomic, weak) IBOutlet UIButton *proButton;
@property (nonatomic, weak) IBOutlet UILabel *vstrateLabel;
@property (nonatomic, weak) IBOutlet UILabel *vstrateSubLabel1;
@property (nonatomic, weak) IBOutlet UILabel *vstrateSubLabel2;
@property (nonatomic, weak) IBOutlet UILabel *proLabel;
@property (nonatomic, weak) IBOutlet UILabel *proSubLabel1;
@property (nonatomic, weak) IBOutlet UILabel *proSubLabel2;

@end

#pragma mark -

@implementation ContentQuickStartViewController

#pragma mark Properties

static NSMutableDictionary *_shownNotifications = nil;

- (BOOL)statusBarHidden
{
    return YES;
}

#pragma mark Business Logic

- (void)popWithFinish:(TabBarAction)action
{
    [self dismissViewControllerAnimated:NO completion:^{
        if ([self.delegate respondsToSelector:@selector(contentQuickStartViewController:didTabBar:)])
            [self.delegate contentQuickStartViewController:self didTabBar:action];
    }];
}

- (IBAction)settingsAction:(id)sender
{
    [self navigationBarView:self.navigationBarView action:NavigationBarViewActionSettings];
}

- (IBAction)proAction:(id)sender
{
    JoinCommunityViewController *vc = [[JoinCommunityViewController alloc] init];
    [self presentViewController:vc animated:NO completion:nil];
}

- (IBAction)vstrateAction:(id)sender
{
    [self popWithFinish:TabBarActionVstrate];
}

#pragma mark TutorialViewControllerDelegate

- (void)showTutorialViewController
{
    TutorialViewController *vc = [[TutorialViewController alloc] initWithNibName:NSStringFromClass(TutorialViewController.class) bundle:nil];
    vc.delegate = self;
    vc.dontShowFlagHidden = NO;
    [self presentViewController:vc animated:NO completion:nil];
}

- (void)tutorialViewControllerDidSkip:(TutorialViewController *)sender
{
    BOOL tipWelcome = !sender.dontShowFlagValue;
    if (tipWelcome != AccountController2.sharedInstance.userAccount.tipWelcome.boolValue) {
        [AccountController2.sharedInstance updateUserLocally:^(NSError *error, AccountInfo *accountInfo) {
            accountInfo.tipWelcome = @(tipWelcome);
        } andSaveWithCallback:nil];
    }
    [self showNotificationsIf];
}

#pragma mark TabViewDelegate

- (void)tabBarView:(TabBarView *)sender action:(TabBarAction)action changesSelection:(BOOL)changesSelection
{
    [super tabBarView:sender action:action changesSelection:changesSelection];
    [self popWithFinish:action];
}

#pragma mark Notifications

- (BOOL)shouldShowNotification:(Notification *)notification
{
    if ([_shownNotifications.allKeys containsObject:notification.identity]) {
        NSDate *shownDate = _shownNotifications[notification.identity];
        if ([NSDate.date timeIntervalSinceDate:shownDate] < 600)
            return NO;
    }
    _shownNotifications[notification.identity] = NSDate.date;
    return YES;
}

- (void)showNotificationsIf
{
    self.view.userInteractionEnabled = NO;
    [MediaService.mainThreadInstance getLastNotification:^(Notification *notification, NSError *error) {
        if (notification != nil && [self shouldShowNotification:notification]) {
            NotificationViewController *vc = [[NotificationViewController alloc] initWithNotification:notification];
            [self presentViewController:vc animated:NO completion:nil];
        }
        self.view.userInteractionEnabled = YES;
    }];
}

#pragma mark Application Events

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    if (self.view != nil)
        [self showNotificationsIf];
}

#pragma mark Localization

- (void)setLocalizableStrings
{
    [self.vstrateLabel setText:VstratorStrings.HomeQuickStartVstrateLabel];
    [self.vstrateSubLabel1 setText:VstratorStrings.HomeQuickStartVstrateSubLabel1];
    [self.vstrateSubLabel2 setText:VstratorStrings.HomeQuickStartVstrateSubLabel2];
    [self.proLabel setText:VstratorStrings.HomeQuickStartProLabel];
    [self.proSubLabel1 setText:VstratorStrings.HomeQuickStartProSubLabel1];
    [self.proSubLabel2 setText:VstratorStrings.HomeQuickStartProSubLabel2];
}

#pragma mark Global Init

+ (void)initialize
{
    _shownNotifications = [[NSMutableDictionary alloc] init];
}

#pragma mark View Lifecycle

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.tabBarView.selectedAction = TabBarActionNotSet;
}

- (void)viewDidLoad
{
    // Super
    [super viewDidLoad];
    // Localization
    [self setLocalizableStrings];
    // Navigation Bar
    self.navigationBarView.hidden = YES;
    self.logoImageView.frame = CGRectMake(self.logoImageView.frame.origin.x, VstratorConstants.ScreenOfPlatform4m ? 90 : 133, self.logoImageView.frame.size.width, self.logoImageView.frame.size.height);
    // Images
    [self.proButton setBackgroundImage:[UIImage resizableImageNamed:@"bt-home-join-normal"] forState:UIControlStateNormal];
    // Hide self to show tutorial, if needed
    _showLogin = self.firstTimeMode && !AccountController2.sharedInstance.userLoggedIn;
    _showTutorial = self.firstTimeMode && AccountController2.sharedInstance.userAccount.tipWelcome.boolValue;
    if (_showLogin && _showTutorial)
        [self showBlackoutView];
}

- (void)viewDidAppear:(BOOL)animated
{
    // Super
    [super viewDidAppear:animated];
    // Application Events
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    // Launch following processing only once
    if (_viewDidAppearOnce)
        return;
    _viewDidAppearOnce = YES;
    // Show different objects, if needed
    if (_showLogin) {
        _showLogin = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            __block __weak ContentQuickStartViewController *blockSelf = self;
            [self.loginManager login:LoginQuestionTypeNone callback:^(NSError *error, BOOL userIdentityChanged) {
                [blockSelf showTutorialViewController];
                [blockSelf hideBlackoutView];
            }];
        });
    } else if (_showTutorial) {
        _showTutorial = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showTutorialViewController];
            [self hideBlackoutView];
        });
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showNotificationsIf];
        });
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    // Application Events
    [NSNotificationCenter.defaultCenter removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    // Super
    [super viewWillDisappear:animated];
}

- (void)viewDidUnload
{
    // Release any retained subviews of the main view.
    self.proButton = nil;
    self.vstrateButton = nil;
    self.vstrateLabel = nil;
    self.vstrateSubLabel1 = nil;
    self.vstrateSubLabel2 = nil;
    self.proLabel = nil;
    self.proSubLabel1 = nil;
    self.proSubLabel2 = nil;
    // Super
    [self setLogoImageView:nil];
    [super viewDidUnload];
}

@end
