//
//  MediaTypeInfo.m
//  VstratorApp
//
//  Created by akupr on 29.07.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "MediaTypeInfo.h"
#import <RestKit/RestKit.h>

@implementation MediaTypeInfo

+(RKObjectMapping *)mapping
{
	RKObjectMapping* mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromDictionary:@{
     @"VstratorAppID": @"applicationId",
     @"MediaType": @"mediaType",
     @"Title": @"title"}];
	return mapping;
}

@end
