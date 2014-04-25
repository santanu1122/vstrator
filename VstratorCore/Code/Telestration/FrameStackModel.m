//
//  FrameStackModel.m
//  VstratorApp
//
//  Created by user on 12.03.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "Frame.h"
#import "FrameStackModel.h"
#import "NSMutableArray+Stack.h"

@implementation FrameStackModel

-(id) copy
{
    FrameStackModel *model = [[FrameStackModel alloc] init];
    [model load:[self createExport]];
    model.index = self.index;
    model.reverseIndex = self.reverseIndex;
    return model;
}

- (void)addFrameWithTime:(NSTimeInterval)time
             frameNumber:(int)frameNumber
          frameTransform:(FrameTransform *)frameTransform
{
    [self addFrameWithTime:time
               frameNumber:frameNumber
              frameNumber2:-1
     frameTransform:frameTransform
           frameTransform2:nil];
}

- (void)addFrameWithTime:(NSTimeInterval)time
             frameNumber:(int)frameNumber
            frameNumber2:(int)frameNumber2
          frameTransform:(FrameTransform *)frameTransform
         frameTransform2:(FrameTransform *)frameTransform2
{
    Frame *f = [[Frame alloc] init];
    f.frameNumber = frameNumber;
    f.frameNumber2 = frameNumber2;
    f.time = time;
    f.frameTransform = [frameTransform copy];
    f.frameTransform2 = [frameTransform2 copy];
    [self.stack push:f];
}

-(void) clearAll
{
    [self.stack removeAllObjects];
}

-(NSArray*) createExport
{
    NSMutableArray *set = [[NSMutableArray alloc] init];
    for (Frame *f in self.stack) {
        NSDictionary *dict = @{ @"index": @(f.frameNumber),
                                @"index1": @(f.frameNumber2),
                                @"time": @(f.timeInMS),
                                @"transform": [self createFrameTrasformExport:f.frameTransform],
                                @"transform1": [self createFrameTrasformExport:f.frameTransform2] };
        [set addObject:dict];
    }
    return [NSArray arrayWithArray:set];
}

- (NSDictionary *)createFrameTrasformExport:(FrameTransform *)frameTransform
{
    return @{ @"transform": NSStringFromCGAffineTransform(frameTransform.transform),
              @"contentOffset": NSStringFromCGPoint(frameTransform.contentOffset),
              @"zoomScale": @(frameTransform.zoomScale) };
}

-(void) load:(NSArray *)frames
{
    for (NSDictionary *f in frames) {
        Frame *frame = [[Frame alloc] init];
        frame.frameNumber = [f[@"index"] intValue];
        if (f[@"index1"]) frame.frameNumber2 = [f[@"index1"] intValue];
        frame.timeInMS = [f[@"time"] intValue];
        if (f[@"transform"]) frame.frameTransform = [self loadFrameTransform:f[@"transform"]];
        if (f[@"transform1"]) frame.frameTransform2 = [self loadFrameTransform:f[@"transform1"]];
        [self.stack push:frame];
    }
}

- (FrameTransform *)loadFrameTransform:(NSDictionary *)dict
{
    FrameTransform *frameTransform = [[FrameTransform alloc] init];
    frameTransform.transform = CGAffineTransformFromString(dict[@"transform"]);
    frameTransform.contentOffset = CGPointFromString(dict[@"contentOffset"]);
    frameTransform.zoomScale = [dict[@"zoomScale"] floatValue];
    return frameTransform;
}

@end
