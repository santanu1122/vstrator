//
//  SideBySideEditorViewController.m
//  VstratorApp
//
//  Created by user on 12.03.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "AVPlayer+Extensions.h"
#import "ImageGenerationDispatcher.h"
#import "SideBySideEditorViewController.h"
#import "TelestrationConstants.h"
#import "TelestrationEditorViewController+Subclassing.h"
#import "TelestrationPlaybackView.h"
#import "VstrationController.h"
#import "VstrationSessionModel.h"
#import "VstratorExtensions.h"
#import "VstratorConstants.h"
#import "VstratorStrings.h"

@interface SideBySideEditorViewController() <TelestrationPlaybackViewDelegate> {
    BOOL _isPlaybackLocked;
    float _previousSliderValue;
    float _previousSlider2Value;
}

@property (nonatomic) BOOL shouldPlayOnRecordStart2;

@property (nonatomic, weak) IBOutlet TelestrationPlaybackView *playbackView2;
@property (nonatomic, weak) IBOutlet UIImageView *timelineSliderImageViewForPlaybackView;
@property (nonatomic, weak) IBOutlet UIImageView *timelineSliderImageViewForPlaybackView2;
@property (weak, nonatomic) IBOutlet UIButton *flipButton2;
@property (nonatomic, weak) IBOutlet UIButton *playbackPlayButton1;
@property (nonatomic, weak) IBOutlet UIButton *playbackPauseButton1;
@property (nonatomic, weak) IBOutlet UIButton *playbackPlayButton2;
@property (nonatomic, weak) IBOutlet UIButton *playbackPauseButton2;
@property (nonatomic, weak) IBOutlet UIButton *playbackLockButton;
@property (weak, nonatomic) IBOutlet UISlider *timelineSlider2;

@end

@implementation SideBySideEditorViewController

#pragma mark - Playback (Subclassing)

- (BOOL)playbackViewSetupWithError:(NSError**)error
{
    if (![super playbackViewSetupWithError:error]) return NO;
    
    BOOL result = [self.playbackView2 playbackViewSetupWithDuration:self.controller.model.originalClip2.duration
                                                        playbackUrl:self.controller.model.playbackURL2
                                               playbackImagesFolder:self.controller.model.originalClip2.playbackImagesFolder
                                                          frameRate:self.controller.model.originalClip2.frameRate.floatValue
                                                           delegate:self
                                                              error:error];
    if (result) {
        CGSize size = CGSizeMake(self.controller.model.originalClip2.width.intValue, self.controller.model.originalClip2.height.intValue);
        [self setPlaybackView:self.playbackView2 initZoomForSize:size];
    }
    return result;
}

- (void)setPlaybackView:(TelestrationPlaybackView*)playbackView initZoomForSize:(CGSize)size
{
    [playbackView setInitZoomForSize:size isSideBySide:YES];
}

- (NSInteger)playbackCurrentFrameNumber2
{
    return self.playbackView2.currentFrameNumber;
}

- (FrameTransform *)playbackCurrentTransform2
{
    return self.playbackView2.currentFrameTransform;
}

- (IBAction)playbackPause:(id)sender
{
    [super playbackPause:sender];
    [self.playbackView2 pause];
}

- (IBAction)playbackPlay:(id)sender
{
    BOOL playbackAtEOF = super.playbackAtEOF;
    BOOL playback2AtEOF = self.playbackView2.eof;
    BOOL bothAtEOF = playbackAtEOF && playback2AtEOF;
    if (bothAtEOF || !playbackAtEOF) {
        [super playbackPlay:sender];
    }
    if (bothAtEOF || !playback2AtEOF) {
        [self.playbackView2 play];
    }
}

- (IBAction)playbackPlay1:(id)sender
{
    if (_isPlaybackLocked) {
        [self playbackPlay:sender];
        return;
    }
    [super playbackPlay:sender];
}

- (IBAction)playbackPlay2:(id)sender
{
    if (_isPlaybackLocked) {
        [self playbackPlay:sender];
        return;
    }
    [self.playbackView2 play];
}

- (IBAction)playbackPause1:(id)sender
{
    if (_isPlaybackLocked) {
        [self playbackPause:sender];
        return;
    }
    [super playbackPause:sender];
}

- (IBAction)playbackPause2:(id)sender
{
    if (_isPlaybackLocked) {
        [self playbackPause:sender];
        return;
    }
    [self.playbackView2 pause];
}

- (IBAction)playbackLock:(id)sender
{
    self.playbackLockButton.selected = !self.playbackLockButton.selected;
    _isPlaybackLocked = !_isPlaybackLocked;
}

- (IBAction)seekToPreviousFrame:(id)sender
{
    [super seekToPreviousFrame:sender];
    [self.playbackView2 seekToPrevFrame];
}

- (IBAction)seekToNextFrame:(id)sender
{
    [super seekToNextFrame:sender];
    [self.playbackView2 seekToNextFrame];
}

- (IBAction)seekToSlider2Position:(id)sender
{
    [self seekToSlider2Position];
    if (_isPlaybackLocked) {
        self.timelineSlider.value += self.timelineSlider2.value - _previousSlider2Value;
        [super seekToSliderPosition:sender];
    }
    _previousSlider2Value = self.timelineSlider2.value;
}

- (void)seekToSlider2Position
{
    [self.playbackView2 seekToSliderPosition:NO];
}

- (IBAction)timelineSlider2DidEndSliding:(id)sender {
    [self timelineSlider2DidEndSliding];
    if (_isPlaybackLocked) {
        self.timelineSlider.value += self.timelineSlider2.value - _previousSlider2Value;
        [super timelineSliderDidEndSliding:sender];
    }
    _previousSlider2Value = self.timelineSlider2.value;
}

- (void)timelineSlider2DidEndSliding
{
    [self.playbackView2 seekToSliderPosition:YES];
}

- (IBAction)seekToSliderPosition:(id)sender
{
    [super seekToSliderPosition:sender];
    if (_isPlaybackLocked) {
        self.timelineSlider2.value += self.timelineSlider.value - _previousSliderValue;
        [self seekToSlider2Position];
    }
    _previousSliderValue = self.timelineSlider.value;
}

- (IBAction)timelineSliderDidEndSliding:(id)sender
{
    [super timelineSliderDidEndSliding:sender];
    if (_isPlaybackLocked) {
        self.timelineSlider2.value += self.timelineSlider.value - _previousSliderValue;
        [self timelineSlider2DidEndSliding];
    }
    _previousSliderValue = self.timelineSlider.value;
}

- (void)waitForReadiness
{
    [super waitForReadiness];
    [self waitForReadiness:^AVPlayerStatus{
        return self.playbackView2.playbackStatus;
    }];
}

- (void)setPlaybackViewsToNil
{
    [super setPlaybackViewsToNil];
    [self.playbackView2 setViewsToNil];
    self.playbackView2.delegate = nil;
    self.playbackView2 = nil;
}

- (void)savePlaybackTime
{
    [super savePlaybackTime];
    [self.playbackView2 savePlayerTime];
}

- (void)restorePlaybackTime:(void (^)())callback
{
    [super restorePlaybackTime:^{
        [self.playbackView2 restorePlayerTime:callback];
    }];
}

#pragma mark Tools

- (void)offZoom
{
    [super offZoom];
    self.flipButton2.hidden = YES;
}

- (void)setHiddenForFlipButton:(BOOL)hidden
{
    [super setHiddenForFlipButton:hidden];
    self.flipButton2.hidden = hidden;
}

- (IBAction)flip2Action:(id)sender {
    [self.playbackView2 flipCurrentFrame];
}

#pragma mark - Playback Buttons

- (void)updatePlaybackButtons
{
    self.playbackPlayButton1.hidden = super.playbackViewPlaying;
    self.playbackPauseButton1.hidden = !self.playbackPlayButton1.hidden;
    
    self.playbackPlayButton2.hidden = self.playbackView2.playing;
    self.playbackPauseButton2.hidden = !self.playbackPlayButton2.hidden;
    
    self.playbackPlayButton.hidden = super.playbackViewPlaying && self.playbackView2.playing;
    self.playbackPauseButton.hidden = !self.playbackPlayButton.hidden;
}

#pragma mark - Recording

- (void)recordStartingEvent
{
    // Super
    [super recordStartingEvent];
    // Playback
    self.shouldPlayOnRecordStart2 = self.playbackView2.playing;
    if (self.shouldPlayOnRecordStart2)
        [self.playbackView2 pause];
}

- (void)recordStartedEvent
{
    // Super
    [super recordStartedEvent];
    // Playback
    if (self.shouldPlayOnRecordStart2)
        [self.playbackView2 play];
}

#pragma mark - TelestrationPlayback

- (void)telestrationPlaybackViewDidChange:(TelestrationPlaybackBaseView *)sender
{
    [self updatePlaybackButtons];
}

#pragma mark TelestrationPlayerViewControllerDelegate

- (void)telestrationPlayerViewControllerDidCancel:(TelestrationPlayerViewController *)sender
{
    [super telestrationPlayerViewControllerDidCancel:sender];
    [self.playbackView2 seekToStart];
}

#pragma mark Gesture Recognizers

- (void)seekToPrevFrameContinuously
{
    [super seekToPrevFrameContinuously];
    [self.playbackView2 seekToPrevFrameContinuously];
}

- (void)seekToNextFrameContinuously
{
    [super seekToNextFrameContinuously];
    [self.playbackView2 seekToNextFrameContinuously];
}

- (void)stopSeekContinuously
{
    [super stopSeekContinuously];
    [self.playbackView2 pause];
}

#pragma mark - Ctor

- (id)initWithClip:(Clip *)clip clip2:(Clip *)clip2 delegate:(id<TelestrationEditorViewControllerDelegate>)delegate error:(NSError **)error
{
    VstrationSessionModel *model = [[VstrationSessionModel alloc] initWithClip:clip clip2:clip2];
    return [super initWithSessionModel:model delegate:delegate error:error];
}

- (BOOL)setupWithSessionModel:(VstrationSessionModel *)model delegate:(id<TelestrationEditorViewControllerDelegate>)delegate error:(NSError *__autoreleasing *)error
{
    BOOL result = [super setupWithSessionModel:model delegate:delegate error:error];
    return result;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    _previousSliderValue = 0;
    _previousSlider2Value = 0;
    
    self.timelineSliderImageViewForPlaybackView.image = [UIImage resizableImageNamed:@"bg-telestration-slider"];
    self.timelineSliderImageViewForPlaybackView2.image = [UIImage resizableImageNamed:@"bg-telestration-slider"];
    [self.playbackPauseButton1 setBackgroundImage:[UIImage resizableImageNamed:@"bt-grey-t01-normal"] forState:UIControlStateNormal];
    [self.playbackPauseButton1 setBackgroundImage:[UIImage resizableImageNamed:@"bt-grey-t01-sel"] forState:UIControlStateHighlighted];
    [self.playbackPlayButton1 setBackgroundImage:[UIImage resizableImageNamed:@"bt-grey-t01-normal"] forState:UIControlStateNormal];
    [self.playbackPlayButton1 setBackgroundImage:[UIImage resizableImageNamed:@"bt-grey-t01-sel"] forState:UIControlStateHighlighted];
    [self.playbackPauseButton2 setBackgroundImage:[UIImage resizableImageNamed:@"bt-grey-t01-normal"] forState:UIControlStateNormal];
    [self.playbackPauseButton2 setBackgroundImage:[UIImage resizableImageNamed:@"bt-grey-t01-sel"] forState:UIControlStateHighlighted];
    [self.playbackPlayButton2 setBackgroundImage:[UIImage resizableImageNamed:@"bt-grey-t01-normal"] forState:UIControlStateNormal];
    [self.playbackPlayButton2 setBackgroundImage:[UIImage resizableImageNamed:@"bt-grey-t01-sel"] forState:UIControlStateHighlighted];
}

- (void)fixUiForIos7
{
    [super fixUiForIos7];
    CGRect frame = self.timelineSlider2.frame;
    frame.origin.y = 5;
    self.timelineSlider2.frame = frame;
}

- (void)viewDidUnload
{
    // Release any retained subviews of the main view.
    [self setFlipButton2:nil];
    [self setTimelineSliderImageViewForPlaybackView:nil];
    [self setTimelineSliderImageViewForPlaybackView2:nil];
    [self setPlaybackPlayButton1:nil];
    [self setPlaybackPauseButton1:nil];
    [self setPlaybackPlayButton2:nil];
    [self setPlaybackPauseButton2:nil];
    [self setPlaybackLockButton:nil];
    [self setTimelineSlider2:nil];
    // Super
    [super viewDidUnload];
}

@end
