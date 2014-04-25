//
//  TelestrationBaseViewController.m
//  VstratorApp
//
//  Created by user on 12.03.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "TelestrationBaseViewController.h"
#import "VstratorExtensions.h"

#import "BaseTelestrationShapeView.h"
#import "CircleTelestrationShapeView.h"
#import "FreehandTelestrationShapeView.h"
#import "LineTelestrationShapeView.h"
#import "PlayerView.h"
#import "SquareTelestrationShapeView.h"
#import "TelestrationRecordingController.h"
#import "VstrationController.h"
#import "VstrationMediaModel.h"
#import "VstratorExtensions.h"

@implementation TelestrationBaseViewController

#pragma mark - Properties

@synthesize playbackView = _playbackView;
@synthesize player = _player;
@synthesize scrubSlider = _scrubSlider;
@synthesize telestrationView = _telestrationView;
@synthesize seekForwardButton = _seekForwardButton;
@synthesize seekBackwardsButton = _seekBackwardsButton;
@synthesize playPauseButton = _playPauseButton;
@synthesize controller = _controller;

- (NSString *)sessionAudioFileName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    return [NSString stringWithFormat:@"%@/%@", path, self.controller.media.audioFileName];
}

#pragma mark - Playback Logic

- (float)playerCurrentTime
{
    return CMTimeGetSeconds(self.player.currentTime);
}

- (CMTime)playerNewTimeValue:(float)time
{
    CMTime ti = CMTimeMake(time*TIME_SCALE, TIME_SCALE);
    return ti;
}

- (int)playerFrameNumber
{
    return self.playerCurrentTime / FRAME_FLOAT;
}

- (IBAction)sliderChanged:(id)sender 
{
    [self seekToTime];
}

- (void)playVideo 
{
    //[self.playPauseButton setBackgroundImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
    [self setupScrubber];
    [self.player play];
}

- (void)pauseVideoInt
{
    if (self.player) {
        [self.player pause];
    }
    [self stopScrubber];
}

- (void)pauseVideo
{
    // button
    //UIImage *image = [UIImage imageNamed:@"play.png"];
    //[self.playPauseButton setBackgroundImage:image forState:UIControlStateNormal];
    // actions
    [self pauseVideoInt];
}

- (BOOL)isPaused
{
    return self.player.rate == 0.0f;
}

- (IBAction)playPause:(id)sender
{
    if (self.isPaused) {
        [self playVideo];
    } else {
        [self pauseVideo];
    }
}

- (void)seekToTime 
{
    [self pauseVideo];
    [self.player seekToTime:[self playerNewTimeValue:self.scrubSlider.value] toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
}

- (void)seek:(BOOL)forward
{
    [self pauseVideo];
    if (forward) {
        [self.player seekToTime:CMTimeAdd(self.player.currentTime, theFrame) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    } else {
        [self.player seekToTime:CMTimeSubtract(self.player.currentTime, theFrame) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    }
    NSLog(@"New Time: %f", self.playerCurrentTime);
}

- (IBAction)seekBackwards:(id)sender
{
    [self seek:NO];
}

- (IBAction)seekForwards:(id)sender
{
    [self seek:YES];
}

- (void)setupScrubber
{
    self.scrubSlider.minimumValue = 0.0f;
    self.scrubSlider.maximumValue = self.controller.media.duration.floatValue;
    
	__block TelestrationBaseViewController* blockSelf = self;
    theScrubberTimer = [self.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(.1f, NSEC_PER_SEC) queue:NULL usingBlock:^(CMTime time) {
        [blockSelf syncScrubber];
    }];
}

- (void)syncScrubber
{
    float secs = self.playerCurrentTime;
    self.scrubSlider.value = secs;
    if (secs >= self.scrubSlider.maximumValue) {
        [self pauseVideo];
        [self.player seekToTime:kCMTimeZero];
    }
}

- (void)stopScrubber
{
    if (theScrubberTimer != nil) {
        NSLog(@"Invalidating scrubber timer.");
        [theScrubberTimer invalidate];
        theScrubberTimer = nil;
    }
}

#pragma mark - Video/Audio Data

- (BOOL)initializePlayer:(NSError **)error
{
    NSAssert(error != nil, VstratorConstants.ErrorErrorPointerIsNilOrInvalidText);
    *error = nil;
    // perform
    self.player = [AVPlayer playerWithURL:self.controller.videoURL];
    if (self.player.error == nil) {
        [self muteAudio];
        return YES;
    }
    // failure
    NSLog(@"Error with the player: %@", self.player.error);
    *error = self.player.error;
    return NO;
}

- (void)muteAudio
{
    AVAsset *asset = [[self.player currentItem] asset];
    NSArray *audioTracks = [asset tracksWithMediaType:AVMediaTypeAudio];
    
    // Mute all the audio tracks
    NSMutableArray *allAudioParams = [NSMutableArray array];
    for (AVAssetTrack *track in audioTracks) {
        AVMutableAudioMixInputParameters *audioInputParams = AVMutableAudioMixInputParameters.audioMixInputParameters;
        [audioInputParams setVolume:0.0 atTime:kCMTimeZero];
        [audioInputParams setTrackID:[track trackID]];
        [allAudioParams addObject:audioInputParams];
    }
    AVMutableAudioMix *audioZeroMix = [AVMutableAudioMix audioMix];
    [audioZeroMix setInputParameters:allAudioParams];
    
    [[self.player currentItem] setAudioMix:audioZeroMix];
}

#pragma mark - TrashAlertDelegate replacement

- (void)trashData
{
	self.controller.media.telestrationData = nil;
    
    NSError *error = nil;
    NSString *audioFileName = self.sessionAudioFileName;
    if ([NSFileManager.defaultManager fileExistsAtPath:audioFileName]) {
        [NSFileManager.defaultManager removeItemAtPath:audioFileName error:&error];
    }
	if (error) {
		NSLog(@"Error deleting audio file: %@", error);
    }
}

#pragma mark - Application Events

- (void)applicationWillResignActiveAction
{
    // intentionally left blank
}

- (void)applicationDidEnterBackgroundAction
{
    // intentionally left blank
}

#pragma mark - Ctor

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        theFrame = CMTimeMake(FRAME_SKIP, TIME_SCALE);
        theScrubberTimer = nil;
        self.controller = [[VstrationController alloc] init];
        // Application Events
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActiveAction) name:UIApplicationWillResignActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackgroundAction) name:UIApplicationDidEnterBackgroundNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    // Application Events
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    // Video
    [self pauseVideoInt];
}

#pragma mark - View lifecycle

- (void)viewDidUnload
{
    // Release any retained subviews of the main view.
    // player
    [self pauseVideoInt];
	// outlets
    [self.playbackView setPlayer:nil];
    [self setPlaybackView:nil];
    [self setSeekForwardButton:nil];
    [self setSeekBackwardsButton:nil];
    [self setPlayPauseButton:nil];
    [self setScrubSlider:nil];
    [self setTelestrationView:nil];
    // Super
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

@end
