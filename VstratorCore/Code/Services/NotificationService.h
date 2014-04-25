//
//  NotificationService.h
//  VstratorCore
//
//  Created by akupr on 22.10.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Callbacks.h"

@class NotificationInfo, NotificationButtonInfo;

@protocol NotificationService

-(void)getNotification:(void(^)(NotificationInfo* notification, NSError* error))callback;
-(void)pushTheButtonWithIdentity:(NSString*)buttonIdentity callback:(ErrorCallback)callback;

@end
