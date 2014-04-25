//
//  TelestrationPlaybackView.h
//  VstratorApp
//
//  Created by Mac on 23.05.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

//NOTE: removeFromSuperview will zero all IBOutlet links

#import <UIKit/UIKit.h>
#import "TelestrationPlaybackBaseView.h"

@interface TelestrationPlaybackImageView : TelestrationPlaybackBaseView

- (void)seekToFrameNumber:(NSInteger)frameNumber;
- (BOOL)loadFramesDirectory:(NSString *)framesDirectory error:(NSError **)error;
- (void)savePlayerFrameNumber:(NSInteger)frameNumber;
- (void)restorePlayerFrame;

@end



