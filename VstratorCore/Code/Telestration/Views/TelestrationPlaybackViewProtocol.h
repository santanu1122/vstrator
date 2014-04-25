//
//  TelestrationPlaybackViewProtocol.h
//  VstratorCore
//
//  Created by Admin on 05/06/2013.
//  Copyright (c) 2013 OnTarget. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FrameTransform.h"

@class TelestrationPlaybackBaseView;

@protocol TelestrationPlaybackViewDelegate<NSObject>

@optional
- (void)telestrationPlaybackViewDidChange:(TelestrationPlaybackBaseView *)sender;

@end

@protocol TelestrationPlaybackViewProtocol <NSObject>

@property (nonatomic, weak) IBOutlet UIButton *pauseButton;
@property (nonatomic, weak) IBOutlet UIButton *playButton;
@property (nonatomic, weak) IBOutlet UIButton *seekForwardButton;
@property (nonatomic, weak) IBOutlet UIButton *seekBackwardButton;
@property (nonatomic, weak) IBOutlet UISlider *timelineSlider;

@property (nonatomic, weak) id<TelestrationPlaybackViewDelegate> delegate;
@property (nonatomic, readonly) BOOL eof;
@property (nonatomic, readonly) BOOL playing;
@property (nonatomic, readonly) NSInteger currentFrameNumber;
@property (nonatomic, readonly) FrameTransform *currentFrameTransform;

- (void)pause;
- (void)play;
- (void)seekToNextFrame;
- (void)seekToPrevFrame;
- (void)seekToNextFrameContinuously;
- (void)seekToPrevFrameContinuously;
- (void)seekToSliderPosition:(BOOL)isLastPosition;
- (void)seekToStart;
- (void)flipCurrentFrame;
- (void)setViewsToNil;
- (void)setCurrentFrameZoom:(float)zoom contentOffset:(CGPoint)offset;

@end
