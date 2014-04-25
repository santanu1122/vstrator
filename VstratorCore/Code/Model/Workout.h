//
//  Workout.h
//  VstratorCore
//
//  Created by akupr on 23.08.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DownloadContent, TrainingEvent, User, WorkoutExercise;

@interface Workout : NSManagedObject

@property (nonatomic, retain) NSString * category;
@property (nonatomic, retain) NSString * identity;
@property (nonatomic, retain) NSNumber * intensityLevel;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * note;
@property (nonatomic, retain) User *author;
@property (nonatomic, retain) DownloadContent *download;
@property (nonatomic, retain) NSSet *events;
@property (nonatomic, retain) NSSet *exercises;
@end

@interface Workout (CoreDataGeneratedAccessors)

- (void)addEventsObject:(TrainingEvent *)value;
- (void)removeEventsObject:(TrainingEvent *)value;
- (void)addEvents:(NSSet *)values;
- (void)removeEvents:(NSSet *)values;

- (void)addExercisesObject:(WorkoutExercise *)value;
- (void)removeExercisesObject:(WorkoutExercise *)value;
- (void)addExercises:(NSSet *)values;
- (void)removeExercises:(NSSet *)values;

@end
