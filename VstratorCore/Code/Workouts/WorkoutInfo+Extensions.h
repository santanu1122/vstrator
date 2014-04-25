//
//  WorkoutInfo+Extensions.h
//  VstratorApp
//
//  Created by Lion User on 30/07/2012.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "WorkoutInfo.h"

@interface WorkoutInfo (Extensions)

+ (WorkoutInfo *)createWithName:(NSString *)name
                 authorIdentity:(NSString *)authorIdentity
                 intensityLevel:(IntensityLevel)intensityLevel
                      exercises:(NSArray *)exercises;

@end
