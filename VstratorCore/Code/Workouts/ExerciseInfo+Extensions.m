//
//  ExerciseInfo+Extensions.m
//  VstratorApp
//
//  Created by Lion User on 30/07/2012.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "ExerciseInfo+Extensions.h"
#import "ExerciseParamsInfo+Extensions.h"

@implementation ExerciseInfo (Extensions)

+ (ExerciseInfo *)from:(Exercise *)exercise
{
    ExerciseInfo *exerciseInfo = [[ExerciseInfo alloc] init];
    exerciseInfo.name = exercise.name;
    exerciseInfo.media = exercise.media;
    NSMutableArray *params = [[NSMutableArray alloc] initWithCapacity:exercise.params.count];
    for (ExerciseParams *param in exercise.params) {
        [params addObject:[ExerciseParamsInfo from:param]];
    }
    exerciseInfo.params = params.copy;
    exerciseInfo.exercise = exercise;
    return exerciseInfo;
}

+ (ExerciseInfo *)createWithName:(NSString *)name media:(Media *)media sortOrder:(NSNumber *)sortOrder params:(NSArray *)params
{
    ExerciseInfo *exerciseInfo = [[ExerciseInfo alloc] init];
    exerciseInfo.name = name;
    exerciseInfo.media = media;
    exerciseInfo.sortOrder = sortOrder;
    exerciseInfo.params = params;
    return exerciseInfo;
}

- (void)addParams:(ExerciseParamsInfo *)params
{
    NSMutableArray *result = self.params.mutableCopy;
    if (result == nil) result = [[NSMutableArray alloc] init];
    [result addObject:params];
    self.params = result;
}

- (ExerciseParamsInfo *)paramsByLevel:(IntensityLevel)level
{
    ExerciseParamsInfo *result = nil;
    for (ExerciseParamsInfo *param in self.params) {
        if (param.intensityLevel != level) continue;
        result = param;
        break;
    }
    return result;
}

@end
