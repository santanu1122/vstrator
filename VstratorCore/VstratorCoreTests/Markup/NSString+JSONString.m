//
//  NSString+JSONString.m
//  VstratorCore
//
//  Created by akupr on 28.08.13.
//  Copyright (c) 2013 OnTarget. All rights reserved.
//

#import "NSString+JSONString.h"

@implementation NSString (JSONString)

-(id)objectFromJSONString
{
    NSError* dontUsed = nil;
    return [NSJSONSerialization JSONObjectWithData:[self dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&dontUsed];
}

@end
