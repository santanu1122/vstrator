//
//  Notification+Extensions.h
//  VstratorCore
//
//  Created by akupr on 23.10.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "Notification.h"

@class NotificationInfo;

@interface Notification (Extensions)

+(Notification*)notificationFromInfo:(NotificationInfo*)info forUser:(User*)user inContext:(NSManagedObjectContext*)context error:(NSError**)error;

@end
