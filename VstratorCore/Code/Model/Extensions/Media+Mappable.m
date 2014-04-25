//
//  Media+Mappable.m
//  VstratorCore
//
//  Created by akupr on 13.09.13.
//  Copyright (c) 2013 OnTarget. All rights reserved.
//

#import <RestKit/RestKit.h>
#import "Media+Mappable.h"

@implementation Media (Mappable)

+(RKObjectMapping *)serialization
{
    RKObjectMapping* mapping = [RKObjectMapping requestMapping];
    [mapping addAttributeMappingsFromDictionary:@{
     @"title": @"title",
     @"videoKey": @"videoKey",
     @"action.name": @"action",
     @"action.sport.name": @"sport",
     @"note": @"notes",
     @"isPrivate" : @"isPrivate",
     @"isPublic" : @"isPublic"
     }];
    return mapping;
}

-(BOOL)isPublic { return YES; }
-(BOOL)isPrivate { return NO; }

@end
