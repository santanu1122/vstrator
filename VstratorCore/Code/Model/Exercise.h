//
//  Exercise.h
//  VstratorCore
//
//  Created by akupr on 21.08.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DownloadContent, ExerciseParams, Media, WorkoutExercise;

@interface Exercise : NSManagedObject

@property (nonatomic, retain) NSString * equipment;
@property (nonatomic, retain) NSString * identity;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * note;
@property (nonatomic, retain) Media *media;
@property (nonatomic, retain) NSSet *params;
@property (nonatomic, retain) NSSet *workouts;
@property (nonatomic, retain) DownloadContent *download;
@end

@interface Exercise (CoreDataGeneratedAccessors)

- (void)addParamsObject:(ExerciseParams *)value;
- (void)removeParamsObject:(ExerciseParams *)value;
- (void)addParams:(NSSet *)values;
- (void)removeParams:(NSSet *)values;

- (void)addWorkoutsObject:(WorkoutExercise *)value;
- (void)removeWorkoutsObject:(WorkoutExercise *)value;
- (void)addWorkouts:(NSSet *)values;
- (void)removeWorkouts:(NSSet *)values;

@end
