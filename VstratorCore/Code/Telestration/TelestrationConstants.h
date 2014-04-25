//
//  TelestrationConstants
//  VstratorCore
//
//  Created by Virtualler on 05.08.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

typedef enum {
    TelestrationShapeFreehand = 0,
    TelestrationShapeRectangle = 1,
    TelestrationShapeCircle = 2,
    TelestrationShapeLine = 3,
    TelestrationShapeArrow = 4
} TelestrationShapes;

@interface TelestrationConstants : NSObject

+ (NSTimeInterval)maxRecordDuration;
+ (double)framesPerSecond;
+ (CMTime)frameDurationForFrameRate:(float)frameRate;
+ (NSTimeInterval)frameDurationInSecsForFrameRate:(float)frameRate;
+ (NSTimeInterval)recordingFrameDurationInSecs;
+ (NSInteger)frameNumberByTime:(NSTimeInterval)time forFrameRate:(float)frameRate;
+ (CMTime)frameTimeByNumber:(int)frameNumber forFrameRate:(float)frameRate;

@end
