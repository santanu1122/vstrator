//
//  TelestrationEditViewController.h
//  VstratorApp
//
//  Created by user on 12.03.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContentActionDelegate.h"
#import "TelestrationBaseViewController.h"

@class Clip, Session;

@interface TelestrationEditViewController : TelestrationBaseViewController<UIAlertViewDelegate, ContentActionDelegate>

@property (nonatomic, unsafe_unretained, readonly) id<ContentActionDelegate> delegate;

- (id)initWithClip:(Clip *)clip delegate:(id<ContentActionDelegate>)delegate error:(NSError **)error;
- (id)initWithSession:(Session *)session delegate:(id<ContentActionDelegate>)delegate error:(NSError **)error;

@end
