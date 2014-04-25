//
//  ExerciseParamsInfo+Extensions.m
//  VstratorApp
//
//  Created by Lion User on 30/07/2012.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "ExerciseParamsInfo+Extensions.h"

@implementation ExerciseParamsInfo (Extensions)

+ (ExerciseParamsInfo *)from:(ExerciseParams *)exerciseParams
{
    ExerciseParamsInfo *exerciseParamsInfo = [[ExerciseParamsInfo alloc] init];
    exerciseParamsInfo.intensityLevel = exerciseParams.level.intValue;
    exerciseParamsInfo.time = exerciseParams.duration.intValue;
    exerciseParamsInfo.reps = exerciseParams.reps.intValue;
    exerciseParamsInfo.sets = exerciseParams.sets.intValue;
    exerciseParamsInfo.weight = exerciseParams.weight.intValue;
    return exerciseParamsInfo;
}
+ (ExerciseParamsInfo *)createFor:(ExerciseInfo *)exerciseInfo
               withIntensityLevel:(IntensityLevel)level
                             time:(int)time
                             reps:(int)reps
                             sets:(int)sets
                           weight:(int)weight
{
    ExerciseParamsInfo *exerciseParamsInfo = [[ExerciseParamsInfo alloc] init];
    exerciseParamsInfo.intensityLevel = level;
    exerciseParamsInfo.time = time;
    exerciseParamsInfo.reps = reps;
    exerciseParamsInfo.sets = sets;
    exerciseParamsInfo.weight = weight;
    [exerciseInfo addParams:exerciseParamsInfo];
    return exerciseParamsInfo;
}

@end
