//
//  CameraViewController.m
//  VstratorApp
//
//  Created by Mac on 11.07.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "AccountController2.h"
#import "CameraViewController.h"
#import "RecordIndicatorView.h"
#import "SystemInformation.h"
#import "TipCameraView.h"
#import "VideoRecorder.h"
#import "VstratorExtensions.h"
#import "VstratorStrings.h"

#define kVAFpsKey @"CameraSelectedFps"

@interface CameraViewController () <TipViewDelegate, VideoRecorderDelegate> {
    BOOL _subscribedDeviceRotationNotifications;
    BOOL _tipIsShown;
    CGFloat _shutterTopViewRelHeight, _shutterBottomViewRelY;
    int _selectedFps;
    BOOL _isCameraBusy;
}

@property (nonatomic, strong) VideoRecorder *videoRecorder;
@property (nonatomic, strong) IBOutlet UIView *videoPreviewView;
@property (nonatomic, weak) IBOutlet UIButton *cancelButton;
@property (nonatomic, weak) IBOutlet UIButton *importButton;
@property (nonatomic, weak) IBOutlet UIButton *showGuidesButton;
@property (nonatomic, weak) IBOutlet UIButton *toggleCameraButton;
@property (nonatomic, weak) IBOutlet UIButton *toggleRecordButton;
@property (nonatomic, strong) IBOutlet UIView *guidesView;
@property (nonatomic, strong) IBOutlet UIImageView *guideImageView;
@property (nonatomic, weak) IBOutlet RecordIndicatorView *recordIndicatorView;
@property (weak, nonatomic) IBOutlet UIView *toolbarView;
@property (weak, nonatomic) IBOutlet UIImageView *toolbarBackgoundImage;
@property (nonatomic, strong) NSTimer *recordTimer;
@property (nonatomic, copy) Callback0 recordCompletionHandler;
@property (nonatomic, strong) TipCameraView *tipCameraView;

@property (nonatomic, strong) IBOutlet UIView *shutterView;
@property (nonatomic, weak) IBOutlet UIView *shutterTopView;
@property (nonatomic, weak) IBOutlet UIView *shutterBottomView;
@property (nonatomic, weak) IBOutlet UIImageView *shutterTopLeftImageView;
@property (nonatomic, weak) IBOutlet UIImageView *shutterTopRightImageView;
@property (nonatomic, weak) IBOutlet UIImageView *shutterBottomLeftImageView;
@property (nonatomic, weak) IBOutlet UIImageView *shutterBottomRightImageView;

@property (weak, nonatomic) IBOutlet UIButton *fpsButton;
@property (strong, nonatomic) IBOutlet UIView *fpsView;
@property (weak, nonatomic) IBOutlet UIImageView *fpsBackgroundImage;
@property (weak, nonatomic) IBOutlet UIButton *fps1Button;
@property (weak, nonatomic) IBOutlet UIButton *fps2Button;
@property (weak, nonatomic) IBOutlet UIButton *fps3Button;
@property (weak, nonatomic) IBOutlet UILabel *fpsLabel;

@end

#pragma mark -

@implementation CameraViewController

#pragma mark Properties

- (BOOL)statusBarHidden
{
    return YES;
}

- (VideoRecorder *)videoRecorder
{
    if (!_videoRecorder) {
        _videoRecorder = [[VideoRecorder alloc] init];
        _videoRecorder.delegate = self;
    }
    return _videoRecorder;
}

#pragma mark Capture Buttons and View State

- (void)updateButtonStates
{
    if (self.videoRecorder.isLoaded) {
        self.toggleCameraButton.enabled = YES;
        self.toggleRecordButton.enabled = YES;
    } else {
        self.toggleCameraButton.enabled = NO;
        self.toggleRecordButton.enabled = NO;
    }
}

- (void)enableCaptureButtonsAndView
{
    self.view.userInteractionEnabled = YES;
    self.cancelButton.enabled = YES;
    self.importButton.enabled = YES;
    [self updateButtonStates];
}

- (void)disableCaptureButtonsAndView
{
    self.view.userInteractionEnabled = NO;
    self.cancelButton.enabled = NO;
    self.importButton.enabled = NO;
    self.toggleCameraButton.enabled = NO;
    self.toggleRecordButton.enabled = NO;
}

#pragma mark MaxDurationTimer

- (void)stopRecordTimer
{
    if (self.recordTimer) {
        [self.recordTimer invalidate];
        self.recordTimer = nil;
    }
    [self.recordIndicatorView stop];
}

- (void)startRecordTimer
{
    [self stopRecordTimer];
    [self.recordIndicatorView startWithStartValue:VstratorConstants.ClipMaxDuration endValue:0];
    self.recordTimer = [NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(fireRecordTimer:) userInfo:NSDate.date repeats:YES];
}

- (void)fireRecordTimer:(NSTimer *)timer
{
    NSAssert(timer != nil && timer.userInfo != nil && [timer.userInfo isKindOfClass:NSDate.class], VstratorConstants.AssertionArgumentIsNilOrInvalid);
    // get record length
    NSDate *startTimerDate = (NSDate *)timer.userInfo;
    NSTimeInterval recordDuration = [NSDate.date timeIntervalSinceDate:startTimerDate];
    // stop functionality when reached ClipMaxDuration
    if (recordDuration >= VstratorConstants.ClipMaxDuration - 0.05f) {
        [self stopRecordTimer];
        if (self.videoRecorder.isRecording)
            [self toggleRecordAction:self.toggleRecordButton];
    }
}

#pragma mark VideoRecorderDelegate

- (void)videoRecorder:(VideoRecorder *)videoRecoder didFailWithError:(NSError *)error
{
    CFRunLoopPerformBlock(CFRunLoopGetMain(), kCFRunLoopCommonModes, ^(void) {
        if (!self.videoRecorder.isRecording)
            [self stopRecordTimer];
        [self enableCaptureButtonsAndView];
        [UIAlertViewWrapper alertError:error];
    });
}

- (void)videoRecorderDidStartRecording:(VideoRecorder *)videoRecoder
{
    CFRunLoopPerformBlock(CFRunLoopGetMain(), kCFRunLoopCommonModes, ^(void) {
        [self startRecordTimer];
        [self enableCaptureButtonsAndView];
        self.toggleRecordButton.selected = self.toggleRecordButton.enabled;
        [self.fpsView removeFromSuperview];
        self.fpsButton.hidden = NO;
        self.fpsButton.enabled = NO;
    });
}

- (void)videoRecorderDidStopRecording:(VideoRecorder *)videoRecoder
{
    CFRunLoopPerformBlock(CFRunLoopGetMain(), kCFRunLoopCommonModes, ^(void) {
        // perform
        [self stopRecordTimer];
        [self enableCaptureButtonsAndView];
        self.toggleRecordButton.selected = NO;
        self.fpsButton.enabled = YES;
        // callback
        if (self.recordCompletionHandler != nil) {
            Callback0 clbk = self.recordCompletionHandler;
            self.recordCompletionHandler = nil;
            clbk();
            return;
        }
        
        if ([self.delegate respondsToSelector:@selector(cameraViewControllerDidCapture:videoUrlQOrig:videoUrlQLow:)])
            [self.delegate cameraViewControllerDidCapture:self
                                            videoUrlQOrig:self.videoRecorder.outputFileUrlQOrig
                                             videoUrlQLow:self.videoRecorder.outputFileUrlQLow];
    });
}

#pragma mark Actions

- (IBAction)cancelAction:(id)sender
{
    if (_isCameraBusy) return;
    [self disableCaptureButtonsAndView];
    // create handler
    __weak CameraViewController *weakSelf = self;
    Callback0 handler = ^{
        if ([weakSelf.delegate respondsToSelector:@selector(cameraViewControllerDidCancel:)])
            [weakSelf.delegate cameraViewControllerDidCancel:weakSelf];
    };
    // perform
    if (self.videoRecorder.isRecording) {
        self.recordCompletionHandler = handler;
        [self.videoRecorder stopRecording];
    } else {
        [self enableCaptureButtonsAndView];
        handler();
    }
}

- (IBAction)importAction:(id)sender
{
    if (_isCameraBusy) return;
    [self disableCaptureButtonsAndView];
    // create handler
    __weak CameraViewController *weakSelf = self;
    Callback0 handler = ^{
        if ([weakSelf.delegate respondsToSelector:@selector(cameraViewControllerDidImport:)])
            [weakSelf.delegate cameraViewControllerDidImport:weakSelf];
    };
    // perform
    if (self.videoRecorder.isRecording) {
        self.recordCompletionHandler = handler;
        [self.videoRecorder stopRecording];
    } else {
        [self enableCaptureButtonsAndView];
        handler();
    }
}

- (IBAction)toggleRecordAction:(id)sender
{
    if (_isCameraBusy) return;
    [self disableCaptureButtonsAndView];
    
	if (self.videoRecorder.isRecording) {
		[self.videoRecorder stopRecording];
	}
	else {
        [self.videoRecorder startRecording];
	}
}

- (IBAction)showGuidesAction:(id)sender
{
    if (_isCameraBusy) return;
    if (self.guidesView.superview != nil)
        return;
    // hide one, show another
    self.showGuidesButton.hidden = YES;
    self.guidesView.frame = CGRectMake(self.showGuidesButton.frame.origin.x, self.showGuidesButton.frame.origin.y, self.guidesView.frame.size.width, self.guidesView.frame.size.height);
    [self.showGuidesButton.superview addSubview:self.guidesView];
}

- (IBAction)selectGuidesAction:(UIButton *)sender
{
    if (_isCameraBusy) return;
    if (self.guidesView.superview == nil)
        return;
    // hide one, show another
    [self.guidesView removeFromSuperview];
    self.showGuidesButton.hidden = NO;
    // hide current Guide
    if (self.guideImageView != nil) {
        [self.guideImageView removeFromSuperview];
        self.guideImageView = nil;
    }
    // return if GUIDES button was pressed
    if (sender.tag == 0 || sender.imageView == nil)
        return;
    // create UIImageView
    UIImage *image = [UIImage imageWithCGImage:sender.imageView.image.CGImage];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    CGFloat newImageWidth = 3 * image.size.width;
    CGFloat newImageHeight = 3 * image.size.height;
    imageView.frame = CGRectMake(0.5 * (self.videoPreviewView.frame.size.width - newImageWidth), 0.5 * (self.videoPreviewView.frame.size.height - newImageHeight), newImageWidth, newImageHeight);
    imageView.userInteractionEnabled = NO;
    imageView.backgroundColor = UIColor.clearColor;
    imageView.opaque = NO;
    // assign & show UIImageView
    self.guideImageView = imageView;
    [self.videoPreviewView addSubview:self.guideImageView];
}

#pragma mark TipCameraViewDelegate and Helpers

- (void)tipViewDidFinish:(UIView *)sender tipFlag:(BOOL)tipFlag
{
    _tipIsShown = YES;
    if (sender && sender.superview)
        [sender removeFromSuperview];
    NSNumber *tipFlagNumber = @(tipFlag);
    if (![AccountController2.sharedInstance.userAccount.tipCamera isEqualToNumber:tipFlagNumber]) {
        [AccountController2.sharedInstance updateUserLocally:^(NSError *error, AccountInfo *accountInfo) {
            accountInfo.tipCamera = tipFlagNumber;
        } andSaveWithCallback:nil];
    }
}

- (void)createAndShowTipCameraViewIf
{
    if (self.tipCameraView || _tipIsShown || !AccountController2.sharedInstance.userAccount.tipCamera.boolValue)
        return;
    // create tip
    TipCameraView *tipCameraView = [[TipCameraView alloc] initWithDelegate:self tipFlag:YES];
    tipCameraView.transform = CGAffineTransformMakeRotation(270 * M_PI / 180.0);
    tipCameraView.frame = CGRectMake(self.view.bounds.size.width, (self.view.bounds.size.height - tipCameraView.frame.size.height) / 2.0, tipCameraView.frame.size.width, tipCameraView.frame.size.height);
    [self.view addSubview:tipCameraView];
    self.tipCameraView = tipCameraView;
    // set up an animation for the transition between the views
    [UIView animateWithDuration:0.4 animations:^{
        tipCameraView.frame = CGRectOffset(tipCameraView.frame, -tipCameraView.frame.size.width, 0);
    }];
}

- (void)hideAndRemoveTipCameraViewIf
{
    if (self.tipCameraView == nil)
        return;
    if (self.tipCameraView.superview) {
        
        
        [UIView animateWithDuration:0.2 animations:^{
            self.tipCameraView.frame = CGRectOffset(self.tipCameraView.frame, self.tipCameraView.frame.size.width, 0);
        } completion:^(BOOL finished) {
            if (self.tipCameraView.superview)
                [self.tipCameraView removeFromSuperview];
            self.tipCameraView = nil;
        }];
        
        
    } else {
        self.tipCameraView = nil;
    }
}

#pragma mark Device Rotation

- (void)subscribeDeviceRotationNotifications
{
    if (_subscribedDeviceRotationNotifications)
        return;
    _subscribedDeviceRotationNotifications = YES;
    [UIDevice.currentDevice beginGeneratingDeviceOrientationNotifications];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(deviceDidRotate:) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)unsubscribeDeviceRotationNotifications
{
    if (!_subscribedDeviceRotationNotifications)
        return;
    _subscribedDeviceRotationNotifications = NO;
    [NSNotificationCenter.defaultCenter removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    [UIDevice.currentDevice endGeneratingDeviceOrientationNotifications];
}

- (void)deviceDidRotate:(NSNotification *)notification
{
    // any thread
    if (!NSThread.isMainThread) {
        [self performSelectorOnMainThread:@selector(deviceDidRotate:) withObject:notification waitUntilDone:NO];
        return;
    }
    // main thread
    UIDeviceOrientation orientation = UIDevice.currentDevice.orientation;
	[self.videoRecorder setVideoOrientation:orientation];
    
    if (!UIDeviceOrientationIsValidInterfaceOrientation(orientation))
        return;
    if (self.videoRecorder.isRecording || self.view == nil || !self.shutterView.hidden)
        return;

    if (UIDeviceOrientationIsPortrait(orientation))
        [self createAndShowTipCameraViewIf];
    else if (UIDeviceOrientationIsLandscape(orientation))
        [self hideAndRemoveTipCameraViewIf];
}

#pragma mark Shutter

- (void)showShutter
{
    [self layoutShutterViews];
    self.shutterView.hidden = NO;
}

- (void)layoutShutterViews
{
    // shutterView
    if (UIDeviceOrientationIsLandscape(UIDevice.currentDevice.orientation))
        self.shutterView.transform = CGAffineTransformMakeRotation(0);
    else
        self.shutterView.transform = CGAffineTransformMakeRotation(270 * M_PI / 180.0);
    self.shutterView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    // shutterTopView
    CGFloat newShutterTopViewHeight = self.shutterView.bounds.size.height * _shutterTopViewRelHeight;
    self.shutterTopView.frame = CGRectMake(0, 0, self.shutterView.bounds.size.width, newShutterTopViewHeight);
    // shutterBottomView
    CGFloat newShutterBottomViewY = newShutterTopViewHeight - _shutterBottomViewRelY;
    self.shutterBottomView.frame = CGRectMake(0, newShutterBottomViewY, self.shutterView.bounds.size.width, self.shutterView.bounds.size.height - newShutterBottomViewY);
}

- (void)hideShutter:(Callback0)callback
{ 
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
        if (callback)
            callback();
        [UIView animateWithDuration:0.4 animations:^{
            self.shutterTopView.frame = CGRectOffset(self.shutterTopView.frame, 0, -self.shutterTopView.frame.size.height);
            self.shutterBottomView.frame = CGRectOffset(self.shutterBottomView.frame, 0, self.shutterBottomView.frame.size.height);
        } completion:^(BOOL finished) {
            self.shutterView.hidden = YES;
            [self deviceDidRotate:nil];
        }];
    });
}

#pragma mark Fps

- (IBAction)showFpsAction:(id)sender {
    CGRect frame = self.fpsView.frame;
    frame.origin.x = self.fpsButton.frame.origin.x + self.toolbarView.frame.origin.x - (frame.size.width - self.fpsButton.frame.size.width);
    frame.origin.y = self.fpsButton.frame.origin.y;
    self.fpsView.frame = frame;
    [self.view addSubview:self.fpsView];
    [self.fpsView becomeFirstResponder];
    self.fpsButton.hidden = YES;
    self.fps1Button.selected = self.fps1Button.tag == _selectedFps;
    self.fps2Button.selected = self.fps2Button.tag == _selectedFps;
    self.fps3Button.selected = self.fps3Button.tag == _selectedFps;
}

- (IBAction)selectFpsAction:(id)sender {
    if (_isCameraBusy) return;
    _isCameraBusy = YES;
    [self.fpsView removeFromSuperview];
    self.fpsButton.hidden = NO;
    __block int fps = ((UIButton*)sender).tag;
    if (fps == _selectedFps) {
        _isCameraBusy = NO;
        return;
    }
    [self showShutter];
    [self hideShutter:^{
        [self.videoRecorder setupWithPreviewView:self.videoPreviewView andFrameRate:fps];
        fps = (int)self.videoRecorder.frameRate;
        [self.fpsButton setTitle:[NSString stringWithFormat:@"%d", fps] forState:UIControlStateNormal];
        _selectedFps = fps;
        [NSUserDefaults.standardUserDefaults setFloat:_selectedFps forKey:kVAFpsKey];
        _isCameraBusy = NO;
    }];
}

- (void)setupFpsSelector
{
    [self initSelectedFps];
    
    [self.fpsButton setTitle:[NSString stringWithFormat:@"%d", _selectedFps] forState:UIControlStateNormal];
    
    if ([SystemInformation isSystemVersionLessThan:@"7.0"] || ![self.videoRecorder isFrameRateSupported:60]) {
        [self.fpsButton removeFromSuperview];
        [self.fpsLabel removeFromSuperview];
        return;
    }
   
    [self addFpsButtonDelimiterAtPosition:1 withImageName:@"bg-camera-fps-delimiter-left"];
    
    if (![self.videoRecorder isFrameRateSupported:120]) {
        [self.fps2Button removeFromSuperview];
        
        CGRect frame = self.fpsView.frame;
        frame.size.width -= self.fps1Button.frame.size.width;
        self.fpsView.frame = frame;
        
        self.fps1Button.tag = 30;
        self.fps3Button.tag = 60;
        [self.fps3Button setTitle:@"60" forState:UIControlStateNormal];
    } else {
        self.fps1Button.tag = 30;
        self.fps2Button.tag = 60;
        self.fps3Button.tag = 120;
        
        [self addFpsButtonDelimiterAtPosition:2 withImageName:@"bg-camera-fps-delimiter-right"];
    }
    
    self.fpsBackgroundImage.image = [UIImage resizableImageNamed:@"bg-camera-fps"];
}

- (void)initSelectedFps
{
    _selectedFps = [NSUserDefaults.standardUserDefaults floatForKey:kVAFpsKey];
    if (_selectedFps == 0) {
        _selectedFps = 30;
    }
}

- (void)addFpsButtonDelimiterAtPosition:(int)position withImageName:(NSString*)imageName
{
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
    imageView.frame = CGRectMake(self.fps1Button.frame.size.width * position, 0, imageView.frame.size.width, self.fpsView.frame.size.height);
    [self.fpsView addSubview:imageView];
}

#pragma mark Localization

- (void) setLocalizableStrings
{
    [self.cancelButton setTitle:VstratorStrings.HomeCaptureClipCancelButtonTitle forState:UIControlStateNormal];
    [self.importButton setTitle:VstratorStrings.HomeCaptureClipImportButtonTitle forState:UIControlStateNormal];
    self.importButton.titleLabel.textAlignment = UITextAlignmentCenter;
    [self.showGuidesButton setTitle:VstratorStrings.HomeCaptureClipShowGuidesButtonTitle forState:UIControlStateNormal];
    self.fpsLabel.text = [VstratorStrings HomeCaptureClipFpsLabel];
}

#pragma mark Ctor

- (void)dealloc
{
    [self unsubscribeDeviceRotationNotifications];
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self name:UIApplicationDidBecomeActiveNotification object:[UIApplication sharedApplication]];
    [notificationCenter removeObserver:self name:UIApplicationWillResignActiveNotification object:[UIApplication sharedApplication]];
    
    [self.videoRecorder stopAndTearDownCaptureSession];
}

#pragma mark View Lifecycle

- (void)applicationDidBecomeActive:(NSNotification*)notifcation
{
    self.toggleRecordButton.selected = NO;
	[self.videoRecorder resumeCaptureSession];
}

- (void)applicationWillResignActive:(NSNotification*)notification
{
    [self.videoRecorder tearDownPreviewView];
}

- (void)viewDidLoad
{
    // Super
    [super viewDidLoad];
    
    // Shutter: ...images
    UIImage *shutterPartImage = [UIImage imageNamed:@"bg-camera-shutter-left-top"];
    self.shutterTopLeftImageView.image = [shutterPartImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, shutterPartImage.size.height - 2, shutterPartImage.size.width - 2)];
    shutterPartImage = [UIImage imageNamed:@"bg-camera-shutter-right-top"];
    self.shutterTopRightImageView.image = [shutterPartImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, shutterPartImage.size.width - 2, shutterPartImage.size.height - 2, 0)];
    shutterPartImage = [UIImage imageNamed:@"bg-camera-shutter-left-bottom"];
    self.shutterBottomLeftImageView.image = [shutterPartImage resizableImageWithCapInsets:UIEdgeInsetsMake(shutterPartImage.size.height - 2, 0, 0, shutterPartImage.size.width - 2)];
    shutterPartImage = [UIImage imageNamed:@"bg-camera-shutter-right-bottom"];
    self.shutterBottomRightImageView.image = [shutterPartImage resizableImageWithCapInsets:UIEdgeInsetsMake(shutterPartImage.size.height - 2, shutterPartImage.size.width - 2, 0, 0)];
    // ...views
    self.shutterView.frame = self.view.frame;
    _shutterTopViewRelHeight = self.shutterTopView.frame.size.height / self.shutterView.frame.size.height;
    _shutterBottomViewRelY = self.shutterTopView.frame.size.height - self.shutterBottomView.frame.origin.y;
    self.shutterView.hidden = YES;
    [self.view addSubview:self.shutterView];

    // Custom
    [self setLocalizableStrings];
    self.navigationBarView.hidden = YES;
    
    // Button action(s)
    SEL toggleRecordSelector = @selector(toggleRecordAction:);
    [self.toggleRecordButton addTarget:self action:toggleRecordSelector forControlEvents:UIControlEventTouchUpInside];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:[UIApplication sharedApplication]];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillResignActive:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:[UIApplication sharedApplication]];
    
    // RecordIndicatorView
    RecordIndicatorView *indicatorView = [[RecordIndicatorView alloc] init];
    indicatorView.frame = CGRectMake(330, 15, indicatorView.frame.size.width, indicatorView.frame.size.height);
    [self.view addSubview:indicatorView];
    self.recordIndicatorView = indicatorView;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self showShutter];
    [self subscribeDeviceRotationNotifications];
}

- (void)setupVideoRecorder
{
    [self setupFpsSelector];
    [self.videoRecorder setupWithPreviewView:self.videoPreviewView andFrameRate:_selectedFps];
    if (VstratorConstants.ScreenOfPlatform5e) {
        CGRect frame = self.videoPreviewView.frame;
        frame.size.width = self.view.bounds.size.width;
        self.videoPreviewView.frame = frame;
        [self.videoRecorder layoutPreviewView];
    }
    [self enableCaptureButtonsAndView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self hideShutter:^{ [self setupVideoRecorder]; }];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self unsubscribeDeviceRotationNotifications];
    [super viewDidDisappear:animated];
}

- (void)viewDidUnload
{
    self.videoRecorder = nil;
    self.videoPreviewView = nil;
    self.cancelButton = nil;
    self.importButton = nil;
    self.showGuidesButton = nil;
    self.toggleCameraButton = nil;
    self.toggleRecordButton = nil;
    self.guidesView = nil;
    self.guideImageView = nil;
    self.recordCompletionHandler = nil;
    self.shutterView = nil;
    self.shutterTopView = nil;
    self.shutterBottomView = nil;
    self.shutterTopLeftImageView = nil;
    self.shutterTopRightImageView = nil;
    self.shutterBottomLeftImageView = nil;
    self.shutterBottomRightImageView = nil;
    self.toolbarBackgoundImage = nil;
    self.toolbarView = nil;
    [super viewDidUnload];
}

#pragma mark Orientations

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
}

@end
