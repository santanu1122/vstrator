//
//  TelestrationPlayerViewController2.m
//  VstratorApp
//
//  Created by user on 12.03.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "TelestrationPlayerViewController2.h"

#import "AVPlayer+Extensions.h"
#import "BaseTelestrationShapeView.h"
#import "FrameStackModel.h"
#import "TelestrationPlaybackSequence.h"
#import "TelestrationPlaybackView.h"
#import "TelestrationPlayerView.h"
#import "TelestrationModel.h"
#import "VstrationController.h"
#import "VstrationMediaModel.h"
#import "VstratorExtensions.h"
#import "VstratorStrings.h"

#import <AVFoundation/AVFoundation.h>
#import <AVFoundation/AVAsset.h>
#import <AVFoundation/AVPlayer.h>
#import <AVFoundation/AVPlayerLayer.h>
#import <AVFoundation/AVAudioPlayer.h>

@interface TelestrationPlayerViewController2() <AVAudioPlayerDelegate, AVAudioSessionDelegate>
{
    AVPlayer *thePlayer;
    AVPlayer *thePlayer2;
    AVAudioPlayer *theAudioPlayer;
    TelestrationPlaybackSequence *theSequence;
    NSTimer *theSequenceTimer;
    NSTimer *theProgressTimer;
}

@property (nonatomic, readonly) BOOL autoPlay;
@property (nonatomic, readonly) BOOL saveMode;

@property (nonatomic, strong) IBOutlet UIView *messageView;
@property (nonatomic, unsafe_unretained) IBOutlet TelestrationPlayerView *playerView;
@property (nonatomic, unsafe_unretained) IBOutlet TelestrationPlayerView *playerView2;
@property (nonatomic, unsafe_unretained) IBOutlet UIView *shapesView;

@property (nonatomic, unsafe_unretained) IBOutlet UIProgressView *progressBar;
@property (nonatomic, unsafe_unretained) IBOutlet UIButton *pauseButton;
@property (nonatomic, unsafe_unretained) IBOutlet UIButton *playButton;
@property (nonatomic, unsafe_unretained) IBOutlet UIButton *redoButton;
@property (nonatomic, unsafe_unretained) IBOutlet UIButton *saveButton;

@end

@implementation TelestrationPlayerViewController2

#pragma mark - Properties

@synthesize delegate = _delegate;
@synthesize autoPlay = _autoPlay;
@synthesize saveMode = _saveMode;

@synthesize messageView = _messageView;
@synthesize playerView = _playerView;
@synthesize playerView2 = _playerView2;
@synthesize shapesView = _shapesView;

@synthesize progressBar = _progressBar;
@synthesize pauseButton = _pauseButton;
@synthesize playButton = _playButton;
@synthesize redoButton = _redoButton;
@synthesize saveButton = _saveButton;

#pragma mark - Navigation Staff

- (void)dismissWithFinish:(ContentAction)action
{
    [self dismissViewControllerAnimatedVApp:NO completionHandler:^{
        if ([self.delegate respondsToSelector:@selector(baseResponderDidFinish:withContentAction:)])
            [self.delegate baseResponderDidFinish:self withContentAction:action];
    }];
}

#pragma mark - Scrubbed

- (void)setupProgressTimer
{
    if (theProgressTimer != nil)
        return;
    theProgressTimer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(syncProgress) userInfo:nil repeats:YES];
}

- (void)syncProgress
{
    if (self.progressBar != nil && theAudioPlayer != nil)
        self.progressBar.progress = (float)(theAudioPlayer.currentTime / theAudioPlayer.duration);
}

- (void)stopProgressTimer
{
    if (theProgressTimer == nil)
        return;
    [theProgressTimer invalidate];
    theProgressTimer = nil;
}

#pragma mark - Playback

- (void)playPlayback
{
    // prepare audio & sequence
    NSError *error = nil;
    if (![self prepareAudioSessionAndPlayer:&error]) {
        [UIAlertViewWrapper alertError:error];
        return;
    }
    [self prepareSequence];
    [self setupProgressTimer];
    // play
    [theAudioPlayer play];
    [self playSequence:NO];
    // vis
    self.pauseButton.hidden = NO;
    self.playButton.hidden = YES;
}

- (void)pausePlaybackCore
{
    if (theAudioPlayer != nil && theAudioPlayer.isPlaying)
        [theAudioPlayer stop];
    [self stopSequenceTimer];
    [self stopProgressTimer];
}

- (void)pausePlayback
{
    // core
    [self pausePlaybackCore];
    // views
    [self syncProgress];
    //[self clearTelestrationShapes];
    if (self.pauseButton != nil)
        self.pauseButton.hidden = YES;
    if (self.playButton != nil)
        self.playButton.hidden = NO;
}

- (void)stopPlaybackCore
{
    [self pausePlaybackCore];
    if (theAudioPlayer != nil)
        theAudioPlayer.currentTime = 0;
    if (thePlayer != nil)
        [thePlayer seekToTime:kCMTimeZero toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    if (thePlayer2 != nil)
        [thePlayer2 seekToTime:kCMTimeZero toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
}

- (void)stopPlayback
{
    // core
    [self stopPlaybackCore];
    // views
    [self syncProgress];
    [self clearShapeViews];
    if (self.pauseButton != nil)
        self.pauseButton.hidden = YES;
    if (self.playButton != nil)
        self.playButton.hidden = NO;
}

#pragma mark - Sequence

- (void)prepareSequence
{
    [self seekSequence:theAudioPlayer.currentTime];
}

- (void)seekSequence:(NSTimeInterval)time
{
    // stop sequence if any
    [self stopSequenceTimer];
    // seek
    NSArray *steps = [theSequence seekToTime:time];
    [self showSequenceSteps:steps];
}

- (void)playSequence:(BOOL)continueMode
{
    NSTimeInterval currentTime = theAudioPlayer.currentTime;
    NSTimeInterval nextTime = 0;
    // show items
    NSArray *steps = [theSequence playAtTime:currentTime continueMode:continueMode nextTime:&nextTime];
    [self showSequenceSteps:steps];
    // plan next call
    NSTimeInterval timeInterval = nextTime - currentTime;
    if (timeInterval > 0)
        [self startSequenceTimer:timeInterval continueMode:YES];
}

- (void)showSequenceSteps:(NSArray *)steps
{
    for (NSObject *step in steps) {
        if ([step isKindOfClass:TelestrationPlaybackShapeStep.class])
            [self showSequenceShapeStep:(TelestrationPlaybackShapeStep *)step];
        else if ([step isKindOfClass:TelestrationPlaybackVideoStep.class])
            [self showSequenceVideoStep:(TelestrationPlaybackVideoStep *)step];
    }
}

- (void)showSequenceShapeStep:(TelestrationPlaybackShapeStep *)step
{
    if (step.action == TelestrationPlaybackShapeActionShow)
        [self showShapeView:step.shape];
    else if (step.action == TelestrationPlaybackShapeActionHide)
        [self hideShapeView:step.shape];
}

- (void)showSequenceVideoStep:(TelestrationPlaybackVideoStep *)step
{
    if (step.area == TelestrationPlaybackVideoAreaPlayer)
        [self showSequenceVideoStep:step player:thePlayer];
    else if (step.area == TelestrationPlaybackVideoAreaPlayer2)
        [self showSequenceVideoStep:step player:thePlayer2];
}

- (void)showSequenceVideoStep:(TelestrationPlaybackVideoStep *)step player:(AVPlayer *)player
{
    NSAssert(player != nil, VstratorConstants.AssertionArgumentIsNilOrInvalid);
    if (step.action == TelestrationPlaybackVideoActionPause) {
        [player pause];
    } else if (step.action == TelestrationPlaybackVideoActionPlay) {
        [player play];
    } else if (step.action == TelestrationPlaybackVideoActionSeek) {
        CMTime seekTime = [TelestrationPlaybackView scaledTimeWithTime:step.actionTime];
        [player seekToTime:seekTime]; // toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    }
}

#pragma mark - Sequence Timer

- (void)startSequenceTimer:(NSTimeInterval)timeInterval continueMode:(BOOL)continueMode
{
    theSequenceTimer = [NSTimer scheduledTimerWithTimeInterval:timeInterval
                                                        target:self
                                                      selector:@selector(performSequenceTimer:)
                                                      userInfo:[NSNumber numberWithBool:continueMode]
                                                       repeats:NO];
}

- (void)performSequenceTimer:(NSTimer *)timer
{
    BOOL continueMode = timer != nil && timer.userInfo != nil && [timer.userInfo isKindOfClass:NSNumber.class] && ((NSNumber *)timer.userInfo).boolValue;
    [self playSequence:continueMode];
}

- (void)stopSequenceTimer
{
    if (theSequenceTimer == nil)
        return;
    [theSequenceTimer invalidate];
    theSequenceTimer = nil;
}

#pragma mark - Sequence ShapeViews

- (void)showShapeView:(BaseTelestrationShapeView *)shape
{
    // check
    NSAssert(self.shapesView != nil && shape != nil && shape.superview == nil, VstratorConstants.AssertionArgumentIsNilOrInvalid);
    // perform
    [self.shapesView addSubview:shape];
    [shape scaleByPercentage:1.0 withNavBarHeight:0]; 
    [shape setNeedsDisplay];
}

- (void)hideShapeView:(BaseTelestrationShapeView *)shape
{
    // check
    NSAssert(self.shapesView != nil && shape != nil && shape.superview != nil, VstratorConstants.AssertionArgumentIsNilOrInvalid);
    // hide
    [shape removeFromSuperview];
}

- (void)clearShapeViews
{
    if (self.shapesView == nil)
        return;
    for (UIView *v in self.shapesView.subviews)
        [v removeFromSuperview];
}

#pragma mark - Application Events

- (void)applicationWillResignActiveAction
{
    [self pausePlayback];
}

#pragma mark - Actions

- (void)backAction:(id)sender
{
    [self dismissWithFinish:ContentActionCancel];
}

- (void)redoAction:(id)sender
{
    [self stopPlayback];
    [self dismissWithFinish:self.saveMode ? ContentActionRedo : ContentActionCancel];
}

- (void)saveAction:(id)sender
{
    [self stopPlayback];
    [self dismissWithFinish:ContentActionSave];
}

- (IBAction)playAction:(id)sender
{
    [self playPlayback];
}

- (IBAction)pauseAction:(id)sender
{
    [self pausePlayback];
}

- (IBAction)stopAction:(id)sender
{
    [self stopPlayback];
}

#pragma mark - AVAudioSessionDelegate

- (void)beginInterruption
{
    [self pausePlayback];
}

//- (void)endInterruption
//{
//    // intentionally left blank
//}

//- (void)inputIsAvailableChanged:(BOOL)isInputAvailable
//{
//    NSLog(@"inputIsAvailableChanged");
//}

#pragma mark - AVAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [self stopPlayback];
}

//- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
//{
//    NSLog(@"audioPlayerDecodeErrorDidOccur: %@", error);
//    [self stopPlayback];
//}

- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player
{
    [self pausePlayback];
}

//- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player
//{
//    [self endInterruption];
//}

#pragma mark - Setup

- (BOOL)attachAudioSession:(NSError **)error
{
    NSAssert(error != nil, VstratorConstants.AssertionErrorPointerIsNil);
    *error = nil;
    // perform
    NSError *audioError = nil;
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setDelegate:self];
    [audioSession setCategory:AVAudioSessionCategorySoloAmbient error:&audioError];
    if (audioError == nil)
        [audioSession setActive:YES error:&audioError];
    if (audioError != nil) {
        [self detachAudioSession];
        *error = [NSError errorWithError:audioError text:VstratorStrings.ErrorAudioSessionInitText];
    }
    return *error == nil;
}

- (void)detachAudioSession
{
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    if ([audioSession delegate] == self) {
        [audioSession setDelegate:nil];
        [audioSession setActive:NO error:nil];
    }
}

- (BOOL)prepareAudioSessionAndPlayer:(NSError **)error
{
    NSAssert(error != nil, VstratorConstants.AssertionErrorPointerIsNil);
    *error = nil;
    // session
    NSError *audioError = nil;
    [[AVAudioSession sharedInstance] setActive:YES error:&audioError];
    // player
    if (audioError == nil && ![theAudioPlayer prepareToPlay])
        audioError = [[NSError alloc] init];
    // over
    if (audioError != nil)
        *error = [NSError errorWithError:audioError text:VstratorStrings.ErrorActivatingAudioSessionOrPlayer];
    return *error == nil;
}

- (BOOL)setupAudioWithController:(VstrationController *)controller error:(NSError **)error
{
    NSAssert(error != nil, VstratorConstants.AssertionErrorPointerIsNil);
    *error = nil;
    // perform
    NSError *audioError = nil;
    if ([self attachAudioSession:&audioError]) {
        // audio file name
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *path = [paths objectAtIndex:0];
        NSString *audioFileName = [NSString stringWithFormat:@"%@/%@", path, controller.media.audioFileName];
        NSLog(@"Audio URL: %@", audioFileName);
        // setup
        theAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:audioFileName] error:&audioError];
        if (audioError == nil) {
            theAudioPlayer.delegate = self;
        } else {
            [self detachAudioSession];
        }
    }
    // over
    if (audioError != nil)
        *error = [NSError errorWithError:audioError text:VstratorStrings.ErrorAudioPlayerInitText];
    return *error == nil;
}

- (BOOL)setupVideoWithController:(VstrationController *)controller error:(NSError **)error
{
    NSAssert(error != nil, VstratorConstants.AssertionErrorPointerIsNil);
    *error = nil;
    // perform: ...player #1
    NSError *videoError = nil;
    thePlayer = [AVPlayer dequeuePlayerWithURL:controller.media.videoURL];
    if (thePlayer.error != nil) {
        NSLog(@"Error with the player #1: %@", thePlayer.error);
        videoError = thePlayer.error;
    }
    // ...player #2
    else if (controller.media.isSideBySide) {
        thePlayer2 = [AVPlayer dequeuePlayerWithURL2:controller.media.videoURL2];
        if (thePlayer2.error != nil) {
            NSLog(@"Error with the player #2: %@", thePlayer2.error);
            videoError = thePlayer2.error;
        }
    }
    // over
    if (videoError != nil)
        *error = [NSError errorWithError:videoError text:VstratorStrings.ErrorVideoPlayerInitText];
    return *error == nil;
}

- (void)setupSequenceWithController:(VstrationController *)controller
{
    theSequence = [[TelestrationPlaybackSequence alloc] initWithController:controller];
}

- (void)setupWithController:(VstrationController *)controller autoPlay:(BOOL)autoPlay saveMode:(BOOL)saveMode delegate:(id<BaseResponderDelegate>)delegate error:(NSError **)error
{
    NSAssert(error != nil, VstratorConstants.AssertionErrorPointerIsNil);
    *error = nil;
    // ivars
    _delegate = delegate;
    _autoPlay = autoPlay;
    _saveMode = saveMode;
    // setup
    if ([self setupAudioWithController:controller error:error])
        if ([self setupVideoWithController:controller error:error])
            [self setupSequenceWithController:controller];
}

#pragma mark - Ctor

- (id)initForPlayWithSession:(Session *)session autoPlay:(BOOL)autoPlay delegate:(id<BaseResponderDelegate>)delegate error:(NSError **)error
{
    self = [self initWithNibName:NSStringFromClass(self.class) bundle:nil];
    if (self) {
        VstrationMediaModel *media = [[VstrationMediaModel alloc] initWithSession:session];
        VstrationController *controller = [[VstrationController alloc] init];
        if ([controller load:media error:error]) {
            [self setupWithController:controller autoPlay:autoPlay saveMode:NO delegate:delegate error:error];
        } else {
            *error = [NSError errorWithError:*error text:VstratorStrings.ErrorLoadingSelectedSession];
        }
    }
    return self;
}

- (id)initForSaveWithController:(VstrationController *)controller delegate:(id<BaseResponderDelegate>)delegate error:(NSError **)error
{
    self = [self initWithNibName:NSStringFromClass(self.class) bundle:nil];
    if (self) {
        [self setupWithController:controller autoPlay:YES saveMode:YES delegate:delegate error:error];
    }
    return self;
}

- (void)dealloc
{
    [self stopPlaybackCore];
}

#pragma mark - Localization

- (void)setLocalizableStrings
{
    [self.redoButton setTitle:VstratorStrings.MediaSessionPlaybackRedoButtonTitle forState:UIControlStateNormal];
    [self.saveButton setTitle:VstratorStrings.MediaSessionPlaybackSaveButtonTitle forState:UIControlStateNormal];
}

#pragma mark - View Livecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // localization
    [self setLocalizableStrings];
    // navigation
    self.navigationBarView.hidden = YES;
    // mode
    if (!self.saveMode) {
        [self.redoButton setTitle:VstratorStrings.NavigationBarBackButtonTitle forState:UIControlStateNormal];
        self.saveButton.hidden = YES;
    }
    // player #1
    [self.playerView setPlayer:thePlayer];
    // player #2
    if (thePlayer2 != nil) {
        [self.playerView2 setPlayer:thePlayer2];
    } else {
        [self.playerView2 removeFromSuperview];
        self.playerView2 = nil;
        self.playerView.frame = self.shapesView.frame;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    // Super
    [super viewWillAppear:animated];
    // Status Bar
    UIApplication.sharedApplication.statusBarHidden = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // Application Events
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActiveAction) name:UIApplicationWillResignActiveNotification object:nil];
    // Audio Session
    NSError *audioError = nil;
    if (![self attachAudioSession:&audioError]) {
        audioError = [NSError errorWithError:audioError text:VstratorStrings.ErrorAudioPlayerInitText];
        [UIAlertViewWrapper alertError:audioError];
    }
    // Audo Play
    else if (self.autoPlay) {
        [self playAction:self.playButton];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    // Status Bar
    UIApplication.sharedApplication.statusBarHidden = NO;
    // Video/Audio
    [self stopPlayback];
    [self detachAudioSession];
    // Application Events
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    // Super
    [super viewWillDisappear:animated];
}

- (void)viewDidUnload
{
    // Release any retained subviews of the main view.
    [self setPlayerView:nil];
    [self setPlayerView2:nil];
    [self setPauseButton:nil];
    [self setPlayButton:nil];
    [self setShapesView:nil];
    [self setProgressBar:nil];
    [self setMessageView:nil];
    [self setRedoButton:nil];
    [self setSaveButton:nil];
    // Super
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

@end
