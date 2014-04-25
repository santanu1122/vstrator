//
//  Exercise+Extensions.m
//  VstratorApp
//
//  Created by Lion User on 18/07/2012.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "Exercise+Extensions.h"
#import "ExerciseParams+Extensions.h"
#import "Media+Extensions.h"
#import "Workout+Extensions.h"

@implementation Exercise (Extensions)

+(Exercise*)createExerciseForMedia:(Media*)media name:(NSString*)name
{
    Exercise *exercise = [NSEntityDescription insertNewObjectForEntityForName:@"Exercise" inManagedObjectContext:media.managedObjectContext];
    exercise.identity = [[NSProcessInfo processInfo] globallyUniqueString];
    exercise.name = name;
    exercise.media = media;
    return exercise;
}

- (ExerciseParams *)paramsByLevel:(int)level
{
    ExerciseParams *result = nil;
    for (ExerciseParams *param in self.params) {
        if (param.level.intValue != level) continue;
        result = param;
        break;
    }
    return result;
}

+(Exercise*)exerciseFromObject:(NSDictionary*)object inContext:(NSManagedObjectContext*)context error:(NSError**)error
{
    Exercise* exercise = [NSEntityDescription insertNewObjectForEntityForName:@"Exercise" inManagedObjectContext:context];
    exercise.identity = object[@"ID"];
    exercise.name = object[@"ExerciseName"];
    exercise.note = object[@"Description"];
    exercise.equipment = object[@"EquipmentRequired"];
    if (*error) return exercise;
    NSArray* params = object[@"IntensityLevels"];
    for (NSDictionary* info in params) {
        ExerciseParams* param = [ExerciseParams exerciseParamsFromObject:info inContext:context error:error];
        if (*error) break;
        param.exercise = exercise;
    }
    NSDictionary* videoInfo = object[@"RelatedClipVideo"];
    if (!videoInfo)
        videoInfo = object[@"RelatedVstratedVideo"];
    if (videoInfo)
        exercise.media = [Media mediaFromObject:videoInfo inContext:context error:error];
//    else {
//        NSDictionary* dict = [NSDictionary dictionaryWithObject:@"Incorrect media information" forKey:NSLocalizedDescriptionKey];
//        *error = [NSError errorWithDomain:@"com.vstrator" code:-1 userInfo:dict];
//        return nil;
//    }
    return exercise;
}

@end
