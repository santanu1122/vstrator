//
//  WorkoutExercise.h
//  VstratorCore
//
//  Created by akupr on 20.08.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Exercise, Workout;

@interface WorkoutExercise : NSManagedObject

@property (nonatomic, retain) NSNumber * sortOrder;
@property (nonatomic, retain) Workout *workout;
@property (nonatomic, retain) Exercise *exercise;

@end
