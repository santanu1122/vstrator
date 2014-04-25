//
//  MediaService.h
//  VstratorApp
//
//  Created by user on 19.03.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Callbacks.h"
#import "AccountInfo.h"
#import "Action.h"
#import "Clip+Extensions.h"
#import "DownloadContent+Extensions.h"
#import "Exercise+Extensions.h"
#import "ExerciseParams+Extensions.h"
#import "Media+Extensions.h"
#import "Session+Extensions.h"
#import "Sport.h"
#import "Workout+Extensions.h"
#import "WorkoutInfo+Extensions.h"
#import "UploadFile.h"
#import "UploadRequest+Extensions.h"
#import "User+Extensions.h"

@class UploadData, ClipMetaInfo, ContentSet, UploadRequestInfo, Notification, NotificationButton, NotificationInfo;

typedef void (^UploadRequestCallback)(NSString* uploadRequestIdentity, NSError*error);
typedef void (^UploadDataCallback)(UploadData*data, NSError*error);

@interface MediaService : NSObject

#pragma mark - Shared Instance

+(MediaService *) mainThreadInstance;
+(void)initialize2;

#pragma mark Init

-(id) initWithQueue:(dispatch_queue_t)queue;
-(id) initWithQueue:(dispatch_queue_t)queue supportUndo:(BOOL)needsUndo;

#pragma mark Media

-(void) searchMedia:(SearchMediaType)mediaType
   authorIdentities:(NSArray *)authorIdentities
        queryString:(NSString *)queryString
               type:(MediaType)type
     skipIncomplete:(BOOL)skipIncomplete
           callback:(FetchItemsCallback)callback;

-(void) hasNewMedia:(SearchMediaType)mediaType
   authorIdentities:(NSArray *)authorIdentities
               type:(MediaType)type
           callback:(void (^)(BOOL has, NSError *error))callback;

-(void) selectSports:(GetItemsCallback)callback;

-(void) createClipWithURL:(NSURL *)url
                    title:(NSString *)title
                sportName:(NSString *)sportName
               actionName:(NSString *)actionName
                     note:(NSString *)note
           authorIdentity:(NSString *)authorIdentity
                 callback:(GetClipCallback)callback;

-(void) createSessionWithURL:(NSURL *)url
					   title:(NSString *)title
				   sportName:(NSString *)sportName
				  actionName:(NSString *)actionName
			  authorIdentity:(NSString *)authorIdentity
					callback:(GetMediaCallback)callback;

-(void) findClipWithIdentity:(NSString *)identity
                    callback:(GetClipCallback)callback;

-(void) fetchMediaWithIdentity:(NSString*)identity callback:(void(^)(Media *media, NSError* error))callback;

-(void) nextMediaForThumbnailDownload:(void(^)(Media* media, NSError* error))callback;

-(void) findUserWithMostRecentActivity:(GetAuthorCallback)callback;
-(void) findUserWithIdentity:(NSString *)identity
                    callback:(GetAuthorCallback)callback;
-(void) findOrCreateUserWithIdentity:(NSString *)authorIdentity
            andUpdateWithAccountInfo:(AccountInfo *)accountInfo
                            callback:(GetAuthorCallback)callback;
-(void) findUserWithEmail:(NSString *)email
                 callback:(GetAuthorCallback)callback;
-(void) findUserWithFacebookIdentity:(NSString *)identity
                            callback:(GetAuthorCallback)callback;

-(void) findSportWithName:(NSString *)sportName
                 callback:(GetSportCallback)callback;

-(void) findActionWithName:(NSString *)actionName
                 sportName:(NSString *)sportName
                  callback:(GetActionCallback)callback;

-(BOOL) deleteObject:(NSManagedObject*)object error:(NSError**)error;

-(void) saveChangesSync;
-(void) saveChanges:(ErrorCallback)callback;
-(void) rollbackChanges:(ErrorCallback)callback;
-(void) processInContext:(BOOL(^)(NSManagedObjectContext* context))callback;

-(void) findMediaWithURL:(NSURL *)url mediaType:(SearchMediaType)mediaType authorIdentity:(NSString *)authorIdentity callback:(GetMediaCallback)callback;
-(void) fetchAllMediaInCallback:(void(^)(NSArray*mediaList, NSError*error))callback;

#pragma mark Workouts

-(void) searchWorkoutsByCategory:(NSString*)category
                authorIdentities:(NSArray *)authorIdentities
                  intensityLevel:(IntensityLevel)level
                     queryString:(NSString *)queryString
                  skipIncomplete:(BOOL)skipIncomplete
                        callback:(FetchItemsCallback)callback;

-(void) hasNewWorkoutsWithCategory:(NSString*)category
                  authorIdentities:(NSArray *)authorIdentities
                    intensityLevel:(IntensityLevel)level
                          callback:(void(^)(BOOL has, NSError* error))callback;

-(void) createWorkoutInfo:(WorkoutInfo *)workoutInfo
                 callback:(GetWorkoutCallback)callback;

#pragma mark Upload

-(void)uploadRequestsWithStatus:(UploadRequestStatus)status authorIdentities:(NSArray *)authorIdentities callback:(FetchItemsCallback)callback;
-(void)uploadRequestWithStatus:(UploadRequestStatus)status authorIdentities:(NSArray *)authorIdentities callback:(GetUploadRequestCallback)callback;
-(void)nextUploadRequestInfo:(NSArray *)authorIdentities callback:(UploadRequestInfoCallback)callback;
-(void)addMediaToUploadQueue:(Media*)media withVisibility:(UploadRequestVisibility)visibility callback:(ErrorCallback)callback;
-(void)dataUploaded:(UploadData*)data withError:(NSError*)error;
-(void)uploadRequestCompleeted:(NSString *)uploadRequestIdentity videoKey:(NSString*)videoKey withError:(NSError *)error callback:(ErrorCallback)callback;
-(void)clipMetaInfoForUploadRequestIdentity:(NSString *)identity callback:(void(^)(ClipMetaInfo*metaInfo, NSError* error))callback;
-(void)nextCompleetedUploadRequestWithoutURL:(NSArray *)authorIdentities sortOrder:(int)sortOrder callback:(void (^)(UploadRequest*, NSError *))callback;
-(void)uploadRequest:(NSString*)identity gotURL:(NSURL*)url withError:(NSError*)error;
-(void)updateUploadRequestWithInfo:(UploadRequestInfo*)info callback:(ErrorCallback)callback;
-(void)changeUploadRequest:(NSString*)identity status:(UploadRequestStatus)status;
-(void)retryUploading:(UploadRequest*)uploadRequest callback:(ErrorCallback)callback;
-(void)stopUploading:(UploadRequest*)uploadRequest callback:(ErrorCallback)callback;
-(void)fetchNotFinishedRequests:(void(^)(NSArray* requests, NSError* error))callback;

#pragma mark Download

-(void)downloadContentWithStatus:(DownloadContentStatus)status authorIdentities:(NSArray*)authorIdentities callback:(FetchItemsCallback)callback;
-(void)findMediaByVideoKey:videoKey callback:(void(^)(Media* media,NSError* error))callback;
-(void)createMediaForDownload:(NSDictionary*)info callback:(void(^)(Media* media,NSError* error))callback;
-(void)nextDownloadContentRequested:(void(^)(DownloadContent*content, NSError*error))callback;
-(void)findWorkoutById:(NSString*)identity callback:(void(^)(Workout *workout, NSError *error))callback;
-(void)createWorkoutForDownload:(NSDictionary*)info callback:(void(^)(Workout *workout, NSError *error))callback;
-(void)findExerciseById:(NSString*)identity callback:(void(^)(Exercise *exercise, NSError *error))callback;
-(void)createExerciseForDownload:(NSDictionary*)info callback:(void(^)(Exercise *workout, NSError *error))callback;
-(void)findContentSetByIdentity:(NSString*)identity callback:(void(^)(ContentSet* set, NSError* error))callback;
-(void)createContentSet:(NSDictionary*)info callback:(void(^)(ContentSet *newSet, NSError *createError))callback;
-(void)contentSetByProductID:(NSString*)productIdentifier callback:(void(^)(ContentSet* contentSet, NSError* error))callback;
-(void)fetchContentSets:(FetchItemsCallback)callback;

#pragma mark TrainingEvents

-(void)fetchTrainingEventsFrom:(NSDate*)startDate to:(NSDate*)endDate callback:(FetchItemsCallback)callback;
-(void)allTrainingEventsWithCallback:(void(^)(NSArray* events, NSError* error))callback;

#pragma mark Notifications

typedef void (^NotificationCallback)(Notification* notification, NSError* error);

-(void)getLastNotification:(NotificationCallback)callback;
-(void)pushNotificationButton:(NotificationButton*)button callback:(ErrorCallback)callback;
-(void)addNotificationInfo:(NotificationInfo*)info forUserIdentity:(NSString*)identity callback:(ErrorCallback)callback;

@end
