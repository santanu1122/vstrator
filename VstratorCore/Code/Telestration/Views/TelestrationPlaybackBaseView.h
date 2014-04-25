//
//  TelestrationPlaybackBaseView.h
//  VstratorCore
//
//  Created by Admin1 on 23.08.13.
//  Copyright (c) 2013 OnTarget. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TelestrationPlaybackViewProtocol.h"

@interface TelestrationPlaybackBaseView : UIView <TelestrationPlaybackViewProtocol>

@property (nonatomic, weak) IBOutlet UIButton *pauseButton;
@property (nonatomic, weak) IBOutlet UIButton *playButton;
@property (nonatomic, weak) IBOutlet UIButton *seekForwardButton;
@property (nonatomic, weak) IBOutlet UIButton *seekBackwardButton;
@property (nonatomic, weak) IBOutlet UISlider *timelineSlider;

@property (nonatomic, weak) id<TelestrationPlaybackViewDelegate> delegate;
@property (nonatomic, readonly) BOOL eof;
@property (nonatomic, readonly) BOOL playing;
@property (nonatomic, readonly) NSInteger currentFrameNumber;
@property (nonatomic) FrameTransform *currentFrameTransform;
@property (nonatomic) float FrameRate;

- (void)setCurrentFrameTransform:(FrameTransform *)currentFrameTransform animated:(BOOL)animated;

@end
