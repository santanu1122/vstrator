//
//  TelestrationViewEditorController+Subclassing.h
//  VstratorApp
//
//  Created by Virtualler on 06.08.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "TelestrationEditorViewController.h"

@class TelestrationPlaybackView, TelestrationPlayerViewController, VstrationController, VstrationSessionModel;

@interface TelestrationEditorViewController (Subclassing)

//- (UIButton *)playbackSeekBackwardButton;
//- (UIButton *)playbackSeekForwardButton;
- (UIButton *)playbackPlayButton;
- (UIButton *)playbackPauseButton;
- (TelestrationPlaybackView *)playbackView;
- (UISlider *)timelineSlider;

- (id)initWithSessionModel:(VstrationSessionModel *)model delegate:(id<TelestrationEditorViewControllerDelegate>)delegate error:(NSError **)error;
- (BOOL)setupWithSessionModel:(VstrationSessionModel *)model delegate:(id<TelestrationEditorViewControllerDelegate>)delegate error:(NSError **)error;

- (VstrationController *)controller;

- (BOOL)playbackViewSetupWithError:(NSError**)error;
- (void)setPlaybackView:(TelestrationPlaybackView*)playbackView initZoomForSize:(CGSize)size;

- (BOOL)playbackViewPlaying;
- (NSTimeInterval)playbackAtEOF;
- (NSInteger)playbackCurrentFrameNumber;
- (NSInteger)playbackCurrentFrameNumber2;

- (IBAction)playbackPause:(id)sender;
- (IBAction)playbackPlay:(id)sender;
- (IBAction)seekToPreviousFrame:(id)sender;
- (IBAction)seekToNextFrame:(id)sender;
- (IBAction)seekToSliderPosition:(id)sender;
- (IBAction)timelineSliderDidEndSliding:(id)sender;

- (void)seekToPrevFrameContinuously;
- (void)seekToNextFrameContinuously;
- (void)stopSeekContinuously;

- (void)recordStartingEvent;
- (void)recordStartedEvent;

- (void)offZoom;
- (void)setHiddenForFlipButton:(BOOL)hidden;
- (void)waitForReadiness;
- (void)waitForReadiness:(NSInteger(^)())statusCallback;
- (void)setPlaybackViewsToNil;
- (void)telestrationPlayerViewControllerDidCancel:(TelestrationPlayerViewController *)sender;
- (void)savePlaybackTime;
- (void)restorePlaybackTime:(void(^)())callback;
- (void)fixUiForIos7;

@end
