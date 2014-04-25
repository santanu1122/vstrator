//
//  Workout+Extensions.m
//  VstratorApp
//
//  Created by akupr on 17.07.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "User+Extensions.h"
#import "Workout+Extensions.h"
#import "Exercise+Extensions.h"
#import "WorkoutExercise.h"
#import "VstratorConstants.h"
#import "TrainingEvent.h"
#import "ExerciseParams.h"

@implementation Workout (Extensions)

+(Workout*)createWorkoutWithName:(NSString*)name
                  authorIdentity:(NSString *)authorIdentity
                  intensityLevel:(IntensityLevel)intensityLevel
                       inContext:(NSManagedObjectContext*)context
                           error:(NSError**)error
{
    User* author = [User findUserWithIdentity:authorIdentity inContext:context error:error];
    if (*error) return nil;
    Workout *workout = [NSEntityDescription insertNewObjectForEntityForName:@"Workout" inManagedObjectContext:context];
    workout.identity = [[NSProcessInfo processInfo] globallyUniqueString];
    workout.name = name;
    workout.author = author;
    workout.intensityLevel = [NSNumber numberWithInt:intensityLevel];
    return workout;
}

+(Workout*)workoutFromObject:(NSDictionary*)object inContext:(NSManagedObjectContext*)context error:(NSError**)error
{
    Workout* workout = [NSEntityDescription insertNewObjectForEntityForName:@"Workout" inManagedObjectContext:context];
    workout.identity = object[@"ID"];
    workout.name = object[@"WorkoutName"];
    workout.intensityLevel = object[@"IntensityLevel"];
    workout.note = object[@"Description"];
    workout.category = object[@"Category"];
    workout.author = [User findUserWithIdentity:[VstratorConstants ProUserIdentity] inContext:context error:error];
    if (*error) return workout;
    int order = 0;
    NSArray* exercises = object[@"Exercises"];
    for (NSDictionary* info in exercises) {
        Exercise* exercise = [Exercise exerciseFromObject:info inContext:context error:error];
        if (*error) break;
        [workout addExercise:exercise withSortOrder:order++];
    }
    return workout;
}

-(NSArray*)exercisesBySortOrder
{
    NSArray* sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey:@"sortOrder" ascending:YES]];
    return [self.exercises sortedArrayUsingDescriptors:sortDescriptors];
}

-(void)addExercise:(Exercise *)exercise withSortOrder:(int)sortOrder
{
    WorkoutExercise* link = [NSEntityDescription insertNewObjectForEntityForName:@"WorkoutExercise" inManagedObjectContext:self.managedObjectContext];
    link.sortOrder = @(sortOrder);
    link.workout = self;
    link.exercise = exercise;
}

-(TrainingEvent*)addTrainingEvent:(NSDate *)date intensityLevel:(IntensityLevel)level user:(User*)user
{
    TrainingEvent* event = [NSEntityDescription insertNewObjectForEntityForName:@"TrainingEvent" inManagedObjectContext:self.managedObjectContext];
    event.identity = [[NSProcessInfo processInfo] globallyUniqueString];
    event.date = date;
    event.workout = self;
    event.intensityLevel = [NSNumber numberWithInt:level];
    event.user = user;
    return event;
}

-(NSNumber *)duration
{
    int total = 0;
    IntensityLevel level = self.intensityLevel.intValue;
    for (WorkoutExercise* link in self.exercises) {
        for (ExerciseParams* params in link.exercise.params) {
            if (params.level.intValue == level) {
                total += params.duration.intValue;
                break;
            }
        }
    }
    return @(total);
}

@end
