//
//  Workout+Extensions.h
//  VstratorApp
//
//  Created by akupr on 17.07.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "ExerciseParams+Extensions.h"
#import "Workout.h"

@class Exercise;

@interface Workout (Extensions)

@property (nonatomic, readonly) NSNumber* duration;

-(NSArray*)exercisesBySortOrder;
-(void)addExercise:(Exercise*)exercise withSortOrder:(int)sortOrder;
-(TrainingEvent*)addTrainingEvent:(NSDate*)date intensityLevel:(IntensityLevel)level user:(User*)user;

+(Workout*)createWorkoutWithName:(NSString*)name
                  authorIdentity:(NSString *)authorIdentity
                  intensityLevel:(IntensityLevel)intensityLevel
                       inContext:(NSManagedObjectContext*)context
                           error:(NSError**)error;

+(Workout*)workoutFromObject:(NSDictionary*)object inContext:(NSManagedObjectContext*)context error:(NSError**)error;

@end
