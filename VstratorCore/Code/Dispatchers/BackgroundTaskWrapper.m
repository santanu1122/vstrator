//
//  BackgroundTaskWrapper.m
//  VstratorCore
//
//  Created by akupr on 11.03.13.
//  Copyright (c) 2013 OnTarget. All rights reserved.
//

#import "BackgroundTaskWrapper.h"

@interface BackgroundTaskWrapper()

@property (nonatomic, copy) Callback0 task;
@property (nonatomic, copy) Callback0 expirationHandler;

@end

@implementation BackgroundTaskWrapper

-(id)initWithTask:(Callback0)task
{
    return [self initWithTask:task expirationHandler:nil];
}

-(id)initWithTask:(Callback0)task expirationHandler:(Callback0)handler
{
    self = [self init];
    if (self) {
        self.task = task;
        self.expirationHandler = handler;
    }
    return self;
}

-(void)run
{
    __block BackgroundTaskWrapper *saveSelf = self;
    __block UIBackgroundTaskIdentifier *bgTask = nil;
    Callback0 cleanup = ^{
        if (saveSelf.expirationHandler) saveSelf.expirationHandler();
        [[UIApplication sharedApplication] endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
        saveSelf = nil;
    };
    bgTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:cleanup];

    dispatch_queue_t queue = dispatch_queue_create("Background task", 0);
    dispatch_async(queue, ^{
        _task();
        cleanup();
    });
    dispatch_release(queue);
}

+(BackgroundTaskWrapper *)wrapperWithTask:(Callback0)task
{
    return [[BackgroundTaskWrapper alloc] initWithTask:task];
}

+(BackgroundTaskWrapper *)wrapperWithTask:(Callback0)task expirationHandler:(Callback0)handler
{
    return [[BackgroundTaskWrapper alloc] initWithTask:task expirationHandler:handler];
}

@end
