//
//  WorkoutExercise+Extensions.h
//  VstratorCore
//
//  Created by akupr on 20.08.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "WorkoutExercise.h"

@interface WorkoutExercise (Extensions)

-(int)moveEarlier:(int)positions error:(NSError**)error;
-(int)moveLater:(int)positions error:(NSError**)error;

@end
