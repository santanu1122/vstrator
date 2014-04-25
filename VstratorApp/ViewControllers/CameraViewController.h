//
//  CameraViewController.h
//  VstratorApp
//
//  Created by Mac on 11.07.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"


typedef enum {
    CameraViewControllerCaptureModeVideo = 0,
    CameraViewControllerCaptureModeStillImage
} CameraViewControllerCaptureMode;

@protocol CameraViewControllerDelegate;


@interface CameraViewController : BaseViewController

@property (nonatomic, weak) id<CameraViewControllerDelegate> delegate;
@property (nonatomic) NSTimeInterval videoMaximumDuration;
@property (nonatomic) CameraViewControllerCaptureMode captureMode;

@end


@protocol CameraViewControllerDelegate <NSObject>

@optional
- (void)cameraViewControllerDidCancel:(CameraViewController *)sender;
- (void)cameraViewControllerDidImport:(CameraViewController *)sender;
- (void)cameraViewControllerDidCapture:(CameraViewController *)sender videoUrlQOrig:(NSURL *)videoUrlQOrig videoUrlQLow:(NSURL*)videoUrlQLow;
- (void)cameraViewControllerDidCapture:(CameraViewController *)sender image:(UIImage *)image;

@end
