//
//  FrameTransform.h
//  VstratorCore
//
//  Created by Admin on 01/02/2013.
//  Copyright (c) 2013 OnTarget. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FrameTransform : NSObject <NSCopying>

@property (nonatomic) CGAffineTransform transform;
@property (nonatomic) CGPoint contentOffset;
@property (nonatomic) float zoomScale;

+ (FrameTransform *)frameTransformWith:(CGAffineTransform)transform
                         contentOffset:(CGPoint)contentOffset
                             zoomScale:(float)zoomScale;

@end
