//
//  TelestrationPlaybackView.m
//  VstratorApp
//
//  Created by Mac on 23.05.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "TelestrationConstants.h"
#import "TelestrationPlaybackBaseView+Subclassing.h"
#import "TelestrationPlaybackImageView.h"
#import "TelestrationScrollableImageView.h"
#import "VstratorConstants.h"
#import "VstratorExtensions.h"
#import "VstratorStrings.h"

@interface TelestrationPlaybackImageView() {
    NSInteger _playerFrameNumber;
    BOOL _playingForward;
}

@property (nonatomic, strong) TelestrationScrollableImageView *scrollableView;

@property (nonatomic) NSInteger lastFrameNumber;
@property (nonatomic, strong) NSString *framesDirectory;
@property (nonatomic, strong) NSTimer *playbackTimer;

@end

#pragma mark -

@implementation TelestrationPlaybackImageView

@synthesize currentFrameNumber = _currentFrameNumber;

#pragma mark Properties

- (TelestrationScrollableImageView *)scrollableView
{
    if (!_scrollableView) {
        _scrollableView = [[TelestrationScrollableImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        _scrollableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return _scrollableView;
}

#pragma mark TelestrationPlaybackViewProtocol

- (BOOL)eof
{
    return self.currentFrameNumber >= self.lastFrameNumber;
}

- (BOOL)playing
{
    return self.playbackTimer != nil;
}

- (void)play
{
    if (self.playing) return;
    if (self.eof) [self updateCurrentFrame:0];
    _playingForward = YES;
    [self startPlaybackTimer];
    [self showPauseButton];
    [self callDelegateDidChange];
}

- (void)pause
{
    if ([self pauseInt]) [self callDelegateDidChange];
}

- (void)seekToNextFrame
{
    [self seekToFrameNumberInt:self.currentFrameNumber + 1];
}

- (void)seekToPrevFrame
{
    [self seekToFrameNumberInt:self.currentFrameNumber - 1];
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
    _playingForward = forward;
    [self startPlaybackTimer];
}

- (void)seekToSliderPosition:(BOOL)isLastPosition
{
    if (self.timelineSlider != nil)
        [self seekToFrameNumberInt:round(self.timelineSlider.value)];
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
}

#pragma mark Utils

- (void)showPauseButton
{
    self.pauseButton.hidden = NO;
    self.playButton.hidden = YES;
}

- (void)showPlayButton
{
    self.pauseButton.hidden = YES;
    self.playButton.hidden = NO;
}

- (void)seekToFrameNumberInt:(NSInteger)frameNumber
{
    BOOL hasStateChanges = [self pauseInt];
    BOOL hasSliderChanges = [self updateCurrentFrame:frameNumber];
    if (hasStateChanges || hasSliderChanges) {
        [self syncTimelineSliderValue];
        [self callDelegateDidChange];
    }
}

- (BOOL)pauseInt
{
    if (!self.playing) return NO;
    [self stopPlaybackTimer];
    [self showPlayButton];
    return YES;
}

#pragma mark Current Frame

- (BOOL)updateCurrentFrame:(NSInteger)frameNumber
{
    if (frameNumber < 0 || frameNumber > self.lastFrameNumber || frameNumber == self.currentFrameNumber)
        return NO;
    _currentFrameNumber = frameNumber;
    [self showCurrentFrame];
    return YES;
}

- (BOOL)showCurrentFrame
{
    NSInteger frameNumber = self.currentFrameNumber;
    if (frameNumber < 0 || frameNumber > self.lastFrameNumber) return NO;
    
    NSString* frameFilePath = [self findImageFileForFrameNumber:frameNumber];
    if (!frameFilePath) return NO;

    UIImage *image = [self loadImageForPath:frameFilePath];
    if (!image)  return NO;

    self.scrollableView.image = image;
    return YES;
}

- (NSString*)findImageFileForFrameNumber:(NSInteger)frameNumber
{
    NSString* frameFilePath = [self.framesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%d.jpg", frameNumber + 1]];
    if (![[NSFileManager defaultManager] fileExistsAtPath:frameFilePath]) {
        NSLog(@"Cannot find the image file for the current frame number: %d", frameNumber);
        return nil;
    }
    return frameFilePath;
}

- (UIImage*)loadImageForPath:(NSString*)path
{
    UIImage *image = [UIImage imageWithContentsOfFile:path];
    if (!image) NSLog(@"Cannot load the image file for path: %@", path);
    return image;
}

#pragma mark Playback Timer

- (void)startPlaybackTimer
{
    [self stopPlaybackTimer];
    self.playbackTimer = [NSTimer scheduledTimerWithTimeInterval:[TelestrationConstants frameDurationInSecsForFrameRate:self.FrameRate]
                                                          target:self
                                                        selector:@selector(playbackTimerAction:)
                                                        userInfo:nil
                                                         repeats:YES];
    [self playbackTimerAction:self.playbackTimer];
}

- (void)stopPlaybackTimer
{
    if (self.playbackTimer == nil) return;
    [self.playbackTimer invalidate];
    self.playbackTimer = nil;
}

- (void)playbackTimerAction:(NSTimer *)timer
{
    BOOL hasStateChanges = NO;
    BOOL hasSliderChanges = NO;
    int lastFrame = _playingForward ? self.lastFrameNumber : 0;
    int increment = _playingForward ? 1 : -1;
    if ((!_playingForward && self.currentFrameNumber <= 0) ||
        (_playingForward && self.currentFrameNumber >= self.lastFrameNumber - 1)) {
        hasStateChanges = [self pauseInt];
        hasSliderChanges = [self updateCurrentFrame:lastFrame];
    } else {
        hasSliderChanges = [self updateCurrentFrame:self.currentFrameNumber + increment];
    }
    if (hasStateChanges || hasSliderChanges) {
        [self syncTimelineSliderValue];
    }
}

#pragma mark Timeline

- (void)syncTimelineSliderValue
{
    if (self.timelineSlider != nil && round(self.timelineSlider.value) != self.currentFrameNumber)
        self.timelineSlider.value = self.currentFrameNumber;
}

- (void)syncTimelineSliderLimits
{
    if (self.timelineSlider == nil)
        return;
    self.timelineSlider.minimumValue = 0.0f;
    self.timelineSlider.maximumValue = self.lastFrameNumber;
}

#pragma mark TelestrationPlaybackImageView

-(void)seekToFrameNumber:(NSInteger)frameNumber
{
    [self seekToFrameNumberInt:frameNumber];
}

- (void)seekToStart
{
    [self seekToFrameNumberInt:0];
}

- (BOOL)loadFramesDirectory:(NSString *)framesDirectory error:(NSError **)error
{
    NSParameterAssert(error);
    *error = nil;
    BOOL isDirectory = YES;
    if (![NSFileManager.defaultManager fileExistsAtPath:framesDirectory isDirectory:&isDirectory] || !isDirectory) {
        *error = [NSError errorWithText:VstratorStrings.ErrorLoadingSelectedSession];
    } else if (![self loadLastFrameNumber:framesDirectory]) {
        *error = [NSError errorWithText:VstratorStrings.ErrorLoadingSelectedSession];
    } else {
        self.framesDirectory = framesDirectory;
        [self syncTimelineSliderLimits];
        [self seekToStart];
    }
    return (*error == nil);
}

- (BOOL)loadLastFrameNumber:(NSString *)framesDirectory
{
    NSArray *files = [NSFileManager.defaultManager contentsOfDirectoryAtPath:framesDirectory error:nil];
    NSPredicate *frameFilesPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES '[0-9]+\\.[jJ][pP][gG]'"];
    self.lastFrameNumber = [files filteredArrayUsingPredicate:frameFilesPredicate].count - 1;
    return self.lastFrameNumber > 0;
}

- (void)savePlayerFrameNumber:(NSInteger)frameNumber
{
    _playerFrameNumber = frameNumber;
}

- (void)restorePlayerFrame
{
    [self updateCurrentFrame:_playerFrameNumber];
}

#pragma mark View Lifecycle

- (void)setup
{
    [super setup];

    _currentFrameNumber = -1;
    self.lastFrameNumber = 0;
}

- (void)removeFromSuperview
{
    [self stopPlaybackTimer];
    [self setViewsToNil];
    [super removeFromSuperview];
}

- (void)dealloc
{
    [self stopPlaybackTimer];
}

@end
