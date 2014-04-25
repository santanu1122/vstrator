//
//  ChangePasswordInfo.m
//  VstratorCore
//
//  Created by akupr on 10.09.13.
//  Copyright (c) 2013 OnTarget. All rights reserved.
//

#import <RestKit/RestKit.h>
#import "ChangePasswordInfo.h"

@implementation ChangePasswordInfo

+(RKObjectMapping *)serialization
{
    RKObjectMapping* mapping = [RKObjectMapping requestMapping];
    [mapping addAttributeMappingsFromDictionary:@{
     @"oldPassword": @"oldPassword",
     @"password": @"newPassword"}];
    return mapping;
}

@end
