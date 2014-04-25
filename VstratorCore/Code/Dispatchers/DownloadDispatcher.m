//
//  DownloadDispatcher.m
//  VstratorApp
//
//  Created by akupr on 21.07.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "BackgroundTaskWrapper.h"
#import "DownloadDispatcher.h"
#import "MediaService.h"
#import "ServiceFactory.h"
#import "MediaTypeInfo.h"
#import "VstratorConstants.h"
#import "Media.h"

static const NSTimeInterval DownloadMediaSleepInterval = 15.;
static const NSTimeInterval DownloadThumbnailSleepInterval = 15.;
static DownloadDispatcher* SharedInstance;

@interface DownloadDispatcher() {
    id<DownloadService> _downloadService;
    MediaService* _mediaService;
}

@property (atomic) BOOL needToStop;
@property (atomic) BOOL thumbnailsRetrievingIsRunning;
@property (atomic) BOOL downloadIsRunning;
@property (atomic) BOOL fetchingMediaIsRunning;

@property (nonatomic, strong, readonly) MediaService* mediaService;
@property (nonatomic, strong, readonly) id<DownloadService> downloadService;

@end

@implementation DownloadDispatcher

#pragma mark - Properties

@synthesize needToStop = _needToStop;

-(id<DownloadService>)downloadService
{
	return _downloadService ? _downloadService : (_downloadService = [[ServiceFactory sharedInstance] createDownloadService]);
}

-(MediaService *)mediaService
{
	return _mediaService ? _mediaService : (_mediaService = [MediaService new]);
}

+(DownloadDispatcher *)sharedInstance
{
	return SharedInstance ? SharedInstance : (SharedInstance = [DownloadDispatcher new]);
}

#pragma mark - Interface

-(void)stop
{
	self.needToStop = YES;
}

-(void)start
{
	self.needToStop = NO;
    [self fetchAvailableMediaAsync];
    [self downloadRequestedMediaAsync];
    [self downloadThumbnailsAsync];
}

#pragma mark - download media

-(void)downloadRequestedMediaAsync
{
    @synchronized(self) {
        if (self.downloadIsRunning) return;
        self.downloadIsRunning = YES;
    }
    [[BackgroundTaskWrapper wrapperWithTask:^{
        while (!self.needToStop) {
            if (![self processNextRequest] && !self.needToStop)
                [NSThread sleepForTimeInterval:DownloadMediaSleepInterval];
        }
        @synchronized(self) {
            self.downloadIsRunning = NO;
        }
    }] run];
}

-(BOOL)processNextRequest
{
    __block BOOL processed = NO;
    dispatch_semaphore_t ds = dispatch_semaphore_create(0);
    [self.mediaService nextDownloadContentRequested:^(DownloadContent*content, NSError*error) {
        if (error) {
            NSLog(@"Cannot get requested download content. Error: %@", error);
        } else if (content) {
            ErrorCallback callback = ^(NSError* e) {
                processed = YES;
                if (error) {
                    NSLog(@"Cannot download content. Error: %@", e);
                    content.status = @(DownloadContentStatusFailed);
                } else {
                    content.status = @(DownloadContentStatusCompleeted);
                }
                [self.mediaService saveChangesSync];
                dispatch_semaphore_signal(ds);
            };
            content.status = @(DownloadContentStatusInProgress);
            switch (content.type.intValue) {
                case DownloadContentTypeMedia:
                    [self downloadMediaAsync:content.media callback:callback];
                    return;
                case DownloadContentTypeExercise:
                    [self downloadExercise:content.exercise callback:callback];
                    return;
                case DownloadContentTypeWorkout:
                    [self downloadWorkoutAsync:content.workout callback:callback];
                    return;
                default:
                    break;
            }
        }
        dispatch_semaphore_signal(ds);
    }];
    dispatch_semaphore_wait(ds, DISPATCH_TIME_FOREVER);
    return processed;
}

-(void)downloadMediaAsync:(Media*)media callback:(ErrorCallback)callback
{
    NSAssert(media, @"Argument media is nil");
    NSAssert(callback, @"Argument callback is nil");
    NSURL* url = [NSURL URLWithString:media.publicURL];
    NSError* error = nil;
    NSData* data = [NSData dataWithContentsOfURL:url options:0 error:&error];
    if (!error && data) {
        NSString* fileName = [NSString stringWithFormat:@"/Documents/%@.mp4", media.identity];
        NSURL* localURL = [NSURL fileURLWithPath:[NSHomeDirectory() stringByAppendingPathComponent:fileName]];
        [data writeToURL:localURL atomically:YES];
        media.url = localURL.absoluteString;
    }
    callback(error);
    //    [self.downloadService downloadDataByURL:url callback:^(NSData *data, NSError *error) {
    //        if (!error) {
    //            NSString* fileName = [NSString stringWithFormat:@"/Documents/%@.mp4", media.identity];
    //            NSURL* localURL = [NSURL fileURLWithPath:[NSHomeDirectory() stringByAppendingPathComponent:fileName]];
    //            [data writeToURL:localURL atomically:YES];
    //            media.url = localURL.absoluteString;
    //        }
    //        callback(error);
    //    }];
}

-(void)downloadWorkoutAsync:(Workout*)workout callback:(ErrorCallback)callback
{
    NSAssert(callback, @"Argument callback is nil");
    NSAssert(workout, @"Argument workout is nil");
    __block int count = workout.exercises.count;
    __block NSError* globalError = nil;
    for (Exercise* exercise in workout.exercises) {
        [self downloadExercise:exercise callback:^(NSError *error) {
            if (error) globalError = error; // TODO: combine the errors
            if (!--count) callback(globalError);
        }];
    }
}

-(void)downloadExercise:(Exercise*)exercise callback:(ErrorCallback)callback
{
    NSAssert(callback, @"Argument callback is nil");
    NSAssert(exercise, @"Argument exercise is nil");
    if (!exercise.media.url) {
        [self downloadMediaAsync:exercise.media callback:callback];
    } else {
        callback(nil);
    }
}

#pragma mark - fetch media info

-(void)fetchAvailableMediaAsync
{
    [self.downloadService getAvailableMediaTypesWithCallback:^(NSArray*mediaTypes, NSError*error) {
        if (error) {
            NSLog(@"Cannot get available media types. Error: %@", error);
        } else if (!mediaTypes || !mediaTypes.count) {
            NSLog(@"Warning! There are no media types available for the download.");
        } else {
            [self processMediaTypesAsync:mediaTypes];
        }
    }];
}

-(void)processMediaTypesAsync:(NSArray*)mediaTypes
{
    @synchronized(self) {
        if (self.fetchingMediaIsRunning) return;
        self.fetchingMediaIsRunning = YES;
    }
    [[BackgroundTaskWrapper wrapperWithTask:^{
        dispatch_semaphore_t ds = dispatch_semaphore_create(0); // only one mediaType at a time
        [self.downloadService getContentSets:^(NSArray* array, NSError* error) {
            if (error) {
                NSLog(@"Cannot get content sets. Error: %@", error);
            } else if (array) {
                [self importContentSets:array];
            }
            dispatch_semaphore_signal(ds);
        }];
        dispatch_semaphore_wait(ds, DISPATCH_TIME_FOREVER);
        for (MediaTypeInfo* info in mediaTypes) {
            if (self.needToStop) break;
            if (info.mediaType == DownloadMediaTypeExtras)
                continue; // not implemented now
            [self.downloadService getMediaListForType:info callback:^(NSArray* mediaList, NSError* error) {
                if (error) {
                    NSLog(@"Cannot download media list. Error: %@", error);
                } else {
                    switch (info.mediaType) {
                        case DownloadMediaTypeClips:
                        case DownloadMediaTypeVstratedClips:
                            [self importVideos:mediaList];
                            break;
                        case DownloadMediaTypeExercises:
                            [self importExercises:mediaList];
                            break;
                        case DownloadMediaTypeWorkouts:
                            [self importWorkouts:mediaList];
                            break;
                        case DownloadMediaTypeFeaturedVideos:
                            [self importFeaturedVideos:mediaList];
                            break;
                        default:
                            break;
                    }
                }
                dispatch_semaphore_signal(ds);
            }];
            dispatch_semaphore_wait(ds, DISPATCH_TIME_FOREVER);
        }
        dispatch_release(ds);
        @synchronized(self) {
            self.fetchingMediaIsRunning = NO;
        }
    }] run];
}

-(void)downloadThumbnailsAsync
{
    @synchronized(self) {
        if (self.thumbnailsRetrievingIsRunning) return;
        self.thumbnailsRetrievingIsRunning = YES;
    }
    [[BackgroundTaskWrapper wrapperWithTask:^{
        while (!self.needToStop) {
            if (![self updateThumbnail] && !self.needToStop)
                [NSThread sleepForTimeInterval:DownloadThumbnailSleepInterval];
        }
        @synchronized(self) {
            self.thumbnailsRetrievingIsRunning = NO;
        }
    }] run];
}

-(BOOL)updateThumbnail
{
    __block BOOL downloadStarted = NO;
    dispatch_semaphore_t ds = dispatch_semaphore_create(0);
    [self.mediaService nextMediaForThumbnailDownload:^(Media* media, NSError* error) {
        if (error) {
            NSLog(@"Cannot get next media for thumbnail download. Error: %@", error);
        } else if (media) {
            NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:media.thumbURL] options:0 error:&error];
            if (error) {
                NSLog(@"Cannot download media thumbnail. Error: %@", error);
            } else if (data) {
                media.thumbnail = UIImageJPEGRepresentation([UIImage imageWithData:data], VstratorConstants.ThumbnailJPEGQuality);
                [self.mediaService saveChangesSync];
                downloadStarted = YES;
            }
        }
        dispatch_semaphore_signal(ds);
    }];
    dispatch_semaphore_wait(ds, DISPATCH_TIME_FOREVER);
    dispatch_release(ds);
    return downloadStarted;
}

-(void)importContentSets:(NSArray*)contentSets
{
    for (NSDictionary* info in contentSets) {
        [self importContentSet:info];
    }
}

-(void)importContentSet:(NSDictionary*)info
{
    NSString* identity = info[@"ID"];
    [self.mediaService findContentSetByIdentity:identity callback:^(ContentSet* set, NSError* findError) {
        if (findError) {
            NSLog(@"Cannot find content set with an identity %@. Error: %@", identity, findError);
        } else if (!set) {
            [self.mediaService createContentSet:info callback:^(ContentSet *newSet, NSError *createError) {
                if (createError) {
                    NSLog(@"Cannot create content set. Error: %@", createError);
                } else if (newSet) {
                    [self.mediaService saveChanges:^(NSError *saveError) {
                        if (saveError) {
                            NSLog(@"Cannot save content set. Error: %@", saveError);
                            [self.mediaService rollbackChanges:nil];
                        }
                    }];
                } else {
                    NSLog(@"Cannot create content set. Unknown error");
                    [self.mediaService rollbackChanges:nil];
                }
            }];
        }
    }];
}

-(void)importVideos:(NSArray*)mediaList
{
    for (NSDictionary* info in mediaList) {
        [self importVideo:info type:MediaTypeUsual];
    }
}

-(void)importVideo:(NSDictionary*)info type:(MediaType)type
{
    NSString* videoKey = info[@"videoKey"];
    [self.mediaService findMediaByVideoKey:videoKey callback:^(Media *media, NSError *findError) {
        if (findError) {
            NSLog(@"Cannot find media. Error: %@", findError);
        } else if (!media) {
            [self.mediaService createMediaForDownload:info callback:^(Media *newMedia, NSError *createError) {
                if (!createError && newMedia) {
                    newMedia.type = @(type);
                    [self.mediaService saveChanges:^(NSError *saveError) {
                        if (saveError) {
                            NSLog(@"Cannot save media. Error: %@", saveError);
                            [self.mediaService rollbackChanges:nil];
                        }
                    }];
                } else {
                    [self.mediaService rollbackChanges:nil];
                }
            }];
        }
    }];
}

-(void)importWorkouts:(NSArray*)workoutList
{
    for (NSDictionary* info in workoutList) {
        NSString* identity = info[@"ID"];
        [self.mediaService findWorkoutById:identity callback:^(Workout *workout, NSError *error) {
            if (error || workout) {
                if (error) NSLog(@"Cannot find workout. Error: %@", error);
                return;
            }
            [self.mediaService createWorkoutForDownload:info callback:^(Workout *workout1, NSError *error1) {
                if (!error1 && workout1) [self.mediaService saveChanges:^(NSError *error2) {
                    if (error2) {
                        NSLog(@"Cannot save workout. Error: %@", error2);
                        [self.mediaService rollbackChanges:nil];
                    }
                }];
                else {
                    [self.mediaService rollbackChanges:nil];
                }
            }];
        }];
    }
}

-(void)importExercises:(NSArray*)exercisesList
{
    for (NSDictionary* info in exercisesList) {
        NSString* identity = info[@"ID"];
        [self.mediaService findExerciseById:identity callback:^(Exercise *exercise, NSError *error) {
            if (error || exercise) {
                if (error) NSLog(@"Cannot find exercise. Error: %@", error);
                return;
            }
            [self.mediaService createExerciseForDownload:info callback:^(Exercise *newExercise, NSError *errorCreation) {
                if (!errorCreation && newExercise) [self.mediaService saveChanges:^(NSError *error2) {
                    if (error2) {
                        NSLog(@"Cannot save exercise. Error: %@", error2);
                        [self.mediaService rollbackChanges:nil];
                    }
                }];
                else {
                    [self.mediaService rollbackChanges:nil];
                }
            }];
        }];
    }
}

-(void)importFeaturedVideos:(NSArray*)videos
{
    for (NSDictionary* info in videos) {
        NSMutableDictionary* fixed = [NSMutableDictionary dictionaryWithDictionary:info];
        fixed[@"sport"] = @"Other";
        fixed[@"action"] = @"Other";
        [self importVideo:fixed type:MediaTypeFeaturedVideo];
    }
}

@end
