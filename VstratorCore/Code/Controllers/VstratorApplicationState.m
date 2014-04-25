//
//  VstratorApplicationState.m
//  VstratorApp
//
//  Created by Admin on 18/06/2013.
//  Copyright (c) 2013 OnTarget. All rights reserved.
//

#import "VstratorApplicationState.h"

@implementation VstratorApplicationState

static bool _isInBackground;

+ (BOOL)isInBackground
{
    @synchronized(self) {
        return _isInBackground;
    }
}

+ (void)setIsInBackground:(BOOL)isInBackground
{
    @synchronized(self) {
        _isInBackground = isInBackground;
    }
}

@end
