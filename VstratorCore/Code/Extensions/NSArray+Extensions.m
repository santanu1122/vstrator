//
//  NSArray+Extensions.m
//  VstratorApp
//
//  Created by Mac on 01.05.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "NSArray+Extensions.h"

@implementation NSArray (Extensions)

+ (NSArray *)sortedArrayWithArrayByName:(NSArray *)array
{
    if (array == nil || array.count <= 1)
        return array;
    NSSortDescriptor *nameSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
    return [[NSArray arrayWithArray:array] sortedArrayUsingDescriptors:@[nameSortDescriptor]];
    
}

@end
