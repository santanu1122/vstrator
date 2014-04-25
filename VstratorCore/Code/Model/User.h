//
//  User.h
//  VstratorCore
//
//  Created by akupr on 12.08.13.
//  Copyright (c) 2013 OnTarget. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Media, Notification, Sport, TrainingEvent, Workout;

@interface User : NSManagedObject

@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * facebookAccessToken;
@property (nonatomic, retain) NSDate * facebookExpirationDate;
@property (nonatomic, retain) NSString * facebookIdentity;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * identity;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSString * password;
@property (nonatomic, retain) NSData * picture;
@property (nonatomic, retain) NSString * pictureUrl;
@property (nonatomic, retain) NSNumber * tipCamera;
@property (nonatomic, retain) NSNumber * tipSession;
@property (nonatomic, retain) NSNumber * tipWelcome;
@property (nonatomic, retain) NSString * twitterIdentity;
@property (nonatomic, retain) NSNumber * uploadQuality;
@property (nonatomic, retain) NSString * vstratorIdentity;
@property (nonatomic, retain) NSString * vstratorUserName;
@property (nonatomic, retain) NSNumber * uploadOptions;
@property (nonatomic, retain) NSSet *media;
@property (nonatomic, retain) NSSet *notifications;
@property (nonatomic, retain) Sport *primarySport;
@property (nonatomic, retain) NSSet *trainingEvents;
@property (nonatomic, retain) NSSet *workouts;
@end

@interface User (CoreDataGeneratedAccessors)

- (void)addMediaObject:(Media *)value;
- (void)removeMediaObject:(Media *)value;
- (void)addMedia:(NSSet *)values;
- (void)removeMedia:(NSSet *)values;

- (void)addNotificationsObject:(Notification *)value;
- (void)removeNotificationsObject:(Notification *)value;
- (void)addNotifications:(NSSet *)values;
- (void)removeNotifications:(NSSet *)values;

- (void)addTrainingEventsObject:(TrainingEvent *)value;
- (void)removeTrainingEventsObject:(TrainingEvent *)value;
- (void)addTrainingEvents:(NSSet *)values;
- (void)removeTrainingEvents:(NSSet *)values;

- (void)addWorkoutsObject:(Workout *)value;
- (void)removeWorkoutsObject:(Workout *)value;
- (void)addWorkouts:(NSSet *)values;
- (void)removeWorkouts:(NSSet *)values;

@end
