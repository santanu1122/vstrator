//
//  TelestrationPlaybackViewController.h
//  VstratorApp
//
//  Created by user on 12.03.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "TelestrationBaseViewController.h"
#import "ContentActionDelegate.h"

@class Session, VstrationMediaModel;

@interface TelestrationPlaybackViewController : TelestrationBaseViewController<AVAudioPlayerDelegate, AVAudioSessionDelegate> 

@property (nonatomic, unsafe_unretained, readonly) id<ContentActionDelegate> delegate;

- (id)initForPlayWithSession:(Session *)session
                    delegate:(id<ContentActionDelegate>)delegate
                       error:(NSError **)error;
- (id)initForSaveWithVstrationController:(VstrationController *)vstrationController
                                delegate:(id<ContentActionDelegate>)delegate
                                   error:(NSError **)error;

@end
