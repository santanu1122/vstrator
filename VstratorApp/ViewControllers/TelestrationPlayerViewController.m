//
//  TelestrationPlayerViewController.m
//  VstratorApp
//
//  Created by user on 12.03.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "TelestrationPlayerViewController.h"

#import "BaseTelestrationShapeView.h"
#import "Clip.h"
#import "Frame.h"
#import "FrameStackModel.h"
#import "ImageGenerationDispatcher.h"
#import "Media+Extensions.h"
#import "Session.h"
#import "SystemInformation.h"
#import "TelestrationConstants.h"
#import "TelestrationModel.h"
#import "TelestrationPlaybackImageView.h"
#import "VstrationController.h"
#import "VstrationSessionModel.h"
#import "VstratorExtensions.h"
#import "VstratorStrings.h"

#import <AVFoundation/AVFoundation.h>


@interface TelestrationPlayerViewController() <AVAudioPlayerDelegate> {
    BOOL _viewDidAppearOnce;
    BOOL _playbackIsReady;
}

@property (nonatomic, readonly) BOOL autoPlay;
@property (nonatomic, readonly) BOOL saveMode;

@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (nonatomic, strong, readonly) VstrationController *controller;
@property (nonatomic, strong, readonly) NSArray *frames;
@property (nonatomic, strong, readonly) NSArray *shapes;
@property (atomic) BOOL playbackQueueActive;
@property (nonatomic, strong) NSTimer *progressTimer;

@property (nonatomic, weak) IBOutlet UIView *areaView;
@property (nonatomic, weak) IBOutlet TelestrationPlaybackImageView *playbackView;
@property (nonatomic, weak) IBOutlet TelestrationPlaybackImageView *playbackView2;
@property (nonatomic, weak) IBOutlet UIView *shapesView;

@property (weak, nonatomic) IBOutlet UIView *toolsView;
@property (nonatomic, weak) IBOutlet UIImageView *toolbarImageView;
@property (nonatomic, weak) IBOutlet UIImageView *progressSliderImageView;
@property (nonatomic, weak) IBOutlet UISlider *progressSlider;
@property (nonatomic, weak) IBOutlet UIButton *pauseButton;
@property (nonatomic, weak) IBOutlet UIButton *playButton;
@property (nonatomic, weak) IBOutlet UIButton *seekForwardButton;
@property (nonatomic, weak) IBOutlet UIButton *seekBackwardButton;
@property (nonatomic, weak) IBOutlet UIButton *redoButton;
@property (nonatomic, weak) IBOutlet UIButton *saveButton;

@end

#pragma mark -

@implementation TelestrationPlayerViewController

#pragma mark Properties

@synthesize shapes = _shapes;

- (NSArray *)frames
{
    return self.controller.frames.stack;
}

- (NSArray *)shapes
{
    if (_shapes == nil)
        _shapes = ((TelestrationModel *)[self.controller.telestrations copy]).stack;
    return _shapes;
}

- (BOOL)statusBarHidden
{
    return YES;
}

#pragma mark Navigation Staff

- (void)dismissWithCancel
{
    // delay call if activity exists
    if (self.playbackQueueActive || self.audioPlayer.playing) {
        self.view.userInteractionEnabled = NO;
        [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(dismissWithCancel) userInfo:nil repeats:NO];
        return;
    }
    // dismiss
    self.view.userInteractionEnabled = YES;
    [self dismissViewControllerAnimated:NO completion:^{
        if ([self.delegate respondsToSelector:@selector(telestrationPlayerViewControllerDidCancel:)])
            [self.delegate telestrationPlayerViewControllerDidCancel:self];
    }];
}

- (void)dismissWithSave
{
    // delay call if activity exists
    if (self.playbackQueueActive || self.audioPlayer.playing) {
        self.view.userInteractionEnabled = NO;
        [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(dismissWithSave) userInfo:nil repeats:NO];
        return;
    }
    // dismiss
    self.view.userInteractionEnabled = YES;
    [self dismissViewControllerAnimated:NO completion:^{
        if ([self.delegate respondsToSelector:@selector(telestrationPlayerViewControllerDidSave:)])
            [self.delegate telestrationPlayerViewControllerDidSave:self];
    }];
}

#pragma mark Progress

- (void)startProgressTimer
{
    if (self.progressTimer != nil)
        return;
    self.progressTimer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(syncProgress) userInfo:nil repeats:YES];
}

- (void)syncProgress
{
    if (self.progressSlider != nil && self.audioPlayer != nil)
        self.progressSlider.value = (float)(self.audioPlayer.currentTime / self.audioPlayer.duration);
}

- (void)stopProgressTimer
{
    if (self.progressTimer == nil)
        return;
    [self.progressTimer invalidate];
    self.progressTimer = nil;
}

#pragma mark Playback

- (void)playPlayback
{
    if (!_playbackIsReady) return;
    
    // prepare audio & sequence
    NSError *error = nil;
    if (![self prepareAudioSessionAndPlayer:&error]) {
        [UIAlertViewWrapper alertError:error];
        return;
    }
    // progress
    [self startProgressTimer];
    // audio
    self.audioPlayer.delegate = self;
    [self.audioPlayer play];
    // queue
    [self performPlaybackQueue:YES];
    // views
    self.pauseButton.hidden = NO;
    self.playButton.hidden = YES;
}

- (void)seekPlayback:(BOOL)forward
{
    [self pausePlayback];
    // define new time
    NSTimeInterval audioDuration = self.audioPlayer.duration;
    NSTimeInterval frameDuration = [TelestrationConstants frameDurationInSecsForFrameRate:[TelestrationConstants framesPerSecond]];
    NSTimeInterval audioNewTime = self.audioPlayer.currentTime + (forward ? 1 : -1) * frameDuration;
    if (audioNewTime < 1e-3)
        audioNewTime = 0;
    else if (audioNewTime > audioDuration - 1e-3)
        audioNewTime = audioDuration;
    // check if it's worth to mode
    if (fabs(self.audioPlayer.currentTime - audioNewTime) < 1e-3)
        return;
    // shift
    self.audioPlayer.currentTime = audioNewTime;
    [self performPlaybackQueue:NO];
}

- (void)seekPlaybackToFrame:(Frame *)seekFrame
{
    if (seekFrame.frameNumber >= 0) {
        [self.playbackView seekToFrameNumber:seekFrame.frameNumber];
        self.playbackView.currentFrameTransform = seekFrame.frameTransform;
    }
    if (self.controller.model.isSideBySide && seekFrame.frameNumber2 >= 0) {
        [self.playbackView2 seekToFrameNumber:seekFrame.frameNumber2];
        self.playbackView2.currentFrameTransform = seekFrame.frameTransform2;
    }
}

- (void)pausePlayback
{
    // audio
    if (self.audioPlayer != nil) {
        self.audioPlayer.delegate = nil;
        if (self.audioPlayer.playing)
            [self.audioPlayer pause];
    }
    // progress
    [self stopProgressTimer];
    [self syncProgress];
    //[self clearTelestrationShapes];
    // views
    self.pauseButton.hidden = YES;
    self.playButton.hidden = NO;
}

- (void)stopPlayback
{
    // audio
    if (self.audioPlayer != nil) {
        self.audioPlayer.delegate = nil;
        if (self.audioPlayer.playing)
            [self.audioPlayer stop];
        self.audioPlayer.currentTime = 0;
    }
    // progress
    [self stopProgressTimer];
    [self syncProgress];
    // telestrations
    [self clearTelestrationShapes];
    // views
    self.pauseButton.hidden = YES;
    self.playButton.hidden = NO;
}

#pragma mark Shapes

- (void)clearTelestrationShapes
{
    if (self.shapesView == nil)
        return;
    for (UIView *v in self.shapesView.subviews)
        [v removeFromSuperview];
}

- (void)rebuildTelestrationShapes:(NSNumber *)timeNumber
{
    NSTimeInterval time = timeNumber.doubleValue;
    for (BaseTelestrationShapeView *shape in self.shapes) {
        if (shape.startTime >= 0 && shape.startTime <= time && (shape.endTime < shape.startTime || shape.endTime > time)) {
            if (shape.superview == nil) {
                [self.shapesView addSubview:shape];
                [shape scaleByPercentage:1.0 withNavBarHeight:0];
                [shape setNeedsDisplay];
            }
        } else {
            if (shape.superview != nil) {
                [shape removeFromSuperview];
            }
        }
    }
}

#pragma mark Core Logic

- (Frame *)findFrameByTime:(NSTimeInterval)time
{
    if (self.frames.count <= 0)
        return nil;
    // find current frame (assume that frames are sorted by Frame.time)
    Frame *currFrame = (self.frames)[0];
    for (int i = 1; i < self.frames.count; i++) {
        Frame *frame = (self.frames)[i];
        if (time < frame.time - 1e-3)
            break;
        currFrame = frame;
    }
    return currFrame;
}

- (void)performPlaybackQueue:(BOOL)continuousMode
{
    self.playbackQueueActive = YES;
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
    dispatch_async(queue, ^(void) {
        
        // last state
        Frame *prevFrame = nil;
        
        // loop
        do
        {
            NSDate * startDate = NSDate.date;
            NSTimeInterval audioTime = self.audioPlayer.currentTime;
            
            // if we're done, stop playback
            float audioDuration = self.audioPlayer.duration;
            if (audioTime >= audioDuration - 1e-3) {
                if (continuousMode) {
                    [self performSelectorOnMainThread:@selector(stopPlayback) withObject:nil waitUntilDone:NO];
                    break;
                } else {
                    audioTime = audioDuration;
                }
            }
            
            // shown current frame
            Frame *currFrame = [self findFrameByTime:audioTime];
            if (currFrame != nil && (prevFrame == nil ||
                                     prevFrame.frameNumber != currFrame.frameNumber ||
                                     prevFrame.frameNumber2 != currFrame.frameNumber2 ||
                                     ![prevFrame.frameTransform isEqual:currFrame.frameTransform] ||
                                     (currFrame.frameTransform2 != nil &&
                                      ![prevFrame.frameTransform2 isEqual:currFrame.frameTransform2]))) {
                [self performSelectorOnMainThread:@selector(seekPlaybackToFrame:) withObject:currFrame waitUntilDone:YES];
                prevFrame = currFrame;
            }
            
            // rebuild telestrations
            [self performSelectorOnMainThread:@selector(rebuildTelestrationShapes:) withObject:@(audioTime) waitUntilDone:YES];
            
            // sleep
            if (continuousMode) {
                NSTimeInterval frameDuration = [TelestrationConstants frameDurationInSecsForFrameRate:[TelestrationConstants framesPerSecond]];
                Frame *nextFrame = [self findFrameByTime:audioTime + frameDuration];
                NSTimeInterval sleepTimeInterval = (nextFrame == nil ? frameDuration : nextFrame.time - audioTime) - [NSDate.date timeIntervalSinceDate:startDate];
                if (sleepTimeInterval > 0)
                    [NSThread sleepForTimeInterval:sleepTimeInterval];
            }
        } while (continuousMode && self.audioPlayer.playing);
        
        self.playbackQueueActive = NO;
    });
    dispatch_release(queue);
}

#pragma mark Application Events

- (void)applicationWillResignActive:(UIApplication *)application
{
    [self pausePlayback];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // play and stop playback to prevent jumping of the time slider
    // audio player changes current time when play back has started
    // this happens only from resuming the application from the background state
    [self playPlayback];
    [self pausePlayback];
}

#pragma mark Actions

- (IBAction)redoAction:(id)sender
{
    [self pausePlayback];
    [self dismissWithCancel];
}

- (IBAction)saveAction:(id)sender
{
    [self pausePlayback];
    [self dismissWithSave];
}

- (IBAction)playAction:(id)sender
{
    [self playPlayback];
}

- (IBAction)pauseAction:(id)sender
{
    [self pausePlayback];
}

- (IBAction)seekBackwardAction:(id)sender
{
    [self seekPlayback:NO];
}

- (IBAction)seekForwardAction:(id)sender
{
    [self seekPlayback:YES];
}

#pragma mark AVAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [self stopPlayback];
}

//- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
//{
//    [self stopPlayback];
//    [UIAlertViewWrapper alertError:error];
//}

- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player
{
    [self pausePlayback];
}

#pragma mark Setup

- (BOOL)activateAudioSession:(NSError **)error
{
    NSAssert(error != nil, VstratorConstants.AssertionErrorPointerIsNil);
    *error = nil;
    // perform
    NSError *audioError = nil;
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:&audioError];
    if (audioError == nil)
        [audioSession setActive:YES error:&audioError];
    if (audioError)
        *error = [NSError errorWithError:audioError text:VstratorStrings.ErrorAudioSessionInitText];
    return *error == nil;
}

- (void)deactivateAudioSession
{
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setActive:NO error:nil];
}

- (BOOL)prepareAudioSessionAndPlayer:(NSError **)error
{
    NSAssert(error != nil, VstratorConstants.AssertionErrorPointerIsNil);
    *error = nil;
    // session
    NSError *audioError = nil;
    [[AVAudioSession sharedInstance] setActive:YES error:&audioError];
    // player
    if (audioError == nil && ![self.audioPlayer prepareToPlay])
        audioError = [[NSError alloc] init];
    // over
    if (audioError)
        *error = [NSError errorWithError:audioError text:VstratorStrings.ErrorActivatingAudioSessionOrPlayer];
    return *error == nil;
}

- (BOOL)setupAudioWithController:(VstrationController *)controller error:(NSError **)error
{
    NSAssert(error != nil, VstratorConstants.AssertionErrorPointerIsNil);
    *error = nil;
    // perform
    NSError *audioError = nil;
    if ([self activateAudioSession:&audioError]) {
        // audio file name
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *path = paths[0];
        NSString *audioFileName = [NSString stringWithFormat:@"%@/%@", path, controller.model.audioFileName];
        NSLog(@"Audio URL: %@", audioFileName);
        // setup
        self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:audioFileName] error:&audioError];
        if (audioError != nil) {
            [self deactivateAudioSession];
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
    // over
    if (videoError != nil)
        *error = [NSError errorWithError:videoError text:VstratorStrings.ErrorVideoPlayerInitText];
    return *error == nil;
}

- (BOOL)setupWithController:(VstrationController *)controller autoPlay:(BOOL)autoPlay saveMode:(BOOL)saveMode delegate:(id<TelestrationPlayerViewControllerDelegate>)delegate error:(NSError **)error
{
    NSParameterAssert(error);
    *error = nil;
    // ivars
    _delegate = delegate;
    _autoPlay = autoPlay;
    _saveMode = saveMode;
    // setup
    if ([self setupAudioWithController:controller error:error] && [self setupVideoWithController:controller error:error])
        _controller = controller;
    return !*error;
}

#pragma mark Ctor

- (id)initForPlayWithSession:(Session *)session autoPlay:(BOOL)autoPlay delegate:(id<TelestrationPlayerViewControllerDelegate>)delegate error:(NSError **)error
{
    self = [self initWithNibName:NSStringFromClass(self.class) bundle:nil];
    if (self) {
        VstrationSessionModel *model = [[VstrationSessionModel alloc] initWithSession:session];
        VstrationController *controller = [[VstrationController alloc] init];
        if ([controller load:model error:error]) {
            [self setupWithController:controller autoPlay:autoPlay saveMode:NO delegate:delegate error:error];
        } else {
            NSLog(@"Error in initForPlayWithSession: %@", *error);
            *error = [NSError errorWithError:*error text:VstratorStrings.ErrorLoadingSelectedSession];
        }
    }
    return self;
}

- (id)initForSaveWithController:(VstrationController *)controller delegate:(id<TelestrationPlayerViewControllerDelegate>)delegate error:(NSError **)error
{
    self = [self initWithNibName:NSStringFromClass(self.class) bundle:nil];
    if (self) {
        [self setupWithController:controller autoPlay:NO saveMode:YES delegate:delegate error:error];
    }
    return self;
}

#pragma mark Localization

- (void)setLocalizableStrings
{
    [self.redoButton setTitle:VstratorStrings.MediaSessionPlaybackRedoButtonTitle forState:UIControlStateNormal];
    [self.saveButton setTitle:VstratorStrings.MediaSessionPlaybackSaveButtonTitle forState:UIControlStateNormal];
}

#pragma mark View Readiness

- (void)updatePlaybackControlsEnabled:(BOOL)value
{
    self.playButton.enabled = self.pauseButton.enabled = self.progressSlider.enabled = self.saveButton.enabled = value;
}

- (void)waitForReadinessAsync
{
    [[ImageGenerationDispatcher sharedInstance] waitForIdentitiesProcessed:self.controller.model.originalClipsIdentities callback:^(NSError* error) {
        dispatch_async(dispatch_get_main_queue(), ^{ [self imagesProcessedWithError:error]; });
    }];
}

-(void)imagesProcessedWithError:(NSError*)error
{
    if (!error) {
        [self.playbackView loadFramesDirectory:self.controller.model.originalClip.playbackImagesFolder error:&error];
        if (!error && self.controller.model.isSideBySide)
            [self.playbackView2 loadFramesDirectory:self.controller.model.originalClip2.playbackImagesFolder error:&error];
    }
    if (error)
        error = [NSError errorWithError:error text:VstratorStrings.ErrorLoadingSelectedSession];
    [self updatePlaybackControlsEnabled:!error];
    [self hideBGActivityIndicator:error];
    if (!error) {
        _playbackIsReady = YES;
        if (self.autoPlay) {
            [self playAction:self.playButton];
        }
    }
}

#pragma mark View Livecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // localization
    [self setLocalizableStrings];
    // navigation
    self.navigationBarView.hidden = YES;
    // images
    self.toolbarImageView.image = [UIImage resizableImageNamed:@"bg-telestration-bottom"];
    [self.pauseButton setBackgroundImage:[UIImage resizableImageNamed:@"bt-grey-t01-normal"] forState:UIControlStateNormal];
    [self.pauseButton setBackgroundImage:[UIImage resizableImageNamed:@"bt-grey-t01-sel"] forState:UIControlStateHighlighted];
    [self.playButton setBackgroundImage:[UIImage resizableImageNamed:@"bt-grey-t01-normal"] forState:UIControlStateNormal];
    [self.playButton setBackgroundImage:[UIImage resizableImageNamed:@"bt-grey-t01-sel"] forState:UIControlStateHighlighted];
    [self.saveButton setBackgroundImage:[UIImage resizableImageNamed:@"bt-grey-t01-normal"] forState:UIControlStateNormal];
    [self.saveButton setBackgroundImage:[UIImage resizableImageNamed:@"bt-grey-t01-sel"] forState:UIControlStateHighlighted];
    self.progressSliderImageView.image = [UIImage resizableImageNamed:@"bg-telestration-slider"];
    // mode
    if (!self.saveMode) {
        [self.redoButton setTitle:VstratorStrings.NavigationBarBackButtonTitle forState:UIControlStateNormal];
        self.saveButton.hidden = YES;
        CGFloat widthShift = (self.view.bounds.size.width - self.progressSliderImageView.frame.origin.x - 7) - self.progressSliderImageView.frame.size.width;
        self.progressSliderImageView.frame = CGRectMake(self.progressSliderImageView.frame.origin.x, self.progressSliderImageView.frame.origin.y, self.progressSliderImageView.frame.size.width + widthShift, self.progressSliderImageView.frame.size.height);
        self.progressSlider.frame = CGRectMake(self.progressSlider.frame.origin.x, self.progressSlider.frame.origin.y, self.progressSlider.frame.size.width + widthShift, self.progressSlider.frame.size.height);
    }
    if (!self.controller.model.isSideBySide) {
        self.playbackView.frame = self.shapesView.frame;
        self.playbackView2.hidden = YES;
    }
    // slider
    self.progressSlider.minimumValue = 0.0;
    self.progressSlider.maximumValue = 1.0;
    // fix for resolution
    if (VstratorConstants.ScreenOfPlatform5e) {
        self.toolsView.frame = CGRectMake(self.toolsView.frame.origin.x, self.toolsView.frame.origin.y, 86, self.toolsView.frame.size.height);
        self.areaView.frame = CGRectMake(119, 20, self.areaView.frame.size.width, self.areaView.frame.size.height);
    }
    // Show loading page
    [self showBGActivityIndicator:VstratorStrings.MediaClipPlaybackProcessingActivityTitle];

    if ([SystemInformation isSystemVersionLessThan:@"7.0"])
        [self fixUiForIos7];
}

- (void)fixUiForIos7
{
    CGRect frame = self.progressSlider.frame;
    frame.origin.y = 11;
    self.progressSlider.frame = frame;
}

- (void)viewDidAppear:(BOOL)animated
{
    // Super
    [super viewDidAppear:animated];
    // Application Events
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    // Audio Session
    NSError *audioError = nil;
    if (![self activateAudioSession:&audioError]) {
        audioError = [NSError errorWithError:audioError text:VstratorStrings.ErrorAudioPlayerInitText];
        [UIAlertViewWrapper alertError:audioError];
    }
    // Launch following processing only once
    if (_viewDidAppearOnce)
        return;
    _viewDidAppearOnce = YES;

    [self waitForReadinessAsync];
}

- (void)viewWillDisappear:(BOOL)animated
{
    // Video/Audio
    [self pausePlayback];
    [self deactivateAudioSession];
    // Application Events
    [NSNotificationCenter.defaultCenter removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [NSNotificationCenter.defaultCenter removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    // Super
    [super viewWillDisappear:animated];
}

- (void)viewDidUnload
{
    // Release any retained subviews of the main view.
    [[self playbackView] setViewsToNil];
    [[self playbackView] setDelegate:nil];
    [[self playbackView2] setViewsToNil];
    [[self playbackView2] setDelegate:nil];
    [self setPlaybackView:nil];
    [self setPlaybackView2:nil];
    [self setShapesView:nil];
    [self setToolbarImageView:nil];
    [self setProgressSliderImageView:nil];
    [self setProgressSlider:nil];
    [self setRedoButton:nil];
    [self setPauseButton:nil];
    [self setPlayButton:nil];
    [self setSaveButton:nil];
    [self setSeekForwardButton:nil];
    [self setSeekBackwardButton:nil];
    // Super
    [self setAreaView:nil];
    [self setToolsView:nil];
    [super viewDidUnload];
}

//- (void)didReceiveMemoryWarning
//{
//    //TODO: check it
//    [self redoAction:self.redoButton];
//}

#pragma mark Orientation

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

@end
