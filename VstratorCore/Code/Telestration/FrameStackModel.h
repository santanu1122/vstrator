//
//  FrameStackModel.h
//  VstratorApp
//
//  Created by user on 12.03.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FrameTransform.h"
#import "StackModel.h"

@interface FrameStackModel : StackModel

-(id) copy;

-(void) addFrameWithTime:(NSTimeInterval)time
             frameNumber:(int)frameNumber
          frameTransform:(FrameTransform *)frameTransform;
-(void) addFrameWithTime:(NSTimeInterval)time
             frameNumber:(int)frameNumber
            frameNumber2:(int)frameNumber2
          frameTransform:(FrameTransform *)frameTransform
         frameTransform2:(FrameTransform *)frameTransform2;
-(NSArray *) createExport;
-(void) load:(NSArray *)frames;

@end
