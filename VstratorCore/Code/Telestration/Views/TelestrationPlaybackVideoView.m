//
//  TelestrationPlaybackVideoView.m
//  VstratorApp
//
//  Created by Mac on 23.05.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "AVPlayer+Extensions.h"
#import "MemoryProfiling.h"
#import "TelestrationConstants.h"
#import "TelestrationPlaybackBaseView+Subclassing.h"
#import "TelestrationPlaybackVideoView.h"
#import "TelestrationScrollableVideoView.h"
#import "VstratorExtensions.h"

typedef void(^RestoreCallback)();

@interface TelestrationPlaybackVideoView() {
    dispatch_queue_t _imageQueue;
    UIImageOrientation _imageOrientation;
    CMTime _currentPlayerTime;
    BOOL _dontShowImage;
    RestoreCallback _restoreCallback;
    BOOL _processPlayerStatusChanged;
}

@property (nonatomic, strong) TelestrationScrollableVideoView *scrollableView;

@property (nonatomic, readonly) NSTimeInterval currentTimeInSecs;
@property (nonatomic, readonly) NSTimeInterval duration;
@property (nonatomic, strong) NSTimer *timelineTimer;
@property (nonatomic, strong) NSURL *fileUrl;
@property (nonatomic) CMTime actualTime;
@property (atomic) NSTimeInterval currentTime;
@property (nonatomic, strong, readonly) AVAsset *asset;
@property (nonatomic, strong, readonly) AVAssetImageGenerator *imageGenerator;
@property (nonatomic, strong, readonly) AVAssetTrack *videoTrack;

@end

#pragma mark -

@implementation TelestrationPlaybackVideoView

@synthesize asset = _asset;
@synthesize imageGenerator = _imageGenerator;

#pragma mark Properties

- (TelestrationScrollableVideoView *)scrollableView
{
    if (!_scrollableView) {
        _scrollableView = [[TelestrationScrollableVideoView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        _scrollableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return _scrollableView;
}

- (NSTimeInterval)currentTimeInSecs
{
    return CMTimeGetSeconds(self.scrollableView.player.currentTime);
}

- (AVAsset *)asset
{
    if (!_asset) {
        _asset = [AVAsset assetWithURL:self.fileUrl];
    }
    return _asset;
}

- (AVAssetImageGenerator *)imageGenerator
{
    if (!_imageGenerator) {
        _imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:self.asset];
        _imageGenerator.requestedTimeToleranceAfter = kCMTimeZero;
        _imageGenerator.requestedTimeToleranceBefore = kCMTimeZero;
    }
    return _imageGenerator;
}

- (AVAssetTrack *)videoTrack
{
    NSArray *videoTracks = [self.asset tracksWithMediaType:AVMediaTypeVideo];
    if (videoTracks.count == 0) return nil;
    return [videoTracks objectAtIndex:0];
}

#pragma mark TelestrationPlaybackViewProtocol

- (BOOL)eof
{
    return self.currentTimeInSecs >= self.duration - 0.1f;
}

- (BOOL)playing
{
    return (self.scrollableView.player != nil && self.scrollableView.player.rate != 0);
}

- (NSInteger)currentFrameNumber
{
    double actualTimeInSeconds = CMTimeGetSeconds(self.actualTime);
    if (actualTimeInSeconds == 0)
        return [TelestrationConstants frameNumberByTime:self.currentTimeInSecs forFrameRate:self.FrameRate];
    else
        return [TelestrationConstants frameNumberByTime:actualTimeInSeconds forFrameRate:self.FrameRate];
}

- (void)pause
{
    [self pauseInt];
    [self showImageForTime:self.timelineSlider.value callback:nil];
    [self callDelegateDidChange];
}

- (void)play
{
    if (self.playing) return;
    if (self.eof) [self seekToStart];
    [self startTimelineTimer];
    [self.scrollableView.player play];
    [self checkPauseAndPlayButtonsHiddenState];
    [self resetImageView];
    [self callDelegateDidChange];
}

- (void)seekToPrevFrame
{
    [self seek:NO];
}

- (void)seekToNextFrame
{
    [self seek:YES];
}

- (void)seekToPrevFrameContinuously
{
    [self seekContinuously:NO];
}

- (void)seekToNextFrameContinuously
{
    [self seekContinuously:YES];
}

- (void)seekContinuously:(BOOL)forward
{
    [self startTimelineTimer];
    self.scrollableView.player.rate = forward ? 1.0 : -1.0;
    [self resetImageView];
}

- (void)seekToSliderPosition:(BOOL)isLastPosition
{
    [self seekToTime:self.timelineSlider.value isLastPosition:isLastPosition];
}

- (void)flipCurrentFrame
{
    [self.scrollableView appendViewTransform:CGAffineTransformMakeScale(-1, 1)];
}

- (void)setViewsToNil
{
    self.pauseButton = nil;
    self.playButton = nil;
    self.seekBackwardButton = nil;
    self.seekForwardButton = nil;
    self.timelineSlider = nil;
    [self.scrollableView.player removeObserver:self forKeyPath:@"status"];
    self.scrollableView.player = nil;
    self.scrollableView = nil;
}

#pragma mark Utils

- (void)resetImageView
{
    self.scrollableView.image = nil;
    self.actualTime = CMTimeMake(0, NSEC_PER_SEC);
}

- (void)checkPauseAndPlayButtonsHiddenState
{
    self.pauseButton.hidden = !self.playing;
    self.playButton.hidden = self.playing;
}

- (void)pauseInt
{
    if (self.playing)
        [self.scrollableView.player pause];
    [self stopTimelineTimer];
    [self checkPauseAndPlayButtonsHiddenState];
}

- (void)seekToTime:(NSTimeInterval)time isLastPosition:(BOOL)isLastPosition
{
    [self pauseInt];
    [self.scrollableView.player seekToTime:CMTimeMake(time * NSEC_PER_SEC, NSEC_PER_SEC)
                           toleranceBefore:kCMTimeZero
                            toleranceAfter:kCMTimeZero];
    [self afterSeekToTime:time isLastPosition:isLastPosition callback:nil];
}

- (void)seekToTime:(NSTimeInterval)time isLastPosition:(BOOL)isLastPosition callback:(void(^)())callback
{
    [self pauseInt];
    [self.scrollableView.player seekToTime:CMTimeMake(time * NSEC_PER_SEC, NSEC_PER_SEC)
                           toleranceBefore:kCMTimeZero
                            toleranceAfter:kCMTimeZero
                         completionHandler:^(BOOL finished) {
                             [self afterSeekToTime:time isLastPosition:isLastPosition callback:callback];
                         }];
}

- (void)afterSeekToTime:(NSTimeInterval)time isLastPosition:(BOOL)isLastPosition callback:(void(^)())callback
{
    [self syncTimelineSlider];
    if (isLastPosition) {
        [self showImageForTime:time callback:callback];
    } else {
        self.scrollableView.image = nil;
    }
}

- (void)seek:(BOOL)forward
{
    [self pauseInt];
    CMTime newTime = forward ? CMTimeAdd(self.scrollableView.player.currentTime, [TelestrationConstants frameDurationForFrameRate:self.FrameRate]) : CMTimeSubtract(self.scrollableView.player.currentTime, [TelestrationConstants frameDurationForFrameRate:self.FrameRate]);
    [self.scrollableView.player seekToTime:newTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    [self syncTimelineSlider];
    [self showImageForTime:CMTimeGetSeconds(newTime) callback:nil];
}

- (void)showImageForTime:(NSTimeInterval)time callback:(void(^)())callback
{
    if (_dontShowImage) return;
    self.currentTime = time;
    dispatch_async(_imageQueue, ^{
        if (self.currentTime != time) return;
        NSError *error;
        CMTime askedPoint = self.scrollableView.player.currentTime;
        CMTime actualTime;
        
        CGImageRef cgImage = [self.imageGenerator copyCGImageAtTime:askedPoint actualTime:&actualTime error:&error];
        UIImage *image = [UIImage imageWithCGImage:cgImage scale:1.0 orientation:_imageOrientation];
        CGImageRelease(cgImage);
        
//        logMemUsage();
        
        if (!image) return;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.playing) return;
            self.scrollableView.image = image;
            self.actualTime = actualTime;
            if (callback) callback();
        });
    });
}

#pragma mark - Timeline

- (void)startTimelineTimer
{
    NSAssert(self.timelineSlider != nil, VstratorConstants.AssertionArgumentIsNilOrInvalid);
    [self syncTimelineSliderLimits];
	__block __unsafe_unretained TelestrationPlaybackVideoView *blockSelf = self;
    self.timelineTimer = [self.scrollableView.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(.1f, NSEC_PER_SEC) queue:NULL usingBlock:^(CMTime time) {
        if ([blockSelf syncPlayerState])
            [blockSelf callDelegateDidChange];
    }];
}

- (void)syncTimelineSliderLimits
{
    if (self.timelineSlider == nil)
        return;
    self.timelineSlider.minimumValue = 0.0f;
    self.timelineSlider.maximumValue = self.duration;
}

- (BOOL)syncPlayerState
{
    BOOL stateChanged = NO;
    NSTimeInterval secs = self.currentTimeInSecs;
    if ((self.scrollableView.player.rate > 0 && secs >= self.duration) ||
        (self.scrollableView.player.rate < 0 && secs <= 0)) {
        [self pauseInt];
        stateChanged = YES;
    }
    BOOL sliderChanged = [self syncTimelineSlider];
    return stateChanged || sliderChanged;
}

- (BOOL)syncTimelineSlider
{
    float secs = self.currentTimeInSecs;
    if (self.timelineSlider != nil && self.timelineSlider.value != secs) {
        self.timelineSlider.value = secs;
        return YES;
    }
    return NO;
}

- (void)stopTimelineTimer
{
    if (self.timelineTimer == nil)
        return;
    [self.timelineTimer invalidate];
    self.timelineTimer = nil;
}

#pragma mark TelestrationPlaybackVideoView

- (void)seekToStart
{
    [self resetImageView];
    [self seekToTime:0 isLastPosition:YES];
}

- (void)loadPlayer:(AVPlayer *)player duration:(NSTimeInterval)duration fileUrl:(NSURL *)fileUrl
{
    NSAssert(player != nil && duration >= 0, VstratorConstants.AssertionArgumentIsNilOrInvalid);
    self.scrollableView.player = player;
    [self.scrollableView.player addObserver:self forKeyPath:@"status" options:0 context:nil];
    _duration = duration;
    self.fileUrl = fileUrl;
    [self syncTimelineSliderLimits];
    [self calculateImageOrientation];
}

- (void)calculateImageOrientation
{
    if (!self.videoTrack) return;
    CGAffineTransform transform = self.videoTrack.preferredTransform;
    CGFloat angle = atan2(transform.b, transform.a) * 180 / M_PI;
    switch ((int)angle) {
        case 0:
            _imageOrientation = UIImageOrientationUp;
            break;
        case 180:
            _imageOrientation = UIImageOrientationDown;
            break;
        case 90:
            _imageOrientation = UIImageOrientationRight;
            break;
        case -90:
            _imageOrientation = UIImageOrientationLeft;
            break;
        default:
            _imageOrientation = UIImageOrientationUp;
            break;
    }
}

- (void)savePlayerTime
{
    _dontShowImage = YES;
    _currentPlayerTime = self.scrollableView.player.currentTime;
}

- (void)restorePlayerTime:(void(^)())callback
{
    _dontShowImage = NO;
    _restoreCallback = callback;
    if (self.playbackStatus == AVPlayerStatusReadyToPlay || self.playbackStatus == AVPlayerStatusFailed) {
        [self restorePlayerTime];
    } else {
        _processPlayerStatusChanged = YES;
    }
}

- (void)restorePlayerTime
{
    [self seekToTime:CMTimeGetSeconds(_currentPlayerTime) isLastPosition:YES callback:^{
        if (_restoreCallback) _restoreCallback();
        _restoreCallback = nil;
    }];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (!_processPlayerStatusChanged) return;
    if (object != self.scrollableView.player || ![keyPath isEqualToString:@"status"] ||
        self.playbackStatus == AVPlayerStatusReadyToPlay || self.playbackStatus == AVPlayerStatusFailed) return;
    _processPlayerStatusChanged = NO;
    [self restorePlayerTime];
}

- (AVPlayerStatus)playbackStatus
{
    AVPlayer *player = self.scrollableView.player;
    if (player == nil || player.status == AVPlayerStatusFailed || player.currentItem.status == AVPlayerItemStatusFailed)
        return AVPlayerStatusFailed;
    if (player.status == AVPlayerStatusReadyToPlay && player.currentItem.status == AVPlayerItemStatusReadyToPlay)
        return AVPlayerStatusReadyToPlay;
    return AVPlayerStatusUnknown;
}

#pragma mark View Lifecycle

- (void)setup
{
    [super setup];
    
    self.timelineTimer = nil;
    _imageQueue = dispatch_queue_create("ImageQueue", 0);
}

- (void)removeFromSuperview
{
    [self pauseInt];
    [self setViewsToNil];
    [super removeFromSuperview];
}

- (void)dealloc
{
    [self pauseInt];
    self.scrollableView.player = nil;
    dispatch_release(_imageQueue);
}

@end
