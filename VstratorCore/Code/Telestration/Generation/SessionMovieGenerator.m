//
//  SessionMovieGenerator.m
//  VstratorCore
//
//  Created by akupr on 05.10.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "SessionMovieGenerator.h"

#import "AVAsset+Extensions.h"
#import "Clip+Extensions.h"
#import "LayoutInfo.h"
#import "MarkupData.h"
#import "MarkupDataCollection.h"
#import "NSError+Extensions.h"
#import "Session+Extensions.h"
#import "StrokeInfo.h"
#import "TelestrationConstants.h"
#import "VstratorConstants.h"
#import "StrokeInfo.h"
#import "LayoutInfo.h"
#import "NSError+Extensions.h"
#import "AVAsset+Extensions.h"
#import "MemoryProfiling.h"

#import <AVFoundation/AVFoundation.h>

static const CGFloat DefaultWidth = 640;
static const CGFloat DefaultHeight = 360;

@interface SessionMovieGenerator()

@property (nonatomic, strong, readonly) NSString* folderName;
@property (nonatomic, strong, readonly) NSURL* outputURL;

@end

@implementation SessionMovieGenerator

#pragma mark - Properties

@synthesize session = _session;

-(void)setSession:(Session *)session
{
    if (_session != session) {
        _session = session;
        _outputURL = [NSURL URLWithString:session.url];
    }
}

#pragma mark - Init

-(id)init
{
    self = [super init];
    if (self) {
        _width = DefaultWidth;
        _height = DefaultHeight;
        _folderName = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/temp"];
//        const char* temp = tempnam([NSTemporaryDirectory() UTF8String], NULL);
//        _folderName = [NSString stringWithCString:temp encoding:NSUTF8StringEncoding];
//        free((void*)temp);
    }
    return self;
}

-(id)initWithSession:(Session *)session
{
    self = [self init];
    if (self) {
        self.session = session;
        _folderName = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@", session.originalClip.identity]];
    }
    return self;
}

//-(void)dealloc
//{
//    // Cleanup
//    NSString* folderName = self.folderName;
//    dispatch_queue_t queue = dispatch_queue_create("Cleanup queue", 0);
//    dispatch_async(queue, ^{
//        [[NSFileManager defaultManager] removeItemAtPath:folderName error:nil];
//    });
//    dispatch_release(queue);
//}

+(SessionMovieGenerator *)generatorWithSession:(Session *)session
{
    return [[SessionMovieGenerator alloc] initWithSession:session];
}

#pragma mark - Generation

-(void)generateAsync:(ErrorCallback)callback
{
    [self generateMediaImagesAsync:^(NSError *error) {
//        if (error) {
            if (callback) callback(error);
//        } else {
//            [self generateSessionVideoAsync:callback];
//        }
    }];
}

-(void)generateSessionVideoAsync:(ErrorCallback)callback
{
    NSLog(@"Start writing video with url '%@'", self.outputURL);

    [[NSFileManager defaultManager] removeItemAtURL:self.outputURL error:nil];

    NSError *error = nil;
    AVAssetWriter *videoWriter = [AVAssetWriter assetWriterWithURL:self.outputURL fileType:AVFileTypeQuickTimeMovie error:&error];
    if (error) {
        if (callback) callback(error);
        return;
    }
    
    NSDictionary *videoSettings = @{AVVideoCodecKey: AVVideoCodecH264,
                                   AVVideoWidthKey:@((int)self.width),
                                   AVVideoHeightKey:@((int)self.height)};
    AVAssetWriterInput* writerInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:videoSettings];
    if (!writerInput) {
        if (callback) callback([NSError errorWithText:@"Cannot write the video"]);
        return;
    }
    AVAssetWriterInputPixelBufferAdaptor *adaptor = [AVAssetWriterInputPixelBufferAdaptor
                                                     assetWriterInputPixelBufferAdaptorWithAssetWriterInput:writerInput
                                                     sourcePixelBufferAttributes:nil];
    if (!adaptor || ![videoWriter canAddInput:writerInput]) {
        if (callback) callback([NSError errorWithText:@"Cannot write the video"]);
        return;
    }

    [videoWriter addInput:writerInput];
    
    // add audio
    AVURLAsset* audioAsset = [AVURLAsset assetWithURL:self.session.audioFileURL];
    AVAssetReader* audioReader = [AVAssetReader assetReaderWithAsset:audioAsset error:&error];
    if (error) {
        if (callback) callback(error);
        return;
    }

    AVAssetReaderTrackOutput* audioReaderTrackOutput =
    [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:[[audioAsset tracksWithMediaType:AVMediaTypeAudio] lastObject]
                                               outputSettings:nil];
    [audioReader addOutput:audioReaderTrackOutput];
    AVAssetWriterInput* audioWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio outputSettings:nil];
    audioWriterInput.expectsMediaDataInRealTime = NO;
    [videoWriter addInput:audioWriterInput];
    [audioReader startReading];
    
    // start session
    [videoWriter startWriting];
    [videoWriter startSessionAtSourceTime:kCMTimeZero];
    
    
    MarkupDataCollection* collection = [[MarkupDataCollection alloc] initWithSession:self.session error:&error];
    if (error) {
        if (callback) callback(error);
        return;
    }
    
    __block int currentFrameIndex = -1;
    for (int i = currentFrameIndex + 1; i < collection.markup.count; ++i) {
        MarkupData* data = collection.markup[i];
        if (data.dataFormat == MarkupDataFormatFrame) {
            currentFrameIndex = i;
            break;
        }
    }
    
    NSTimeInterval duration = self.session.duration.doubleValue;
    __block int count = 0;
    
    dispatch_queue_t queue = dispatch_queue_create("Media Input Queue", 0);
    [writerInput requestMediaDataWhenReadyOnQueue:queue usingBlock:^{
        
        while (writerInput.isReadyForMoreMediaData) @autoreleasepool {
            // Calc current time
            CMTime presentTime = CMTimeMake(count++, TelestrationConstants.framesPerSecond);
            
            if (CMTimeGetSeconds(presentTime) > duration) {
                [writerInput markAsFinished];
                CVPixelBufferPoolRelease(adaptor.pixelBufferPool);
                break;
            }
            
            // Find the frame
            for (int i = currentFrameIndex + 1; i < collection.markup.count; ++i) {
                MarkupData* data = collection.markup[i];
                if (data.dataFormat == MarkupDataFormatFrame) {
                    if (data.actionTime > CMTimeGetSeconds(presentTime)) break;
                    currentFrameIndex = i;
                }
            }
            if (currentFrameIndex == -1) {
                [videoWriter cancelWriting];
                if (callback) callback([NSError errorWithText:@"The markup has no frames"]);
                break;
            }
            
            MarkupData* frame = collection.markup[currentFrameIndex];
            // Determine the image file name
            //NOTE: rewritten using the assumption that frame rate equals to TelestrationConstants.framesPerSecond
            //CMTime frameTime = [TelestrationConstants frameTimeByNumber:frame.showFrame-1];
            //frameTime = CMTimeConvertScale(frameTime, TelestrationConstants.framesPerSecond, kCMTimeRoundingMethod_Default);
            //int index = (int) frameTime.value + 1;
            //NSString* fileName = [self.folderName stringByAppendingPathComponent:[NSString stringWithFormat:@"%d.jpg", index]];
            NSString* fileName = [self.folderName stringByAppendingPathComponent:[NSString stringWithFormat:@"%d.jpg", frame.showFrame]];
            
            if (![[NSFileManager defaultManager] fileExistsAtPath:fileName]) {
                [videoWriter cancelWriting];
                if (callback) callback([NSError errorWithText:@"Cannot find the image file for the current frame"]);
                break;
            }
        
            UIImage* inputImage = [UIImage imageWithContentsOfFile:fileName];
            if (!inputImage) {
                [videoWriter cancelWriting];
                if (callback) callback([NSError errorWithText:@"Cannot get the image for the current frame"]);
                break;
            }
            
            //NSLog(@"%d frame, %d image processing", count, index);
            UIImage* outputImage = [self imageWithImage:(UIImage*)inputImage markup:collection.markup frame:frame];
            
            // Add the new frame to writer
            NSError* pixelBufferError = nil;
            CVPixelBufferRef buffer = [self newPixelBufferFromCGImage:[outputImage CGImage] frameSize:outputImage.size error:&pixelBufferError];
            if (pixelBufferError) {
                [videoWriter cancelWriting];
                if (callback) callback(pixelBufferError);
                return;
            }
            [adaptor appendPixelBuffer:buffer withPresentationTime:presentTime];
            CVBufferRelease(buffer);
        }
    }];
    
    [audioWriterInput requestMediaDataWhenReadyOnQueue:queue usingBlock:^{
        while (audioWriterInput.readyForMoreMediaData) {
            CMSampleBufferRef buffer = nil;
            if (audioReader.status == AVAssetReaderStatusReading && (buffer = [audioReaderTrackOutput copyNextSampleBuffer])) {
                BOOL result = [audioWriterInput appendSampleBuffer:buffer];
                CMSampleBufferInvalidate(buffer);
                CFRelease(buffer);
                if (!result) [audioReader cancelReading];
            } else {
                [audioWriterInput markAsFinished];
                switch (audioReader.status) {
                    case AVAssetReaderStatusReading:
                        // the reader has more for other tracks, even if this one is done
                        break;
                    case AVAssetReaderStatusCompleted:
                        NSLog(@"Stop writing video");
                        [videoWriter finishWriting];
                        if (callback) callback(nil);
                        break;
                    case AVAssetReaderStatusCancelled:
                    case AVAssetReaderStatusFailed:
                        [videoWriter cancelWriting];
                        if (callback) callback([NSError errorWithText:@"Cannot read the audio file"]);
                        break;
                }
                break;
            }
        }
    }];
    dispatch_release(queue);
}

-(UIImage*)imageWithImage:(UIImage*)inputImage markup:(NSArray*)markup frame:(MarkupData*)frame
{
    UIGraphicsBeginImageContext(CGSizeMake(self.width, self.height));
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    UIGraphicsPushContext(context);
    
    [inputImage drawInRect:CGRectMake(0, 0, self.width, self.height)];
    
    CGFloat tx = (CGFloat)self.width / frame.primaryLayout.width;
    CGFloat ty = (CGFloat)self.height / frame.primaryLayout.height;
    
    CGContextScaleCTM(context, tx, ty);
    CGContextSetLineWidth(context, 3.f / tx);
    
    for (MarkupData* data in markup) {
        if (data.dataFormat != MarkupDataFormatXaml) continue;
        if (data.inFrame > frame.showFrame) continue;
        if (data.outFrame != -1 && data.outFrame < frame.showFrame) continue;
        CGContextSetStrokeColorWithColor(context, data.strokeObject.color.CGColor);
        //CGContextSetLineWidth(context, 3.f / tx);
        // Draw the shape
        if (data.drawingToolMode == ToolModeFreeHand) {
            BOOL first = YES;
            for (NSDictionary* point in data.strokeObject.points) {
                CGFloat x = [point[@"X"] floatValue];
                CGFloat y = [point[@"Y"] floatValue];
                if (first) {
                    CGContextMoveToPoint(context, x, y);
                    first = NO;
                } else {
                    CGContextAddCurveToPoint(context, x, y, x, y, x, y);
                }
            }
        } else {
            int secondPointIndex = data.drawingToolMode == ToolModeLine ? 1 : 2;
            NSDictionary* p = (data.strokeObject.points)[0];
            NSDictionary* p1 = (data.strokeObject.points)[secondPointIndex];
            CGPoint start = CGPointMake([p[@"X"] floatValue], [p[@"Y"] floatValue]);
            CGPoint end = CGPointMake([p1[@"X"] floatValue], [p1[@"Y"] floatValue]);
            switch (data.drawingToolMode) {
                case ToolModeEllipse:
                    CGContextAddEllipseInRect(context, CGRectMake(start.x, start.y, end.x, end.y));
                    break;
                case ToolModeLine:
                    CGContextMoveToPoint(context, start.x, start.y);
                    CGContextAddLineToPoint(context, end.x, end.y);
                    break;
                case ToolModeRectangle:
                    //CGContextSetLineWidth(context, 6.f / tx);
                    CGContextAddRect(context, CGRectMake(start.x, start.y, end.x, end.y));
                    break;
                default:
                    break;
            }
        }
        CGContextStrokePath(context);
    }
    UIGraphicsPopContext();
    UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return outputImage;
}

#pragma mark - Generating images

-(CVPixelBufferRef)newPixelBufferFromCGImage:(CGImageRef)image frameSize:(CGSize)frameSize error:(NSError**)error
{
    NSDictionary *options = @{(id)kCVPixelBufferCGImageCompatibilityKey: @YES,
                             (id)kCVPixelBufferCGBitmapContextCompatibilityKey: @YES};
    CVPixelBufferRef pxbuffer = NULL;
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault, frameSize.width, frameSize.height,
                                          kCVPixelFormatType_32ARGB, (__bridge CFDictionaryRef) options, &pxbuffer);
    
    if (status != kCVReturnSuccess || !pxbuffer) {
        *error = [NSError errorWithText:@"Cannot create pixel buffer"];
        return pxbuffer;
    }
    
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    if (!pxdata) {
        CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
        CVBufferRelease(pxbuffer);
        *error = [NSError errorWithText:@"Cannot get base address of the pixel buffer"];
        return NULL;
    }
    
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pxdata, frameSize.width,
                                                 frameSize.height, 8, 4*frameSize.width, rgbColorSpace,
                                                 kCGImageAlphaNoneSkipFirst);
    if (!context) {
        *error = [NSError errorWithText:@"Cannot create graphics context for image drawing"];
        CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
        CVBufferRelease(pxbuffer);
        return NULL;
    }
    CGContextConcatCTM(context, CGAffineTransformIdentity);
    CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(image), CGImageGetHeight(image)), image);
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    
    return pxbuffer;
}

-(void)generateMediaImagesAsync:(ErrorCallback)callback
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.folderName isDirectory:nil]) {
        if (callback) callback(nil);
        return;
    }

    Clip* clip = self.session.originalClip;
    if (!clip) {
        if (callback) callback([NSError errorWithText:@"No original clip exists"]);
        return;
    }
    NSURL* url = clip.existsPlaybackQuality ? [NSURL fileURLWithPath:clip.pathForPlaybackQuality] : [NSURL URLWithString:clip.url];
    [self.class generateImagesByMediaURL:url inFolder:self.folderName callback:callback];
}

+(void)generateImagesByMediaURL:(NSURL*)url inFolder:(NSString*)folder callback:(ErrorCallback)callback
{
    NSLog(@"started processing video with url '%@'", url);
    
    dispatch_queue_t queue = dispatch_queue_create("Writing images queue", 0);
    dispatch_async(queue, ^{
        @autoreleasepool {
        AVURLAsset* asset = [AVURLAsset assetWithURL:url];
        if (!asset) {
            if (callback) callback([NSError errorWithText:[NSString stringWithFormat:@"Cannot read video with URL: %@", url]]);
            return;
        }
        UIImageOrientation orientation = [self convertOrientation:[asset orientation]];
        
        AVAssetTrack* track = [[asset tracksWithMediaType:AVMediaTypeVideo] lastObject];
        if (!track) {
            if (callback) callback([NSError errorWithText:@"Asset does not contain video track"]);
            return;
        }
        
        //reader
        NSError* error = nil;
        AVAssetReader* reader = [[AVAssetReader alloc] initWithAsset:asset error:&error];
        if (!reader || error) {
            if (callback) callback([NSError errorWithText:@"Cannot read original clip"]);
            return;
        }
        
        // trackOutput
        NSDictionary* outputSettings = @{(NSString*) kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_32BGRA)};
        AVAssetReaderTrackOutput* trackOutput = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:track outputSettings:outputSettings];
        // add to reader
        [reader addOutput:trackOutput];
        
        // start
        if (![reader startReading]) {
            if (callback) callback([NSError errorWithText:@"Cannot read original clip"]);
            return;
        }
        
        NSFileManager* manager = [NSFileManager defaultManager];
        [manager createDirectoryAtPath:folder withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) {
            if (callback) callback([NSError errorWithText:[NSString stringWithFormat:@"Cannot create folder '%@'. Error: %@", folder, error]]);
            return;
        }
        
        int count = 0;
        long size = 0;
//        bool printSizes = YES;
        while (reader.status == AVAssetReaderStatusReading) @autoreleasepool {
            
            logMemUsage();
            
            CMSampleBufferRef buffer = [trackOutput copyNextSampleBuffer];
            if (buffer) {
                CVImageBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(buffer);
                CVPixelBufferLockBaseAddress(pixelBuffer,0);
                // Get information about the image
                uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddress(pixelBuffer);
                size_t bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer);
                size_t width = CVPixelBufferGetWidth(pixelBuffer);
                size_t height = CVPixelBufferGetHeight(pixelBuffer);
                
//                if (printSizes) {
//                    NSLog(@"Display Frame : %zu %zu %zu", width, height, bytesPerRow);
//                    printSizes = NO;
//                }
                
                // We unlock the image buffer
                CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
                
                // Create a CGImageRef from the CVImageBufferRef
                CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
                CGContextRef newContext = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
                CGImageRef newImage = CGBitmapContextCreateImage(newContext);
                
                UIImage *image= [UIImage imageWithCGImage:newImage scale:1.0 orientation:orientation];
                NSData* data = UIImageJPEGRepresentation(image, VstratorConstants.ClipFrameJPEGQuality);
                [data writeToFile:[folder stringByAppendingPathComponent:[NSString stringWithFormat:@"%d.jpg", ++count]] atomically:YES];
                size += data.length;
                
                CGImageRelease(newImage);
                CGContextRelease(newContext);
                CGColorSpaceRelease(colorSpace);
                
                CMSampleBufferInvalidate(buffer);
                CFRelease(buffer);
            }
        }
        NSLog(@"stop");
        NSLog(@"%d frames. %ld size", count, size);
        if (callback) callback(nil);
    }
    });
    dispatch_release(queue);
}

+(UIImageOrientation)convertOrientation:(UIInterfaceOrientation)orientation
{
    switch (orientation) {
        case UIInterfaceOrientationPortrait:
            return UIImageOrientationRight;
        case UIInterfaceOrientationPortraitUpsideDown:
            return UIImageOrientationLeft;
        case UIInterfaceOrientationLandscapeRight:
            return UIImageOrientationDown;
        default:
        case UIInterfaceOrientationLandscapeLeft:
            return UIImageOrientationUp;
    }
}

@end
