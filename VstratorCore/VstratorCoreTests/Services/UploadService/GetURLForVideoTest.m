//
//  GetURLForVideoTest.m
//  VstratorCore
//
//  Created by akupr on 13.09.13.
//  Copyright (c) 2013 OnTarget. All rights reserved.
//

#import "GetURLForVideoTest.h"

@implementation GetURLForVideoTest

-(void)testSuccess
{
    __block BOOL inCallback = NO;
    __block NSURL* result;
    __block NSError* fault;
    [self.service getURLForVideoKey:@"123123123" isVstration:NO callback:^(NSURL *url, NSError *error) {
        inCallback = YES;
        fault = error;
        result = url;
    }];
    RKObjectRequestOperation* operation = [self.objectManager.operationQueue.operations lastObject];
    [self.objectManager.operationQueue waitUntilAllOperationsAreFinished];
    expect(operation.HTTPRequestOperation.response.statusCode).to.equal(200);
    expect(inCallback).will.beTruthy();
    expect(result).toNot.beNil();
    expect(fault).to.beNil();
    [self.mockDelegate verify];
}

@end
