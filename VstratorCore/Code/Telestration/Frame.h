//
//  Frame.h
//  VstratorCore
//
//  Created by Admin on 01/02/2013.
//  Copyright (c) 2013 OnTarget. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FrameTransform;

@interface Frame : NSObject

@property (nonatomic) int frameNumber;
@property (nonatomic) int frameNumber2;
@property (nonatomic) NSTimeInterval time;
@property (nonatomic) int timeInMS;
@property (nonatomic) FrameTransform *frameTransform;
@property (nonatomic) FrameTransform *frameTransform2;

@end
