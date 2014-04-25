//
//  ImportMediaDispatcher.m
//  VstratorApp
//
//  Created by user on 29.05.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "ImportMediaDispatcher.h"
#import "Callbacks.h"
#import "MediaService.h"
#import "VstratorConstants.h"
#import "AccountInfo.h"
#import "Exercise+Extensions.h"
#import "Workout+Extensions.h"
#import "Action+Extensions.h"
#import "Sport+Extensions.h"

@interface ImportMediaDispatcher()

@property (nonatomic, strong, readonly) MediaService* mediaService;

@end

@implementation ImportMediaDispatcher

@synthesize mediaService = _mediaService;

-(MediaService *)mediaService
{
    return _mediaService ? _mediaService : (_mediaService = [MediaService new]);
}

#pragma mark - Import

-(void)importMediaList:(NSArray*)mediaList asSession:(BOOL)isSession
{
    [self importMediaList:mediaList asSession:isSession type:MediaTypeUsual];
}

-(void)importMediaList:(NSArray*)mediaList asSession:(BOOL)isSession type:(MediaType)type
{
	for (NSDictionary* info in mediaList) {
        [self importMedia:info asSession:isSession type:type];
	}
}

-(void)importMedia:(NSDictionary*)info asSession:(BOOL)isSession type:(MediaType)type
{
    NSString* title = info[@"title"];
    NSString* note = info[@"note"];
    NSString* sport = info[@"sport"];
    NSString* action = info[@"action"];
    NSString* fileName = info[@"filename"];
    NSString *filePath = [NSBundle.mainBundle pathForResource:fileName ofType:nil inDirectory:@"Content"];
    if (filePath && [NSFileManager.defaultManager fileExistsAtPath:filePath]) {
        dispatch_semaphore_t ds = dispatch_semaphore_create(0);
        NSURL* url = [NSURL fileURLWithPath:filePath];
        NSString* videoKey = [self parseVideoKeyFromFileName:fileName];
        __block ImportMediaDispatcher* this = self;
        [self.mediaService processInContext:^BOOL(NSManagedObjectContext *context) {
            BOOL result = NO;
            do {
                Media* media = [NSEntityDescription insertNewObjectForEntityForName:isSession ? @"Session" : @"Clip" inManagedObjectContext:context];
                [media setupURL:url title:title authorIdentity:VstratorConstants.ProUserIdentity sportName:sport actionName:action note:note callback:nil];
                media.url = fileName; // it will be fixed on the first app start
                media.type = @(type);
                media.videoKey = videoKey;
                if (isSession) {
                    Session *session = (Session*)media;
                    NSString* originalClipFileName = info[@"originalClip"];
                    if (originalClipFileName) {
                        NSString *originalFilePath = [NSBundle.mainBundle pathForResource:originalClipFileName ofType:nil inDirectory:@"Content"];
                        if (!originalFilePath || ![NSFileManager.defaultManager fileExistsAtPath:originalFilePath]) {
                            NSLog(@"File '%@' with original clip video not found", originalClipFileName);
                            break;
                        }
                        NSError* findClipError = nil;
                        Clip* originalClip = (Clip*) [this findMediaByFileNamePart:originalClipFileName inContext:context error:&findClipError];
                        if (findClipError) {
                            NSLog(@"Cannot find media for originalCLip '%@'. Error: %@", originalClipFileName, findClipError);
                            break;
                        }
                        if (!originalClip) {
                            NSLog(@"Cannot find media for originalCLip '%@'", originalClipFileName);
                            break;
                        }
                        session.originalClip = originalClip;
                    }
                }
                result = YES;
            } while (0);
            dispatch_semaphore_signal(ds);
            return result;
        }];
        dispatch_semaphore_wait(ds, DISPATCH_TIME_FOREVER);
        dispatch_release(ds);
        this = nil;
    } else {
        NSLog(@"File '%@' not found", fileName);
    }
}

-(NSString*)parseVideoKeyFromFileName:(NSString*)fileName
{
    return [[[fileName pathComponents] lastObject] stringByDeletingPathExtension];
}

-(NSNumber*)parseTimeString:(NSString*)timeString
{
    unsigned min = 0, sec = 0;
    const char *t, *s = [timeString UTF8String];
    if ((t = strchr(s, ':')) == s)
        sscanf(s, ":%u", &sec);
    else if (t)
        sscanf(s, "%u:%u", &min, &sec);
    else
        sscanf(s, "%u", &min);
    return @((float)sec / 60 + min);
}

-(NSNumber*)parseIntString:(id)intString
{
    if ([intString isKindOfClass:[NSString class]]) //&& !strcasecmp([intString UTF8String], "n/a"))
        return @0;
    return (NSNumber*)intString;
}

-(void)importExercises:(NSArray*)exercisesList
{
    for (NSDictionary* info in exercisesList) {
        // Fix the data
        NSMutableArray* levels = [NSMutableArray array];
        for (int level = 1; level <= 3; ++level) {
            NSString* reps = [NSString stringWithFormat:@"Rep%d", level];
            NSString* sets = [NSString stringWithFormat:@"Sets%d", level];
            NSString* time = [NSString stringWithFormat:@"Time%d", level];
            NSString* weight = [NSString stringWithFormat:@"Weight%d", level];
            NSDictionary* obj = @{@"Level": @(level),
                                 @"Reps": [self parseIntString:info[reps]],
                                 @"Sets": [self parseIntString:info[sets]],
                                 // TODO: Resistance skipped, fix it
                                 @"Duration": [self parseTimeString:info[time]],
                                 @"Weight": [self parseIntString:info[weight]]};
            [levels addObject:obj];
        }
        NSMutableDictionary* fixed = [NSMutableDictionary dictionaryWithDictionary:info];
        fixed[@"IntensityLevels"] = levels;

        dispatch_semaphore_t ds = dispatch_semaphore_create(0);
        __block ImportMediaDispatcher* this = self;
        [self.mediaService processInContext:^BOOL(NSManagedObjectContext *context) {
            BOOL result = NO;
            do {
                NSString* identity = info[@"ID"];
                NSError* error = nil;
                Exercise* exercise = (Exercise*) [this fetchEntity:@"Exercise"
                                                   withIdentity:identity
                                                      inContext:context
                                                          error:&error];
                if (error) {
                    NSLog(@"Cannot import exercise. Error: %@", error);
                    break;
                }
                if (exercise) break; // Exercise with this ID was already imported
                exercise = [Exercise exerciseFromObject:fixed inContext:context error:&error];
                if (error) {
                    NSLog(@"Cannot import exercise. Error: %@", error);
                    break;
                }
                //
                NSString* sessionKey = info[@"SessionKey"];
                if (!sessionKey || [sessionKey isEqualToString:@""]) {
                    NSLog(@"Error in importing data. No session key passed for exercise with ID = %@", identity);
                    break;
                }
                Media* media = [this findMediaByFileNamePart:sessionKey inContext:context error:&error];
                if (error) {
                    NSLog(@"Cannot import exercise. Error: %@", error);
                    break;
                }
                if (!media) {
                    NSLog(@"Cannot find media with sessionKey '%@'", sessionKey);
                    break;
                }
                exercise.media = media;
                result = YES;
            } while (0);
            dispatch_semaphore_signal(ds);
            return result;
        }];
        dispatch_semaphore_wait(ds, DISPATCH_TIME_FOREVER);
        dispatch_release(ds);
    }
}

// TODO: move the code to mediaService
-(Media*)findMediaByFileNamePart:(NSString*)fileNamePart inContext:(NSManagedObjectContext*)context error:(NSError**)error
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Media"];
    request.fetchLimit = 1;
    request.predicate = [NSPredicate predicateWithFormat:@"url CONTAINS[cd] %@", fileNamePart];
    NSArray *result = [context executeFetchRequest:request error:error];
    return *error ? nil : result.lastObject;
}

-(IntensityLevel)parseIntensityString:(NSString*)intensityString
{
    const char* s = [intensityString UTF8String];
    if (strstr(s, "Beg")) {
        return IntensityLevelBeginer;
    } else if (strstr(s, "Int")) {
        return IntensityLevelIntermediate;
    } else if (strstr(s, "Adv")) {
        return IntensityLevelAdvanced;
    }
    return IntensityLevelBeginer;
}

-(void)importWorkouts:(NSArray*)workoutsList
{
    __block ImportMediaDispatcher* this = self;
    for (NSDictionary* info in workoutsList) {
        NSMutableDictionary* fixed = [NSMutableDictionary dictionaryWithDictionary:info];
        fixed[@"WorkoutName"] = info[@"Title"];
        dispatch_semaphore_t ds = dispatch_semaphore_create(0);
        [self.mediaService processInContext:^BOOL(NSManagedObjectContext *context) {
            BOOL needToCommit = NO;
            do {
                NSError* error = nil;
                Workout* workout = (Workout*) [this fetchEntity:@"Workout"
                                                   withIdentity:(NSString*)info[@"ID"]
                                                      inContext:context
                                                          error:&error];
                if (error) {
                    NSLog(@"Cannot import workout. Error: %@", error);
                    break;
                }
                
                if (workout) break; // Workout with this ID was already imported
                
                workout = [Workout workoutFromObject:fixed inContext:context error:&error];
                if (error) {
                    NSLog(@"Cannot import workout. Error: %@", error);
                    break;
                }
                workout.intensityLevel = @([this parseIntensityString:fixed[@"Intensity"]]);
                needToCommit = [this linkWorkout:workout withExercisesFromInfo:fixed inContext:context];
            } while(0);
            dispatch_semaphore_signal(ds);
            return needToCommit;
        }];
        dispatch_semaphore_wait(ds, DISPATCH_TIME_FOREVER);
        dispatch_release(ds);
    }
    this = nil;
}

-(BOOL)linkWorkout:(Workout*)workout withExercisesFromInfo:(NSDictionary*)info inContext:(NSManagedObjectContext*)context
{
    NSError* error = nil;
    for (int i = 0; i < 50; ++i) {
        NSString* key = [NSString stringWithFormat:@"Exercise %d", i+1];
        NSString* identity = [info[key] description];
        if (!identity) break;
        
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Exercise"];
        request.fetchLimit = 1;
        request.predicate = [NSPredicate predicateWithFormat:@"identity = %@", identity];
        NSArray *result = [context executeFetchRequest:request error:&error];
        
        if (error) {
            NSLog(@"Cannot import workout. Error: %@", error);
            return NO;
        }
        
        if (result && result.count == 1) {
            Exercise* exercise = [result lastObject];
            [workout addExercise:exercise withSortOrder:i];
        }
    }
    return YES;
}

// TODO: fix the owner
-(NSManagedObject*)fetchEntity:(NSString*)entity withIdentity:(NSString*)identity inContext:(NSManagedObjectContext*)context error:(NSError**)error
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:entity];
    request.fetchLimit = 1;
    request.predicate = [NSPredicate predicateWithFormat:@"identity = %@", identity];
    NSArray *result = [context executeFetchRequest:request error:error];
    return !*error && result && result.count == 1 ? [result lastObject] : nil;
}

-(void)importAdditionalVideos:(NSArray*)videoList
{
    NSMutableArray* array = [NSMutableArray array];
    for (NSDictionary* info in videoList) {
        NSDictionary* fixed = @{@"filename": [info[@"VideoKey"] stringByAppendingString:@".mp4"],
                               @"sport": @"Other",
                               @"action": @"Other",
                               @"title": info[@"Title"],
                               @"note": info[@"Description"]};
        [array addObject:fixed];
    }
    [self importMediaList:array asSession:NO type:MediaTypeFeaturedVideo];
}

-(void) processJsonWithCallback:(ErrorCallback)callback
{
    NSAssert(callback, @"Argument errorCallback is nil");
    __block ImportMediaDispatcher* this = self;
    dispatch_queue_t callingQueue = dispatch_get_current_queue();
    dispatch_queue_t queue = dispatch_queue_create("Process JSON queue", 0);
    dispatch_async(queue, ^{
        NSString *importFilePath = [[NSBundle mainBundle] pathForResource:@"import" ofType:@"json" inDirectory:@"Content"];
        NSFileManager* fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:importFilePath]) {
            NSError* error = nil;
            NSData *json = [NSData dataWithContentsOfFile:importFilePath options:0 error:&error];
            if (error) {
                dispatch_async(callingQueue, ^{ callback(error); });
                this = nil;
                return;
            }
            NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:json options:0 error:&error];
            if (error) {
                dispatch_async(callingQueue, ^{ callback(error); });
                this = nil;
                return;
            }
            NSLog(@"------------\nImporting clips");
            [this importMediaList:dict[@"clips"] asSession:NO];
            NSLog(@"Importing sessions");
            [this importMediaList:dict[@"sessions"] asSession:YES];
            NSLog(@"Importing exercises");
            [this importExercises:dict[@"exercises"]];
            NSLog(@"Importing workouts");
            [this importWorkouts:dict[@"workouts"]];
            NSLog(@"Importing additional clips");
            [this importAdditionalVideos:dict[@"additionalClips"]];
            NSLog(@"All the objects imported\n---------------");
        }
        dispatch_async(callingQueue, ^{ callback(nil); });
        this = nil;
    });
    dispatch_release(queue);
}

-(void)processImportWithCallback:(ErrorCallback)callback
{
    __block ImportMediaDispatcher* this = self;
	[self.mediaService findUserWithIdentity:[VstratorConstants ProUserIdentity] callback:^(NSError *error, User *user) {
		if (error) {
			callback(error);
            this = nil;
			return;
		}
        [this ensureProUserExists:user callback:^(NSError *error1) {
            if (error1) {
                callback(error1);
                this = nil;
                return;
            }
            [this processJsonWithCallback:^(NSError *error2) {
                if (error2) {
                    callback(error2);
                    this = nil;
                    return;
                }
                callback(nil);
                this = nil;
            }];
        }];
	}];
}

-(void)ensureProUserExists:(User*)user callback:(ErrorCallback)callback
{
    if (user) {
        callback(nil);
        return;
    }
    AccountInfo* info = [AccountInfo new];
    __block ImportMediaDispatcher* this = self;
    [self.mediaService findOrCreateUserWithIdentity:info.identity andUpdateWithAccountInfo:info callback:^(NSError *error, User *author) {
        if (error) {
            callback(error);
        } else {
            author.identity = [VstratorConstants ProUserIdentity];
            author.email = [VstratorConstants ProUserIdentity]; // TODO: add pro email to consts
            [this.mediaService saveChanges:callback];
        }
        this = nil;
    }];
}

@end
