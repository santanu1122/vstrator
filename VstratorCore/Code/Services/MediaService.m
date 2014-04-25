//
//  MediaServiceImpl.m
//  VstratorApp
//
//  Created by user on 19.03.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "MediaService.h"

#import "AccountInfo.h"
#import "AccountController2.h"
#import "ClipMetaInfo.h"
#import "ExerciseInfo.h"
#import "ExerciseParams+Extensions.h"
#import "ExerciseParamsInfo.h"
#import "MarkupDataCollection.h"
#import "Media+Extensions.h"
#import "Models+Extensions.h"
#import "Notification+Extensions.h"
#import "NotificationButton.h"
#import "NSFileManager+Extensions.h"
#import "Sport+Extensions.h"
#import "UploadData.h"
#import "UploadDispatcher.h"
#import "UploadFile+Extensions.h"
#import "UploadRequest+Extensions.h"
#import "UploadRequestInfo.h"
#import "VstratorExtensions.h"
#import "VstratorStrings.h"
#import "Workout+Extensions.h"
#import "ContentSet+Extensions.h"

//#define DEBUG_NOTIFICATIONS
//#define DEBUG_INSTANCES

@interface MediaService()

@property (nonatomic, readonly) dispatch_queue_t queue;
@property (nonatomic, readonly) BOOL hasOwnQueue;
@property (nonatomic, strong, readonly) NSManagedObjectModel* model;
@property (nonatomic, strong, readonly) NSManagedObjectContext* context;
@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator* coordinator;
@property (nonatomic, readonly) BOOL supportUndo;

@end


@implementation MediaService

#pragma mark Properties

@synthesize queue = _queue;
@synthesize context = _context;
@synthesize supportUndo = _supportUndo;

static MediaService *_mainThreadInstance = nil;
static NSManagedObjectModel* _model;
static NSPersistentStoreCoordinator* _coordinator;
static NSMutableArray* _services;

#ifdef DEBUG_INSTANCES
static int InstanceCount;
#endif

+(MediaService *)mainThreadInstance
{
    return _mainThreadInstance;
}

+(NSMutableArray*)services
{
    if (_services == nil)
        _services = [NSMutableArray new];
    return _services;
}

-(NSManagedObjectContext *)context
{
    if (_context == nil) {
        NSAssert(dispatch_get_current_queue() == self.queue, @"The context created in a wrong queue");
        _context = [NSManagedObjectContext new];
        if (!self.supportUndo)
            _context.undoManager = nil;
        _context.persistentStoreCoordinator = self.coordinator;
    }
	return _context;
}

-(NSManagedObjectModel *)model
{
	if (_model == nil) {
        NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"VstratorModels" ofType:@"bundle"];
        NSURL *modelURL = [[NSBundle bundleWithPath:bundlePath] URLForResource:@"VstratorDataModel" withExtension:@"momd"];
        _model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
        NSAssert(_model, @"Cannot create data model");
    }
    return _model;
}

-(NSPersistentStoreCoordinator *)coordinator
{
    if (_coordinator)
        return _coordinator;
    BOOL needAttrFix = NO;
    NSError *error = nil;
    NSString *storagePath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/Vstrator.sqlite"]];
	// If the expected store doesn't exist, copy the default store.
	if (![NSFileManager.defaultManager fileExistsAtPath:storagePath]) {
        needAttrFix = YES;
        // Get default storage path
		NSString *defaultStorePath = [[NSBundle mainBundle] pathForResource:@"Vstrator" ofType:@"sqlite" inDirectory:@"Content"];
        if (defaultStorePath) {
            // Copy file from the default path
            [NSFileManager.defaultManager copyItemAtPath:defaultStorePath toPath:storagePath error:&error];
            NSAssert1(!error, @"Cannot copy default storage. Error: %@", error);
        }
	}
    NSURL *storageUrl = [NSURL fileURLWithPath:storagePath];
    _coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.model];
    NSDictionary *options = @{NSMigratePersistentStoresAutomaticallyOption: @YES, NSInferMappingModelAutomaticallyOption: @YES};
    NSAssert1([_coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storageUrl options:options error:&error],
              @"Cannot initialize persistent coordinator. Error: %@", error);
    if (needAttrFix) {
        [[NSFileManager defaultManager] addSkipBackupAttributeToItemAtURL:storageUrl error:&error];
        if (error) {
            NSLog(@"Cannot fix storage backup attribute. Error: %@", error);
        }
    }
    return _coordinator;
}

#pragma mark InterQueue Sync

-(void)contextDidSave:(NSNotification*)notification
{
    dispatch_async(self.queue, ^{
#ifdef DEBUG_NOTIFICATIONS
        if (self == _mainThreadInstance)
            NSLog(@"mediaService(%p,main) has got the notification", self);
        else
            NSLog(@"mediaService(%p) has got the notification", self);
#endif
        [self.context mergeChangesFromContextDidSaveNotification:notification];
    });
}

-(void)registerService
{
    @synchronized ([MediaService services]) {
        for (NSValue* value in [MediaService services]) {
            MediaService* other = [value pointerValue];
            [[NSNotificationCenter defaultCenter] addObserver:other
                                                     selector:@selector(contextDidSave:)
                                                         name:NSManagedObjectContextDidSaveNotification
                                                       object:self.context];
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(contextDidSave:)
                                                         name:NSManagedObjectContextDidSaveNotification
                                                       object:other.context];
        }
        [[MediaService services] addObject:[NSValue valueWithNonretainedObject:self]];
    }
}

-(void)unregisterService
{
    @synchronized ([MediaService services]) {
        for (NSValue* value in [MediaService services]) {
            MediaService* service = [value pointerValue];
            if (service == self) {
                [[MediaService services] removeObject:value];
                break;
            }
        }
        for (NSValue* value in [MediaService services]) {
            MediaService* other = [value pointerValue];
            [[NSNotificationCenter defaultCenter] removeObserver:other
                                                            name:NSManagedObjectContextDidSaveNotification
                                                          object:self.context];
            [[NSNotificationCenter defaultCenter] removeObserver:self
                                                            name:NSManagedObjectContextDidSaveNotification
                                                          object:other.context];
        }
    }
}

#pragma mark Ctors/Dtors

+(void)initialize2
{
    static BOOL initialized = NO;
    if (!initialized) {
        _mainThreadInstance = [[MediaService alloc] initWithQueue:dispatch_get_main_queue() supportUndo:NO];
        _mainThreadInstance.context.stalenessInterval = 0;
        initialized = YES;
#ifdef DEBUG_INSTANCES
        NSLog(@"MediaService main instance is %p", _mainThreadInstance);
#endif
    }
}

-(id)init
{
    self = [super init];
    if (self) {
#ifdef DEBUG_INSTANCES
        NSLog(@"MediaService(%d, %p)", ++InstanceCount, self);
#endif
        _supportUndo = YES;
        _queue = dispatch_queue_create("MediaService queue", 0);
        _hasOwnQueue = YES;
        // Switch the queue because the context will be created here
        dispatch_sync(_queue, ^{ [self registerService]; });
    }
    return self;
}

-(id)initWithQueue:(dispatch_queue_t)queue
{
    return [self initWithQueue:queue supportUndo:YES];
}

-(id)initWithQueue:(dispatch_queue_t)queue supportUndo:(BOOL)supportUndo
{
    self = [super init];
    if (self) {
#ifdef DEBUG_INSTANCES
        NSLog(@"MediaService(%d, %p)", ++InstanceCount, self);
#endif
        _supportUndo = supportUndo;
        _queue = queue;
        _hasOwnQueue = NO;
        if (_queue == dispatch_get_current_queue()) {
            [self registerService];
        } else {
            // Switch the queue because the context will be created here
            dispatch_sync(_queue, ^{ [self registerService]; });
        }
    }
    return self;
}

-(void)dealloc
{
    [self unregisterService];
#ifdef DEBUG_INSTANCES
    NSLog(@"~MediaService(%d, %p)", --InstanceCount, self);
#endif
    if (self.hasOwnQueue) dispatch_release(_queue);
}

#pragma mark Helpers

-(NSFetchedResultsController *) fetchedResultsControllerForEntityName:(NSString *)entityName
                                                        withPredicate:(NSPredicate *)predicate
                                                   andSortDescriptors:(NSArray *)sortDescriptors
{
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:self.context];
	[request setEntity:entity];
	request.predicate = predicate;
	request.sortDescriptors = sortDescriptors;
	return [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.context sectionNameKeyPath:nil cacheName:nil];
}

-(NSString *) joinConditions:(NSArray *)conditions
                  byOperator:(NSString *) operator
{
	operator = [NSString stringWithFormat:@" %@ ", operator];
    NSMutableArray* wrapped = [NSMutableArray new];
    for (id condition in conditions) {
        [wrapped addObject:[NSString stringWithFormat:@"(%@)", condition]];
    }
	return [NSString stringWithFormat:@"(%@)",[NSPredicate predicateWithFormat:[wrapped componentsJoinedByString:operator]].predicateFormat];
}

-(NSArray *) mediaRequestConditionsWithQueryString:(NSString *)queryString
{
	NSMutableArray *conditions = [[NSMutableArray alloc] init];
    if (queryString != nil) {
        [conditions addObject:[NSPredicate predicateWithFormat:@"title CONTAINS[cd] %@", queryString].predicateFormat];
        [conditions addObject:[NSPredicate predicateWithFormat:@"action.sport.name CONTAINS[cd] %@", queryString].predicateFormat];
        [conditions addObject:[NSPredicate predicateWithFormat:@"action.name CONTAINS[cd] %@", queryString].predicateFormat];
    }
	return conditions;
}

-(NSArray *) mediaRequestConditionsWithAuthorIdentities:(NSArray *)authorIdentities
{
	NSMutableArray *conditions = [[NSMutableArray alloc] init];
	for (NSString* identity in authorIdentities) {
        [conditions addObject:[NSPredicate predicateWithFormat:@"author.identity = %@", identity].predicateFormat];
	}
	return conditions;
}

-(void)existsEntity:(NSString*)entityName withConditions:(NSArray*)conditions callback:(void (^)(BOOL, NSError *))callback
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:entityName];
    request.predicate = conditions.count > 0 ? [NSPredicate predicateWithFormat:[self joinConditions:conditions byOperator:@"AND"]] : nil;
    request.includesSubentities = NO;
    request.fetchLimit = 1;
    NSError* error = nil;
    NSArray* result = [self.context executeFetchRequest:request error:&error];
    if (callback) callback(error ? NO : result != nil && result.count > 0, error);
}

#pragma mark MediaService

-(void)searchMedia:(SearchMediaType)mediaType
  authorIdentities:(NSArray *)authorIdentities
       queryString:(NSString *)queryString
              type:(MediaType)type
    skipIncomplete:(BOOL)skipIncomplete
          callback:(FetchItemsCallback)callback
{
	dispatch_async(self.queue, ^{
		NSString* entityName = nil;
		switch (mediaType) {
			case SearchMediaTypeClips:
				entityName = @"Clip";
				break;
			case SearchMediaTypeSessions:
				entityName = @"Session";
				break;
			case SearchMediaTypeAll:
			default:
				entityName = @"Media";
				break;
		}
        NSMutableArray *conditions = [NSMutableArray array];
        NSArray *authorConditions = [self mediaRequestConditionsWithAuthorIdentities:authorIdentities];
        if (authorConditions.count > 0)
            [conditions addObject:[self joinConditions:authorConditions byOperator:@"OR"]];
        NSArray *queryStringConditions = [self mediaRequestConditionsWithQueryString:queryString];
        if (queryStringConditions.count > 0)
            [conditions addObject:[self joinConditions:queryStringConditions byOperator:@"OR"]];
        if (type != MediaTypeAll)
            [conditions addObject:[NSPredicate predicateWithFormat:@"type = %d", type]];
        if (skipIncomplete)
            [conditions addObject:[NSPredicate predicateWithFormat:@"url != nil"]];
		NSPredicate* predicate = conditions.count > 0 ? [NSPredicate predicateWithFormat:[self joinConditions:conditions byOperator:@"AND"]] : nil;
		NSArray* sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO]];
		NSFetchedResultsController* controller = [self fetchedResultsControllerForEntityName:entityName withPredicate:predicate andSortDescriptors:sortDescriptors];
        if (callback) callback(nil, controller);
	});
}

-(void)hasNewMedia:(SearchMediaType)mediaType
  authorIdentities:(NSArray *)authorIdentities
              type:(MediaType)type
          callback:(void (^)(BOOL, NSError *))callback
{
	dispatch_async(self.queue, ^{
		NSString* entityName = nil;
		switch (mediaType) {
			case SearchMediaTypeClips:
				entityName = @"Clip";
				break;
			case SearchMediaTypeSessions:
				entityName = @"Session";
				break;
			case SearchMediaTypeAll:
			default:
				entityName = @"Media";
				break;
		}
        NSMutableArray *conditions = [NSMutableArray array];
        NSArray *authorConditions = [self mediaRequestConditionsWithAuthorIdentities:authorIdentities];
        if (authorConditions.count > 0)
            [conditions addObject:[self joinConditions:authorConditions byOperator:@"OR"]];
        if (type != MediaTypeAll)
            [conditions addObject:[NSPredicate predicateWithFormat:@"type = %d", type]];
        [conditions addObject:[NSPredicate predicateWithFormat:@"download != nil AND (download.status = %d OR download.status = %d)",
                               DownloadContentStatusNew, DownloadContentStatusRequested]];
        [self existsEntity:entityName withConditions:conditions callback:callback];
    });
}

-(void) selectSports:(GetItemsCallback)callback
{
	dispatch_async(self.queue, ^{
		NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Sport"];
        NSError *error = nil;
		NSArray *result = [self.context executeFetchRequest:request error:&error];
        if (callback) callback(error, result);
	});
}

-(void) createClipWithURL:(NSURL *)url
                    title:(NSString *)title
                sportName:(NSString *)sportName
               actionName:(NSString *)actionName
                     note:(NSString *)note
           authorIdentity:(NSString *)authorIdentity
                 callback:(GetClipCallback)callback
{
	dispatch_async(self.queue, ^{
        NSError *error0 = nil;
        // try to find clip
        Clip *clip = [Media findMediaWithURL:url mediaType:SearchMediaTypeClips authorIdentity:authorIdentity inContext:self.context error:&error0];
        if (error0 == nil) {
            // if not exists, create, otherwise, generate error
            if (clip == nil) {
				clip = [NSEntityDescription insertNewObjectForEntityForName:@"Clip" inManagedObjectContext:self.context];
				[clip setupURL:url title:title authorIdentity:authorIdentity sportName:sportName actionName:actionName note:note callback:^(NSError *error1) {
                    if (callback) callback(error1, clip);
				}];
            } else {
                error0 = [NSError errorWithText:VstratorStrings.ErrorClipAlreadyInTheLibraryText];
            }
        }
        if (error0 != nil && callback != nil) {
            callback(error0, nil);
        }
	});
}

-(void)createSessionWithURL:(NSURL *)url
                      title:(NSString *)title
                  sportName:(NSString *)sportName
				 actionName:(NSString *)actionName
             authorIdentity:(NSString *)authorIdentity
                   callback:(GetMediaCallback)callback
{
	dispatch_async(self.queue, ^{
        Media *media = [NSEntityDescription insertNewObjectForEntityForName:@"Session" inManagedObjectContext:self.context];
        [media setupURL:url title:title authorIdentity:authorIdentity sportName:sportName actionName:actionName note:nil callback:^(NSError *error) {
            if (callback) callback(error, media);
        }];
	});
}

-(void) findClipWithIdentity:(NSString *)identity
                    callback:(GetClipCallback)callback
{
	dispatch_async(self.queue, ^{
        NSError *error = nil;
        Clip *clip = [Clip findClipWithIdentity:identity inContext:self.context error:&error];
        if (error == nil && clip == nil) {
            error = [NSError errorWithText:VstratorStrings.ErrorClipNotFoundInTheLibraryText];
        }
        if (callback) callback(error, clip);
	});
}

-(void)findMediaWithURL:(NSURL *)url mediaType:(SearchMediaType)mediaType authorIdentity:(NSString *)authorIdentity callback:(GetMediaCallback)callback
{
	dispatch_async(self.queue, ^{
		NSError* error = nil;
		Media* media = [Media findMediaWithURL:url mediaType:mediaType authorIdentity:authorIdentity inContext:self.context error:&error];
        if (callback) callback(error, media);
	});
}

-(void) findUserWithMostRecentActivity:(GetAuthorCallback)callback
{
	dispatch_async(self.queue, ^{
        NSError *error = nil;
        // try to find the most recent media to return its author
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Media"];
        request.predicate = [NSPredicate predicateWithFormat:@"author.identity !=[c] %@", VstratorConstants.ProUserIdentity];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO]];
        request.fetchLimit = 1;
        NSArray *mediaList = [self.context executeFetchRequest:request error:&error];
        User *mediaAuthor = error == nil && mediaList.count > 0 ? ((Media *)mediaList.lastObject).author : nil;
        if (error != nil || mediaAuthor != nil) {
            if (callback) callback(error, mediaAuthor);
            return;
        }
        // try to find any non-pro user
        request = [[NSFetchRequest alloc] initWithEntityName:@"User"];
        request.predicate = [NSPredicate predicateWithFormat:@"identity !=[c] %@", VstratorConstants.ProUserIdentity];
        request.fetchLimit = 1;
        NSArray *userList = [self.context executeFetchRequest:request error:&error];
        if (callback) callback(error, userList.lastObject);
	});
}

-(void) findUserWithIdentity:(NSString *)identity
                    callback:(GetAuthorCallback)callback;
{
    NSAssert(![NSString isNilOrEmpty:identity], VstratorConstants.AssertionArgumentIsNilOrInvalid);
	dispatch_async(self.queue, ^{
        NSError *error = nil;
        User *author = [User findUserWithIdentity:identity inContext:self.context error:&error];
        if (callback) callback(error, author);
	});
}

-(void) findOrCreateUserWithIdentity:(NSString *)authorIdentity
            andUpdateWithAccountInfo:(AccountInfo *)accountInfo
                            callback:(GetAuthorCallback)callback;
{
    NSParameterAssert(accountInfo);
	dispatch_async(self.queue, ^{
        // execute
        NSError *error = nil;
        User *author = [User findUserWithIdentity:authorIdentity inContext:self.context error:&error];
        if (error == nil) {
            if (author == nil) {
                author = [User createUserInContext:self.context];
                author.identity = authorIdentity;
            }
            [author updateWithAccount:accountInfo inContext:self.context error:&error];
        }
        if (callback) callback(error, author);
	});
}

-(void) findUserWithEmail:(NSString *)email
                 callback:(GetAuthorCallback)callback;
{
    NSAssert(![NSString isNilOrEmpty:email], VstratorConstants.AssertionArgumentIsNilOrInvalid);
	dispatch_async(self.queue, ^{
        NSError *error = nil;
        User *author = [User findUserWithEmail:email inContext:self.context error:&error];
        if (callback) callback(error, author);
	});
}

-(void) findUserWithFacebookIdentity:(NSString *)identity
                            callback:(GetAuthorCallback)callback;
{
    NSAssert(![NSString isNilOrEmpty:identity], VstratorConstants.AssertionArgumentIsNilOrInvalid);
	dispatch_async(self.queue, ^{
        NSError *error = nil;
        User *author = [User findUserWithFacebookIdentity:identity inContext:self.context error:&error];
        if (callback) callback(error, author);
	});
}

-(void) sportWithName:(NSString *)sportName
             callback:(GetSportCallback)callback;
{
    NSAssert(![NSString isNilOrEmpty:sportName], VstratorConstants.AssertionArgumentIsNilOrInvalid);
	dispatch_async(self.queue, ^{
        NSError* error = nil;
        Sport *sport = [Sport sportWithName:sportName inContext:self.context error:&error];
        if (callback) callback(error, sport);
	});
}

-(void) findSportWithName:(NSString *)sportName
                 callback:(GetSportCallback)callback;
{
    return [self sportWithName:sportName callback:callback];
}

-(void) actionWithName:(NSString *)actionName
             sportName:(NSString *)sportName
              callback:(GetActionCallback)callback;
{
    NSAssert(![NSString isNilOrEmpty:sportName], VstratorConstants.AssertionArgumentIsNilOrInvalid);
    NSAssert(![NSString isNilOrEmpty:actionName], VstratorConstants.AssertionArgumentIsNilOrInvalid);
	dispatch_async(self.queue, ^{
        NSError *error = nil;
        Action *action = [Action actionWithName:actionName sportName:sportName inContext:self.context error:&error];
        if (callback) callback(error, action);
	});
}

-(void) findActionWithName:(NSString *)actionName
                 sportName:(NSString *)sportName
                  callback:(GetActionCallback)callback;
{
    NSAssert(![NSString isNilOrEmpty:sportName], VstratorConstants.AssertionArgumentIsNilOrInvalid);
    NSAssert(![NSString isNilOrEmpty:actionName], VstratorConstants.AssertionArgumentIsNilOrInvalid);
	dispatch_async(self.queue, ^{
        NSError *error = nil;
        Action *action = [Action actionWithName:actionName sportName:sportName inContext:self.context error:&error];
        if (callback) callback(error, action);
	});
}

-(void) fetchAllMediaInCallback:(void(^)(NSArray*mediaList, NSError*error))callback
{
    NSParameterAssert(callback);
    dispatch_async(self.queue, ^{
		NSError* error = nil;
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Media"];
        NSArray *result = [self.context executeFetchRequest:request error:&error];
        callback(error ? nil : result, error);
    });
}

-(void) deleteObject:(NSManagedObject *)object
{
    NSParameterAssert(object);
	[object.managedObjectContext deleteObject:object];
}

-(BOOL) deleteObject:(NSManagedObject*)object error:(NSError**)error
{
    NSAssert(object != nil, VstratorConstants.AssertionArgumentIsNilOrInvalid);
    if ([object isKindOfClass:[Media class]]) {
        Media* media = (Media*) object;
        if (![media validateDelete:error])
            return !*error;
    }
    [self deleteObject:object];
    return !*error;
}

-(void) saveChangesSync
{
	NSError* error = nil;
	if (![self.context save:&error]) {
		NSLog(@"Failed to save to data store: %@", [error localizedDescription]);
		NSArray* detailedErrors = [error userInfo][NSDetailedErrorsKey];
		if(detailedErrors != nil && [detailedErrors count] > 0) {
			for(NSError* detailedError in detailedErrors) {
				NSLog(@"  DetailedError: %@", [detailedError userInfo]);
			}
		}
		else {
			NSLog(@"  %@", [error userInfo]);
		}
	}
}

-(void) saveChanges:(ErrorCallback)callback
{
	dispatch_async(self.queue, ^{
        NSError *error = nil;
        if(![self.context save:&error]) {
            NSLog(@"Failed to save to data store: %@", [error localizedDescription]);
            NSArray* detailedErrors = [error userInfo][NSDetailedErrorsKey];
            if(detailedErrors != nil && [detailedErrors count] > 0) {
                for(NSError* detailedError in detailedErrors) {
                    NSLog(@"  DetailedError: %@", [detailedError userInfo]);
                }
            }
            else {
                NSLog(@"  %@", [error userInfo]);
            }
        }
        if (callback) callback(error);
	});
}


-(void) rollbackChanges:(ErrorCallback)callback
{
    NSAssert(self.supportUndo, VstratorConstants.AssertionArgumentIsNilOrInvalid);
	dispatch_async(self.queue, ^{
        [self.context rollback];
        if (callback)
            callback(nil);
	});
}

-(void) processInContext:(BOOL(^)(NSManagedObjectContext* context))callback
{
    NSParameterAssert(callback);
    dispatch_async(self.queue, ^{
        if (callback(self.context)) {
            [self saveChangesSync];
        } else {
            [self.context rollback];
        }
    });
}

#pragma mark Workouts

-(void)searchWorkoutsByCategory:(NSString*)category
               authorIdentities:(NSArray *)authorIdentities
                 intensityLevel:(IntensityLevel)level
                    queryString:(NSString *)queryString
                 skipIncomplete:(BOOL)skipIncomplete
                       callback:(FetchItemsCallback)callback
{
	dispatch_async(self.queue, ^{
        NSMutableArray *conditions = [NSMutableArray array];
        NSArray *authorConditions = [self mediaRequestConditionsWithAuthorIdentities:authorIdentities];
        if (authorConditions.count > 0)
            [conditions addObject:[self joinConditions:authorConditions byOperator:@"OR"]];
        if (category)
            [conditions addObject:[NSPredicate predicateWithFormat:@"category ==[cd] %@", category]];
        if (level != IntensityLevelAll)
            [conditions addObject:[NSPredicate predicateWithFormat:@"intensityLevel = %d", level]];
        if (queryString)
            [conditions addObject:[NSPredicate predicateWithFormat:@"name CONTAINS[cd] %@", queryString].predicateFormat];
        if (skipIncomplete)
            [conditions addObject:[NSPredicate predicateWithFormat:@"download = nil OR download.status = %d", DownloadContentStatusCompleeted]];
        NSPredicate* predicate = nil;
        if (conditions.count > 0)
            predicate = [NSPredicate predicateWithFormat:[self joinConditions:conditions byOperator:@"AND"]];
		NSArray* sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:NO]];
		NSFetchedResultsController* controller = [self fetchedResultsControllerForEntityName:@"Workout" withPredicate:predicate andSortDescriptors:sortDescriptors];
        if (callback) callback(nil, controller);
	});
}

-(void)hasNewWorkoutsWithCategory:(NSString *)category
                 authorIdentities:(NSArray *)authorIdentities
                   intensityLevel:(IntensityLevel)level
                         callback:(void (^)(BOOL, NSError *))callback
{
	dispatch_async(self.queue, ^{
        NSMutableArray *conditions = [NSMutableArray array];
        NSArray *authorConditions = [self mediaRequestConditionsWithAuthorIdentities:authorIdentities];
        if (authorConditions.count > 0)
            [conditions addObject:[self joinConditions:authorConditions byOperator:@"OR"]];
        if (category)
            [conditions addObject:[NSPredicate predicateWithFormat:@"category ==[cd] %@", category]];
        if (level != IntensityLevelAll)
            [conditions addObject:[NSPredicate predicateWithFormat:@"intensityLevel = %d", level]];
        [conditions addObject:[NSPredicate predicateWithFormat:@"download != nil AND (download.status = %d OR download.status = %d)",
                               DownloadContentStatusNew, DownloadContentStatusRequested]];
        [self existsEntity:@"Workout" withConditions:conditions callback:callback];
    });
}

- (void)createWorkoutInfo:(WorkoutInfo *)workoutInfo callback:(GetWorkoutCallback)callback
{
    NSParameterAssert(workoutInfo);
	dispatch_async(self.queue, ^{
        // execute
        NSError *error = nil;
        Workout *workout = [Workout createWorkoutWithName:workoutInfo.name
                                           authorIdentity:workoutInfo.identity
                                           intensityLevel:workoutInfo.intensityLevel
                                                inContext:self.context
                                                    error:&error];
        for (ExerciseInfo *info in workoutInfo.exercises) {
            Exercise *exercise = [Exercise createExerciseForMedia:info.media name:info.name];
            exercise.equipment = info.equipment;
            [workout addExercise:exercise withSortOrder:info.sortOrder.intValue];
            for (ExerciseParamsInfo *paramsInfo in info.params) {
                ExerciseParams *params = [ExerciseParams createParamsForExercise:exercise timeInSeconds:paramsInfo.time intensityLevel:paramsInfo.intensityLevel];
                params.reps = @(paramsInfo.reps);
                params.sets = @(paramsInfo.sets);
                params.weight = @(paramsInfo.weight);
            }
        }
        if (callback) callback(error, workout);
	});
}

#pragma mark Upload

-(NSString *)uploadRequestConditionsWithAuthorIdentities:(NSArray *)authorIdentities
{
	NSMutableArray *conditions = [[NSMutableArray alloc] init];
	for (NSString* identity in authorIdentities) {
        [conditions addObject:[NSPredicate predicateWithFormat:@"media.author.identity = %@", identity].predicateFormat];
	}
    return conditions.count > 0 ? [self joinConditions:conditions byOperator:@"OR"] : nil;
}

-(NSPredicate *)uploadRequestPredicateWithAuthorIdentities:(NSArray *)authorIdentities andPredicate:(NSPredicate *)predicate
{
    NSString *authorPredicateString = [self uploadRequestConditionsWithAuthorIdentities:authorIdentities];
    NSMutableArray *conditions = [[NSMutableArray alloc] initWithObjects:authorPredicateString, nil];
    if (predicate != nil) [conditions addObject:predicate.predicateFormat];
    NSPredicate *resultPredicate = conditions.count > 0 ? [NSPredicate predicateWithFormat:[self joinConditions:conditions byOperator:@"AND"]] : nil;
    return resultPredicate;
}

-(void)addMediaToUploadQueue:(Media*) media withVisibility:(UploadRequestVisibility)visibility callback:(ErrorCallback)callback
{
	dispatch_async(self.queue, ^{
        if (!media.uploadRequest) {
            NSError* error = nil;
            [UploadRequest addMedia:media withVisibility:visibility error:&error];
            if (error) {
                if (callback) callback(error);
            } else {
                [self saveChanges:^(NSError *saveError) {
                    if (!saveError) [[UploadDispatcher sharedInstance] resume];
                    callback(saveError);
                }];
            }
        }
	});
}

-(void)retryUploading:(UploadRequest*)uploadRequest callback:(ErrorCallback)callback
{
    dispatch_async(self.queue, ^{
        [uploadRequest retry];
        [self saveChanges:^(NSError *error) {
            if (!error) [[UploadDispatcher sharedInstance] resume];
            if (callback) callback(error);
        }];
    });
}

-(void)stopUploading:(UploadRequest*)uploadRequest callback:(ErrorCallback)callback
{
    dispatch_async(self.queue, ^{
        [uploadRequest stop];
        [self saveChanges:callback];
    });
}

-(void)dataUploaded:(UploadData*)data withError:(NSError*)error
{
	dispatch_async(self.queue, ^{
        
		NSError* requestError = nil;
		NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"UploadFile"];
		request.fetchLimit = 1;
		request.predicate = [NSPredicate predicateWithFormat:@"identity = %@", data.identity];
        
		NSArray *result = [self.context executeFetchRequest:request error:&requestError];
        
		if (requestError || !result.count) return;
        
		UploadFile* file = [result lastObject];
        
		if (!error) {
			file.status = @(UploadFileStatusUploaded);
			file.uploadDate = [NSDate date];
		} else {
			file.status = @(UploadFileStatusFinishedWithError);
		}
		[self saveChangesSync];
	});
}

-(void)uploadRequestCompleeted:(NSString *)uploadRequestIdentity videoKey:(NSString*)videoKey withError:(NSError *)error callback:(ErrorCallback)callback
{
    NSParameterAssert(callback);
	dispatch_async(self.queue, ^{
        
		NSError* requestError = nil;
		NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"UploadRequest"];
		request.fetchLimit = 1;
		request.predicate = [NSPredicate predicateWithFormat:@"identity = %@", uploadRequestIdentity];
        
		NSArray *result = [self.context executeFetchRequest:request error:&requestError];
        
		if (requestError) {
            callback(requestError);
        } else if (!result.count) {
            callback([NSError errorWithText:[NSString stringWithFormat:@"Internal program error. Cannot find upload request with identity '%@'", uploadRequestIdentity]]);
        } else {
            UploadRequest* uploadRequest = [result lastObject];
            if (!error) {
                uploadRequest.uploadDate = [NSDate date];
                uploadRequest.media.videoKey = videoKey;
                if (uploadRequest.status.intValue != UploadRequestStatusStopped) uploadRequest.status = @(UploadRequestStatusProcessing);
                uploadRequest.failedAttempts = @0;
                [uploadRequest updateDependantRequests];
            } else {
                int attempts = uploadRequest.failedAttempts.intValue + 1;
                uploadRequest.failedAttempts = @(attempts);
                if (attempts >= MaxUploadAttempts) {
                    uploadRequest.status = @(UploadRequestStatusUploadedWithError);
                    [uploadRequest updateDependantRequests];
                }
            }
            [self saveChangesSync];
            callback(nil);
        }
	});
}

-(void)clipMetaInfoForUploadRequestIdentity:(NSString *)identity callback:(void(^)(ClipMetaInfo*metaInfo, NSError* error))callback
{
	dispatch_async(self.queue, ^{
        NSError* error = nil;
        ClipMetaInfo *metaInfo = nil;
		NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"UploadRequest"];
		request.fetchLimit = 1;
		request.predicate = [NSPredicate predicateWithFormat:@"identity = %@ AND media.videoKey = nil", identity];
		NSArray *result = [self.context executeFetchRequest:request error:&error];
		if (error || !result.count) {
            callback(metaInfo, error);
            return;
        }
		UploadRequest* uploadRequest = [result lastObject];
		metaInfo = [[ClipMetaInfo alloc] init];
        metaInfo.title = uploadRequest.media.title;
		metaInfo.action = uploadRequest.media.action.name;
		metaInfo.sport = uploadRequest.media.action.sport.name;
		metaInfo.originalFileName = [[NSURL URLWithString:uploadRequest.media.url] lastPathComponent];
        [uploadRequest.media performBlockIfSession:^(Session *session) {
            if (session.originalClip && session.originalClip.videoKey)
                metaInfo.framesKey = session.originalClip.videoKey;
        }];
        callback(metaInfo, error);
	});
}

-(NSPredicate *)uploadRequestsPredicateWithStatus:(UploadRequestStatus)status authorIdentities:(NSArray *)authorIdentities
{
    NSPredicate* statusPredicate = nil;
    switch (status) {
        case UploadRequestStatusAll:
            break;
        case UploadRequestStatusInProgress:
            statusPredicate = [NSPredicate predicateWithFormat:@"status = %d OR status = %d OR status = %d", UploadRequestStatusUploading, UploadRequestStatusProcessing, UploadRequestStatusAwaitingOriginalClipProcessing];
            break;
        default:
            statusPredicate = [NSPredicate predicateWithFormat:@"status = %d", status];
            break;
    }
    return[self uploadRequestPredicateWithAuthorIdentities:authorIdentities andPredicate:statusPredicate];
}

-(void)uploadRequestsWithStatus:(UploadRequestStatus)status authorIdentities:(NSArray *)authorIdentities callback:(FetchItemsCallback)callback
{
    dispatch_async(self.queue, ^{
        NSPredicate *predicate = [self uploadRequestsPredicateWithStatus:status authorIdentities:authorIdentities];
        NSArray *sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"sortOrder" ascending:YES]];
        NSFetchedResultsController* controller = [self fetchedResultsControllerForEntityName:@"UploadRequest" withPredicate:predicate andSortDescriptors:sortDescriptors];
        if (callback) callback(nil, controller);
    });
}

-(void)uploadRequestWithStatus:(UploadRequestStatus)status authorIdentities:(NSArray *)authorIdentities callback:(GetUploadRequestCallback)callback
{
    dispatch_async(self.queue, ^{
		NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"UploadRequest"];
		request.fetchLimit = 1;
		request.predicate = [self uploadRequestsPredicateWithStatus:status authorIdentities:authorIdentities];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"sortOrder" ascending:YES]];
        
        NSError *error = nil;
		NSArray *result = [self.context executeFetchRequest:request error:&error];
        
        if (callback) callback(error, result.lastObject);
    });
}

-(void)nextUploadRequestInfo:(NSArray *)authorIdentities callback:(UploadRequestInfoCallback)callback
{
	dispatch_async(self.queue, ^{
        
        NSPredicate* statusPredicate = [NSPredicate predicateWithFormat:@"status = %d OR status = %d", UploadRequestStatusNotStarted, UploadRequestStatusUploading];
        NSPredicate *predicate = [self uploadRequestPredicateWithAuthorIdentities:authorIdentities andPredicate:statusPredicate];
        
		NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"UploadRequest"];
		request.fetchLimit = 1;
		request.predicate = predicate;
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"sortOrder" ascending:YES],
        [NSSortDescriptor sortDescriptorWithKey:@"requestDate" ascending:YES]];
        
        NSError *error = nil;
		NSArray *result = [self.context executeFetchRequest:request error:&error];
        
        UploadRequest* uploadRequest = nil;
        UploadRequestInfo* info = nil;
		if (!error && result.count) {
            uploadRequest = [result lastObject];
            info = [UploadRequestInfo new];
            info.identity = uploadRequest.identity;
            info.recordingKey = uploadRequest.recordingKey;
            info.uploadURL = [NSURL URLWithString:uploadRequest.uploadURL];
            info.isVstration = [uploadRequest.media isKindOfClass:[Session class]];
            for (UploadFile* file in uploadRequest.files) {
                if (file.uploadDate && file.status.intValue == UploadFileStatusUploaded)
                    continue; // the data was already uploaded
                UploadData* data = [[UploadData alloc] init];
                data.identity = file.identity;
                data.type = file.type.intValue;
                data.url = [NSURL URLWithString:file.url];
                if (data.type == UploadFileTypeTelestration) {
                    NSAssert(info.isVstration, @"Telestration data for non vstrated clip uploading");
                    Session* session = (Session*)uploadRequest.media;
                    MarkupDataCollection* collection = [[MarkupDataCollection alloc] initWithSession:session error:&error];
                    if (error) break;
                    NSString* jsonString = [collection asJSONString];
                    data.content = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
                }
                
                [info addUploadData:data];
            }
        }
        callback(uploadRequest, info, error);
	});
    
}

-(void)nextCompleetedUploadRequestWithoutURL:(NSArray *)authorIdentities sortOrder:(int)sortOrder callback:(void (^)(UploadRequest*, NSError *))callback
{
    dispatch_async(self.queue, ^{
        
        NSPredicate *requestPredicate = [self uploadRequestPredicateWithSortOrder:sortOrder];
        NSPredicate *predicate = [self uploadRequestPredicateWithAuthorIdentities:authorIdentities andPredicate:requestPredicate];
        
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"UploadRequest"];
		request.fetchLimit = 1;
		request.predicate = predicate;
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"sortOrder" ascending:YES]];
        NSError *error = nil;
		NSArray *result = [self.context executeFetchRequest:request error:&error];
        
        UploadRequest* uploadRequest = nil;
        if (!error && result.count == 1) {
            uploadRequest = result.lastObject;
        }
        callback(uploadRequest, error);
    });
}

-(NSPredicate *)uploadRequestPredicateWithSortOrder:(int)sortOrder
{
    NSPredicate *statusPredicate = [NSPredicate predicateWithFormat:@"status = %d", UploadRequestStatusProcessing];
    NSMutableArray *conditions = [[NSMutableArray alloc] initWithObjects:statusPredicate, [self uploadRequestFailedPredicate], nil];
    NSPredicate *sortPredicate = [NSPredicate predicateWithFormat:@"sortOrder > %d", sortOrder];
    [conditions addObject:sortPredicate];
    return conditions.count > 0 ? [NSPredicate predicateWithFormat:[self joinConditions:conditions byOperator:@"AND"]] : nil;
}

-(NSPredicate *)uploadRequestFailedPredicate
{
    NSDate *fiveMinutesAgo = [[NSDate date] dateByAddingTimeInterval:-60*5];
    NSDate *tenMinutesAgo = [[NSDate date] dateByAddingTimeInterval:-60*10];
    NSArray *conditions = @[[NSPredicate predicateWithFormat:@"failedAttempts < 5"],
                            [NSPredicate predicateWithFormat:@"failedAttempts < 10 AND lastSurveyDate <= %@", fiveMinutesAgo],
                            [NSPredicate predicateWithFormat:@"lastSurveyDate <= %@", tenMinutesAgo]];
    return [NSPredicate predicateWithFormat:[self joinConditions:conditions byOperator:@"OR"]];
}

-(void) uploadRequest:(NSString*)identity gotURL:(NSURL*)url withError:(NSError*)error
{
    dispatch_async(self.queue, ^{
        //        NSLog(@"UploadRequest(%@) has got the URL", identity);
        UploadRequest* uploadRequest = [self uploadRequestByIdentity:identity];
        if (!uploadRequest) return;
        uploadRequest.lastSurveyDate = [NSDate date];
        if (error) {
            int attempts = uploadRequest.failedAttempts.intValue + 1;
            uploadRequest.failedAttempts = @(attempts);
            if (attempts >= MaxRetrieveURLAttempts)
                uploadRequest.status = @(UploadRequestStatusProcessedWithError);
        } else {
            NSAssert(url, @"Argument error. url == nil");
            uploadRequest.media.publicURL = url.absoluteString;
            uploadRequest.status = @(UploadRequestStatusCompleeted);
        }
        [self saveChangesSync];
    });
}

-(void)updateUploadRequestWithInfo:(UploadRequestInfo*)info callback:(ErrorCallback)callback
{
    NSParameterAssert(callback);
    dispatch_async(self.queue, ^{
        UploadRequest* request = [self uploadRequestByIdentity:info.identity];
        if (!request) {
            NSError* error = [NSError errorWithText:[NSString stringWithFormat:@"Cannot fetch uploadRequest with identity %@", info.identity]];
            callback(error);
            return;
        }
        request.recordingKey = info.recordingKey;
        request.uploadURL = info.uploadURL.absoluteString;
        [self saveChanges:callback];
    });
}


-(void)changeUploadRequest:(NSString*)identity status:(UploadRequestStatus)status
{
    dispatch_async(self.queue, ^{
        UploadRequest* uploadRequest = [self uploadRequestByIdentity:identity];
        if (!uploadRequest) return;
        uploadRequest.status = [NSNumber numberWithInt:status];
        [self saveChangesSync];
    });
}

-(UploadRequest*)uploadRequestByIdentity:(NSString*)identity
{
    NSAssert(dispatch_get_current_queue() == self.queue, @"uploadRequestByIdentity: The method called in a wrong queue");
    NSFetchRequest* request =  [[NSFetchRequest alloc] initWithEntityName:@"UploadRequest"];
    request.fetchLimit = 1;
    request.predicate = [NSPredicate predicateWithFormat:@"identity = %@", identity];
    NSError *error = nil;
    NSArray *result = [self.context executeFetchRequest:request error:&error];
    UploadRequest* uploadRequest = nil;
    if (!error && result.count == 1) {
        uploadRequest = result.lastObject;
    } else {
        NSLog(@"Cannot get UploadRequest with identity = %@. Error: %@", identity, error);
    }
    return uploadRequest;
}

-(void)fetchNotFinishedRequests:(void (^)(NSArray *, NSError *))callback
{
    NSParameterAssert(callback);
    dispatch_async(self.queue, ^{
        NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"UploadRequest"];
        NSMutableArray* predicates = [NSMutableArray array];
        NSArray* statuses = @[@(UploadRequestStatusNotStarted),
                              @(UploadRequestStatusInProgress),
                              @(UploadRequestStatusAwaitingOriginalClipProcessing)];
        for (NSNumber* status in statuses) {
            [predicates addObject:[NSPredicate predicateWithFormat:@"status = %@", status].predicateFormat];
        }
        request.predicate = [NSPredicate predicateWithFormat:[self joinConditions:predicates byOperator:@"OR"]];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"sortOrder" ascending:YES]];
        NSError* error = nil;
        NSArray* result = [self.context executeFetchRequest:request error:&error];
        callback(error? nil : result, error);
    });
}

#pragma mark Download content

-(void)fetchMediaWithIdentity:(NSString*)identity callback:(void(^)(Media *media, NSError* error))callback
{
    NSParameterAssert(identity);
    NSParameterAssert(callback);
    dispatch_async(self.queue, ^{
        NSFetchRequest* request =  [[NSFetchRequest alloc] initWithEntityName:@"Media"];
        request.fetchLimit = 1;
        request.predicate = [NSPredicate predicateWithFormat:@"identity = %@", identity];
        NSError *error = nil;
        NSArray *result = [self.context executeFetchRequest:request error:&error];
        callback(error ? nil : result.lastObject, error);
    });
}

-(void)nextMediaForThumbnailDownload:(void(^)(Media* media, NSError* error))callback
{
    NSParameterAssert(callback);
    dispatch_async(self.queue, ^{
        NSFetchRequest* request =  [[NSFetchRequest alloc] initWithEntityName:@"Media"];
        request.fetchLimit = 1;
        request.predicate = [NSPredicate predicateWithFormat:@"thumbURL != nil AND thumbnail = nil"];
        NSError *error = nil;
        NSArray *result = [self.context executeFetchRequest:request error:&error];
        callback(error ? nil : result.lastObject, error);
    });
}

-(void)downloadContentWithStatus:(DownloadContentStatus)status authorIdentities:(NSArray *)authorIdentities callback:(FetchItemsCallback)callback
{
    dispatch_async(self.queue, ^{
        NSString* entityName = @"DownloadContent";
        NSMutableArray* conditions = [NSMutableArray new];
        if (status != DownloadContentStatusAll) {
            [conditions addObject:[NSPredicate predicateWithFormat:@"status = %d", status].predicateFormat];
        }
        if (authorIdentities) {
            NSMutableArray* authorConditions = [NSMutableArray new];
            for (NSString* identity in authorIdentities) {
                [authorConditions addObject:[NSPredicate predicateWithFormat:@"media.author.identity =[cd] %@", identity].predicateFormat];
            }
            [conditions addObject:[self joinConditions:authorConditions byOperator:@"OR"]];
        }
        NSPredicate* predicate = conditions.count == 0 ? nil : [NSPredicate predicateWithFormat:[self joinConditions:conditions byOperator:@"AND"]];
        NSArray* sortDescriptors = @[];//WithObject:[NSSortDescriptor sortDescriptorWithKey:@"sortOrder" ascending:YES]];
        NSFetchedResultsController* controller = [self fetchedResultsControllerForEntityName:entityName withPredicate:predicate andSortDescriptors:sortDescriptors];
        if (callback) callback(nil, controller);
    });
}

-(void)findMediaByVideoKey:videoKey callback:(void(^)(Media*,NSError*))callback
{
    NSParameterAssert(callback);
	dispatch_async(self.queue, ^{
		NSError* error = nil;
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Media"];
        request.predicate = [NSPredicate predicateWithFormat:@"videoKey = %@", videoKey];
        NSArray *result = [self.context executeFetchRequest:request error:&error];
        callback(error ? nil : result.lastObject, error);
	});
}

-(void)createMediaForDownload:(NSDictionary*)info callback:(void(^)(Media*,NSError*))callback
{
    NSParameterAssert(callback);
    dispatch_async(self.queue, ^{
        Media* media = nil;
        NSError* error = nil;
        do {
            media = [Media mediaFromObject:info inContext:self.context error:&error];
            if (error) break;
            media.download = [DownloadContent contentFromObject:info inContext:self.context];
            NSArray* setIDs = info[@"setIDs"];
            for (NSString* identity in setIDs) {
                ContentSet* set = [self findContentSetByIdentity:identity error:&error];
                if (error) break;
                if (!set) {
                    error = [NSError errorWithText:@"Cannot find content set to add the media for downloading"];
                    break;
                }
                [set addContentsObject:media.download];
            }
        } while (0);
        callback(media, error);
    });
}

-(ContentSet*)findContentSetByIdentity:(NSString*)identity error:(NSError**)error
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"ContentSet"];
    request.predicate = [NSPredicate predicateWithFormat:@"identity = %@", identity];
    return [[self.context executeFetchRequest:request error:error] lastObject];
}

-(void)findContentSetByIdentity:(NSString *)identity callback:(void (^)(ContentSet *, NSError *))callback
{
    NSParameterAssert(callback);
    dispatch_async(self.queue, ^{
		NSError* error = nil;
        ContentSet* set = [self findContentSetByIdentity:identity error:&error];
        callback(set, error);
    });
}

-(void)createContentSet:(NSDictionary *)info callback:(void (^)(ContentSet *, NSError *))callback
{
    NSParameterAssert(callback);
    dispatch_async(self.queue, ^{
        NSError* error = nil;
        ContentSet* set = [ContentSet contentSetFromObject:info inContext:self.context error:&error];
        callback(set, error);
    });
}

-(void)contentSetByProductID:(NSString *)productIdentifier callback:(void (^)(ContentSet *, NSError *))callback
{
    NSParameterAssert(callback);
    dispatch_async(self.queue, ^{
        NSError* error = nil;
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"ContentSet"];
        request.predicate = [NSPredicate predicateWithFormat:@"inAppPurchaseID = %@", productIdentifier];
        NSArray* result = [self.context executeFetchRequest:request error:&error];
        callback(error ? nil : result.lastObject, error);
    });
}

-(void)fetchContentSets:(FetchItemsCallback)callback
{
    NSParameterAssert(callback);
    dispatch_async(self.queue, ^{
        NSString* entityName = @"ContentSet";
        NSPredicate* predicate = nil;
        NSArray* sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
        NSFetchedResultsController* controller = [self fetchedResultsControllerForEntityName:entityName
                                                                               withPredicate:predicate
                                                                          andSortDescriptors:sortDescriptors];
        callback(nil, controller);
    });
}

-(void)nextDownloadContentRequested:(void(^)(DownloadContent*content, NSError*error))callback
{
    NSParameterAssert(callback);
    dispatch_async(self.queue, ^{
        NSFetchRequest* request = [[NSFetchRequest alloc] initWithEntityName:@"DownloadContent"];
        request.fetchLimit = 1;
        // First try to continue broken download
        request.predicate = [NSPredicate predicateWithFormat:@"media.publicURL != nil AND (status = %d OR status = %d)",
                             DownloadContentStatusInProgress, DownloadContentStatusRequested];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"status" ascending:NO]];
        NSError* error = nil;
        NSArray *result = [self.context executeFetchRequest:request error:&error];
        callback(error ? nil : result.lastObject, error);
    });
}

-(void)findWorkoutById:(NSString*)identity callback:(void(^)(Workout *workout, NSError *error))callback
{
    NSParameterAssert(callback);
	dispatch_async(self.queue, ^{
		NSError* error = nil;
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Workout"];
        request.predicate = [NSPredicate predicateWithFormat:@"identity = %@", identity];
        NSArray *result = [self.context executeFetchRequest:request error:&error];
        callback(error ? nil : result.lastObject, error);
	});
}

-(void)createWorkoutForDownload:(NSDictionary*)info callback:(void(^)(Workout *workout, NSError *error))callback
{
    NSParameterAssert(callback);
    dispatch_async(self.queue, ^{
        NSError* error = nil;
        Workout* workout = [Workout workoutFromObject:info inContext:self.context error:&error];
        workout.download = [DownloadContent contentFromObject:info inContext:self.context];
        callback(workout, error);
    });
}

-(void)findExerciseById:(NSString*)identity callback:(void(^)(Exercise *exercise, NSError *error))callback
{
    NSParameterAssert(callback);
	dispatch_async(self.queue, ^{
		NSError* error = nil;
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Exercise"];
        request.predicate = [NSPredicate predicateWithFormat:@"identity = %@", identity];
        NSArray *result = [self.context executeFetchRequest:request error:&error];
        callback(error ? nil : result.lastObject, error);
	});
}

-(void)createExerciseForDownload:(NSDictionary*)info callback:(void(^)(Exercise *workout, NSError *error))callback
{
    NSParameterAssert(callback);
    dispatch_async(self.queue, ^{
        NSError* error = nil;
        Exercise* exercise = [Exercise exerciseFromObject:info inContext:self.context error:&error];
        exercise.download = [DownloadContent contentFromObject:info inContext:self.context];
        callback(exercise, error);
    });
}

-(void)fetchTrainingEventsFrom:(NSDate*)startDate to:(NSDate*)endDate callback:(FetchItemsCallback)callback
{
    NSParameterAssert(callback);
    NSParameterAssert(startDate);
    NSParameterAssert(endDate);
    dispatch_async(self.queue, ^{
        NSString* identity = [AccountController2 sharedInstance].userIdentity;
        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"user.identity = %@ AND date >= %@ AND date < %@", identity, startDate, endDate];
		NSArray* sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO]];
		NSFetchedResultsController* controller = [self fetchedResultsControllerForEntityName:@"TrainingEvent" withPredicate:predicate andSortDescriptors:sortDescriptors];
        callback(nil, controller);
    });
}

-(void)allTrainingEventsWithCallback:(void(^)(NSArray* result, NSError* error))callback
{
    NSParameterAssert(callback);
    dispatch_async(self.queue, ^{
		NSError* error = nil;
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"TrainingEvent"];
        NSArray *result = [self.context executeFetchRequest:request error:&error];
        callback(error ? nil : result, error);
    });
}

#pragma mark - Notifications

-(void)getLastNotification:(void (^)(Notification *, NSError *))callback
{
    NSParameterAssert(callback);
    dispatch_async(self.queue, ^{
        NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"Notification"];
        request.predicate = [NSPredicate predicateWithFormat:@"pushedButtonIdentity = nil"];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES]];
        request.fetchLimit = 1;
        NSError* error = nil;
        NSArray* result = [self.context executeFetchRequest:request error:&error];
        callback(error ? nil : result.lastObject, error);
    });
}

-(void)pushNotificationButton:(NotificationButton*)button callback:(ErrorCallback)callback
{
    NSParameterAssert(button);
    NSParameterAssert(callback);
    dispatch_async(self.queue, ^{
        button.notification.pushedButtonIdentity = button.identity;
        [self saveChanges:callback];
    });
}

-(void)addNotificationInfo:(NotificationInfo*)info forUserIdentity:(NSString*)identity callback:(ErrorCallback)callback
{
    NSParameterAssert(info);
    dispatch_async(self.queue, ^{
        NSError* error = nil;
        User *user = [User findUserWithIdentity:identity inContext:self.context error:&error];
        if (error) {
            if (callback) callback(error);
            return;
        }
        [Notification notificationFromInfo:info forUser:user inContext:self.context error:&error];
        if (error) {
            if (callback) callback(error);
            return;
        }
        [self saveChanges:^(NSError *savingError) {
            if (savingError) [self rollbackChanges:nil];
            if (callback) callback(savingError);
        }];
    });
}

@end
