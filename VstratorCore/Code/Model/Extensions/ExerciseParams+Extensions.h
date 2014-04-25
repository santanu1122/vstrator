//
//  ExerciseParams+Extensions.h
//  VstratorApp
//
//  Created by akupr on 18.07.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "ExerciseParams.h"

typedef enum {
    IntensityLevelAll, // Used only in requests to mediaService
    IntensityLevelBeginer,
    IntensityLevelIntermediate,
    IntensityLevelAdvanced
} IntensityLevel;

@interface ExerciseParams (Extensions)

+(ExerciseParams*)createParamsForExercise:(Exercise*)exercise
                            timeInSeconds:(int)time
                           intensityLevel:(IntensityLevel)intensityLevel;

+(ExerciseParams*)exerciseParamsFromObject:(NSDictionary*)object inContext:(NSManagedObjectContext*)context error:(NSError**)error;

@end
