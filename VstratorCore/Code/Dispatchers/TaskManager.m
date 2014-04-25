//
//  TaskManager.m
//  VstratorCore
//
//  Created by akupr on 07.11.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "TaskManager.h"
#import "DownloadDispatcher.h"
#import "UploadDispatcher.h"
#import "ImageGenerationDispatcher.h"
#import "NotificationDispatcher.h"
#import "VstratorAppServices.h"

@implementation TaskManager

#pragma mark Properties

static int _tasksCount;
static TaskManager *_sharedInstance;

+(TaskManager *)sharedInstance
{
    return _sharedInstance ? _sharedInstance : (_sharedInstance = [TaskManager new]);
}

#pragma mark Persistent Dispatchers

-(void)startPersistentDispatchers
{
    if (_tasksCount)
        NSLog(@"Warning! TaskCount != 0 on dispatchers start");
    NSLog(@"Starting persistent dispatchers");
#ifdef kVANotificationDispatcherActive
    [NotificationDispatcher.sharedInstance start];
#endif
    [ImageGenerationDispatcher.sharedInstance start];
}

- (void)stopPersistentDispatchers
{
    NSLog(@"Stopping persistent dispatchers");
#ifdef kVANotificationDispatcherActive
    [NotificationDispatcher.sharedInstance stop];
#endif
    [ImageGenerationDispatcher.sharedInstance stop];
}

#pragma mark Task-Based Dispatchers

- (void)startTaskDispatchers
{
    if (_tasksCount)
        NSLog(@"Warning! TaskCount != 0 on dispatchers start");
    NSLog(@"Starting task-based dispatchers");
#ifdef kVADownloadDispatcherActive
    [DownloadDispatcher.sharedInstance start];
#endif
#ifdef kVAUploadDispatcherActive
    [UploadDispatcher.sharedInstance start];
#endif
}

- (void)stopTaskDispatchers
{
    NSLog(@"Stopping task-based dispatchers");
#ifdef kVADownloadDispatcherActive
    [DownloadDispatcher.sharedInstance stop];
#endif
#ifdef kVAUploadDispatcherActive
    [UploadDispatcher.sharedInstance stop];
#endif
}

@end
