//
//  StackModel.h
//  
//
//  Created by user on 12.03.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSMutableArray+Stack.h"

@interface StackModel : NSObject 

@property (nonatomic, strong, readonly) NSMutableArray *stack;
@property (nonatomic, assign) int index;
@property (nonatomic, assign) int reverseIndex;

- (NSArray *)items;
- (int)count;
- (void)push:(id) object;
- (id)pop;
- (id)nextObject;
- (id)lastItem;
- (void)clear;

@end
