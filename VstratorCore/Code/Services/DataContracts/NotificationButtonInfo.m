//
//  NotificationButtonInfo.m
//  VstratorCore
//
//  Created by akupr on 22.10.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <RestKit/RestKit.h>
#import "NotificationButtonInfo.h"

@implementation NotificationButtonInfo

+(RKObjectMapping *)mapping
{
	RKObjectMapping* mapping = [RKObjectMapping mappingForClass:[NotificationButtonInfo class]];
    [mapping addAttributeMappingsFromDictionary:@{
     @"ID": @"identity",
     @"ButtonText": @"text",
     @"ButtonType": @"type",
     @"MediaType": @"mediaType",
     @"MediaID": @"mediaIdentity",
     @"ClickURI": @"clickURL"}];
	return mapping;
}

@end
