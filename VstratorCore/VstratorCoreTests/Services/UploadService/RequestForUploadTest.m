//
//  RequestForUploadTest.m
//  VstratorCore
//
//  Created by akupr on 11.09.13.
//  Copyright (c) 2013 OnTarget. All rights reserved.
//

#import "RequestForUploadTest.h"
#import "UploadRequestInfo.h"

@implementation RequestForUploadTest

-(void)testSuccess
{
    __block BOOL inCallback = NO;
    __block UploadRequestInfo* result;
    __block NSError* fault;
    [self.service requestForUpload:UploadTypeClip callback:^(UploadRequestInfo *info, NSError *error) {
        inCallback = YES;
        fault = error;
        result = info;
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
