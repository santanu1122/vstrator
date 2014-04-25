//
//  ImageGenerationDispatcher.m
//  VstratorCore
//
//  Created by akupr on 17.10.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "BackgroundTaskWrapper.h"
#import "ImageGenerationDispatcher.h"
#import "MediaService.h"
#import "MediaImagesGenerator.h"

@interface ImageGenerationDispatcher()

@property (atomic) BOOL running;
@property (atomic) BOOL stopRequested;
@property (atomic) BOOL backgroudTaskExpired;

@property (nonatomic, strong, readonly) MediaService *mediaService;
@property (nonatomic, strong, readonly) NSMutableArray* mediaStack;
@property (nonatomic, strong, readonly) NSMutableDictionary* waitings;
@property (nonatomic, strong) NSError* processingError;
@property (nonatomic, strong) MediaImagesGenerator* generator;

@end

@implementation ImageGenerationDispatcher

#pragma mark Properties

static ImageGenerationDispatcher* _sharedInstance;

@synthesize backgroudTaskExpired = _backgroudTaskExpired;
@synthesize running = _running;
@synthesize mediaService = _mediaService;

+(ImageGenerationDispatcher*)sharedInstance
{
    return _sharedInstance ? _sharedInstance : (_sharedInstance = [ImageGenerationDispatcher new]);
}

-(MediaService *)mediaService
{
	return _mediaService ? _mediaService : (_mediaService = [MediaService new]);
}

- (BOOL)running
{
    @synchronized (self) {
        return _running;
    }
}

- (void)setRunning:(BOOL)running
{
    @synchronized (self) {
        _running = running;
    }
}

-(BOOL)backgroudTaskExpired
{
    @synchronized (self) {
        return _backgroudTaskExpired;
    }
}

-(void)setBackgroudTaskExpired:(BOOL)backgroudTaskExpired
{
    @synchronized (self) {
        _backgroudTaskExpired = backgroudTaskExpired;
    }
}

#pragma mark Ctor

- (id)init
{
    self = [super init];
    if (self) {
        _mediaStack = [NSMutableArray new];
        _waitings = [NSMutableDictionary new];
    }
    return self;
}

#pragma mark State

-(void)start
{
    self.stopRequested = NO;
    [self fetchAvailableMediaAsync:^(NSError *error) {
        if (error) {
            NSLog(@"Cannot fetch available media for the processing images generation. Error: %@", error);
            return;
        }
        [self processAvailableMediaAsync];
    }];
}

-(void)resume
{
    self.stopRequested = NO;
    [self processAvailableMediaAsync];
}

-(void)stop
{
    self.stopRequested = YES;
    [self.generator stop];
}

#pragma mark Control File

+(void)writeControlFileToFolder:(NSString*)folder
{
    NSError* error = nil;
    [@"Images generated" writeToFile:[folder stringByAppendingPathComponent:@"control.00.txt"] atomically:YES encoding:NSUTF8StringEncoding error:&error];
    if (error)
        NSLog(@"Cannot write control file to folder '%@'. Error: %@", folder, error);
}

+(BOOL)controlFileExistInFolder:(NSString*)folder
{
    return [[NSFileManager defaultManager] fileExistsAtPath:[folder stringByAppendingPathComponent:@"control.00.txt"]];
}

#pragma mark Processors

-(void)fetchAvailableMediaAsync:(ErrorCallback)callback
{
    [self.mediaService fetchAllMediaInCallback:^(NSArray *mediaList, NSError *error) {
        if (!error) @synchronized(self.mediaStack) {
            [self.mediaStack removeAllObjects];
            for (Media* media in mediaList) {
                if (!media.url) continue;
                [media performBlockIfClip:^(Clip *clip) {
                    if (![self.class controlFileExistInFolder:clip.playbackImagesFolder]) {
                        [self.mediaStack addObject:clip.identity];
                    }
                } orSession:^(Session *session) {
                    if (!session.originalClip) {
                        if (![self.class controlFileExistInFolder:session.playbackImagesFolder])
                            [self.mediaStack addObject:session.identity];
                    } else {
                        if (![self.class controlFileExistInFolder:session.originalClip.playbackImagesFolder])
                            [self.mediaStack addObject:session.originalClip.identity];
                        if (session.originalClip2 && ![self.class controlFileExistInFolder:session.originalClip2.playbackImagesFolder])
                            [self.mediaStack addObject:session.originalClip2.identity];
                    }
                }];
            }
        }
        if (callback) callback(error);
    }];
}

-(void)processAvailableMediaAsync
{
    if (self.running) return;
    self.running = YES;
    self.backgroudTaskExpired = NO;
    [[BackgroundTaskWrapper wrapperWithTask:^{
        while (!self.stopRequested) {
            NSString* identity = [self popNextMediaIdentity];
            if (!identity) break;
            [self processMediaWithIdentity:identity];
        }
        _mediaService = nil;
        self.running = NO;
    } expirationHandler:^{
        self.backgroudTaskExpired = YES;
        [self stop];
        self.running = NO;
    }] run];
}

-(void)processMediaWithIdentity:(NSString*)identity
{
    dispatch_semaphore_t ds = dispatch_semaphore_create(0);
    [self.mediaService fetchMediaWithIdentity:identity callback:^(Media *media, NSError *error) {
        if (error || !media) {
            NSLog(@"Cannot fetch media with identity '%@'. Error: %@", identity, error);
            [self notifyMediaProcessed:identity withError:error];
            dispatch_semaphore_signal(ds);
        } else {
            [self processMedia:media callback:^(NSError *processError) {
                dispatch_semaphore_signal(ds);
            }];
        }
    }];
    dispatch_semaphore_wait(ds, DISPATCH_TIME_FOREVER);
    dispatch_release(ds);
    _mediaService = nil;
}

-(void)processMedia:(Media*)media callback:(ErrorCallback)callback
{
    NSString* folder = media.playbackImagesFolder;
    // skip existing
    if ([self.class controlFileExistInFolder:folder]) {
        callback(nil);
        return;
    }
    // use playback URL if possible
    __block NSURL* url = [NSURL URLWithString:media.url];
    [media performBlockIfClip:^(Clip *clip) {
        if (clip.existsPlaybackQuality) url = [NSURL fileURLWithPath:clip.pathForPlaybackQuality];
    }];
    NSString* identity = media.identity;
    self.generator = [MediaImagesGenerator new];
    [self.generator generateImagesWithMediaURL:url inFolder:folder callback:^(BOOL compleeted, NSError *error) {
        if (error) {
            NSLog(@"Cannot generate media images. Error: %@", error);
        } else if (compleeted) {
            [self.class writeControlFileToFolder:folder];
            [self notifyMediaProcessed:identity withError:error];
        } else {
            [self pushBackIdentity:identity]; // incomplete processing, push the media identity again
        }
        self.generator = nil;
        callback(error);
    }];
}

#pragma mark Waitings

-(void)notifyMediaProcessed:(NSString*)identity withError:(NSError*)error
{
    @synchronized(self.waitings) {
        NSValue* value = self.waitings[identity];
        if (value) {
            if (error) self.processingError = error;
            [self.waitings removeObjectForKey:identity];
            if (!self.waitings.count) {
                dispatch_semaphore_signal((dispatch_semaphore_t)value.pointerValue);
            }
        }
    }
}

-(void)addWaiting:(NSString*)identity semaphore:(dispatch_semaphore_t)ds
{
    self.waitings[identity] = [NSValue valueWithPointer:ds];
}

-(NSArray*)filterAlreadyProcessed:(NSArray*)identities
{
    NSMutableArray* notProcessed = [NSMutableArray array];
    for (NSString* identity in identities) {
        dispatch_semaphore_t ds = dispatch_semaphore_create(0);
        [self.mediaService fetchMediaWithIdentity:identity callback:^(Media *media, NSError *error) {
            if (error || ![self.class controlFileExistInFolder:media.playbackImagesFolder]) {
                [notProcessed addObject:identity];
            }
            dispatch_semaphore_signal(ds);
        }];
        dispatch_semaphore_wait(ds, DISPATCH_TIME_FOREVER);
        dispatch_release(ds);
    }
    return notProcessed;
}

-(void)waitForIdentitiesProcessed:(NSArray*)identities callback:(ErrorCallback)callback
{
    NSParameterAssert(callback);
    identities = [self filterAlreadyProcessed:identities];
    if (identities.count == 0) {
        callback(nil);
        return;
    }
    dispatch_queue_t queue = dispatch_queue_create("Waiting queue", 0);
    dispatch_async(queue, ^{
        dispatch_semaphore_t ds = dispatch_semaphore_create(0);
        @synchronized(self.waitings) {
            for (NSString* identity in identities) {
                [self addWaiting:identity semaphore:ds];
            }
            [self pushIdentities:identities];
        }
        dispatch_semaphore_wait(ds, DISPATCH_TIME_FOREVER);
        dispatch_release(ds);
        NSError* error = self.processingError;
        self.processingError = nil;
        dispatch_async(dispatch_get_main_queue(), ^{ callback(error); });
    });
    dispatch_release(queue);
}

+(BOOL)checkIdentityProcessedInFolder:(NSString *)folder
{
    return [self.class controlFileExistInFolder:folder];
}

#pragma mark Media Stack

-(NSString*)popNextMediaIdentity
{
    NSString* identity = nil;
    @synchronized(self.mediaStack) {
        identity = [self.mediaStack lastObject];
        if (identity) [self.mediaStack removeLastObject];
    }
    return identity;
}

-(void)pushMedia:(Media *)media
{
    @synchronized(self.mediaStack) {
        [media performBlockIfClip:^(Clip *clip) {
            [self.mediaStack addObject:media.identity];
        } orSession:^(Session *session) {
            if (session.originalClip2)
                [self.mediaStack addObject:session.originalClip2.identity];
            if (session.originalClip)
                [self.mediaStack addObject:session.originalClip.identity];
            else
                [self.mediaStack addObject:session.identity];
        }];
    }
    [self resume];
}

-(void)pushIdentities:(NSArray*)identities
{
    @synchronized(self.mediaStack) {
        for (NSString* identity in identities) {
            [self.mediaStack addObject:identity];
        }
    }
    [self resume];
}

-(void)pushBackIdentity:(NSString*)identity
{
    @synchronized(self.mediaStack) {
        [self.mediaStack addObject:identity];
    }
}

-(void)addMediaToProcessing:(Media *)media
{
    [self pushMedia:media];
}

@end
