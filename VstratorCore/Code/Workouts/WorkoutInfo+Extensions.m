//
//  WorkoutInfo+Extensions.m
//  VstratorApp
//
//  Created by Lion User on 30/07/2012.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "WorkoutInfo+Extensions.h"

@implementation WorkoutInfo (Extensions)

+ (WorkoutInfo *)createWithName:(NSString *)name
                 authorIdentity:(NSString *)authorIdentity
                 intensityLevel:(IntensityLevel)intensityLevel
                      exercises:(NSArray *)exercises
{
    WorkoutInfo *workoutInfo = [[WorkoutInfo alloc] init];
    workoutInfo.name = name;
    workoutInfo.identity = authorIdentity;
    workoutInfo.intensityLevel = intensityLevel;
    workoutInfo.exercises = exercises;
    return workoutInfo;
}

@end
