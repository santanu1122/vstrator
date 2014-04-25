//
//  CameraManagerViewController.h
//  VstratorApp
//
//  Created by Mac on 02.04.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

typedef enum {
    CameraManagerClipActionNon,
    CameraManagerClipActionOpen,
    CameraManagerClipActionVstrate
} CameraManagerClipAction;

@protocol CameraManagerResponderDelegate;


@interface CameraManagerViewController : BaseViewController

@property (nonatomic, weak) id<CameraManagerResponderDelegate> delegate;

@end


@protocol CameraManagerResponderDelegate <NSObject>

@optional
- (void)cameraManagerViewControllerDidCancel:(CameraManagerViewController *)sender;
@required
- (void)cameraManagerViewControllerDidFinish:(CameraManagerViewController *)sender
                                withLastClip:(Clip *)lastClip
                                clipAction:(CameraManagerClipAction)clipAction;

@end
