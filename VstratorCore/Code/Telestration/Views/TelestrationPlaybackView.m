//
//  TelestrationPlaybackView.m
//  VstratorCore
//
//  Created by Admin1 on 26.08.13.
//  Copyright (c) 2013 OnTarget. All rights reserved.
//

#import "ImageGenerationDispatcher.h"
#import "NSError+Extensions.h"
#import "TelestrationPlaybackView.h"
#import "TelestrationPlaybackImageView.h"
#import "TelestrationPlaybackVideoView.h"
#import "UIAlertViewWrapper.h"
#import "VstratorConstants.h"
#import "VstratorStrings.h"

@interface TelestrationPlaybackView()

@property (nonatomic, strong) TelestrationPlaybackImageView *playbackImageView;
@property (nonatomic, strong) TelestrationPlaybackVideoView *playbackVideoView;
@property (nonatomic, weak, readonly) id<TelestrationPlaybackViewProtocol> playbackViewGeneral;
@property (nonatomic, strong) NSURL *playbackUrl;
@property (nonatomic, strong) NSNumber *duration;
@property (nonatomic, strong) NSString *playbackImagesFolder;

@end

@implementation TelestrationPlaybackView {
    BOOL _playbackVideoViewIsActive;
    AVPlayer *_thePlayer;
}

- (id<TelestrationPlaybackViewProtocol>)playbackViewGeneral
{
    if (_playbackVideoViewIsActive)
        return self.playbackVideoView;
    return self.playbackImageView;
}

- (TelestrationPlaybackImageView *)playbackImageView
{
    if (!_playbackImageView) {
        _playbackImageView = [[TelestrationPlaybackImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    }
    return _playbackImageView;
}

- (TelestrationPlaybackVideoView *)playbackVideoView
{
    if (!_playbackVideoView) {
        _playbackVideoView = [[TelestrationPlaybackVideoView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    }
    return _playbackVideoView;
}

#pragma mark TelestrationPlaybackView

- (AVPlayerStatus)playbackStatus
{
    if (!_playbackVideoViewIsActive)
        return AVPlayerStatusReadyToPlay;
    return self.playbackVideoView.playbackStatus;
}

- (BOOL)playbackViewSetupWithDuration:(NSNumber*)duration
                          playbackUrl:(NSURL*)playbackUrl
                 playbackImagesFolder:(NSString*)playbackImagesFolder
                            frameRate:(float)frameRate
                             delegate:(id<TelestrationPlaybackViewDelegate>)delegate
                                error:(NSError **)error
{
    self.duration = duration;
    self.playbackUrl = playbackUrl;
    self.playbackImagesFolder = playbackImagesFolder;
    
    [self reloadPlaybackWithError:error];
    if (*error) {
        *error = [NSError errorWithError:*error text:VstratorStrings.ErrorVideoPlayerInitText];
        return NO;
    }
    
    self.playbackImageView.delegate = delegate;
    self.playbackImageView.FrameRate = frameRate;

    [self.playbackVideoView loadPlayer:_thePlayer duration:duration.doubleValue fileUrl:playbackUrl];
    [self.playbackVideoView seekToStart];
    self.playbackVideoView.delegate = delegate;
    self.playbackVideoView.FrameRate = frameRate;

    [self addSubview:self.playbackImageView];
    [self addSubview:self.playbackVideoView];
    
    [self checkAndShowPlaybackView];
    
    return YES;
}

- (void)setInitZoomForSize:(CGSize)size isSideBySide:(BOOL)isSideBySide
{
    CGFloat factor = isSideBySide ? 0.5 : 1;
    CGSize screenSize = CGSizeMake(VstratorConstants.ScrollViewSizeForLandscape.width * factor, VstratorConstants.ScrollViewSizeForLandscape.height);
    // calculate scale between size and sceenSize
    float scaleWidth = screenSize.width / size.width;
    float scaleHeight = screenSize.height / size.height;
    float scale = fminf(scaleWidth, scaleHeight);
    // calculate zoom for portrait and landscape clips
    float zoom;
    if (size.width < size.height) {
        zoom = screenSize.width / (size.width * scale);
    } else {
        zoom = screenSize.height / (size.height * scale);
    }
    // center frame
    int x = fabsf((screenSize.width - fmaxf(screenSize.width, size.width * scale) * zoom) / 2); // should be 0
    int y = fabsf((screenSize.height - fmaxf(screenSize.height, size.height * scale) * zoom) / 2);
    [self setCurrentFrameZoom:zoom contentOffset:CGPointMake(x, y)];
}

- (BOOL)reloadPlaybackWithError:(NSError **)error
{
    NSAssert(error != nil, VstratorConstants.AssertionErrorPointerIsNil);
    *error = nil;
    _thePlayer = [AVPlayer dequeuePlayerWithURL:self.playbackUrl];
    if (_thePlayer.error != nil) {
        NSLog(@"Error with the player: %@", _thePlayer.error);
        *error = _thePlayer.error;
    }
    return (*error == nil);
}

- (void)savePlayerTime
{
    if (_playbackVideoViewIsActive) {
        [self.playbackVideoView savePlayerTime];
        [self.playbackImageView savePlayerFrameNumber:self.playbackVideoView.currentFrameNumber];
    } else {
        [self.playbackImageView savePlayerFrameNumber:self.playbackImageView.currentFrameNumber];
    }
}

- (void)restorePlayerTime:(void(^)())callback
{
    if (_playbackVideoViewIsActive) {
        [self.playbackVideoView restorePlayerTime:callback];
    } else {
        [self.playbackImageView restorePlayerFrame];
        callback();
    }
}

#pragma mark Internal Methods

- (void)checkAndShowPlaybackView
{
    if (!_playbackVideoViewIsActive) return;
    if ([ImageGenerationDispatcher checkIdentityProcessedInFolder:self.playbackImagesFolder]) {
        NSError *error;
        if (![self.playbackImageView loadFramesDirectory:self.playbackImagesFolder error:&error]) {
            [UIAlertViewWrapper alertError:error];
            return;
        }
        [self.playbackImageView seekToFrameNumber:self.playbackVideoView.currentFrameNumber];
        [self.playbackImageView setCurrentFrameTransform:self.playbackVideoView.currentFrameTransform animated:NO];
        [self.playbackVideoView removeFromSuperview];
        _playbackVideoViewIsActive = NO;
    }
}

- (void)setup
{
    _playbackVideoViewIsActive = YES;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

#pragma mark TelestrationPlaybackViewProtocol

- (void)setDelegate:(id<TelestrationPlaybackViewDelegate>)delegate
{
    _delegate = self.playbackImageView.delegate = self.playbackVideoView.delegate = delegate;
}

- (BOOL)eof
{
    return self.playbackViewGeneral.eof;
}

- (BOOL)playing
{
    return self.playbackViewGeneral.playing;
}

- (NSInteger)currentFrameNumber
{
    return self.playbackViewGeneral.currentFrameNumber;
}

- (FrameTransform *)currentFrameTransform
{
    return self.playbackViewGeneral.currentFrameTransform;
}

- (void)setPauseButton:(UIButton *)pauseButton
{
    _pauseButton = self.playbackImageView.pauseButton = self.playbackVideoView.pauseButton = pauseButton;
}

- (void)setPlayButton:(UIButton *)playButton
{
    _playButton = self.playbackImageView.playButton = self.playbackVideoView.playButton = playButton;
}

- (void)setSeekForwardButton:(UIButton *)seekForwardButton
{
    _seekForwardButton = self.playbackImageView.seekForwardButton = self.playbackVideoView.seekForwardButton = seekForwardButton;
}

- (void)setSeekBackwardButton:(UIButton *)seekBackwardButton
{
    _seekBackwardButton = self.playbackImageView.seekBackwardButton = self.playbackVideoView.seekBackwardButton = seekBackwardButton;
}

- (void)setTimelineSlider:(UISlider *)timelineSlider
{
    _timelineSlider = self.playbackImageView.timelineSlider = self.playbackVideoView.timelineSlider = timelineSlider;
}

- (void)pause
{
    [self.playbackViewGeneral pause];
    [self checkAndShowPlaybackView];
}

- (void)play
{
    if (!self.playbackViewGeneral.playing)
        [self.playbackViewGeneral play];
}

- (void)seekToNextFrame
{
    [self.playbackViewGeneral seekToNextFrame];
    [self checkAndShowPlaybackView];
}

- (void)seekToPrevFrame
{
    [self.playbackViewGeneral seekToPrevFrame];
    [self checkAndShowPlaybackView];
}

- (void)seekToPrevFrameContinuously
{
    [self.playbackViewGeneral seekToPrevFrameContinuously];
}

- (void)seekToNextFrameContinuously
{
    [self.playbackViewGeneral seekToNextFrameContinuously];
}

- (void)seekToSliderPosition:(BOOL)isLastPosition
{
    [self.playbackViewGeneral seekToSliderPosition:isLastPosition];
    [self checkAndShowPlaybackView];
}

- (void)seekToStart
{
    [self.playbackViewGeneral seekToStart];
    [self checkAndShowPlaybackView];
}

- (void)flipCurrentFrame
{
    [self.playbackViewGeneral flipCurrentFrame];
}

- (void)setViewsToNil
{
    [self.playbackImageView setViewsToNil];
    [self.playbackVideoView setViewsToNil];
    self.playbackImageView = nil;
    self.playbackVideoView = nil;
}

- (void)setCurrentFrameZoom:(float)zoom contentOffset:(CGPoint)offset
{
    [self.playbackViewGeneral setCurrentFrameZoom:zoom contentOffset:offset];
}

@end
