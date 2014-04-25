//
//  VideoStatusInfo.m
//  VstratorCore
//
//  Created by akupr on 12.09.13.
//  Copyright (c) 2013 OnTarget. All rights reserved.
//

#import <RestKit/RestKit.h>
#import "VideoStatusInfo.h"

@implementation VideoStatusInfo

+(RKObjectMapping *)mapping
{
    RKObjectMapping* mapping = [RKObjectMapping mappingForClass:self];
    [mapping addAttributeMappingsFromArray:@[
     @"videoKeyType",
     @"encodingStatus",
     @"title",
     @"videoDate",
     @"videoKey"]];
    [mapping addAttributeMappingsFromDictionary:@{@"videoUrl": @"videoURL"}];
    return mapping;
}

@end
