//
//  ExerciseParams.h
//  VstratorCore
//
//  Created by akupr on 20.08.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Exercise;

@interface ExerciseParams : NSManagedObject

@property (nonatomic, retain) NSNumber * duration;
@property (nonatomic, retain) NSNumber * level;
@property (nonatomic, retain) NSNumber * reps;
@property (nonatomic, retain) NSString * resistance;
@property (nonatomic, retain) NSNumber * sets;
@property (nonatomic, retain) NSNumber * weight;
@property (nonatomic, retain) Exercise *exercise;

@end
