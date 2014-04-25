//
//  SportInfo.m
//  VstratorApp
//
//  Created by user on 19.04.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <RestKit/RestKit.h>
#import "SportInfo.h"

@implementation SportInfo

+(RKObjectMapping*) mapping
{
	RKObjectMapping* mapping = [RKObjectMapping mappingForClass:[SportInfo class]];
    [mapping addAttributeMappingsFromDictionary:@{
     @"id": @"identity",
     @"sport":@"sport",
     @"actions":@"actions"}];
	return mapping;
}

@end
