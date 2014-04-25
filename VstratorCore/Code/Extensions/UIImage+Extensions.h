//
//  UIImage+Extensions.h
//  VstratorApp
//
//  Created by Oleg Bragin on 03.07.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIImage (Extensions)

+(UIImage*)imageWithImage:(UIImage *)image croppedWithRect:(CGRect)newRect;
+(UIImage*)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;

// rotate UIImage to any angle
-(UIImage*)rotate:(UIImageOrientation)orient;

// rotate and scale image from iphone camera
-(UIImage*)rotateAndScaleFromCameraWithMaxSize:(CGFloat)maxSize;

// scale this image to a given maximum width and height
-(UIImage*)scaleWithMaxSize:(CGFloat)maxSize;
-(UIImage*)scaleWithMaxSize:(CGFloat)maxSize
                    quality:(CGInterpolationQuality)quality;

@end
