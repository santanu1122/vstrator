/*
     File: VideoProcessor.m
 Abstract: The class that creates and manages the AV capture session and asset writer
  Version: 1.2
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2011 Apple Inc. All Rights Reserved.
 
 */

#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "MediaImagesGenerator.h"
#import "TelestrationConstants.h"
#import "UIAlertViewWrapper.h"
#import "VideoProcessor.h"
#import "VstratorConstants.h"

#define BYTES_PER_PIXEL 4

@interface VideoProcessor ()

@property (nonatomic, readwrite) Float64 videoFrameRate;
@property (nonatomic, readwrite) CMVideoDimensions videoDimensions;
@property (nonatomic, readwrite) CMVideoCodecType videoType;
@property (nonatomic, readwrite, getter=isRecording) BOOL recording;
@property (nonatomic, strong) AVAssetWriter *assetWriterQOrig;
@property (nonatomic, strong) AVAssetWriterInput *assetWriterAudioInQOrig;
@property (nonatomic, strong) AVAssetWriterInput *assetWriterVideoInQOrig;
@property (nonatomic, strong) AVAssetWriter *assetWriterQLow;
@property (nonatomic, strong) AVAssetWriterInput *assetWriterAudioInQLow;
@property (nonatomic, strong) AVAssetWriterInput *assetWriterVideoInQLow;
@property (nonatomic, strong) NSMutableArray *previousSecondTimestamps;
@property (nonatomic, strong) AVCaptureConnection *audioConnection;
@property (nonatomic) CMBufferQueueRef previewBufferQueue;
@property (nonatomic) dispatch_queue_t movieWritingQueue;
@property (nonatomic) BOOL readyToRecordAudio;
@property (nonatomic) BOOL readyToRecordVideo;
@property (nonatomic) BOOL recordingWillBeStarted;
@property (nonatomic) BOOL recordingWillBeStopped;
@property (nonatomic) int framesCount;

@end

@implementation VideoProcessor

- (id)init
{
    if (self = [super init]) {
        self.previousSecondTimestamps = [[NSMutableArray alloc] init];
    }
    return self;
}

#pragma mark Properties

- (NSURL *)outputFileUrlQOrig
{
    return [self urlInTempFolderForFile:@"output_QOrig.mov"];
}

- (NSURL *)outputFileUrlQLow
{
    return [self urlInTempFolderForFile:@"output_QLow.mov"];
}

- (NSURL*)urlInTempFolderForFile:(NSString*)fileName
{
    return [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), fileName]];
}

#pragma mark Utilities

- (void)didFail:(NSError*)error
{
    [self stopRecording];
    if ([self.delegate respondsToSelector:@selector(recordingDidFail:)])
        [self.delegate recordingDidFail:error];
}

- (void)removeFile:(NSURL *)fileURL error:(NSError*)error
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *filePath = [fileURL path];
    if ([fileManager fileExistsAtPath:filePath]) {
        [fileManager removeItemAtPath:filePath error:&error];
    }
}

#pragma mark Recording

- (void)startWritingAssetWriter:(AVAssetWriter*)assetWriter
             atPresentationTime:(CMTime)presentationTime
                          error:(NSError*)error
{
    if (assetWriter.status != AVAssetWriterStatusUnknown) return;

    if ([assetWriter startWriting]) {
        [assetWriter startSessionAtSourceTime:presentationTime];
    } else {
        error = assetWriter.error;
    }
}

- (void)appendSampleBuffer:(CMSampleBufferRef)sampleBuffer
                    ofType:(NSString*)mediaType
             toAssetWriter:(AVAssetWriter*)assetWriter
        assetWriterVideoIn:(AVAssetWriterInput*)assetWriterVideoIn
      asseterWriterAudioIn:(AVAssetWriterInput*)assetWriterAudioIn
                     error:(NSError*)error
{
    if (assetWriter.status != AVAssetWriterStatusWriting ) return;

    if (mediaType == AVMediaTypeVideo) {
        if (assetWriterVideoIn.readyForMoreMediaData) {
            if (![assetWriterVideoIn appendSampleBuffer:sampleBuffer]) {
                error = assetWriter.error;
            }
        }
    } else if (mediaType == AVMediaTypeAudio) {
        if (assetWriterAudioIn.readyForMoreMediaData) {
            if (![assetWriterAudioIn appendSampleBuffer:sampleBuffer]) {
                error = assetWriter.error;
            }
        }
    }
}

- (void)writeSampleBuffer:(CMSampleBufferRef)sampleBuffer ofType:(NSString *)mediaType
{
    if (mediaType != AVMediaTypeVideo &&
        self.assetWriterQOrig.status == AVAssetWriterStatusUnknown &&
        self.assetWriterQLow.status == AVAssetWriterStatusUnknown) return;
    
    NSError *error;
    
    CMTime presentationTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
    [self startWritingAssetWriter:self.assetWriterQOrig atPresentationTime:presentationTime error:error];
    if (error) {
        [self didFail:error];
        return;
    }
    
    [self startWritingAssetWriter:self.assetWriterQLow atPresentationTime:presentationTime error:error];
    if (error) {
        [self didFail:error];
        return;
    }
	
    [self appendSampleBuffer:sampleBuffer
                      ofType:mediaType
               toAssetWriter:self.assetWriterQOrig
          assetWriterVideoIn:self.assetWriterVideoInQOrig
        asseterWriterAudioIn:self.assetWriterAudioInQOrig
                       error:error];
    if (error) {
        [self didFail:error];
        return;
    }
    
    [self appendSampleBuffer:sampleBuffer
                      ofType:mediaType
               toAssetWriter:self.assetWriterQLow
          assetWriterVideoIn:self.assetWriterVideoInQLow
        asseterWriterAudioIn:self.assetWriterAudioInQLow
                       error:error];
    if (error) {
        [self didFail:error];
        return;
    }
}

- (AVAssetWriterInput*)addAssetWriterAudioInToAssetWriter:(AVAssetWriter*)assetWriter withSettings:(NSDictionary*)settings
{
    if ([assetWriter canApplyOutputSettings:settings forMediaType:AVMediaTypeAudio]) {
		AVAssetWriterInput* assetWriterAudioIn = [[AVAssetWriterInput alloc] initWithMediaType:AVMediaTypeAudio outputSettings:settings];
		assetWriterAudioIn.expectsMediaDataInRealTime = YES;
		if ([assetWriter canAddInput:assetWriterAudioIn]) {
			[assetWriter addInput:assetWriterAudioIn];
            return assetWriterAudioIn;
        }
		else {
			NSLog(@"Couldn't add asset writer audio input.");
		}
	}
	else {
		NSLog(@"Couldn't apply audio output settings.");
    }
    return nil;
}

- (NSDictionary*)setupAssetWriterAudioInputSettingsWithFormat:(CMFormatDescriptionRef)currentFormatDescription
{
    const AudioStreamBasicDescription *currentASBD = CMAudioFormatDescriptionGetStreamBasicDescription(currentFormatDescription);
    
	size_t aclSize = 0;
	const AudioChannelLayout *currentChannelLayout = CMAudioFormatDescriptionGetChannelLayout(currentFormatDescription, &aclSize);
	NSData *currentChannelLayoutData = nil;
	
	// AVChannelLayoutKey must be specified, but if we don't know any better give an empty data and let AVAssetWriter decide.
	if (currentChannelLayout && aclSize > 0 )
		currentChannelLayoutData = [NSData dataWithBytes:currentChannelLayout length:aclSize];
	else
		currentChannelLayoutData = [NSData data];
	
	return @{ AVFormatIDKey: @(kAudioFormatMPEG4AAC),
              AVSampleRateKey: @(currentASBD->mSampleRate),
              AVEncoderBitRatePerChannelKey: @(64000),
              AVNumberOfChannelsKey: @(currentASBD->mChannelsPerFrame),
              AVChannelLayoutKey: currentChannelLayoutData };
}

- (BOOL)setupAssetWriterAudioInput:(CMFormatDescriptionRef)currentFormatDescription
{
	NSDictionary *audioCompressionSettings = [self setupAssetWriterAudioInputSettingsWithFormat:currentFormatDescription];
    
	self.assetWriterAudioInQOrig = [self addAssetWriterAudioInToAssetWriter:self.assetWriterQOrig withSettings:audioCompressionSettings];
    if (!self.assetWriterAudioInQOrig) return NO;
    
    self.assetWriterAudioInQLow = [self addAssetWriterAudioInToAssetWriter:self.assetWriterQLow withSettings:audioCompressionSettings];
    if (!self.assetWriterAudioInQLow) return NO;
    
    return YES;
}

- (AVAssetWriterInput*)addAssetWriterVideoInToAssetWriter:(AVAssetWriter*)assetWriter
                                             withSettings:(NSDictionary*)settings
                                     andFormatDescription:(CMFormatDescriptionRef)formatDescription
{
    if ([assetWriter canApplyOutputSettings:settings forMediaType:AVMediaTypeVideo]) {
		AVAssetWriterInput *assetWriterVideoIn = [[AVAssetWriterInput alloc] initWithMediaType:AVMediaTypeVideo outputSettings:settings];
		assetWriterVideoIn.expectsMediaDataInRealTime = YES;
        CMVideoDimensions dimensions = CMVideoFormatDescriptionGetDimensions(formatDescription);
		assetWriterVideoIn.transform = [self transformFromOrientation:self.videoOrientation andSize:CGSizeMake(dimensions.width, dimensions.height)];
		if ([assetWriter canAddInput:assetWriterVideoIn]) {
			[assetWriter addInput:assetWriterVideoIn];
            return assetWriterVideoIn;
        }
		else {
			NSLog(@"Couldn't add asset writer video input.");
		}
	}
	else {
		NSLog(@"Couldn't apply video output settings.");
	}
    return nil;
}

- (NSDictionary*)setupAssetWriterVideoInputSettingsWithFormat:(CMFormatDescriptionRef)currentFormatDescription
                                           forOriginalQuality:(BOOL)originalQuality
{
    float bitsPerPixel;
	CMVideoDimensions dimensions;
    if (originalQuality) {
        dimensions = CMVideoFormatDescriptionGetDimensions(currentFormatDescription);
    } else {
        dimensions.width = VstratorConstants.PlaybackQualityVideoSize.width;
        dimensions.height = VstratorConstants.PlaybackQualityVideoSize.height;
    }
	int numPixels = dimensions.width * dimensions.height;
	int bitsPerSecond;
	
	// Assume that lower-than-SD resolutions are intended for streaming, and use a lower bitrate
	if ( numPixels < (640 * 480) )
		bitsPerPixel = 4.05; // This bitrate matches the quality produced by AVCaptureSessionPresetMedium or Low.
	else
		bitsPerPixel = 11.4; // This bitrate matches the quality produced by AVCaptureSessionPresetHigh.
	
	bitsPerSecond = numPixels * bitsPerPixel;
	
	return @{ AVVideoCodecKey: AVVideoCodecH264,
              AVVideoWidthKey: @(dimensions.width),
              AVVideoHeightKey: @(dimensions.height),
              AVVideoCompressionPropertiesKey: @{ AVVideoAverageBitRateKey: @(bitsPerSecond),
                                                  AVVideoMaxKeyFrameIntervalKey: @(30) } };
}

- (BOOL)setupAssetWriterVideoInput:(CMFormatDescriptionRef)currentFormatDescription
{
    NSDictionary *videoCompressionSettings = [self setupAssetWriterVideoInputSettingsWithFormat:currentFormatDescription
                                                                             forOriginalQuality:YES];

    self.assetWriterVideoInQOrig = [self addAssetWriterVideoInToAssetWriter:self.assetWriterQOrig
                                                               withSettings:videoCompressionSettings
                                                       andFormatDescription:currentFormatDescription];
    if (!self.assetWriterVideoInQOrig) return NO;

    videoCompressionSettings = [self setupAssetWriterVideoInputSettingsWithFormat:currentFormatDescription
                                                                             forOriginalQuality:NO];
    
    self.assetWriterVideoInQLow = [self addAssetWriterVideoInToAssetWriter:self.assetWriterQLow
                                                              withSettings:videoCompressionSettings
                                                      andFormatDescription:currentFormatDescription];
    if (!self.assetWriterVideoInQLow) return NO;
    
    return YES;
}

- (CGFloat)angleOffsetForOrientation:(AVCaptureVideoOrientation)orientation
{
	CGFloat angle = 0.0;
	
	switch (orientation) {
		case AVCaptureVideoOrientationPortrait:
			angle = M_PI_2;
			break;
		case AVCaptureVideoOrientationPortraitUpsideDown:
			angle = -M_PI_2;
			break;
		case AVCaptureVideoOrientationLandscapeRight:
			angle = 0;
			break;
		case AVCaptureVideoOrientationLandscapeLeft:
			angle = M_PI;
			break;
		default:
			break;
	}
    
	return angle;
}

- (CGAffineTransform)setTxTyForTransform:(CGAffineTransform)transform
                          withOrientation:(AVCaptureVideoOrientation)orientation
                                 andSize:(CGSize)size
{
    switch (orientation) {
		case AVCaptureVideoOrientationPortrait:
			transform.tx = size.height;
			break;
		case AVCaptureVideoOrientationPortraitUpsideDown:
			transform.ty = size.width;
			break;
		case AVCaptureVideoOrientationLandscapeLeft:
			transform.tx = size.width;
            transform.ty = size.height;
			break;
		default:
			break;
	}
    return transform;
}

- (CGAffineTransform)transformFromOrientation:(AVCaptureVideoOrientation)orientation
                                      andSize:(CGSize)size
{
	CGFloat orientationAngleOffset = [self angleOffsetForOrientation:orientation];
    CGAffineTransform transform = CGAffineTransformMakeRotation(orientationAngleOffset);
    return [self setTxTyForTransform:transform
                     withOrientation:orientation
                             andSize:size];
}

- (void) startRecording
{
	dispatch_async(self.movieWritingQueue, ^{
		if (self.recordingWillBeStarted || self.recording) return;

        self.framesCount = 0;
		self.recordingWillBeStarted = YES;

		[self.delegate recordingWillStart];

        NSError *error;
        
		[self removeFile:self.outputFileUrlQOrig error:error];
        if (error) {
            [self didFail:error];
            return;
        }
        
        [self removeFile:self.outputFileUrlQLow error:error];
        if (error) {
            [self didFail:error];
            return;
        }

		self.assetWriterQOrig = [[AVAssetWriter alloc] initWithURL:self.outputFileUrlQOrig fileType:(NSString *)kUTTypeQuickTimeMovie error:&error];
		if (error) {
            [self didFail:error];
            return;
        }
        
		self.assetWriterQLow = [[AVAssetWriter alloc] initWithURL:[self outputFileUrlQLow] fileType:(NSString *)kUTTypeQuickTimeMovie error:&error];
		if (error) {
            [self didFail:error];
            return;
        }
	});	
}

- (void) stopRecording
{
	dispatch_async(self.movieWritingQueue, ^{
		if (self.recordingWillBeStopped || (self.recording == NO)) return;
		
		self.recordingWillBeStopped = YES;
		
		[self.delegate recordingWillStop];

        if (self.assetWriterQOrig && ![self.assetWriterQOrig finishWriting]) {
			[self didFail:self.assetWriterQOrig.error];
		}
        
        if (self.assetWriterQLow && ![self.assetWriterQLow finishWriting]) {
            [self didFail:self.assetWriterQLow.error];
		}
        
        self.assetWriterAudioInQOrig = nil;
        self.assetWriterVideoInQOrig = nil;
        self.assetWriterQOrig = nil;
        
        self.assetWriterAudioInQLow = nil;
        self.assetWriterVideoInQLow = nil;
        self.assetWriterQLow = nil;
        
        self.readyToRecordVideo = NO;
        self.readyToRecordAudio = NO;
        
        [self.delegate recordingDidStop];
	});
}

#pragma mark Capture

- (void)displaySampleBuffer:(CMSampleBufferRef)sampleBuffer
      withFormatDescription:(CMFormatDescriptionRef)formatDescription
             fromConnection:(AVCaptureConnection *)connection
{
	if (connection == self.videoConnection) {
		// Get framerate
		CMTime timestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
		[self calculateFramerateAtTimestamp:timestamp];
        
		// Get frame dimensions (for onscreen display)
		if (self.videoDimensions.width == 0 && self.videoDimensions.height == 0)
			self.videoDimensions = CMVideoFormatDescriptionGetDimensions(formatDescription);
		
		// Get buffer type
		if (self.videoType == 0)
			self.videoType = CMFormatDescriptionGetMediaSubType(formatDescription);
        
		// Enqueue it for preview.  This is a shallow queue, so if image processing is taking too long,
		// we'll drop this frame for preview (this keeps preview latency low).
		OSStatus err = CMBufferQueueEnqueue(self.previewBufferQueue, sampleBuffer);
		if (!err) {
			dispatch_async(dispatch_get_main_queue(), ^{
				CMSampleBufferRef sbuf = (CMSampleBufferRef)CMBufferQueueDequeueAndRetain(self.previewBufferQueue);
				if (sbuf) {
					CVImageBufferRef pixBuf = CMSampleBufferGetImageBuffer(sbuf);
					[self.delegate pixelBufferReadyForDisplay:pixBuf];
					CFRelease(sbuf);
				}
			});
		}
	}
}

- (void)recordSampleBuffer:(CMSampleBufferRef)sampleBuffer
     withFormatDescription:(CMFormatDescriptionRef)formatDescription
            fromConnection:(AVCaptureConnection *)connection
{
    CFRetain(sampleBuffer);
    CFRetain(formatDescription);
    
	dispatch_async(self.movieWritingQueue, ^{
		if (self.assetWriterQOrig && self.assetWriterQLow) {
			BOOL wasReadyToRecord = (self.readyToRecordAudio && self.readyToRecordVideo);
			if (connection == self.videoConnection) {
				if (!self.readyToRecordVideo)
					self.readyToRecordVideo = [self setupAssetWriterVideoInput:formatDescription];
				if (self.readyToRecordVideo && self.readyToRecordAudio)
					[self writeSampleBuffer:sampleBuffer ofType:AVMediaTypeVideo];
			}
			else if (connection == self.audioConnection) {
				if (!self.readyToRecordAudio)
					self.readyToRecordAudio = [self setupAssetWriterAudioInput:formatDescription];
				if (self.readyToRecordAudio && self.readyToRecordVideo)
					[self writeSampleBuffer:sampleBuffer ofType:AVMediaTypeAudio];
			}
			
			BOOL isReadyToRecord = (self.readyToRecordAudio && self.readyToRecordVideo);
			if (!wasReadyToRecord && isReadyToRecord) {
				self.recordingWillBeStarted = NO;
				self.recording = YES;
				[self.delegate recordingDidStart];
			}
		}
        
		CFRelease(sampleBuffer);
        CFRelease(formatDescription);
	});

}

- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection
{
    CMFormatDescriptionRef formatDescription = CMSampleBufferGetFormatDescription(sampleBuffer);
    
	[self displaySampleBuffer:sampleBuffer withFormatDescription:formatDescription fromConnection:connection];
    [self recordSampleBuffer:sampleBuffer withFormatDescription:formatDescription fromConnection:connection];
}

- (void)calculateFramerateAtTimestamp:(CMTime) timestamp
{
	[self.previousSecondTimestamps addObject:[NSValue valueWithCMTime:timestamp]];
    
	CMTime oneSecond = CMTimeMake( 1, 1 );
	CMTime oneSecondAgo = CMTimeSubtract( timestamp, oneSecond );
    
	while( CMTIME_COMPARE_INLINE( [[self.previousSecondTimestamps objectAtIndex:0] CMTimeValue], <, oneSecondAgo ) )
		[self.previousSecondTimestamps removeObjectAtIndex:0];
    
	Float64 newRate = (Float64) [self.previousSecondTimestamps count];
	self.videoFrameRate = (self.videoFrameRate + newRate) / 2;
}

- (AVCaptureDevice *)videoDevice
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices)
        if ([device position] == AVCaptureDevicePositionBack)
            return device;
    
    return nil;
}

- (AVCaptureDevice *)audioDevice
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio];
    if ([devices count] > 0)
        return [devices objectAtIndex:0];
    
    return nil;
}

- (void)setupCaptureSession
{
    self.captureSession = [[AVCaptureSession alloc] init];
    
    AVCaptureDeviceInput *audioIn = [[AVCaptureDeviceInput alloc] initWithDevice:[self audioDevice] error:nil];
    if ([self.captureSession canAddInput:audioIn])
        [self.captureSession addInput:audioIn];
	
	AVCaptureAudioDataOutput *audioOut = [[AVCaptureAudioDataOutput alloc] init];
	dispatch_queue_t audioCaptureQueue = dispatch_queue_create("Audio Capture Queue", DISPATCH_QUEUE_SERIAL);
	[audioOut setSampleBufferDelegate:self queue:audioCaptureQueue];
	dispatch_release(audioCaptureQueue);
	if ([self.captureSession canAddOutput:audioOut])
		[self.captureSession addOutput:audioOut];
	self.audioConnection = [audioOut connectionWithMediaType:AVMediaTypeAudio];
    
    AVCaptureDeviceInput *videoIn = [[AVCaptureDeviceInput alloc] initWithDevice:[self videoDevice] error:nil];
    if ([self.captureSession canAddInput:videoIn])
        [self.captureSession addInput:videoIn];
    self.videoInput = videoIn;
    
	AVCaptureVideoDataOutput *videoOut = [[AVCaptureVideoDataOutput alloc] init];
	[videoOut setAlwaysDiscardsLateVideoFrames:NO];
	[videoOut setVideoSettings:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey]];
	dispatch_queue_t videoCaptureQueue = dispatch_queue_create("Video Capture Queue", DISPATCH_QUEUE_SERIAL);
	[videoOut setSampleBufferDelegate:self queue:videoCaptureQueue];
	dispatch_release(videoCaptureQueue);
	if ([self.captureSession canAddOutput:videoOut])
		[self.captureSession addOutput:videoOut];
    
    self.videoConnection = [videoOut connectionWithMediaType:AVMediaTypeVideo];
}

- (void)setupAndStartCaptureSession
{
	// Create a shallow queue for buffers going to the display for preview.
	OSStatus err = CMBufferQueueCreate(kCFAllocatorDefault, 1, CMBufferQueueGetCallbacksForUnsortedSampleBuffers(), &_previewBufferQueue);
	if (err) {
        NSString *errorText = @"Can't create queue for buffers going to the display to preview.";
        [self didFail:[NSError errorWithDomain:NSOSStatusErrorDomain code:err userInfo:@{ NSLocalizedDescriptionKey: errorText }]];
        return;
    }
	
	// Create serial queue for movie writing
	self.movieWritingQueue = dispatch_queue_create("Movie Writing Queue", DISPATCH_QUEUE_SERIAL);
	
    if (!self.captureSession)
		[self setupCaptureSession];
	
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(captureSessionStoppedRunningNotification:)
                                                 name:AVCaptureSessionDidStopRunningNotification
                                               object:self.captureSession];
	
	if (!self.captureSession.isRunning)
		[self.captureSession startRunning];
}

- (void)pauseCaptureSession
{
	if (self.captureSession.isRunning)
		[self.captureSession stopRunning];
}

- (void)resumeCaptureSession
{
	if (!self.captureSession.isRunning)
		[self.captureSession startRunning];
}

- (void)captureSessionStoppedRunningNotification:(NSNotification *)notification
{
    if ([self isRecording]) {
        [self stopRecording];
    }
}

- (void)stopAndTearDownCaptureSession
{
    [self.captureSession stopRunning];
	if (self.captureSession)
		[[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:AVCaptureSessionDidStopRunningNotification
                                                      object:self.captureSession];
	self.captureSession = nil;
	if (self.previewBufferQueue) {
		CFRelease(self.previewBufferQueue);
		self.previewBufferQueue = NULL;	
	}
	if (self.movieWritingQueue) {
		dispatch_release(self.movieWritingQueue);
		self.movieWritingQueue = NULL;
	}
}

// Perform an auto focus at the specified point. The focus mode will automatically change to locked once the auto focus is complete.
- (void)autoFocusAtPoint:(CGPoint)point
{
    AVCaptureDevice *device = [self.videoInput device];
    if ([device isFocusPointOfInterestSupported] && [device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            [device setFocusPointOfInterest:point];
            [device setFocusMode:AVCaptureFocusModeAutoFocus];
            [device unlockForConfiguration];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }
}

// Switch to continuous auto focus mode at the specified point
- (void)continuousFocusAtPoint:(CGPoint)point
{
    AVCaptureDevice *device = [self.videoInput device];
    if ([device isFocusPointOfInterestSupported] && [device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
		NSError *error;
		if ([device lockForConfiguration:&error]) {
			[device setFocusPointOfInterest:point];
			[device setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
			[device unlockForConfiguration];
		} else {
			NSLog(@"%@", error.localizedDescription);
		}
	}
}

@end
