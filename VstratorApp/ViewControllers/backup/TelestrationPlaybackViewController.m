//
//  TelestrationPlaybackViewController.m
//  VstratorApp
//
//  Created by user on 12.03.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "TelestrationPlaybackViewController.h"

#import "FrameStackModel.h"
#import "PlayerView.h"
#import "TelestrationModel.h"
#import "TelestrationRecordingController.h"
#import "BaseTelestrationShapeView.h"
#import "VstrationController.h"
#import "VstrationMediaModel.h"
#import "VstratorExtensions.h"

@interface TelestrationPlaybackViewController()
{
    AVAudioPlayer *theAudio;
    BaseTelestrationShapeView *theNextTelestration;
    Frame *theNextFrame;
    float theWidthScale;
    float theHeightScale;
}

@property (nonatomic, readonly) BOOL saveMode;
@property (nonatomic, strong) IBOutlet UIView *messageView;
@property (nonatomic, strong) IBOutlet UIProgressView *progressBar;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *redoButton;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *saveButton;

- (IBAction)playStopAction:(id)sender;
- (IBAction)saveAction:(id)sender;
- (IBAction)redoAction:(id)sender;

- (void)stopVideo;
- (void)syncProgress:(id)sender;
- (void)resetTelestrations;
- (void)clearTelestrations;
- (void)displayTelestration:(BaseTelestrationShapeView *)telestration;
- (void)updateVStrations;

@end

@implementation TelestrationPlaybackViewController

#pragma mark - Properties

@synthesize delegate = _delegate;
@synthesize messageView = _messageView;
@synthesize progressBar = _progressBar;
@synthesize redoButton = _redoButton;
@synthesize saveButton = _saveButton;
@synthesize saveMode = _saveMode;

#pragma mark - Navigation Staff

- (void)dismissWithFinish:(ContentAction)action
{
    if (self.saveMode && action == ContentActionSave) {
        //NOTE: do not animate here, as navigation transition with animation is expected in the delegate call
        [self.navigationController popViewControllerAnimated:NO];
    } else {
        [self.navigationController popViewControllerAnimated:NO]; //VstratorConstants.ViewControllersNavigationPopAnimated];
    }
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(contentActionDidFinish:withContentAction:)]) {
        [self.delegate contentActionDidFinish:self withContentAction:action];
    }
}

#pragma mark - Subclassing

- (float)playerCurrentTime
{
    return [theAudio currentTime];
}

- (void)playVideo
{
    //[self.playPauseButton setBackgroundImage:[UIImage imageNamed:@"stop.png"] forState:UIControlStateNormal];
    //[self setupScrubber];
    [theAudio play];
    [self updateVStrations];
}

- (void)pauseVideo
{
    if (theAudio.isPlaying) {
        [theAudio pause];
    }
}

- (BOOL)isPaused
{
    return !theAudio.playing;
}

- (void)seekToTime
{
    [self pauseVideo];
    theAudio.currentTime = self.scrubSlider.value;
}

- (void)seek:(BOOL)forward
{
    [self pauseVideo];
    theAudio.currentTime = theAudio.currentTime + (forward ? FRAME_FLOAT : -FRAME_FLOAT);
}

- (void)seekToTime:(NSNumber *)seekTime
{
    [self.player seekToTime:[self playerNewTimeValue:seekTime.floatValue] toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
}

- (void)setupScrubber
{
    if ((theScrubberTimer == nil || !theScrubberTimer.isValid) && theAudio.isPlaying) {
        theScrubberTimer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(syncProgress:) userInfo:nil repeats:YES];
    }
}

#pragma mark - Actions

- (IBAction)playStopAction:(id)sender
{
    if([self isPaused])  {
        [self playVideo];
    } else {
        [self stopVideo];
    }
}

- (void)backAction:(id)sender
{
    [self dismissWithFinish:ContentActionCancel];
}

- (void)redoAction:(id)sender
{
    [self stopVideo];
    [self dismissWithFinish:self.saveMode ? ContentActionRedo : ContentActionCancel];
}

- (void)saveAction:(id)sender
{
    [self stopVideo];
    [self dismissWithFinish:ContentActionSave];
}

#pragma mark - Business Logic

- (void)stopVideo
{
    [theAudio stop];
    theAudio.currentTime = 0;
    [self stopScrubber];
    [self clearTelestrations];
    [self resetTelestrations];
    self.progressBar.progress = 0;
    [self.player pause];
    [self.player seekToTime:kCMTimeZero];
    //[self.playPauseButton setBackgroundImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
}

- (void)syncProgress:(id)sender
{
    self.progressBar.progress = (float)(theAudio.currentTime / theAudio.duration);
}

- (void)clearTelestrations
{
    for (UIView *v in [self.telestrationView subviews]) {
        [v removeFromSuperview];
    }
}

- (void)resetTelestrations 
{
    self.controller.telestrations.index = 0;
    self.controller.frames.index = 0;
    theNextTelestration = [self.controller.telestrations nextObject];
    theNextFrame = [self.controller.frames nextObject];
}

- (void)displayTelestration:(BaseTelestrationShapeView *)telestration
{
    BaseTelestrationShapeView *temp = [telestration copy];
    [self.telestrationView addSubview:temp];
    [temp scaleByPercentage:theHeightScale withNavBarHeight:0]; //self.navigationController.navigationBar.frame.size.height];
    [temp setNeedsDisplay];
    theNextTelestration = [self.controller.telestrations nextObject];
}

- (void)updateVStrations
{
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    dispatch_async(queue, ^(void) {
        do
        {
            float now = ROUND(theAudio.currentTime);             
            //Update what happens next.
            float frameTime = ceilf(theNextFrame.time * 100)/100;
            float duration = ROUND(theAudio.duration);
            if (now >= duration) {
                [self performSelectorOnMainThread:@selector(stopVideo) withObject:nil waitUntilDone:NO];
                break;
            }
            float telestrationtime = ROUND(theNextTelestration.startTime);
            if (now >= frameTime + 0.1f &&  theNextFrame != nil) {
                float seekTime = FRAME_FLOAT * theNextFrame.frameNumber;
                [self performSelectorOnMainThread:@selector(seekToTime:) withObject:[NSNumber numberWithFloat:seekTime] waitUntilDone:YES];
                theNextFrame = [self.controller.frames nextObject];
            }
            if (now >= telestrationtime + 0.1f && theNextTelestration != nil) {
                NSLog(@"Displaying a telestration");
                NSLog(@"End time: %f", theNextTelestration.endTime);
                [self performSelectorOnMainThread:@selector(displayTelestration:) withObject:theNextTelestration waitUntilDone:YES];               
            }
            
            //Clean up expired telestrations.
            for (BaseTelestrationShapeView *t in [self.telestrationView subviews]) {
                if (ROUND(t.endTime) <= now && t.endTime != -1) {
                    NSLog(@"Removing a telestration");
                    [t performSelectorOnMainThread:@selector(removeFromSuperview) withObject:nil waitUntilDone:YES];
                }
            }
            if (!theScrubberTimer || !theScrubberTimer.isValid) {
                [self performSelectorOnMainThread:@selector(setupScrubber) withObject:nil waitUntilDone:YES];
            }
        } while (!self.isPaused);
        
        NSLog(@"Bailing of the block.");
        //dispatch_release(queue);
        return;
    });
}

- (void)unhideViews {
    [self.messageView removeFromSuperview];
    for (UIView *v in [self.view subviews]) {
        [v setHidden:NO];
    }
    self.playbackView.layer.hidden = NO;
}

#pragma mark - AVAudioSessionDelegate

/* something has caused your audio session to be interrupted */
- (void)beginInterruption
{
    NSLog(@"Audio session interrupted");
    [self stopVideo];
}

/* the interruption is over */
/* Currently the only flag is AVAudioSessionInterruptionFlags_ShouldResume. */
- (void)endInterruptionWithFlags:(NSUInteger)flags
{
    NSLog(@"Audio session interruption ended");
}

/* notification for input become available or unavailable */
- (void)inputIsAvailableChanged:(BOOL)isInputAvailable
{
    NSLog(@"inputIsAvailableChanged");
}

#pragma mark - AVAudioPlayerDelegate

/* audioPlayerDidFinishPlaying:successfully: is called when a sound has finished playing. This method is NOT called if the player is stopped due to an interruption. */
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    NSLog(@"Stopped playing");
    [self stopVideo];
}

/* if an error occurs while decoding it will be reported to the delegate. */
- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
{
    NSLog(@"audioPlayerDecodeErrorDidOccur: %@", error);
    [self stopVideo];
}

/* audioPlayerBeginInterruption: is called when the audio session has been interrupted while the player was playing. The player will have been paused. */
- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player
{
    [self stopVideo];
}


///* audioPlayerEndInterruption:withFlags: is called when the audio session interruption has ended and this player had been interrupted while playing. */
///* Currently the only flag is AVAudioSessionInterruptionFlags_ShouldResume. */
//- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player withFlags:(NSUInteger)flags
//{
//    
//}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    //Set up scaling.
    //    for (AVAssetTrack *track in [self.player.currentItem tracks]) {
    //        NSLog(@"Track natural size: %@", NSStringFromCGSize(track.naturalSize));
    //    }
    //    NSLog(@"Preferred Frame size: %@", NSStringFromCGSize([self.player.currentItem presentationSize]));
    //    for (CALayer *sublayer in [self.playbackView.layer sublayers]) {
    //        NSLog(@"SubLayer: %@", NSStringFromCGRect(sublayer.frame));
    //    }
    
    NSLog(@"TPVC size: %f, %f", self.telestrationView.frame.size.width, self.telestrationView.frame.size.height);
    theHeightScale = self.telestrationView.frame.size.height/256.0f;
    //Scaling down the view
    //    [self.telestrationView setFrame:CGRectMake(self.telestrationView.frame.origin.x, self.telestrationView.frame.origin.y, heightScale * self.telestrationView.frame.size.width, self.telestrationView.frame.size.height)];
    NSLog(@"Scale factor set to: %f", theHeightScale);
}

#pragma mark - Application Events

- (void)applicationWillResignActiveAction
{
    [self stopVideo];
    [super applicationWillResignActiveAction];
}

#pragma mark - Ctor

- (NSError *)configureAudioSession
{
    NSError *error = nil;
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    audioSession.delegate = self;
    [audioSession setCategory:AVAudioSessionCategorySoloAmbient error:&error];
    if (error == nil) {
        [audioSession setActive:YES error:&error];
    }
    return error;
}

- (void)setupWithDelegate:(id<ContentActionDelegate>)delegate saveMode:(BOOL)saveMode error:(NSError **)error
{
    NSAssert(error != nil, VstratorConstants.ErrorErrorPointerIsNilOrInvalidText);
    *error = nil;
    // ivars
    _delegate = delegate;
    _saveMode = saveMode;
    // audio
    NSLog(@"Video URL: %@", self.controller.videoURL);
    NSError *tempError = [self configureAudioSession];
    if (tempError == nil) {
        NSLog(@"Audio URL: %@", self.sessionAudioFileName);
        theAudio = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:self.sessionAudioFileName] error:&tempError];
        theAudio.delegate = self;
        if (tempError == nil) {
            if (![theAudio prepareToPlay]) {
                tempError = [[NSError alloc] init];
            }
        }
    }
    if (tempError) {
        *error = [NSError errorWithError:tempError text:@"Error initializing audio player"];
        return;
    }
    // video
    if (![self initializePlayer:&tempError]) {
        *error = [NSError errorWithError:tempError text:@"Error initializing video player"];
    }
    // clear data
    [self clearTelestrations];
    [self resetTelestrations];
}

- (id)initForPlayWithSession:(Session *)session delegate:(id<ContentActionDelegate>)delegate error:(NSError **)error
{
    self = [super initWithNibName:NSStringFromClass(self.class) bundle:nil];
    if(self) {
        VstrationMediaModel *media = [[VstrationMediaModel alloc] initWithSession:session];
        if ([self.controller load:media error:error]) {
            [self setupWithDelegate:delegate saveMode:NO error:error];
        } else {
            *error = [NSError errorWithError:*error text:@"Error loading selected session"];
        }
    }
    return self;
}

- (id)initForSaveWithVstrationController:(VstrationController *)vstrationController delegate:(id<ContentActionDelegate>)delegate error:(NSError **)error
{
    self = [super initWithNibName:NSStringFromClass(self.class) bundle:nil];
    if (self) {
        self.controller = vstrationController;
        [self setupWithDelegate:delegate saveMode:YES error:error];
    }
    return self;
}

#pragma mark - View Livecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // player
    self.navigationBarView.hidden = YES;
    [self.playbackView setPlayer:self.player];
    // mode
    if (!self.saveMode) {
        [self.redoButton setTitle:@"Back" forState:UIControlStateNormal];
        self.saveButton.hidden = YES;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    if (self.showAndHideBlankViewExecuting)
        return;
    // Super
    [super viewWillAppear:animated];
    // Audio
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    // KVO
    [self addObserver:self forKeyPath:@"view.frame" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial) context:NULL];
    // Status Bar
    UIApplication.sharedApplication.statusBarHidden = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    if (self.showAndHideBlankViewExecuting)
        return;
    [super viewDidAppear:animated];
    [self showAndHideBlankView];
}

- (void)viewWillDisappear:(BOOL)animated
{
    if (self.showAndHideBlankViewExecuting)
        return;
    // Status Bar
    UIApplication.sharedApplication.statusBarHidden = NO;
    // KVO
    [self removeObserver:self forKeyPath:@"view.frame"];
    // Video/Audio
    [self stopVideo];
    [[AVAudioSession sharedInstance] setActive:NO error:nil];
    // Super
    [super viewWillDisappear:animated];
}

- (void)viewDidUnload
{
    // Release any retained subviews of the main view.
    [self setProgressBar:nil];
    [self setMessageView:nil];
    [self setRedoButton:nil];
    [self setSaveButton:nil];
    // super
    [super viewDidUnload];
}

@end
