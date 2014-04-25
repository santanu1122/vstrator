//
//  NotificationButton.h
//  VstratorCore
//
//  Created by akupr on 22.10.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Notification;

@interface NotificationButton : NSManagedObject

@property (nonatomic, retain) NSString * identity;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSNumber * mediaType;
@property (nonatomic, retain) NSString * mediaIdentity;
@property (nonatomic, retain) NSString * clickURL;
@property (nonatomic, retain) Notification *notification;

@end
