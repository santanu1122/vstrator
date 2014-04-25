//
//  BaseViewController.m
//  VstratorApp
//
//  Created by Mac on 07.04.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "AccountController2.h"
#import "BaseViewController.h"
#import "Clip.h"
#import "FeedbackViewController.h"
#import "FlurryLogger.h"
#import "InfoAboutViewController.h"
#import "InfoRootViewController.h"
#import "Media+Extensions.h"
#import "NavigationMenuView.h"
#import "ProfileViewController.h"
#import "Session+Extensions.h"
#import "ShareViewController.h"
#import "TelestrationPlayerViewController.h"
#import "TutorialViewController.h"
#import "RotatableViewProtocol.h"
#import "UploadQualitySelector.h"
#import "UploadQueueViewController.h"
#import "VstratorExtensions.h"
#import "VstratorStrings.h"
#import "WebViewController.h"

#define MENU_ANIMATION_SHOW @"MenuAnimationShow"
#define MENU_ANIMATION_HIDE @"MenuAnimationHide"

typedef enum {
    SplitViewDirectionLeft,
    SplitViewDirectionRight
} SplitViewDirection;

@interface BaseViewController () <MediaPlayerManagerDelegate, NavigationMenuViewDelegate> {
    BOOL _statusBarWasHidden;
    NavigationMenuViewAction _navigationMenuCurrentAction;
    CGPoint _previousLocation;
    SplitViewDirection _splitViewDirection;
}

@property (nonatomic, strong) UIView * activityOverlayView;
@property (nonatomic, strong) UIView * blackoutView;
@property (nonatomic, strong) UIView * splitView;
@property (nonatomic, strong) UIView * splitOverlayView;
@property (nonatomic, strong) NavigationMenuView * navigationMenuView;
@property (nonatomic, strong) UploadQualitySelector *uploadQualitySelector;
@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;

@end

#pragma mark -

@implementation BaseViewController

#pragma mark Properties

@synthesize loginManager = _loginManager;
@synthesize mediaPlayerManager = _mediaPlayerManager;
@synthesize navigationBarView = _navigationBarView;
@synthesize textFieldPopupView = _textFieldPopupView;

- (LoginManager *)loginManager
{
    NSAssert(NSThread.isMainThread, VstratorConstants.AssertionNotMainThreadAccess);
	if (_loginManager == nil) {
        _loginManager = [[LoginManager alloc] init];
        _loginManager.viewController = self;
    }
	return _loginManager;
}

- (MediaPlayerManager *)mediaPlayerManager
{
    NSAssert(NSThread.isMainThread, VstratorConstants.AssertionNotMainThreadAccess);
	if (_mediaPlayerManager == nil) {
        _mediaPlayerManager = [[MediaPlayerManager alloc] init];
        _mediaPlayerManager.viewController = self;
    }
	return _mediaPlayerManager;
}

- (NavigationBarView *)navigationBarView
{
    NSAssert(NSThread.isMainThread, VstratorConstants.AssertionNotMainThreadAccess);
	if (_navigationBarView == nil) {
        _navigationBarView = [[NavigationBarView alloc] initWithFrame:CGRectZero];
        _navigationBarView.frame = CGRectMake(0, 0, self.view.bounds.size.width, _navigationBarView.frame.size.height);
        _navigationBarView.delegate = self;
        _navigationBarView.title = self.title;
        _navigationBarView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
        [self.view addSubview:_navigationBarView];
    }
	return _navigationBarView;
}

- (TextFieldPopupView *)textFieldPopupView
{
    NSAssert(NSThread.isMainThread, VstratorConstants.AssertionNotMainThreadAccess);
	if (_textFieldPopupView == nil) {
        _textFieldPopupView = [[TextFieldPopupView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        if (self.view != nil)
            _textFieldPopupView.backgroundColor = self.view.backgroundColor;
        _textFieldPopupView.delegate = self;
        [self setupTextFieldPopupView:_textFieldPopupView];
    }
	return _textFieldPopupView;
}

- (BOOL)statusBarHidden
{
    return YES;
}

- (UIView *)splitView
{
    if (!_splitView) {
        _splitView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        _splitView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _splitView.backgroundColor = self.view.backgroundColor;
        _splitView.clipsToBounds = YES;
    }
    return _splitView;
}

- (UIView *)splitOverlayView
{
    if (!_splitOverlayView) {
        _splitOverlayView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        _splitOverlayView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _splitOverlayView.backgroundColor = [UIColor clearColor];
        
        UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideNavigationMenuView)];
        [_splitOverlayView addGestureRecognizer:gestureRecognizer];
    }
    return _splitOverlayView;
}

- (NavigationMenuView *)navigationMenuView
{
    if (!_navigationMenuView) {
        _navigationMenuView = [[NavigationMenuView alloc] initWithFrame:CGRectZero];
        CGRect frame = _navigationMenuView.frame;
        frame.size.height = self.view.frame.size.height;
        _navigationMenuView.frame = frame;
        _navigationMenuView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        _navigationMenuView.delegate = self;
    }
    return _navigationMenuView;
}

- (UploadQualitySelector *)uploadQualitySelector
{
    if (!_uploadQualitySelector) {
        _uploadQualitySelector = [[UploadQualitySelector alloc] init];
        _uploadQualitySelector.parentView = self.view;
    }
    return _uploadQualitySelector;
}

- (UIPanGestureRecognizer *)panGestureRecognizer
{
    if (!_panGestureRecognizer) {
        _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
        _panGestureRecognizer.maximumNumberOfTouches = 1;
    }
    return _panGestureRecognizer;
}

#pragma mark MediaPlayerManagerDelegate

- (void)mediaPlayerManagerDidClosed:(MediaPlayerManager *)sender
{
}

//- (CGSize)viewSizeForPortrait
//{
//    CGSize keyWindowFrame = UIApplication.sharedApplication.keyWindow.frame.size;
//    CGFloat statusBarHeight = self.statusBarHidden ? 0 : 20;
//    //CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
//    NSLog(@"%@ - %f", NSStringFromCGSize(keyWindowFrame), statusBarHeight);
//    return CGSizeMake(keyWindowFrame.width, keyWindowFrame.height - statusBarHeight);
//}
//
//- (CGSize)viewSizeForLandscape
//{
//    CGSize keyWindowFrame = UIApplication.sharedApplication.keyWindow.frame.size;
//    CGFloat statusBarHeight = self.statusBarHidden ? 0 : 20;
//    //CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
//    NSLog(@"%@ - %f", NSStringFromCGSize(keyWindowFrame), statusBarHeight);
//    return CGSizeMake(keyWindowFrame.height, keyWindowFrame.width - statusBarHeight);
//}

#pragma mark Navigation Bar

- (void)navigationBarView:(NavigationBarView *)sender action:(NavigationBarViewAction)action
{
    if (action == NavigationBarViewActionBack) {
        [self dismissViewControllerAnimated:NO completion:nil];
    } else if (action == NavigationBarViewActionSettings) {
//        UIViewController *vc = [[InfoRootViewController alloc] initWithNibName:NSStringFromClass(InfoRootViewController.class) bundle:nil];
//        [self presentViewController:vc animated:NO completion:nil];
        [self showNavigationMenuView];
    }
}

#pragma mark NavigationMenuView

- (void)navigatinMenuView:(NavigationMenuView *)sender didAction:(NavigationMenuViewAction)action
{
    _navigationMenuCurrentAction = action;
    if (action == NavigationMenuViewActionUploadQuality) {
        [self executeNavigationMenuCurrentAction];
    } else {
        [self hideNavigationMenuView];
    }
}

- (void)executeNavigationMenuCurrentAction
{
    switch (_navigationMenuCurrentAction) {
        case NavigationMenuViewActionAccountInfo:
        {
            __block __weak BaseViewController *blockSelf = self;
            [self.loginManager login:LoginQuestionTypeDialog callback:^(NSError *error, BOOL userIdentityChanged) {
                if (error == nil) {
                    UIViewController *vc = [[ProfileViewController alloc] initWithNibName:NSStringFromClass(ProfileViewController.class) bundle:nil];
                    [blockSelf presentViewController:vc animated:NO completion:nil];
                }
            }];
            break;
        }
        case NavigationMenuViewActionUploads:
        {
            UploadQueueViewController *vc = [[UploadQueueViewController alloc] initWithNibName:NSStringFromClass(UploadQueueViewController.class) bundle:nil];
            [self presentViewController:vc animated:NO completion:nil];
            [FlurryLogger logTypedEvent:FlurryEventTypeSettingsUploadQueueScreen];
            break;
        }
        case NavigationMenuViewActionInviteFriends:
        {
            ShareViewController *vc = [[ShareViewController alloc] initWithNibName:NSStringFromClass(ShareViewController.class) bundle:nil];
            vc.shareType = ShareTypeInviteFriends;
            vc.messageParameter = VstratorConstants.AppStoreWebAppURL.absoluteString;
            [self presentModalViewController:vc animated:NO];
            break;
        }
        case NavigationMenuViewActionTutorial:
        {
            TutorialViewController *vc = [[TutorialViewController alloc] initWithNibName:NSStringFromClass(TutorialViewController.class) bundle:nil];
            [self presentViewController:vc animated:NO completion:nil];
            [FlurryLogger logTypedEvent:FlurryEventTypeSettingsTutorialScreen];
            break;
        }
        case NavigationMenuViewActionSupportSite:
        {
            WebViewController *vc = [[WebViewController alloc] initWithNibName:NSStringFromClass(WebViewController.class) bundle:nil];
            vc.url = VstratorConstants.VstratorWwwSupportSiteURL;
            [self presentViewController:vc animated:NO completion:nil];
            [FlurryLogger logTypedEvent:FlurryEventTypeSettingsSupportSiteScreen];
            break;
        }
        case NavigationMenuViewActionFeedback:
        {
            __block __weak BaseViewController *blockSelf = self;
            [self.loginManager login:LoginQuestionTypeDialog callback:^(NSError *error, BOOL userIdentityChanged) {
                if (error == nil) {
                    UIViewController *vc = [[FeedbackViewController alloc] initWithNibName:NSStringFromClass(FeedbackViewController.class) bundle:nil];
                    [blockSelf presentViewController:vc animated:NO completion:nil];
                    [FlurryLogger logTypedEvent:FlurryEventTypeSettingsFeedbackScreen];
                }
            }];
            break;
        }
        case NavigationMenuViewActionAboutApp:
        {
            UIViewController *vc = [[InfoAboutViewController alloc] initWithNibName:NSStringFromClass(InfoAboutViewController.class) bundle:nil];
            [self presentViewController:vc animated:NO completion:nil];
            break;
        }
        case NavigationMenuViewActionRateApp:
        {
            if (![UIApplication.sharedApplication openURL:VstratorConstants.AppStoreRateThisAppURL])
                [UIAlertViewWrapper alertString:VstratorStrings.ErrorUnableToOpenSafariWithURL];
            break;
        }
        case NavigationMenuViewActionUploadQuality:
        {
            [self.uploadQualitySelector show];
            break;
        }
        case NavigationMenuViewActionLogout:
        {
            [self showBGActivityIndicator:VstratorStrings.UserLoginLoggingOutActivityTitle];
            [AccountController2.sharedInstance logoutWithCallback:[self hideBGActivityCallback:^(NSError *error) {
                [self.loginManager login:LoginQuestionTypeNone callback:nil];
                [FlurryLogger logTypedEvent:FlurryEventTypeLogout];
            }]];
            break;
        }
        default:
            break;
    }
    _navigationMenuCurrentAction = -1;
}

- (void)setContentUserInteraction:(BOOL)userInteraction
{
    if (userInteraction) {
        self.splitOverlayView.hidden = YES;
    } else {
        self.splitOverlayView.hidden = NO;
        [self.splitView bringSubviewToFront:self.splitOverlayView];
    }
}

- (void)slideSplitViewToDirectin:(SplitViewDirection)direction
{
    NSString *animationId = direction == SplitViewDirectionRight ? MENU_ANIMATION_SHOW : MENU_ANIMATION_HIDE;
    [UIView beginAnimations:animationId context:nil];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];

    CGFloat shift = - self.splitView.frame.origin.x;
    if (direction == SplitViewDirectionRight) shift += self.navigationMenuView.frame.size.width;
    CGRect frame = self.splitView.frame;
    frame.origin.x += shift;
    self.splitView.frame = frame;
    
    [UIView commitAnimations];
}

- (void)animationDidStop:(NSString*)animationID finished:(NSNumber*)finished context:(void*)context
{
    if ([animationID isEqualToString:MENU_ANIMATION_HIDE]) {
        [self.view removeGestureRecognizer:self.panGestureRecognizer];
        
        for (UIView *view in self.splitView.subviews) {
            [view removeFromSuperview];
            [self.view addSubview:view];
        }
        self.splitView.hidden = YES;
        self.navigationMenuView.hidden = YES;
        
        [self setContentUserInteraction:YES];
        
        [self executeNavigationMenuCurrentAction];
    } else if ([animationID isEqualToString:MENU_ANIMATION_SHOW]) {
        [self.view addGestureRecognizer:self.panGestureRecognizer];
    }
}

- (void)showNavigationMenuView
{
    _navigationMenuCurrentAction = -1;
    [self.navigationMenuView refreshMenu:AccountController2.sharedInstance.userLoggedIn];
    
    for (UIView *view in self.view.subviews) {
        if ([view isEqual:self.navigationMenuView] || [view isEqual:self.splitView]) continue;
        [view removeFromSuperview];
        [self.splitView addSubview:view];
    }
    self.splitView.hidden = NO;
    self.navigationMenuView.hidden = NO;
    
    [self setContentUserInteraction:NO];
    
    [self slideSplitViewToDirectin:SplitViewDirectionRight];
}

- (void)hideNavigationMenuView
{
    [self slideSplitViewToDirectin:SplitViewDirectionLeft];
}

- (void)pan:(UIPanGestureRecognizer*)gestureRecognizer
{
    if (self.navigationMenuView.hidden) return;
    
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:
            [self initPan];
            break;
        case UIGestureRecognizerStateChanged:
            [self processPanGestureRecognizer:gestureRecognizer];
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
            [self slideSplitViewToDirectin:_splitViewDirection];
            break;
        default:
            break;
    }
}

- (void)initPan
{
    _previousLocation = CGPointZero;
    _splitViewDirection = SplitViewDirectionLeft;
}

- (void)processPanGestureRecognizer:(UIPanGestureRecognizer*)gestureRecognizer
{
    CGPoint location = [gestureRecognizer translationInView:self.view];
    CGFloat deltaX = location.x - _previousLocation.x;
    
    if (self.splitView.frame.origin.x + deltaX > self.navigationMenuView.frame.size.width ||
        self.splitView.frame.origin.x + deltaX < 0) {
        return;
    }
    
    CGRect frame = self.splitView.frame;
    frame.origin.x += deltaX;
    self.splitView.frame = frame;
    
    _previousLocation = location;
    _splitViewDirection = deltaX > 0 ? SplitViewDirectionRight : SplitViewDirectionLeft;
}

#pragma mark TextFieldPopupView

- (void)setupTextFieldPopupView:(TextFieldPopupView *)textFieldPopupView
{
    // intentionally left blank
}

#pragma mark Helpers:Indicators

- (void)showBGActivityOverlayView:(NSString *)text lockViews:(BOOL)lockViews
{
    // hide if any
    [self hideBGActivityOverlayView];
    // vars
    CGFloat selfWidth = self.view.bounds.size.width;
    CGFloat selfHeight = self.view.bounds.size.height;
    // activity indicator
    UIActivityIndicatorView * activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityIndicator.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    activityIndicator.frame = CGRectOffset(activityIndicator.frame, 0.5 * (selfWidth - activityIndicator.frame.size.width), 0.5 * (selfHeight - activityIndicator.frame.size.height));
    activityIndicator.hidden = NO;
    [activityIndicator startAnimating];
    // label
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.1 * selfWidth, activityIndicator.frame.origin.y + activityIndicator.frame.size.height + 20, 0.8 * selfWidth, 20)];
    label.adjustsFontSizeToFitWidth = YES;
    label.autoresizingMask = activityIndicator.autoresizingMask;
    label.backgroundColor = [UIColor clearColor];
    label.hidden = NO;
    label.text = text;
    label.textAlignment = UITextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    // view
    UIView *activityOverlayView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, selfWidth, selfHeight)];
    activityOverlayView.alpha = 0.8;
    activityOverlayView.autoresizesSubviews = YES;
    activityOverlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    activityOverlayView.backgroundColor = UIColor.blackColor;
    activityOverlayView.opaque = YES;
    activityOverlayView.userInteractionEnabled = lockViews;
    [activityOverlayView addSubview:activityIndicator];
    [activityOverlayView addSubview:label];
    // hide keyboard
    [self.view endEditing:YES];
    // show
    self.activityOverlayView = activityOverlayView;
    [self.view addSubview:self.activityOverlayView];
}

- (void)hideBGActivityOverlayView
{
    if (self.activityOverlayView == nil)
        return;
    if (self.activityOverlayView.superview)
        [self.activityOverlayView removeFromSuperview];
    self.activityOverlayView = nil;
}

- (void)showBGActivityIndicator:(NSString *)title
{
    [self showBGActivityIndicator:title lockViews:YES];
}

- (void)showBGActivityIndicator:(NSString *)title lockViews:(BOOL)lockViews
{
    [self showBGActivityOverlayView:title lockViews:lockViews];
}

- (void)updateBGActivityIndicator:(NSString *)title
{
    [self updateBGActivityIndicator:title lockViews:YES];
}

- (void)updateBGActivityIndicator:(NSString *)title lockViews:(BOOL)lockViews
{
    [self showBGActivityIndicator:title lockViews:lockViews];
}

- (ErrorCallback)hideBGActivityCallback
{
    __block __weak BaseViewController *blockSelf = self;
    return [^(NSError *error) { [blockSelf hideBGActivityIndicator:error]; } copy];
}

- (ErrorCallback)hideBGActivityCallback:(ErrorCallback)callback
{
    __block __weak BaseViewController *blockSelf = self;
    return [^(NSError *error) { [blockSelf hideBGActivityIndicator:error withCallback:callback]; } copy];
}

- (void)hideBGActivityIndicator
{
    [self hideBGActivityOverlayView];
}

- (void)hideBGActivityIndicator:(NSError *)error
{
    [self hideBGActivityIndicator];
    if (error != nil)
        [UIAlertViewWrapper alertError:error];
}

- (void)hideBGActivityIndicator:(NSError *)error withCallback:(ErrorCallback)callback
{
    if (callback == nil) {
        [self hideBGActivityIndicator:error];
    } else {
        [self hideBGActivityIndicator];
        if (error == nil) {
            callback(error);
        } else {
            UIAlertViewWrapper *wrapper = [UIAlertViewWrapper wrapperWithCallback:^(id result) { callback(error); }];
            [wrapper alertError:error];
        }
    }
}

- (void)hideBGActivityIndicator:(NSError *)error0 withSelector:(SEL)selector
{
    if (selector == nil || ![self respondsToSelector:selector]) {
        [self hideBGActivityIndicator:error0];
    } else {
        __block __weak BaseViewController *blockSelf = self;
        [self hideBGActivityIndicator:error0 withCallback:^(NSError *error1) {
            [blockSelf performSelectorOnMainThread:selector withObject:error1 waitUntilDone:NO];
        }];
    }
}

- (void)showBlackoutView
{
    // hide if any
    [self hideBlackoutView];
    // view
    UIView *blackoutView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    blackoutView.autoresizesSubviews = YES;
    blackoutView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    blackoutView.backgroundColor = UIColor.blackColor;
    blackoutView.opaque = YES;
    blackoutView.userInteractionEnabled = NO;
    // hide keyboard
    [self.view endEditing:YES];
    // show
    self.blackoutView = blackoutView;
    [self.view addSubview:self.blackoutView];
}

- (void)hideBlackoutView
{
    if (self.blackoutView == nil)
        return;
    if (self.blackoutView.superview)
        [self.blackoutView removeFromSuperview];
    self.blackoutView = nil;
}

#pragma mark Helpers:Views

+ (void)switchViews:(UIView *)contentView containerView:(UIView *)containerView;
{
    [UIView switchViews:contentView containerView:containerView];
}

- (UIInterfaceOrientation)validOrientation:(UIInterfaceOrientation)orientation
{
    if (UIDeviceOrientationIsValidInterfaceOrientation(orientation) && UIInterfaceOrientationIsLandscape(orientation))
        return orientation;
    return UIInterfaceOrientationPortrait;
}

- (void)setOrientation:(UIInterfaceOrientation)orientation forViewInt:(UIView *)view
{
    if (view == nil)
        return;
    orientation = [self validOrientation:orientation];
    if ([view.class conformsToProtocol:@protocol(RotatableViewProtocol)])
        [(id<RotatableViewProtocol>)view setOrientation:orientation];
}

- (void)setOrientation:(UIInterfaceOrientation)orientation forView:(UIView*)view
{
    if (view == nil)
        return;
    for (UIView *subview in view.subviews) [self setOrientation:orientation forView:subview];
    [self setOrientation:orientation forViewInt:view];
}

#pragma mark Helpers:MoviePlayer

- (void)playMedia:(Media *)media
{
    [FlurryLogger logTypedEvent:FlurryEventTypeVideoPlayback
                 withParameters:@{ @"Video Key": [NSString isNilOrWhitespace:media.videoKey] ? @"" : media.videoKey,
                                   @"Pro Video": [FlurryLogger stringFromBool:media.isProMedia] }];
	[media performBlockIfClip:^(Clip* clip) {
        [self.mediaPlayerManager presentPlayerWithURL:[NSURL URLWithString:clip.url] introMode:NO animated:NO];
	} orSession:^(Session* session) {
		if (session.audioFileURL && session.telestrationData) {
			NSError *error = nil;
			UIViewController *vc = [[TelestrationPlayerViewController alloc] initForPlayWithSession:session autoPlay:YES delegate:nil error:&error];
            if (error == nil) {
                [self presentViewController:vc animated:NO completion:nil];
            } else {
                [UIAlertViewWrapper alertError:error];
            }
		} else {
            [self.mediaPlayerManager presentPlayerWithURL:[NSURL URLWithString:session.url] introMode:NO animated:NO];
		}
	}];
}

#pragma mark View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self navigationBarView];
    
    [self.view addSubview:self.splitView];
    [self.view sendSubviewToBack:self.splitView];
    self.splitView.hidden = YES;
    
    [self.splitView addSubview:self.splitOverlayView];
    self.splitOverlayView.hidden = YES;
    
    [self.view addSubview:self.navigationMenuView];
    [self.view sendSubviewToBack:self.navigationMenuView];
    self.navigationMenuView.hidden = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    //[self rotate:self.interfaceOrientation];
    //[self setOrientation:self.interfaceOrientation forView:self.view];
    _statusBarWasHidden = UIApplication.sharedApplication.statusBarHidden;
    if (_statusBarWasHidden != self.statusBarHidden)
        [UIApplication.sharedApplication setStatusBarHidden:self.statusBarHidden withAnimation:animated];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    if (_statusBarWasHidden != self.statusBarHidden)
        [UIApplication.sharedApplication setStatusBarHidden:_statusBarWasHidden withAnimation:animated];
    [super viewWillDisappear:animated];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self rotate:self.interfaceOrientation];
    [self setOrientation:self.interfaceOrientation forView:self.view];
    //self.navigationBarView.frame = CGRectMake(self.navigationBarView.frame.origin.x, self.navigationBarView.frame.origin.y, self.view.bounds.size.width, self.navigationBarView.frame.size.height);
}

- (void)viewDidUnload
{
    _navigationBarView = nil;
    _textFieldPopupView = nil;
    self.activityOverlayView = nil;
    self.blackoutView = nil;
    [super viewDidUnload];
}

#pragma mark Orientations

- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

//- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
//{
//    [self rotate:toInterfaceOrientation];
//    [self setOrientation:toInterfaceOrientation forView:self.view];
//    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
//}

- (void)rotate:(UIInterfaceOrientation)toInterfaceOrientation
{
    [self.navigationBarView setOrientation:toInterfaceOrientation];
}

#pragma mark Memory Debug

//static NSInteger _instancesCount = 0;
//
//- (id)initWithCoder:(NSCoder *)aDecoder
//{
//    NSLog(@" =>> VC init <%@>. VC count: %d", NSStringFromClass(self.class), ++_instancesCount);
//    return [super initWithCoder:aDecoder];
//}
//
//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    NSLog(@" =>> VC init <%@>. VC count: %d", NSStringFromClass(self.class), ++_instancesCount);
//    return [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//}
//
//- (void)dealloc
//{
//    NSLog(@" =>> VC dealloc <%@>. VC count: %d", NSStringFromClass(self.class), --_instancesCount);
//}

@end
