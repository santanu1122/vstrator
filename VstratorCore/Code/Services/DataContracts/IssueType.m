//
//  IssueType.m
//  VstratorApp
//
//  Created by Mac on 03.04.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "IssueType.h"

@implementation IssueType

@synthesize key = _key;
@synthesize name = _name;

- (id)initWithKey:(IssueTypeKey)key name:(NSString *)name
{
    self = [super init];
    if (self) {
        self.key = key;
        self.name = name;
    }
    return self;
}

@end
