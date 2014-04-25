//
//  NotificationTypes.h
//  VstratorCore
//
//  Created by Virtualler on 14.11.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#ifndef VstratorCore_NotificationTypes_h
#define VstratorCore_NotificationTypes_h

typedef enum {
    NotificationTypeApplication = 0,
    NotificationTypeSystemWide = 1
} NotificationType;

typedef enum {
    NotificationContentTypePlainText = 0,
    NotificationContentTypeHTML = 1, // Reserved for future use
    NotificationContentTypeImageOnly = 2,
} NotificationContentType;

typedef enum {
    NotificationButtonTypeStandard = 0,
    NotificationButtonTypeCancel = 1, // Cancel/Close
    NotificationButtonTypeAlert = 2, // Alert/Delete
    NotificationButtonTypeMediaDownload = 3
} NotificationButtonType;

#endif
