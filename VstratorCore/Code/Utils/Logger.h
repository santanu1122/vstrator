//
//  Logger.h
//  VstratorCore
//
//  Created by Admin on 15/03/2013.
//  Copyright (c) 2013 OnTarget. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Logger : NSObject

+ (void)initLogger;
+ (NSString*)latestAvailableLogFullFileName;

@end
