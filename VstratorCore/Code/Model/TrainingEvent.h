//
//  TrainingEvent.h
//  VstratorCore
//
//  Created by akupr on 15.01.13.
//  Copyright (c) 2013 OnTarget. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class User, Workout;

@interface TrainingEvent : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * identity;
@property (nonatomic, retain) NSNumber * intensityLevel;
@property (nonatomic, retain) Workout *workout;
@property (nonatomic, retain) User *user;

@end
