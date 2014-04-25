//
//  WorkoutExercise+Extensions.m
//  VstratorCore
//
//  Created by akupr on 20.08.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "WorkoutExercise+Extensions.h"
#import "Workout.h"

@implementation WorkoutExercise (Extensions)

-(int)moveEarlier:(int)positions error:(NSError**)error
{
    return [self move:positions error:error];
}

-(int)moveLater:(int)positions error:(NSError**)error
{
    return [self move:-positions error:error];
}

-(int)move:(int)positions error:(NSError**)error
{
    NSAssert(positions, @"Argument error. positions == 0");
    NSFetchRequest* request = [[NSFetchRequest alloc] initWithEntityName:@"WorkoutExercise"];
    if (positions > 0) {
        request.predicate = [NSPredicate predicateWithFormat:@"workout.identity = %@ AND sortOrder < %@", self.workout.identity, self.sortOrder];
        request.fetchLimit = positions;
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"sortOrder" ascending:NO]];
    } else {
        request.predicate = [NSPredicate predicateWithFormat:@"workout.identity = %@ AND sortOrder > %@", self.workout.identity, self.sortOrder];
        request.fetchLimit = -positions;
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"sortOrder" ascending:YES]];
    }
    NSArray* result = [self.managedObjectContext executeFetchRequest:request error:error];
    if (*error) return 0;
    for (int i = 0; i < result.count; ++i) {
        WorkoutExercise* other = result[i];
        NSNumber* temp = other.sortOrder;
        other.sortOrder = self.sortOrder;
        self.sortOrder = temp;
    }
    return result.count;
}

@end
