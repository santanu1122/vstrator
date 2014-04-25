//
//  Exercise+Extensions.h
//  VstratorApp
//
//  Created by Lion User on 18/07/2012.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "Exercise.h"

@class Media;

@interface Exercise (Extensions)

+(Exercise*)createExerciseForMedia:(Media*)media name:(NSString*)name;
+(Exercise*)exerciseFromObject:(NSDictionary*)object inContext:(NSManagedObjectContext*)context error:(NSError**)error;

- (ExerciseParams *)paramsByLevel:(int)level;

@end
