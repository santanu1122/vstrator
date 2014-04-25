//
//  VideoRecorder.h
//  VstratorCore
//
//  Created by Admin1 on 21.10.13.
//  Copyright (c) 2013 OnTarget. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol VideoRecorderDelegate;

@interface VideoRecorder : NSObject

@property (nonatomic, weak) id<VideoRecorderDelegate> delegate;
@property (nonatomic, readonly) BOOL isRecording;
@property (nonatomic, readonly) BOOL isLoaded;
@property (nonatomic, strong, readonly) NSURL *outputFileUrlQOrig;
@property (nonatomic, strong, readonly) NSURL *outputFileUrlQLow;
@property (nonatomic, readonly) float frameRate;

- (BOOL)setupWithPreviewView:(UIView *)previewView andFrameRate:(float)frameRate;
- (void)stopRecording;
- (void)startRecording;
- (void)setVideoOrientation:(int)videoOrientation;
- (void)stopAndTearDownCaptureSession;
- (void)resumeCaptureSession;
- (void)tearDownPreviewView;
- (void)layoutPreviewView;
- (BOOL)isFrameRateSupported:(float)frameRate;

@end

@protocol VideoRecorderDelegate <NSObject>

- (void)videoRecorder:(VideoRecorder*)videoRecoder didFailWithError:(NSError*)error;
- (void)videoRecorderDidStartRecording:(VideoRecorder*)videoRecoder;
- (void)videoRecorderDidStopRecording:(VideoRecorder*)videoRecoder;

@end