//
//  WorkoutInfo.h
//  VstratorApp
//
//  Created by Lion User on 30/07/2012.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ExerciseParams+Extensions.h"

@interface WorkoutInfo : NSObject

@property (nonatomic, strong) NSString * name;
@property (nonatomic, retain) NSString * identity;
@property (nonatomic) IntensityLevel intensityLevel;
@property (nonatomic, strong) NSArray *exercises;

@end
