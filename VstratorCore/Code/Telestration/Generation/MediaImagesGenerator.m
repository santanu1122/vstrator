//
//  MediaImagesGenerator
//  VstratorCore
//
//  Created by akupr on 05.10.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "MediaImagesGenerator.h"

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
#import "MemoryProfiling.h"

#import <AVFoundation/AVFoundation.h>

static const int NumberOfQueues = 4;

@interface MediaImagesGenerator()

@property (atomic) BOOL stopRequested;

@end

#pragma mark -

@implementation MediaImagesGenerator

-(void)stop
{
    self.stopRequested = YES;
}

-(void)generateImagesWithMediaURL:(NSURL*)url inFolder:(NSString*)folder callback:(void(^)(BOOL compleeted, NSError* error))callback
{
    NSLog(@"started processing video with url '%@'", url);
    
    dispatch_queue_t queue = dispatch_queue_create("Writing images queue", 0);
    dispatch_async(queue, ^{
        @autoreleasepool {
            AVURLAsset* asset = [AVURLAsset assetWithURL:url];
            if (!asset) {
                callback(NO, [NSError errorWithText:[NSString stringWithFormat:@"Cannot read video with URL: %@", url]]);
                return;
            }
            AVAssetTrack* track = [[asset tracksWithMediaType:AVMediaTypeVideo] lastObject];
            if (!track) {
                callback(NO, [NSError errorWithText:@"Asset does not contain video track"]);
                return;
            }

            UIImageOrientation orientation = [self orientationFromTransform:track.preferredTransform];
            
            //reader
            __block NSError* error = nil;
            AVAssetReader* reader = [[AVAssetReader alloc] initWithAsset:asset error:&error];
            if (!reader || error) {
                callback(NO, [NSError errorWithText:[NSString stringWithFormat:@"Cannot read original clip. Error: %@", error]]);
                return;
            }
            
            // trackOutput
            NSDictionary* outputSettings = @{(NSString*) kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_32BGRA)};
            AVAssetReaderTrackOutput* trackOutput = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:track outputSettings:outputSettings];
            [reader addOutput:trackOutput];
            
            // start
            if (![reader startReading]) {
                callback(NO, [NSError errorWithText:@"Cannot read original clip"]);
                return;
            }
            
            NSFileManager* manager = [NSFileManager defaultManager];
            [manager createDirectoryAtPath:folder withIntermediateDirectories:YES attributes:nil error:&error];
            if (error) {
                callback(NO, [NSError errorWithText:[NSString stringWithFormat:@"Cannot create folder '%@'. Error: %@", folder, error]]);
                return;
            }
            

            int framesCount = 0;
            
            NSLog(@"%@: image generation is starting", NSStringFromClass(self.class));
            
            dispatch_group_t framingGroup = dispatch_group_create();
            dispatch_semaphore_t ds = dispatch_semaphore_create(NumberOfQueues);

            while (reader.status == AVAssetReaderStatusReading && !error) @autoreleasepool {
                
                if (self.stopRequested) break;
                
                logMemUsage();
                
                CMSampleBufferRef buffer = [trackOutput copyNextSampleBuffer];
                if (buffer) {

                    UIImage *image = [self imageFromBuffer:CMSampleBufferGetImageBuffer(buffer) orientation:orientation];

                    NSInteger index = ++framesCount;
                    dispatch_queue_t framingQueue = dispatch_queue_create(NULL, 0);
                    dispatch_group_async(framingGroup, framingQueue, ^{
                        if (!error) {
                            [self writeImage:image index:index folder:folder error:&error];
                        }
                        dispatch_semaphore_signal(ds);
                    });
                    dispatch_release(framingQueue);
                    dispatch_semaphore_wait(ds, DISPATCH_TIME_FOREVER);
                    
                    CMSampleBufferInvalidate(buffer);
                    CFRelease(buffer);
                }
            }
            
            dispatch_group_wait(framingGroup, DISPATCH_TIME_FOREVER);
            dispatch_release(framingGroup);
            dispatch_release(ds);

            if (reader.status == AVAssetReaderStatusCompleted && !error) {
                NSLog(@"%@: image generation has completed. Frames count: %d", NSStringFromClass(self.class), framesCount);
            } else {
                NSLog(@"%@: image generation failed with error %@, Frames count: %d", NSStringFromClass(self.class), error.localizedDescription, framesCount);
            }
            callback(reader.status == AVAssetReaderStatusCompleted && !error, error);
        }
    });
    dispatch_release(queue);
}

-(BOOL)writeImage:(UIImage*)image index:(int)index folder:(NSString*)folder error:(NSError**)error
{
    NSError *fileError = nil;
    NSData* data = UIImageJPEGRepresentation(image, VstratorConstants.ClipFrameJPEGQuality);
    [data writeToFile:[folder stringByAppendingPathComponent:[NSString stringWithFormat:@"%d.jpg", index]] options:NSDataWritingAtomic error:&fileError];
    if (fileError != nil)
        NSLog(@"frame: %d, error: %@", index, fileError.localizedDescription);
    *error = fileError;
    return !*error;
}

-(UIImage*)imageFromBuffer:(CVImageBufferRef)pixelBuffer orientation:(UIImageOrientation)orientation
{
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);

    uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddress(pixelBuffer);
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer);
    size_t width = CVPixelBufferGetWidth(pixelBuffer);
    size_t height = CVPixelBufferGetHeight(pixelBuffer);
    
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);

    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    CGContextRef contextRef = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpaceRef, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    CGImageRef imageRef = CGBitmapContextCreateImage(contextRef);

    UIImage *image;
    if (width <= VstratorConstants.PlaybackQualityVideoSize.width && height <= VstratorConstants.PlaybackQualityVideoSize.height) {
        image = [UIImage imageWithCGImage:imageRef scale:1.0 orientation:orientation];
    } else {
        CGSize size = [self resizeImageRefSize:CGSizeMake(width, height) maxSize:VstratorConstants.PlaybackQualityVideoSize];
        image = [self imageFromImageRef:imageRef withSize:size orientation:orientation];
    }
    CGImageRelease(imageRef);
    CGContextRelease(contextRef);
    CGColorSpaceRelease(colorSpaceRef);
    return image;
}

-(CGSize)resizeImageRefSize:(CGSize)size maxSize:(CGSize)maxSize
{
    if (size.width < size.height) {
        maxSize = CGSizeMake(maxSize.height, maxSize.width);
    }
    CGFloat scale = fmaxf(size.width / maxSize.width, size.height / maxSize.height);
    return CGSizeMake(roundf(size.width / scale), roundf(size.height / scale));
}

-(UIImage*)imageFromImageRef:(CGImageRef)imageRef withSize:(CGSize)size orientation:(UIInterfaceOrientation)orientation
{
    CGContextRef bitmap = CGBitmapContextCreate(NULL,
                                                size.width,
                                                size.height,
                                                CGImageGetBitsPerComponent(imageRef),
                                                4 * size.width,
                                                CGImageGetColorSpace(imageRef),
                                                CGImageGetBitmapInfo(imageRef));
    CGContextDrawImage(bitmap, CGRectMake(0, 0, size.width, size.height), imageRef);
    CGImageRef ref = CGBitmapContextCreateImage(bitmap);
    
    UIImage* image = [UIImage imageWithCGImage:ref scale:1.0 orientation:orientation];
    
    CGContextRelease(bitmap);
    CGImageRelease(ref);
    
    return image;
}

-(UIImageOrientation)orientationFromTransform:(CGAffineTransform)transform
{
    if (transform.b == -1 && transform.c == 1) return UIImageOrientationLeft;
    if (transform.b == 1 && transform.c == -1) return UIImageOrientationRight;
    if (transform.a == 1 && transform.d == 1) return UIImageOrientationUp;
    if (transform.a == -1 && transform.d == -1) return UIImageOrientationDown;
    return UIImageOrientationUp;
}

@end
