//
//  ExerciseParamsInfo.h
//  VstratorApp
//
//  Created by Lion User on 30/07/2012.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ExerciseParams+Extensions.h"

@interface ExerciseParamsInfo : NSObject

// TODO: Rename properties according to ExerciseParams.h
@property (nonatomic) IntensityLevel intensityLevel;
@property (nonatomic) int time;
@property (nonatomic) int reps;
@property (nonatomic) int sets;
@property (nonatomic) int weight;
@property (nonatomic, retain) NSString *resistance;

@end
