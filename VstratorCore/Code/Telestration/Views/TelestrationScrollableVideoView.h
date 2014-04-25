//
//  TelestrationScrollableVideoView.h
//  VstratorCore
//
//  Created by Admin on 31/01/2013.
//  Copyright (c) 2013 OnTarget. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
#import "TelestrationScrollableBaseView.h"

@interface TelestrationScrollableVideoView : TelestrationScrollableBaseView

@property (strong, nonatomic) AVPlayer *player;

@end
