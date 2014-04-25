//
//  ExerciseParams+Extensions.m
//  VstratorApp
//
//  Created by akupr on 18.07.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "ExerciseParams+Extensions.h"
#import "Exercise.h"

@implementation ExerciseParams (Extensions)

+(ExerciseParams*)createParamsForExercise:(Exercise*)exercise
                            timeInSeconds:(int)time
                           intensityLevel:(IntensityLevel)intensityLevel
{
    ExerciseParams *params = [NSEntityDescription insertNewObjectForEntityForName:@"ExerciseParams"
                                                           inManagedObjectContext:exercise.managedObjectContext];
    params.exercise = exercise;
    params.level = @(intensityLevel);
    params.duration = @(time);
    return params;
}

+(ExerciseParams*)exerciseParamsFromObject:(NSDictionary*)object inContext:(NSManagedObjectContext*)context error:(NSError**)error
{
    ExerciseParams* params = [NSEntityDescription insertNewObjectForEntityForName:@"ExerciseParams" inManagedObjectContext:context];
    params.level = object[@"Level"];
    params.duration = @((int)([object[@"Duration"] floatValue] * 60));
    params.reps = object[@"Reps"];
    params.sets = object[@"Sets"];
    params.resistance = object[@"Resistance"];
    return params;
}


@end
