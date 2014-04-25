//
//  NSArray+Stack.m
//  VstratorApp
//
//  Created by user on 12.03.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "NSMutableArray+Stack.h"

@implementation NSMutableArray (Stack)

-(void) push:(id)object
{
    [self addObject:object];
}

-(id) pop
{
    id object = nil;
    if (self.count > 0) {
        object = self.lastObject;
        [self removeLastObject];
    }
    return object;
}

@end
