//
//  FrameTransform.m
//  VstratorCore
//
//  Created by Admin on 01/02/2013.
//  Copyright (c) 2013 OnTarget. All rights reserved.
//

#import "FrameTransform.h"

@implementation FrameTransform

- (id)copyWithZone:(NSZone *)zone
{
    FrameTransform *frameTransform = [[FrameTransform alloc] init];
    frameTransform.transform = self.transform;
    frameTransform.contentOffset = self.contentOffset;
    frameTransform.zoomScale = self.zoomScale;
    return frameTransform;
}

- (BOOL)isEqual:(id)object
{
    if (![object isMemberOfClass:FrameTransform.class]) return NO;
    FrameTransform *frameTransform = (FrameTransform *)object;
    return [NSStringFromCGAffineTransform(self.transform) isEqualToString:NSStringFromCGAffineTransform(frameTransform.transform)] &&
           [NSStringFromCGPoint(self.contentOffset) isEqualToString:NSStringFromCGPoint(frameTransform.contentOffset)] &&
           self.zoomScale == frameTransform.zoomScale;
}

+ (FrameTransform *)frameTransformWith:(CGAffineTransform)transform
                         contentOffset:(CGPoint)contentOffset
                             zoomScale:(float)zoomScale
{
    FrameTransform *frameTransform = [[FrameTransform alloc] init];
    frameTransform.transform = transform;
    frameTransform.contentOffset = contentOffset;
    frameTransform.zoomScale = zoomScale;
    return frameTransform;
}

@end
