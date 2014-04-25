//
//  TelestrationConstants
//  VstratorCore
//
//  Created by Virtualler on 05.08.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "TelestrationConstants.h"
#import "VstratorConstants.h"

@implementation TelestrationConstants

+ (NSTimeInterval)maxRecordDuration
{
    return 120.0;
}

+ (double)framesPerSecond
{
    return 30.0;
}

+ (CMTime)frameDurationForFrameRate:(float)frameRate
{
    return CMTimeMakeWithSeconds(1.0 / frameRate, NSEC_PER_SEC);
}

+ (NSTimeInterval)frameDurationInSecsForFrameRate:(float)frameRate
{
    return CMTimeGetSeconds([TelestrationConstants frameDurationForFrameRate:frameRate]);
}

+ (NSTimeInterval)recordingFrameDurationInSecs
{
    return CMTimeGetSeconds([TelestrationConstants frameDurationForFrameRate:30]);
}

+ (NSInteger)frameNumberByTime:(NSTimeInterval)time forFrameRate:(float)frameRate
{
    //TODO: round here?
    //NSLog(@"frameNumberByTime: %f %f => round %f", time, time / TelestrationConstants.frameDurationInSecs, time < 1e-3 ? 0 : round(time / TelestrationConstants.frameDurationInSecs));
    return time < 1e-3 ? 0 : round(time / [TelestrationConstants frameDurationInSecsForFrameRate:frameRate]);
}

+ (CMTime)frameTimeByNumber:(int)frameNumber forFrameRate:(float)frameRate
{
    return CMTimeMultiply([TelestrationConstants frameDurationForFrameRate:frameRate], frameNumber);
}

@end
