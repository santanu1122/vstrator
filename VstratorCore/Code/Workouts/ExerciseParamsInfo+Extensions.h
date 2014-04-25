//
//  ExerciseParamsInfo+Extensions.h
//  VstratorApp
//
//  Created by Lion User on 30/07/2012.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "ExerciseInfo+Extensions.h"
#import "ExerciseParams.h"
#import "ExerciseParamsInfo.h"

@interface ExerciseParamsInfo (Extensions)

+ (ExerciseParamsInfo *)from:(ExerciseParams *)exerciseParams;
+ (ExerciseParamsInfo *)createFor:(ExerciseInfo *)exerciseInfo
               withIntensityLevel:(IntensityLevel)level
                             time:(int)time
                             reps:(int)reps
                             sets:(int)sets
                           weight:(int)weight;

@end
