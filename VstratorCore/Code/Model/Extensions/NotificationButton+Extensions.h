//
//  NotificationButton+Extensions.h
//  VstratorCore
//
//  Created by akupr on 24.10.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "NotificationButton.h"

@class NotificationButtonInfo;

@interface NotificationButton (Extensions)

+(NotificationButton*)buttonFromButtonInfo:(NotificationButtonInfo*)info inContext:(NSManagedObjectContext*)context;

@end
