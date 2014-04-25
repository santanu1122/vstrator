//
//  Notification+Extensions.m
//  VstratorCore
//
//  Created by akupr on 23.10.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "Notification+Extensions.h"
#import "NotificationInfo.h"
#import "NotificationButton+Extensions.h"
#import "VstratorStrings.h"
#import "NSError+Extensions.h"

@class NotificationButtonInfo, User;

@implementation Notification (Extensions)

+(Notification *)notificationFromInfo:(NotificationInfo *)info forUser:(User*)user inContext:(NSManagedObjectContext *)context error:(NSError**)error
{
    NSParameterAssert(!*error);
    Notification* notification = [self notificationWithIdentity:info.identity inContext:context error:error];
    if (*error) return nil;
    if (notification) return notification;
    notification = [NSEntityDescription insertNewObjectForEntityForName:@"Notification" inManagedObjectContext:context];
    notification.identity = info.identity;
    notification.type = @(info.type);
    notification.contentType = @(info.contentType);
    notification.title = info.title;
    notification.body = info.body;
    notification.imageURL = info.imageURL.absoluteString;
    notification.image = [NSData dataWithContentsOfURL:info.imageURL];
    notification.additionalNotifications = @(info.additionalNotification);
    notification.date = [NSDate date];
    for (NotificationButtonInfo* b in info.buttons) {
        [notification addButtonsObject:[NotificationButton buttonFromButtonInfo:b inContext:context]];
    }
    notification.user = user;
//    notification.image = ;
    return notification;
}

+(Notification*)notificationWithIdentity:(NSString *)identity
             inContext:(NSManagedObjectContext *)context
                 error:(NSError **)error
{
	NSFetchRequest* request = [[NSFetchRequest alloc] initWithEntityName:@"Notification"];
	request.predicate = [NSPredicate predicateWithFormat:@"identity = %@", identity];
	NSArray* result = [context executeFetchRequest:request error:error];
    if (*error || !result) {
        *error = [NSError errorWithError:*error text:VstratorStrings.ErrorDatabaseSelectText];
        return nil;
    }
    return result.count > 0 ? result.lastObject : nil;
}


@end
