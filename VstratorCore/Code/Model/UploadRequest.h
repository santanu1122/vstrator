//
//  UploadRequest.h
//  VstratorCore
//
//  Created by Admin on 06/03/2013.
//  Copyright (c) 2013 OnTarget. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Media, UploadFile;

@interface UploadRequest : NSManagedObject

@property (nonatomic, retain) NSNumber * failedAttempts;
@property (nonatomic, retain) NSString * identity;
@property (nonatomic, retain) NSString * recordingKey;
@property (nonatomic, retain) NSDate * requestDate;
@property (nonatomic, retain) NSNumber * shareFacebookStatus;
@property (nonatomic, retain) NSNumber * shareTwitterStatus;
@property (nonatomic, retain) NSNumber * sortOrder;
@property (nonatomic, retain) NSNumber * status;
@property (nonatomic, retain) NSDate * uploadDate;
@property (nonatomic, retain) NSString * uploadURL;
@property (nonatomic, retain) NSNumber * visibility;
@property (nonatomic, retain) NSDate * lastSurveyDate;
@property (nonatomic, retain) NSSet *files;
@property (nonatomic, retain) Media *media;
@end

@interface UploadRequest (CoreDataGeneratedAccessors)

- (void)addFilesObject:(UploadFile *)value;
- (void)removeFilesObject:(UploadFile *)value;
- (void)addFiles:(NSSet *)values;
- (void)removeFiles:(NSSet *)values;

@end
