//
//  ExerciseInfo+Extensions.h
//  VstratorApp
//
//  Created by Lion User on 30/07/2012.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "Exercise.h"
#import "ExerciseInfo.h"
#import "Exerciseparams+Extensions.h"
#import "ExerciseParamsInfo.h"

@interface ExerciseInfo (Extensions)

+ (ExerciseInfo *)from:(Exercise *)exercise;
+ (ExerciseInfo *)createWithName:(NSString *)name media:(Media *)media sortOrder:(NSNumber *)sortOrder params:(ExerciseParamsInfo *)params;

- (void)addParams:(ExerciseParamsInfo *)params;
- (ExerciseParamsInfo *)paramsByLevel:(IntensityLevel)level;

@end
