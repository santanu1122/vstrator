//
//  ClipMetaInfo.m
//  VstratorApp
//
//  Created by user on 23.05.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <RestKit/RestKit.h>
#import "ClipMetaInfo.h"

@implementation ClipMetaInfo

+(RKObjectMapping*) mapping
{
	RKObjectMapping* mapping = [RKObjectMapping mappingForClass:[ClipMetaInfo class]];
    [mapping addAttributeMappingsFromDictionary:@{
     @"recordingKey": @"recordingKey",
     @"userKey": @"userKey",
     @"siteKey": @"siteKey",
     @"coachKey": @"coachKey",
     @"title": @"title",
     @"notes": @"notes",
     @"sport": @"sport",
     @"action": @"action",
     @"originalFileName": @"originalFileName",
     @"framesKey": @"framesKey",
     @"isImage": @"isImage",
     @"activityDate": @"activityDate",
     @"notifyAthlete": @"notifyAthlete"}];
	return mapping;
}

+(RKObjectMapping *)serialization
{
    RKObjectMapping* mapping = [RKObjectMapping requestMapping];
    [mapping addAttributeMappingsFromArray:@[
     @"title",
     @"recordingKey",
     @"userKey",
     @"sport",
     @"action",
     @"originalFileName",
     @"framesKey"]];
    [mapping addAttributeMappingsFromDictionary:@{@"activityDateFormatted": @"activityDate"}];
    return mapping;
}

-(NSString *)activityDateFormatted
{
	return [NSDateFormatter localizedStringFromDate:self.activityDate
                                          dateStyle:NSDateFormatterShortStyle
                                          timeStyle:NSDateFormatterShortStyle];
}

@end
