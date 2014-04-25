//
//  GetUserInfoTest.m
//  VstratorCore
//
//  Created by akupr on 09.09.13.
//  Copyright (c) 2013 OnTarget. All rights reserved.
//

#import "GetUserInfoTest.h"

@implementation GetUserInfoTest

-(void)testSuccess
{
    __block VstratorUserInfo* result;
    __block NSError* fault;
    [self.service getUserInfo:^(VstratorUserInfo *userInfo, NSError *error) {
        fault = error;
        result = userInfo;
    }];
    RKObjectRequestOperation* operation = [self.objectManager.operationQueue.operations lastObject];
    [self.objectManager.operationQueue waitUntilAllOperationsAreFinished];
    expect(operation.HTTPRequestOperation.response.statusCode).to.equal(200);
    expect(result).willNot.beNil();
    expect(fault).to.beNil();
    [self.mockDelegate verify];
}

@end
