//
//  AVAsset+Extensions.m
//  VstratorCore
//
//  Created by akupr on 15.10.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "AVAsset+Extensions.h"

@implementation AVAsset (Extensions)

-(UIInterfaceOrientation)assetOrientation
{
    AVAssetTrack *videoTrack = [[self tracksWithMediaType:AVMediaTypeVideo] lastObject];
    double rotation = [self rotationFromTransform:[videoTrack preferredTransform]];
    return [self rotation2orientation:rotation];
}

-(double)rotationFromTransform:(CGAffineTransform)transform
{
    return atan2(transform.b, transform.a) * 180 / M_PI;
}

-(UIInterfaceOrientation)rotation2orientation:(double)rotation
{
    switch ((int)rotation) {
        case 90:
            return UIInterfaceOrientationPortrait;
        case -90:
            return UIInterfaceOrientationPortraitUpsideDown;
        case 180:
            return UIInterfaceOrientationLandscapeRight;
        default:
            return UIInterfaceOrientationLandscapeLeft;
    }
}

@end
