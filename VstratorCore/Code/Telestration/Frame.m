//
//  Frame.m
//  VstratorCore
//
//  Created by Admin on 01/02/2013.
//  Copyright (c) 2013 OnTarget. All rights reserved.
//

#import "Frame.h"

@implementation Frame

- (id)init
{
    self = [super init];
    if (self) {
        self.frameNumber = -1;
        self.frameNumber2 = -1;
        self.time = 0;
    }
    return self;
}

-(int)timeInMS
{
	return self.time * 1000;
}

-(void)setTimeInMS:(int)ms
{
	self.time = (NSTimeInterval) ms / 1000;
}

@end
