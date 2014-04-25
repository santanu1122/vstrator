//
//  VideoRecorder.m
//  VstratorCore
//
//  Created by Admin1 on 21.10.13.
//  Copyright (c) 2013 OnTarget. All rights reserved.
//

#import "AVCamCaptureManager.h"
#import "CameraPreviewView.h"
#import "SystemInformation.h"
#import "VideoProcessor.h"
#import "VideoRecorder.h"

@interface VideoRecorder() <AVCamCaptureManagerDelegate, UIGestureRecognizerDelegate, VideoProcessorDelegate> {
    BOOL _isAVCamActive;
    BOOL _isCaptureManagerLoaded;
}

@property (nonatomic, strong) AVCamCaptureManager *captureManager;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;
@property (nonatomic, strong) VideoProcessor *videoProcessor;
@property (nonatomic, strong) CameraPreviewView *cameraPreviewView;
@property (nonatomic, weak) UIView *videoPreviewView;

@end

@implementation VideoRecorder

const CMVideoDimensions PrimaryDimensions = { 1280, 720 };
const CMVideoDimensions SecondaryDimensions = { 640, 480 };

- (BOOL)isRecording
{
    if (_isAVCamActive) {
        return self.captureManager.isRecording;
    } else {
        return self.videoProcessor.recording;
    }
}

- (BOOL)isLoaded
{
    return _isCaptureManagerLoaded;
}

- (NSURL*)outputFileUrlQOrig
{
    return _isAVCamActive ? self.captureManager.capturedVideoURL : self.videoProcessor.outputFileUrlQOrig;
}

- (NSURL *)outputFileUrlQLow
{
    return _isAVCamActive ? nil : self.videoProcessor.outputFileUrlQLow;
}

- (float)frameRate
{
    return 1 / CMTimeGetSeconds([self videoDevice].activeVideoMinFrameDuration);
}

#pragma mark Autofocus

// Convert from view coordinates to camera coordinates, where {0,0} represents the top left of the picture area, and {1,1} represents
// the bottom right in landscape mode with the home button on the right.
- (CGPoint)convertToPointOfInterestFromViewCoordinates:(CGPoint)viewCoordinates
{
    CGPoint pointOfInterest = CGPointMake(.5f, .5f);
    CGSize frameSize = self.videoPreviewView.frame.size;
    CGRect cleanAperture;
    
    NSArray *ports;
    if (_isAVCamActive) {
        if (self.captureVideoPreviewLayer.isMirrored) {
            viewCoordinates.x = frameSize.width - viewCoordinates.x;
        }
        ports = self.captureManager.videoInput.ports;
    } else {
        ports = self.videoProcessor.videoInput.ports;
    }
    for (AVCaptureInputPort *port in ports) {
        if (port.mediaType == AVMediaTypeVideo) {
            cleanAperture = CMVideoFormatDescriptionGetCleanAperture(port.formatDescription, YES);
            CGSize apertureSize = cleanAperture.size;
            CGPoint point = viewCoordinates;
            
            CGFloat apertureRatio = apertureSize.height / apertureSize.width;
            CGFloat viewRatio = frameSize.width / frameSize.height;
            CGFloat xc = .5f;
            CGFloat yc = .5f;
            // Scale, switch x and y, and reverse x
            if (viewRatio > apertureRatio) {
                CGFloat y2 = apertureSize.width * (frameSize.width / apertureSize.height);
                xc = (point.y + ((y2 - frameSize.height) / 2.f)) / y2; // Account for cropped height
                yc = (frameSize.width - point.x) / frameSize.width;
            } else {
                CGFloat x2 = apertureSize.height * (frameSize.height / apertureSize.width);
                yc = 1.f - ((point.x + ((x2 - frameSize.width) / 2)) / x2); // Account for cropped width
                xc = point.y / frameSize.height;
            }
            
            pointOfInterest = CGPointMake(xc, yc);
            break;
        }
    }
    return pointOfInterest;
}

// Auto focus at a particular point. The focus mode will change to locked once the auto focus happens.
- (void)tapToAutoFocus:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint tapPoint = [gestureRecognizer locationInView:self.videoPreviewView];
    CGPoint convertedFocusPoint = [self convertToPointOfInterestFromViewCoordinates:tapPoint];
    if (_isAVCamActive) {
        if ([self.captureManager.videoInput.device isFocusPointOfInterestSupported]) {
            [self.captureManager autoFocusAtPoint:convertedFocusPoint];
        }
    } else {
        if ([self.videoProcessor.videoInput.device isFocusPointOfInterestSupported]) {
            [self.videoProcessor autoFocusAtPoint:convertedFocusPoint];
        }
    }
}

// Change to continuous auto focus. The camera will constantly focus at the point choosen.
- (void)tapToContinouslyAutoFocus:(UIGestureRecognizer *)gestureRecognizer
{
    if (_isAVCamActive) {
        if ([self.captureManager.videoInput.device isFocusPointOfInterestSupported])
            [self.captureManager continuousFocusAtPoint:CGPointMake(.5f, .5f)];
    } else {
        if ([self.videoProcessor.videoInput.device isFocusPointOfInterestSupported])
            [self.videoProcessor continuousFocusAtPoint:CGPointMake(.5f, .5f)];
    }
}

#pragma mark VideoRecorderProtocol

- (void)stopRecording
{
    if (_isAVCamActive) {
        [self.captureManager stopRecording];
    } else {
        [self.videoProcessor stopRecording];
    }
}

- (void)startRecording
{
    if (_isAVCamActive) {
        [self.captureManager startRecording];
    } else {
        [self.videoProcessor startRecording];
    }
}

- (void)setVideoOrientation:(int)videoOrientation
{
    switch (videoOrientation) {
        case UIDeviceOrientationPortrait:
            self.videoProcessor.videoOrientation = AVCaptureVideoOrientationPortrait;
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            self.videoProcessor.videoOrientation = AVCaptureVideoOrientationPortraitUpsideDown;
            break;
        case UIDeviceOrientationLandscapeLeft:
            self.videoProcessor.videoOrientation = AVCaptureVideoOrientationLandscapeRight;
            break;
        case UIDeviceOrientationLandscapeRight:
            self.videoProcessor.videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
            break;
        default:
            break;
    }
}

- (void)stopAndTearDownCaptureSession
{
    [self clearVideoRecorders];
}

- (void)resumeCaptureSession
{
    [self initCameraPreviewView];
}

- (void)tearDownPreviewView
{
    if (!self.cameraPreviewView) return;
    [self.cameraPreviewView removeFromSuperview];
    self.cameraPreviewView = nil;
}

- (void)layoutPreviewView
{
    if (_isAVCamActive)
        self.captureVideoPreviewLayer.frame = self.videoPreviewView.bounds;
}

- (void)setupFrameRate:(float)frameRate
{
    NSError *error;
    AVCaptureDevice *videoDevice = [self videoDevice];
    
    AVCaptureDeviceFormat *format = [self findFormatForVideoDevice:videoDevice
                                                      byDimensions:PrimaryDimensions
                                                        frameRange:frameRate];
    if (!format) {
        format = [self findFormatForVideoDevice:videoDevice
                                   byDimensions:SecondaryDimensions
                                     frameRange:frameRate];
    }
    
    if (!format) {
        NSString *errorText = @"Can't find suitable video format.";
        [self didFail:[NSError errorWithDomain:NSOSStatusErrorDomain code:error userInfo:@{ NSLocalizedDescriptionKey: errorText }]];
        return;
    }

    if (![videoDevice lockForConfiguration:&error]) {
        if (error) {
            NSString *errorText = @"Can't lock video device for configuration.";
            [self didFail:[NSError errorWithDomain:NSOSStatusErrorDomain code:error userInfo:@{ NSLocalizedDescriptionKey: errorText }]];
        }
        return;
    }
    videoDevice.activeFormat = format;
    for (AVFrameRateRange *range in videoDevice.activeFormat.videoSupportedFrameRateRanges) {
        if (range.maxFrameRate == frameRate) {
            videoDevice.activeVideoMinFrameDuration = videoDevice.activeVideoMaxFrameDuration = CMTimeMake(1, frameRate);
            break;
        }
    }

    [videoDevice unlockForConfiguration];
    
    return;
}

- (BOOL)isFrameRateSupported:(float)frameRate
{
    return [self getAvailableFormatForDevice:[self videoDevice] byFrameRate:frameRate] != nil;
}

#pragma mark AVCamCaptureManagerDelegate

- (void)captureManager:(AVCamCaptureManager *)captureManager didFailWithError:(NSError *)error
{
    if ([self.delegate respondsToSelector:@selector(videoRecorder:didFailWithError:)]) {
        [self.delegate videoRecorder:self didFailWithError:error];
    }
}

- (void)captureManagerRecordingBegan:(AVCamCaptureManager *)captureManager
{
    if ([self.delegate respondsToSelector:@selector(videoRecorderDidStartRecording:)]) {
        [self.delegate videoRecorderDidStartRecording:self];
    }
}

- (void)captureManagerRecordingFinished:(AVCamCaptureManager *)captureManager
{
    if ([self.delegate respondsToSelector:@selector(videoRecorderDidStopRecording:)]) {
        [self.delegate videoRecorderDidStopRecording:self];
    }
}

#pragma mark VideoProcessorDelegate

-(void)pixelBufferReadyForDisplay:(CVPixelBufferRef)pixelBuffer
{
    // Don't make OpenGLES calls while in the background.
	if ([UIApplication sharedApplication].applicationState != UIApplicationStateBackground )
        [self.cameraPreviewView displayPixelBuffer:pixelBuffer];
}

- (void)recordingWillStart
{
}

- (void)recordingDidStart
{
    if ([self.delegate respondsToSelector:@selector(videoRecorderDidStartRecording:)]) {
        [self.delegate videoRecorderDidStartRecording:self];
    }
}

- (void)recordingWillStop
{
}

- (void)recordingDidStop
{
    if ([self.delegate respondsToSelector:@selector(videoRecorderDidStopRecording:)]) {
        [self.delegate videoRecorderDidStopRecording:self];
    }
}

- (void)recordingDidFail:(NSError*)error
{
    if ([self.delegate respondsToSelector:@selector(videoRecorder:didFailWithError:)]) {
        [self.delegate videoRecorder:self didFailWithError:error];
    }
}

#pragma mark Internal

- (void)initCameraPreviewView
{
    if (self.cameraPreviewView) return;
    self.cameraPreviewView = [[CameraPreviewView alloc] initWithFrame:CGRectZero];
    self.cameraPreviewView.frame = CGRectMake(0, 0, self.videoPreviewView.frame.size.width, self.videoPreviewView.frame.size.height);
    self.cameraPreviewView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    [self.videoPreviewView addSubview:self.cameraPreviewView];
}

- (void)clearVideoRecorders
{
    for (UIGestureRecognizer *recognizer in self.videoPreviewView.gestureRecognizers) {
        [self.videoPreviewView removeGestureRecognizer:recognizer];
    }
    
    self.videoPreviewView = nil;
    
    [self.captureVideoPreviewLayer removeFromSuperlayer];
    self.captureVideoPreviewLayer = nil;

    self.captureManager = nil;
    
    [self.cameraPreviewView removeFromSuperview];
    self.cameraPreviewView = nil;

    [self.videoProcessor stopAndTearDownCaptureSession];
    self.videoProcessor = nil;
}

- (BOOL)setupWithPreviewView:(UIView *)previewView andFrameRate:(float)frameRate
{
    if ([SystemInformation isSystemVersionLessThan:@"7.0"] || frameRate == 30) {
        _isAVCamActive = NO;
        frameRate = 30;
    } else {
        _isAVCamActive = YES;
    }
    
    [self clearVideoRecorders];

    self.videoPreviewView = previewView;
    
    if (_isAVCamActive) {
        self.captureManager = [[AVCamCaptureManager alloc] init];
        self.captureManager.delegate = self;
        if (![self.captureManager setupSession]) return NO;
        _isCaptureManagerLoaded = YES;
        
        // Create video preview layer and add it to the UI
        AVCaptureVideoPreviewLayer *newCaptureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureManager.session];
        CALayer *viewLayer = self.videoPreviewView.layer;
        viewLayer.masksToBounds = YES;
        newCaptureVideoPreviewLayer.frame = self.videoPreviewView.bounds;
        if (newCaptureVideoPreviewLayer.isOrientationSupported)
            newCaptureVideoPreviewLayer.orientation = AVCaptureVideoOrientationLandscapeRight;
        newCaptureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        [viewLayer insertSublayer:newCaptureVideoPreviewLayer below:(viewLayer.sublayers)[0]];
        
        self.captureVideoPreviewLayer = newCaptureVideoPreviewLayer;
        
        [self.captureManager.session startRunning];
    } else {
        self.videoProcessor = [[VideoProcessor alloc] init];
        self.videoProcessor.delegate = self;
        
        [self.videoProcessor setupAndStartCaptureSession];
        
        _isCaptureManagerLoaded = YES;
        
        [self initCameraPreviewView];
    }
    
    [self setupVideoDeviceFormatForFrameRate:frameRate];
    
    // Add a single tap gesture to focus on the point tapped, then lock focus
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToAutoFocus:)];
    singleTap.delegate = self;
    singleTap.numberOfTapsRequired = 1;
    [self.videoPreviewView addGestureRecognizer:singleTap];
    
    // Add a double tap gesture to reset the focus mode to continuous auto focus
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToContinouslyAutoFocus:)];
    doubleTap.delegate = self;
    doubleTap.numberOfTapsRequired = 2;
    [singleTap requireGestureRecognizerToFail:doubleTap];
    [self.videoPreviewView addGestureRecognizer:doubleTap];
    
    return YES;
}

- (void)didFail:(NSError*)error
{
    [self stopRecording];
    if ([self.delegate respondsToSelector:@selector(recordingDidFail:)])
        [self.delegate videoRecorder:self didFailWithError:error];
}

- (AVCaptureDevice *)videoDevice
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices)
        if ([device position] == AVCaptureDevicePositionBack)
            return device;
    
    return nil;
}

- (void)setupVideoDeviceFormatForFrameRate:(float)frameRate
{
    AVCaptureSession *captureSession = _isAVCamActive ? self.captureManager.session : self.videoProcessor.captureSession;
    AVCaptureConnection *videoConnection = _isAVCamActive ? self.captureManager.videoConnection : self.videoProcessor.videoConnection;
    
    if ([SystemInformation isSystemVersionGreaterOrEqualTo:@"7.0"]) {
        if ([self canSetPreset:AVCaptureSessionPresetInputPriority forSession:captureSession])
            captureSession.sessionPreset = AVCaptureSessionPresetInputPriority;
        [self setupFrameRate:frameRate];
        return;
    }
    
    if ([self canSetPreset:AVCaptureSessionPreset1280x720 forSession:captureSession]) {
        captureSession.sessionPreset = AVCaptureSessionPreset1280x720;
    } else if ([self canSetPreset:AVCaptureSessionPreset640x480 forSession:captureSession]) {
        captureSession.sessionPreset = AVCaptureSessionPreset640x480;
    }
    
    if (videoConnection.isVideoMinFrameDurationSupported)
        videoConnection.videoMinFrameDuration = CMTimeMake(1, frameRate);
    if (videoConnection.isVideoMaxFrameDurationSupported)
        videoConnection.videoMaxFrameDuration = CMTimeMake(1, frameRate);
}

- (BOOL)canSetPreset:(NSString*)preset forSession:(AVCaptureSession*)captureSession
{
    return [[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo] supportsAVCaptureSessionPreset:preset]
    && [captureSession canSetSessionPreset:preset];
}

- (AVCaptureDeviceFormat*)findFormatForVideoDevice:(AVCaptureDevice*)videoDevice byDimensions:(CMVideoDimensions)dimensions frameRange:(float)frameRange
{
    for (AVCaptureDeviceFormat *format in videoDevice.formats) {
        if (CMFormatDescriptionGetMediaSubType(format.formatDescription) != '420v') continue;
        BOOL isFrameRangeSupported = NO;
        for (AVFrameRateRange *range in format.videoSupportedFrameRateRanges) {
            if (range.maxFrameRate == frameRange) {
                isFrameRangeSupported = YES;
                break;
            }
        }
        if (!isFrameRangeSupported) continue;
        CMVideoDimensions currentDimensions = CMVideoFormatDescriptionGetDimensions(format.formatDescription);
        if (currentDimensions.width == dimensions.width && currentDimensions.height == dimensions.height) {
            return format;
        }
    }
    return nil;
}

- (AVCaptureDeviceFormat*)getAvailableFormatForDevice:(AVCaptureDevice*)videoDevice byFrameRate:(float)frameRate
{
    AVCaptureDeviceFormat *format = [self findFormatForVideoDevice:videoDevice byDimensions:PrimaryDimensions frameRange:frameRate];
    if (!format) {
        format = [self findFormatForVideoDevice:videoDevice byDimensions:SecondaryDimensions frameRange:frameRate];
    }
    return format;
}

@end
