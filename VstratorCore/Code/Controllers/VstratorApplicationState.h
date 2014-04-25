//
//  VstratorApplicationState.h
//  VstratorApp
//
//  Created by Admin on 18/06/2013.
//  Copyright (c) 2013 OnTarget. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VstratorApplicationState : NSObject

+ (BOOL)isInBackground;
+ (void)setIsInBackground:(BOOL)isInBackground;

@end
