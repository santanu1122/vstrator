//
//  SystemInformation.m
//  VstratorCore
//
//  Created by Admin1 on 19.09.13.
//  Copyright (c) 2013 OnTarget. All rights reserved.
//

#import "SystemInformation.h"

@implementation SystemInformation

+ (BOOL)isSystemVersionEqualTo:(NSString *)version
{
    return [[[UIDevice currentDevice] systemVersion] compare:version options:NSNumericSearch] == NSOrderedSame;
}

+ (BOOL)isSystemVersionGreaterThan:(NSString *)version
{
    return [[[UIDevice currentDevice] systemVersion] compare:version options:NSNumericSearch] == NSOrderedDescending;
}

+ (BOOL)isSystemVersionGreaterOrEqualTo:(NSString*)version
{
    return [[[UIDevice currentDevice] systemVersion] compare:version options:NSNumericSearch] != NSOrderedAscending;
}

+ (BOOL)isSystemVersionLessThan:(NSString *)version
{
    return [[[UIDevice currentDevice] systemVersion] compare:version options:NSNumericSearch] == NSOrderedAscending;
}

+ (BOOL)isSystemVersionLessOrEqualTo:(NSString *)version
{
    return [[[UIDevice currentDevice] systemVersion] compare:version options:NSNumericSearch] != NSOrderedDescending;
}

@end
