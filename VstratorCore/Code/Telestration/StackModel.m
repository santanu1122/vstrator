//
//  StackModel.m
//  
//
//  Created by user on 12.03.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "StackModel.h"

@implementation StackModel

@synthesize stack = _stack;
@synthesize index = _index;
@synthesize reverseIndex = _reverseIndex;

- (id)init
{
    self = [super init];
    if (self) {
        _stack = [[NSMutableArray alloc] init];
        self.index = 0;
        self.reverseIndex = 0;
    }
    return self;
}

- (NSArray *)items 
{
    return [NSArray arrayWithArray:self.stack];
}

- (id)lastItem
{
    if (self.stack && self.reverseIndex >= 0 && self.stack.count > 0)
        return (self.stack)[self.reverseIndex--];
    return nil;
}

- (int)count 
{
    return self.stack.count;
}

- (void)resetReverseIndex
{
    self.reverseIndex = self.stack.count - 1;
}

- (void)clear
{
    [self.stack removeAllObjects];
}

- (void)push:(id)object
{
    if (self.stack && object != nil) {
        [self.stack push:object];
        [self resetReverseIndex];
    }
}

- (id)pop
{
    if (self.stack) {
        id item = [self.stack pop];
        [self resetReverseIndex];
        return item;
    }
    return nil;
}

- (id)nextObject
{
    return (self.index < self.stack.count) ? (self.stack)[self.index++] : nil;
}

@end
