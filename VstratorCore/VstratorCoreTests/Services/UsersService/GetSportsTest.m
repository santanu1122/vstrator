//
//  GetSportsTest.m
//  VstratorCore
//
//  Created by akupr on 02.09.13.
//  Copyright (c) 2013 OnTarget. All rights reserved.
//

#import "GetSportsTest.h"

@implementation GetSportsTest

-(void)testSuccess
{
    __block NSArray* result;
    __block NSError* fault;
    [self.service getSportList:^(NSArray *sportList, NSError* error) {
        fault = error;
        result = sportList;
    }];
    RKObjectRequestOperation* operation = [self.objectManager.operationQueue.operations lastObject];
    [self.objectManager.operationQueue waitUntilAllOperationsAreFinished];
    expect(operation.HTTPRequestOperation.response.statusCode).to.equal(200);
    expect(result).willNot.beNil();
    expect(fault).to.beNil();
    [self.mockDelegate verify];
}

@end
