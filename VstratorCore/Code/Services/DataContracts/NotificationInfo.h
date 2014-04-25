//
//  Notification.h
//  VstratorCore
//
//  Created by akupr on 22.10.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Mappable.h"
#import "NotificationTypes.h"

@interface NotificationInfo : NSObject<Mappable>

@property (nonatomic, copy) NSString* identity;
@property (nonatomic) NotificationType type;
@property (nonatomic) NotificationContentType contentType;
@property (nonatomic, copy) NSString* title;
@property (nonatomic, copy) NSString* body;
@property (nonatomic, strong) NSURL* imageURL;
@property (nonatomic) BOOL additionalNotification;
@property (nonatomic, strong) NSArray* buttons;

@end
