//
//  SystemInformation.h
//  VstratorCore
//
//  Created by Admin1 on 19.09.13.
//  Copyright (c) 2013 OnTarget. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SystemInformation : NSObject

+ (BOOL)isSystemVersionEqualTo:(NSString*)version;
+ (BOOL)isSystemVersionGreaterThan:(NSString*)version;
+ (BOOL)isSystemVersionGreaterOrEqualTo:(NSString*)version;
+ (BOOL)isSystemVersionLessThan:(NSString*)version;
+ (BOOL)isSystemVersionLessOrEqualTo:(NSString*)version;

@end
