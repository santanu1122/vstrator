//
//  UpdateManager.m
//  VstratorCore
//
//  Created by akupr on 11.12.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "AccountController2.h"
#import "Action+Extensions.h"
#import "MediaService.h"
#import "Notification.h"
#import "NSFileManager+Extensions.h"
#import "ServiceFactory.h"
#import "Sport+Extensions.h"
#import "SportInfo.h"
#import "TelestrationConstants.h"
#import "TrainingEvent.h"
#import "UpdateManager.h"
#import "VstratorConstants.h"
#import "NSError+Extensions.h"

@interface UpdateManager()

@property (nonatomic, strong, readonly) id<UsersService> usersService;
@property (nonatomic, strong, readonly) MediaService* mediaService;

@end

@implementation UpdateManager

@synthesize usersService = _usersService;
@synthesize mediaService = _mediaService;

-(id<UsersService>)usersService
{
    return _usersService ? _usersService : (_usersService = [[ServiceFactory sharedInstance] createUsersService]);
}

-(MediaService *)mediaService
{
    return _mediaService ? _mediaService : (_mediaService = [MediaService new]);
}

-(void)dealloc
{
    NSLog(@"~UpdateManager()");
}

-(void)processUpdates:(Callback0)callback
{
    dispatch_queue_t queue = dispatch_queue_create("UpdateManager queue", 0);
    dispatch_async(queue, ^{
        [self processUpdatesSync];
        dispatch_sync(dispatch_get_main_queue(), callback);
    });
    dispatch_release(queue);
}

-(void)processUpdatesSync
{
    dispatch_semaphore_t ds = dispatch_semaphore_create(0);
    
    //[self updateSportsAndActions:^(NSError *error) {
    //    if (error) {
    //        NSLog(@"Cannot get sports list. Error: %@", error);
    //    }
    //    dispatch_semaphore_signal(ds);
    //}];
    //dispatch_semaphore_wait(ds, DISPATCH_TIME_FOREVER);
    
    // Fix the media URLs...
    if (![NSUserDefaults.standardUserDefaults boolForKey:@"VstratorAppMediaURLsFixed"]) {
        // ...after the setup
        [self fixupMediaURLs:^(NSError* error) {
            if (error) {
                NSLog(@"Cannot update media URLs after setup. Error: %@", error);
            } else {
                [NSUserDefaults.standardUserDefaults setBool:YES forKey:@"VstratorAppMediaURLsFixed"];
                [NSUserDefaults.standardUserDefaults synchronize];
            }
            dispatch_semaphore_signal(ds);
        }];
    } else {
        // ...after an update
        [self updateMediaURLsWhenAppMoved:^(NSError* error) {
            if (error) {
                NSLog(@"Cannot fix media URLs after update. Error: %@", error);
            }
            dispatch_semaphore_signal(ds);
        }];
    }
    dispatch_semaphore_wait(ds, DISPATCH_TIME_FOREVER);
    
    
    // Store videokeys for the pro-videos
    if (![NSUserDefaults.standardUserDefaults boolForKey:@"VstratorAppVideoKeysFixed"]) {
        [self fixupVideoKeys:^(NSError *error) {
            if (error) {
                NSLog(@"Cannot fix videoKeys. Error: %@", error);
            } else {
                [NSUserDefaults.standardUserDefaults setBool:YES forKey:@"VstratorAppVideoKeysFixed"];
                [NSUserDefaults.standardUserDefaults synchronize];
            }
            dispatch_semaphore_signal(ds);
        }];
        dispatch_semaphore_wait(ds, DISPATCH_TIME_FOREVER);
    }
    
    // Fix the upload statuses
    if (![NSUserDefaults.standardUserDefaults boolForKey:@"VstratorAppUploadStatusesFix"]) {
        [self fixupUploadStatusesWithCallback:^(NSError *error) {
            if (error) {
                NSLog(@"Cannot fix upload statuses. Error: %@", error);
            } else {
                [NSUserDefaults.standardUserDefaults setBool:YES forKey:@"VstratorAppUploadStatusesFix"];
                [NSUserDefaults.standardUserDefaults synchronize];
            }
            dispatch_semaphore_signal(ds);
        }];
        dispatch_semaphore_wait(ds, DISPATCH_TIME_FOREVER);
    }
    
    // Move the generated images to Cache & mark all other content as non iCloud syncable
    if (![NSUserDefaults.standardUserDefaults boolForKey:@"VstratorAppBackupAttributesFixed"]) {
        [self moveGeneratedImagesToCache:^(NSError* error) {
            if (error) {
                NSLog(@"Cannot move generated images to the cache. Error: %@", error);
            } else {
                [self fixupBackupAttributes];
                [NSUserDefaults.standardUserDefaults setBool:YES forKey:@"VstratorAppBackupAttributesFixed"];
                [NSUserDefaults.standardUserDefaults synchronize];
            }
            dispatch_semaphore_signal(ds);
        }];
        dispatch_semaphore_wait(ds, DISPATCH_TIME_FOREVER);
    }
    
    // Fix the intensity levels for the finished workouts
    if (![NSUserDefaults.standardUserDefaults boolForKey:@"VstratorAppIntensityLevelsFixed"]) {
        [self fixupIntensityLevels:^(NSError *error) {
            if (error) {
                NSLog(@"Cannot fix intensity levels. Error: %@", error);
            } else {
                [NSUserDefaults.standardUserDefaults setBool:YES forKey:@"VstratorAppIntensityLevelsFixed"];
                [NSUserDefaults.standardUserDefaults synchronize];
            }
            dispatch_semaphore_signal(ds);
        }];
        dispatch_semaphore_wait(ds, DISPATCH_TIME_FOREVER);
    }
    
    // Do not list uploaded pro videos anymore
    if (![NSUserDefaults.standardUserDefaults boolForKey:@"VstratorAppRemoveProUploads"]) {
        [self removeProUploadsWithCallback:^(NSError *error) {
            if (!error) {
                [NSUserDefaults.standardUserDefaults setBool:YES forKey:@"VstratorAppRemoveProUploads"];
                [NSUserDefaults.standardUserDefaults synchronize];
            } else {
                NSLog(@"Update failed. Cannot remove PRO videos uploads. Error: %@", error);
            }
            dispatch_semaphore_signal(ds);
        }];
        dispatch_semaphore_wait(ds, DISPATCH_TIME_FOREVER);
    }
    
    // Make per-user training events
    if (![NSUserDefaults.standardUserDefaults boolForKey:@"VstratorAppPerUserTrainingEvents"]) {
        [self fixupTrainingEventsWithCallback:^(NSError *error) {
            if (!error) {
                [NSUserDefaults.standardUserDefaults setBool:YES forKey:@"VstratorAppPerUserTrainingEvents"];
                [NSUserDefaults.standardUserDefaults synchronize];
            } else {
                NSLog(@"Update failed. Cannot make per-user training events. Error: %@", error);
            }
            dispatch_semaphore_signal(ds);
        }];
        dispatch_semaphore_wait(ds, DISPATCH_TIME_FOREVER);
    }
    
    // Set Clip.frameRate = 30, if the value is nil
    if (![NSUserDefaults.standardUserDefaults boolForKey:@"VstratorAppClipFrameRateFix"]) {
        [self fixupClipFrameRate:^(NSError *error) {
            if (!error) {
                [NSUserDefaults.standardUserDefaults setBool:YES forKey:@"VstratorAppClipFrameRateFix"];
                [NSUserDefaults.standardUserDefaults synchronize];
            } else {
                NSLog(@"Update failed. Cannot set Clip.frameRate value. Error: %@", error);
            }
            dispatch_semaphore_signal(ds);
        }];
        dispatch_semaphore_wait(ds, DISPATCH_TIME_FOREVER);
    }
    
    dispatch_release(ds);
}

-(void)fixupClipFrameRate:(ErrorCallback)callback
{
    __block UpdateManager* this = self;
    [self.mediaService fetchAllMediaInCallback:^(NSArray *mediaList, NSError *error) {
        if (!error) {
            for (Media* media in mediaList) {
                [media performBlockIfClip:^(Clip *clip) {
                    if (!clip.frameRate) {
                        clip.frameRate = @([TelestrationConstants framesPerSecond]);
                    }
                }];
            }
            [this.mediaService saveChangesSync];
        }
        this = nil;
        callback(error);
    }];
}

-(void)fixupTrainingEventsWithCallback:(ErrorCallback)callback
{
    [self.mediaService findUserWithIdentity:[AccountController2 sharedInstance].userIdentity callback:^(NSError *error, User *user) {
        if (error) {
            callback(error);
        } else if (!user) {
            callback([NSError errorWithText:@"Cannot fetch current user"]);
        } else {
            __block UpdateManager* this = self;
            [this.mediaService allTrainingEventsWithCallback:^(NSArray *events, NSError *fetchEventsError) {
                if (!fetchEventsError && events && events.count > 0) {
                    for (TrainingEvent* event in events) {
                        event.user = user;
                    }
                    [this.mediaService saveChangesSync];
                }
                this = nil;
                callback(fetchEventsError);
            }];
        }
    }];
}

-(void)fixupUploadStatusesWithCallback:(ErrorCallback)callback
{
    if ([self hasGeneratedImages]) {
        callback(nil);
        return; // The fix doesn't needed for this version
    }
    
    __block UpdateManager* this = self;
    NSArray *authorIdentities = @[ VstratorConstants.ProUserIdentity, AccountController2.sharedInstance.userIdentity ];
    [self.mediaService uploadRequestsWithStatus:UploadRequestStatusAll authorIdentities:authorIdentities callback:^(NSError *error, NSFetchedResultsController *result) {
        if (!error) {
            for (UploadRequest* uploadRequest in result.fetchedObjects) {
                switch (uploadRequest.status.intValue) {
                    case 1: // In progress
                        uploadRequest.status = @(UploadRequestStatusInProgress);
                        break;
                    case 2: // Compleeted
                        uploadRequest.status = @(UploadRequestStatusCompleeted);
                        break;
                    case 3: // Finished with an error
                        uploadRequest.status = @(UploadRequestStatusUploadedWithError);
                        break;
                    default:
                        break;
                }
            }
            [this.mediaService saveChangesSync];
        }
        this = nil;
        callback(error);
    }];
}

-(BOOL)hasGeneratedImages
{
    NSString* imagesPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
    for (NSString* file in [[NSFileManager defaultManager] enumeratorAtPath:imagesPath]) {
        if ([file rangeOfString:@"control.txt"].location != NSNotFound) return YES;
    }
    return NO;
}

-(void)removeProUploadsWithCallback:(ErrorCallback)callback
{
    __block UpdateManager* this = self;
    [self.mediaService fetchAllMediaInCallback:^(NSArray *mediaList, NSError *error) {
        if (!error) {
            NSArray* proMedias = [mediaList filteredArrayUsingPredicate:
                                  [NSPredicate predicateWithFormat:@"author.identity = %@ AND uploadRequest != nil",
                                   [VstratorConstants ProUserIdentity]]];
            
            for (Media* media in proMedias) {
                NSError* deleteError = nil;
                [this.mediaService deleteObject:media.uploadRequest error:&deleteError];
                if (deleteError) {
                    NSLog(@"Cannot delete pro-video uploadRequest. Error: %@", deleteError);
                }
            }
            [this.mediaService saveChangesSync];
        }
        this = nil;
        callback(error);
    }];
}

-(void)updateMediaURLsWhenAppMoved:(ErrorCallback)callback
{
    __block UpdateManager* this = self;
    [self.mediaService fetchAllMediaInCallback:^(NSArray *mediaList, NSError *error) {
        if (!error) {
            for (Media* media in mediaList) {
                // Media.url
                if (media.url) {
                    NSString* correctURL = [self fixupURL:media.url];
                    if (correctURL && ![correctURL isEqualToString:media.url]) {
                        media.url = correctURL;
                    }
                }
                // Session.url2
                [media performBlockIfSession:^(Session *session) {
                    if (session.url2) {
                        NSString* correctURL = [self fixupURL:session.url2];
                        if (correctURL && ![correctURL isEqualToString:session.url2]) {
                            session.url2 = correctURL;
                        }
                    }
                }];
                // UploadFile.url
                if (media.uploadRequest) {
                    for (UploadFile* file in media.uploadRequest.files) {
                        if (file.url) {
                            NSString* correctURL = [self fixupURL:file.url];
                            if (correctURL && ![correctURL isEqualToString:file.url]) {
                                file.url = correctURL;
                            }
                        }
                    }
                }
            }
            [this.mediaService saveChangesSync];
        }
        this = nil;
        callback(error);
    }];
}

-(NSString*)fixupURL:(NSString*)urlString
{
    NSParameterAssert(urlString);
    NSURL* url = [NSURL URLWithString:urlString];
    NSURL* correctURL = nil;
    NSString* fileName = url.lastPathComponent;
    if ([urlString rangeOfString:@"Content"].location != NSNotFound) {
        // Pro content
        NSString* filePath = [NSBundle.mainBundle pathForResource:fileName ofType:nil inDirectory:@"Content"];
        if (!filePath || ![NSFileManager.defaultManager fileExistsAtPath:filePath]) {
            NSLog(@"UpdateManager <Warning>: Cannot find file with name '%@'", filePath);
        } else
            correctURL = [NSURL fileURLWithPath:filePath];
    } else if ([urlString rangeOfString:@"Documents"].location != NSNotFound) {
        // User's content
        correctURL = [NSURL fileURLWithPath:[NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@", fileName]]];
    }
    return correctURL.absoluteString;
}

-(void)moveGeneratedImagesToCache:(ErrorCallback)callback
{
    __block UpdateManager* this = self;
    [self.mediaService fetchAllMediaInCallback:^(NSArray *mediaList, NSError *error) {
        if (!error) {
            NSError* mkdirError = nil;
            NSString* newPath = [self newPlaybackImagesFolder];
            [NSFileManager.defaultManager createDirectoryAtPath:newPath withIntermediateDirectories:NO attributes:nil error:&mkdirError];
            if (mkdirError) NSLog(@"Cannot create playback images folder. Error: %@", mkdirError);
            for (Media* media in mediaList) {
                NSString* oldPath = [self oldPlaybackImagesFolder:media.identity];
                if (![NSFileManager.defaultManager fileExistsAtPath:oldPath]) {
                    NSLog(@"Media with id '%@' has no images. Skipped", media.identity);
                    continue;
                }
                NSError* moveError = nil;
                [NSFileManager.defaultManager moveItemAtPath:oldPath toPath:media.playbackImagesFolder error:&moveError];
                if (moveError) NSLog(@"Cannot move generated images for a media with id '%@'. Error: %@0", media.identity, moveError);
            }
        }
        this = nil;
        callback(error);
    }];
}

-(void)fixupMediaURLs:(ErrorCallback)callback
{
    __block UpdateManager* this = self;
    [self.mediaService fetchAllMediaInCallback:^(NSArray *mediaList, NSError *error) {
        if (!error) {
            for (Media* media in mediaList) {
                NSString* filePath = [NSBundle.mainBundle pathForResource:media.url ofType:nil inDirectory:@"Content"];
                if (!filePath || ![NSFileManager.defaultManager fileExistsAtPath:filePath]) {
                    NSLog(@"UpdateManager <Warning>: Cannot find video with filename '%@'", media.url);
                    continue;
                }
                media.url = [[NSURL fileURLWithPath:filePath] absoluteString];
            }
            [this.mediaService saveChangesSync];
        }
        this = nil;
        callback(error);
    }];
}

-(void)fixupIntensityLevels:(ErrorCallback)callback
{
    [self.mediaService processInContext:^BOOL(NSManagedObjectContext *context) {
        NSError* error = nil;
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"TrainingEvent"];
        request.predicate = [NSPredicate predicateWithFormat:@"intensityLevel = 0"];
        NSArray *result = [context executeFetchRequest:request error:&error];
        if (!error) {
            if (result && result.count > 0) {
                for (TrainingEvent* event in result) {
                    event.intensityLevel = [event.workout.intensityLevel copy];
                }
            }
        }
        callback(error);
        return result && result.count > 0;
    }];
}

-(void)fixupVideoKeys:(ErrorCallback)callback
{
    __block UpdateManager* this = self;
    [self.mediaService fetchAllMediaInCallback:^(NSArray *mediaList, NSError *error) {
        if (!error) {
            NSArray* proMedias = [mediaList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"author.identity = %@", [VstratorConstants ProUserIdentity]]];
            for (Media* media in proMedias) {
                NSString* videoKey = [this parseVideoKeyFromURL:[NSURL URLWithString:media.url]];
                if (![videoKey isEqualToString:media.videoKey]) media.videoKey = videoKey;
            }
            [this.mediaService saveChangesSync];
        }
        this = nil;
        callback(error);
    }];
}

-(void)fixupBackupAttributes
{
    NSString* directoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    // Enumerators are recursive
    NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtPath:directoryPath];
    for (NSString* fileName in enumerator) {
        NSError* error = nil;
        NSURL* url = [NSURL fileURLWithPath:[directoryPath stringByAppendingPathComponent:fileName]];
        [[NSFileManager defaultManager] addSkipBackupAttributeToItemAtURL:url error:&error];
        if (error) {
            NSLog(@"Cannot fix backup attribute for '%@'. Error: %@", fileName, error);
        }
    }
}

-(void)updateSportsAndActions:(ErrorCallback)callback
{
    NSParameterAssert(callback);
    __block UpdateManager* this = self;
    NSLog(@"Sports/Actions fetching");
    [self.usersService getSportList:^(NSArray *result, NSError* getSportError) {
        if (getSportError) {
            callback(getSportError);
            return;
        }
        NSLog(@"Sports/Actions fetched");
        [this.mediaService processInContext:^BOOL(NSManagedObjectContext *context) {
            NSError *error = nil;
            for (SportInfo* sport in result) {
                [Sport sportWithName:sport.sport inContext:context error:&error];
                if (error) {
                    NSLog(@"Cannot create sport '%@'. Error: %@", sport.sport, error);
                    break;
                }
                for (NSDictionary* action in sport.actions) {
                    [Action actionWithName:action[@"Value"] sportName:sport.sport inContext:context error:&error];
                    if (error) {
                        NSLog(@"Cannot create action '%@' for sport '%@'. Error: %@", action[@"Value"], sport.sport, error);
                        break;
                    }
                }
                if (error)
                    break;
            }
            NSLog(@"Sports/Actions saved with error: %@", (error ? error.localizedDescription : @"none"));
            this = nil;
            if (callback)
                dispatch_async(dispatch_get_main_queue(), ^{ callback(error); });
            return !error;
        }];
    }];
}

-(NSString*)parseVideoKeyFromURL:(NSURL*)url
{
    return [[[url pathComponents] lastObject] stringByDeletingPathExtension];
}

-(NSString*)oldPlaybackImagesFolder:(NSString*)identity
{
    return [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/%@", identity]];
}

-(NSString*)newPlaybackImagesFolder
{
    NSArray* cachePathArray = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    return [[cachePathArray lastObject] stringByAppendingPathComponent:@"PlaybackImages"];
}


@end
