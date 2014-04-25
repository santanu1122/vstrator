//
//  MarkupTestBase.m
//  VstratorCore
//
//  Created by akupr on 28.08.13.
//  Copyright (c) 2013 OnTarget. All rights reserved.
//

#import <RestKit/RestKit.h>
#import <RestKit/ObjectMapping/RKObjectMappingOperationDataSource.h>

#import "MarkupTestBase.h"

@implementation MarkupTestBase

-(id)serialize:(id)object withMapping:(RKObjectMapping*)mapping
{
    RKMappingOperation *operation = [[RKMappingOperation alloc] initWithSourceObject:object
                                                                   destinationObject:[NSMutableDictionary dictionary]
                                                                             mapping:mapping];
    RKObjectMappingOperationDataSource* dataSource = [RKObjectMappingOperationDataSource new];
    operation.dataSource = dataSource;
    NSError *error = nil;
    [operation performMapping:&error];
    expect(error).to.beNil();
    return error ? nil : operation.destinationObject;
}

@end
