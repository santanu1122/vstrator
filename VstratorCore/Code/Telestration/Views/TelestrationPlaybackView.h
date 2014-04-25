//
//  TelestrationPlaybackView.h
//  VstratorCore
//
//  Created by Admin1 on 26.08.13.
//  Copyright (c) 2013 OnTarget. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AVPlayer+Extensions.h"
#import "TelestrationPlaybackViewProtocol.h"

@class VstrationController;

@interface TelestrationPlaybackView : UIView<TelestrationPlaybackViewProtocol>

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
@property (nonatomic, readonly) AVPlayerStatus playbackStatus;

- (BOOL)playbackViewSetupWithDuration:(NSNumber*)duration
                          playbackUrl:(NSURL*)playbackUrl
                 playbackImagesFolder:(NSString*)playbackImagesFolder
                            frameRate:(float)frameRate
                             delegate:(id<TelestrationPlaybackViewDelegate>)delegate
                                error:(NSError **)error;
- (void)savePlayerTime;
- (void)restorePlayerTime:(void(^)())callback;
- (void)setInitZoomForSize:(CGSize)size isSideBySide:(BOOL)isSideBySide;

@end
