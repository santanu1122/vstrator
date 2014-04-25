//
//  Notification.m
//  VstratorCore
//
//  Created by akupr on 22.10.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <RestKit/RestKit.h>
#import "NotificationInfo.h"
#import "NotificationButtonInfo.h"

@implementation NotificationInfo

+(RKObjectMapping *)mapping
{
	RKObjectMapping* mapping = [RKObjectMapping mappingForClass:[NotificationInfo class]];
    [mapping addAttributeMappingsFromDictionary:@{
     @"ID": @"identity",
     @"NotificationType": @"type",
     @"ContentType": @"contentType",
     @"Title": @"title",
     @"Body": @"body",
     @"ImageURI": @"imageURL",
     @"AdditionalNotification": @"additionalNotification"}];
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"NotificationButtons" toKeyPath:@"buttons" withMapping:[NotificationButtonInfo mapping]]];
	return mapping;
}

@end
