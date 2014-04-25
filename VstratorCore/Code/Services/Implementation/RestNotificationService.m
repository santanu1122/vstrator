//
//  RestNotificationService.m
//  VstratorCore
//
//  Created by akupr on 23.10.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "RestNotificationService.h"
#import "NSError+Extensions.h"
#import "NotificationInfo.h"

@implementation RestNotificationService

-(void)getNotification:(void (^)(NotificationInfo *, NSError *))callback
{
    NSParameterAssert(self.delegate);
    NSParameterAssert(callback);
    BOOL userIsLoggedIn = [self.delegate userIsLoggedIn];

    // appnotification is turned off temporary
    if (!userIsLoggedIn) {
        callback(nil, nil);
        return;
    }
    NSString* path = userIsLoggedIn ? @"notification" : @"appnotifications";
    [[self.delegate objectManager] getObjectsAtPath:path parameters:[self.delegate parameters] success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        callback(mappingResult.firstObject, nil);
    } failure:[self errorCallbackWrapper1:callback]];
}

-(void)pushTheButtonWithIdentity:(NSString *)buttonIdentity callback:(ErrorCallback)callback
{
    NSParameterAssert(self.delegate);
    NSParameterAssert(callback);
    NSString* path = [self.delegate userIsLoggedIn] ? @"notification" : @"appnotifications";
    [[self.delegate objectManager] putObject:nil path:[path stringByAppendingPathComponent:buttonIdentity] parameters:[self.delegate parameters] success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        callback(nil);
    } failure:[self errorCallbackWrapper:callback]];
}

@end
