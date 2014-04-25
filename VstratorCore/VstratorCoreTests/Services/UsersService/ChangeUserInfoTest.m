//
//  ChangeUserInfoTest.m
//  VstratorCore
//
//  Created by akupr on 10.09.13.
//  Copyright (c) 2013 OnTarget. All rights reserved.
//

#import "ChangeUserInfoTest.h"
#import "VstratorUserInfo.h"

@implementation ChangeUserInfoTest

-(void)testSuccess
{
    __block BOOL inCallback = NO;
    __block NSError* fault;
    VstratorUserInfo* info = [VstratorUserInfo new];
    info.email = @"foo@bar.com";
    info.firstName = @"Foo";
    info.lastName = @"Bar";
    [self.service changeUserInfo:info callback:^(NSError *error) {
        inCallback = YES;
        fault = error;
    }];
    RKObjectRequestOperation* operation = [self.objectManager.operationQueue.operations lastObject];
    [self.objectManager.operationQueue waitUntilAllOperationsAreFinished];
    expect(operation.HTTPRequestOperation.response.statusCode).to.equal(200);
    expect(inCallback).will.beTruthy();
    expect(fault).to.beNil();
    [self.mockDelegate verify];
}

@end
