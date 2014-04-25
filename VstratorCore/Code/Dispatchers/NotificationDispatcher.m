//
//  NotificationDispatcher.m
//  VstratorCore
//
//  Created by akupr on 23.10.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "BackgroundTaskWrapper.h"
#import "NotificationDispatcher.h"
#import "MediaService.h"
#import "ServiceFactory.h"
#import "AccountController2.h"
#import "Notification.h"

static const NSTimeInterval SleepTime = 30.;

static NotificationDispatcher* SharedInstance;

@interface NotificationDispatcher()

@property (atomic) BOOL needToStop;
@property (atomic) BOOL inProgress;
@property (nonatomic, strong, readonly) MediaService* mediaService;
@property (nonatomic, strong, readonly) id<NotificationService> notificationService;

@end

@implementation NotificationDispatcher

#pragma mark - Properties

@synthesize needToStop = _needToStop;
@synthesize mediaService = _mediaService;
@synthesize notificationService = _notificationService;

-(MediaService *)mediaService
{
    return _mediaService ? _mediaService : (_mediaService = [MediaService new]);
}

-(id<NotificationService>)notificationService
{
    return _notificationService ? _notificationService : (_notificationService = [[ServiceFactory sharedInstance] createNotificationService]);
}

#pragma mark - Interface

+(NotificationDispatcher *)sharedInstance
{
    return SharedInstance ? SharedInstance : (SharedInstance = [NotificationDispatcher new]);
}

-(void)start
{
    self.needToStop = NO;
    [self fetchNotificationsAsync];
}

-(void)stop
{
    self.needToStop = YES;
}

#pragma mark - Internal

-(void)fetchNotificationsAsync
{
    @synchronized(self) {
        if (self.inProgress) return;
        self.inProgress = YES;
    }
    [[BackgroundTaskWrapper wrapperWithTask:^{
        while (!self.needToStop) {
            if (![self fetchNotification] && !self.needToStop) [NSThread sleepForTimeInterval:SleepTime];
        }
        @synchronized(self) {
            self.inProgress = NO;
        }
    }] run];
}

-(BOOL)fetchNotification
{
    dispatch_semaphore_t ds = dispatch_semaphore_create(0);
    [self.notificationService getNotification:^(NotificationInfo *info, NSError *error) {
        if (error || !info) {
            if (error) NSLog(@"Cannot fetch notification. Error: %@", error);
            dispatch_semaphore_signal(ds);
        } else {
            [self.mediaService addNotificationInfo:info
                                   forUserIdentity:AccountController2.sharedInstance.userIdentity
                                          callback:^(NSError* savingError)
             {
                 if (savingError) {
                     NSLog(@"Cannot save notification. Error: %@", savingError);
                 }
                 dispatch_semaphore_signal(ds);
             }];
        }
    }];
    dispatch_semaphore_wait(ds, DISPATCH_TIME_FOREVER);
    dispatch_release(ds);
    return NO;
}

@end
