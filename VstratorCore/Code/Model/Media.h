//
//  Media.h
//  VstratorCore
//
//  Created by akupr on 06.12.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Action, DownloadContent, Exercise, UploadRequest, User;

@interface Media : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * duration;
@property (nonatomic, retain) NSNumber * height;
@property (nonatomic, retain) NSString * identity;
@property (nonatomic, retain) NSString * note;
@property (nonatomic, retain) NSString * publicURL;
@property (nonatomic, retain) NSString * videoKey;
@property (nonatomic, retain) NSData * thumbnail;
@property (nonatomic, retain) NSString * thumbURL;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSNumber * width;
@property (nonatomic, retain) Action *action;
@property (nonatomic, retain) User *author;
@property (nonatomic, retain) DownloadContent *download;
@property (nonatomic, retain) NSSet *exercises;
@property (nonatomic, retain) UploadRequest *uploadRequest;
@end

@interface Media (CoreDataGeneratedAccessors)

- (void)addExercisesObject:(Exercise *)value;
- (void)removeExercisesObject:(Exercise *)value;
- (void)addExercises:(NSSet *)values;
- (void)removeExercises:(NSSet *)values;

@end
