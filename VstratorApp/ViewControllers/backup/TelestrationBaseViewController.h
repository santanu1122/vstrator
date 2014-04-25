//
//  TelestrationBaseViewController.h
//  VstratorApp
//
//  Created by user on 12.03.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVAsset.h>
#import <AVFoundation/AVPlayer.h>
#import <AVFoundation/AVPlayerLayer.h>
#import "BaseViewController.h"


#define FRAME_SKIP  33333333
#define TIME_SCALE  1000000000
#define FRAME_FLOAT .0333333
#define ROUND(x)    floorf(x * 100)/100


@class PlayerView, VstrationController;


@interface TelestrationBaseViewController : BaseViewController
{
@protected
    CMTime theFrame;
    NSTimer *theScrubberTimer;
}

@property (nonatomic, strong) IBOutlet UISlider *scrubSlider;
@property (nonatomic, strong) IBOutlet UIView *telestrationView;
@property (nonatomic, strong) IBOutlet UIButton *seekForwardButton;
@property (nonatomic, strong) IBOutlet UIButton *playPauseButton;
@property (nonatomic, strong) IBOutlet UIButton *seekBackwardsButton;
@property (nonatomic, strong) IBOutlet PlayerView *playbackView;
@property (nonatomic, strong) AVPlayer *player;
@property (strong) VstrationController *controller;

@property (nonatomic, strong, readonly) NSString *sessionAudioFileName;

- (IBAction)seekForwards:(id)sender;
- (IBAction)seekBackwards:(id)sender;
- (IBAction)sliderChanged:(id)sender;
- (IBAction)playPause:(id)sender;

- (float)playerCurrentTime;
- (CMTime)playerNewTimeValue:(float)time;
- (int)playerFrameNumber;

- (void)playVideo;
- (void)pauseVideo;
- (BOOL)isPaused;
- (void)seekToTime;
- (void)seek:(BOOL)forward;
- (void)setupScrubber;
- (void)syncScrubber;
- (void)stopScrubber;

- (BOOL)initializePlayer:(NSError **)error;
- (void)muteAudio;

- (void)trashData;

- (void)applicationWillResignActiveAction;
- (void)applicationDidEnterBackgroundAction;

@end

