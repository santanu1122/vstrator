//
//  Notification.h
//  VstratorCore
//
//  Created by akupr on 24.10.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class NotificationButton, User;

@interface Notification : NSManagedObject

@property (nonatomic, retain) NSNumber * additionalNotifications;
@property (nonatomic, retain) NSString * body;
@property (nonatomic, retain) NSNumber * contentType;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * identity;
@property (nonatomic, retain) NSData * image;
@property (nonatomic, retain) NSString * imageURL;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSString * pushedButtonIdentity;
@property (nonatomic, retain) NSSet *buttons;
@property (nonatomic, retain) User *user;
@end

@interface Notification (CoreDataGeneratedAccessors)

- (void)addButtonsObject:(NotificationButton *)value;
- (void)removeButtonsObject:(NotificationButton *)value;
- (void)addButtons:(NSSet *)values;
- (void)removeButtons:(NSSet *)values;

@end
