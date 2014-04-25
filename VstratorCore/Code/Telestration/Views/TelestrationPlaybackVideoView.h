//
//  TelestrationPlaybackVideoView.h
//  VstratorApp
//
//  Created by Mac on 23.05.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

//NOTE: removeFromSuperview will zero all IBOutlet links

#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
#import "TelestrationPlaybackBaseView.h"

@interface TelestrationPlaybackVideoView : TelestrationPlaybackBaseView

@property (nonatomic, readonly) AVPlayerStatus playbackStatus;

- (void)loadPlayer:(AVPlayer *)player duration:(NSTimeInterval)duration fileUrl:(NSURL*)fileUrl;
- (void)savePlayerTime;
- (void)restorePlayerTime:(void(^)())callback;

@end
