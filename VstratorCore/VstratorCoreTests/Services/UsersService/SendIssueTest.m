//
//  SendIssueTest.m
//  VstratorCore
//
//  Created by akupr on 11.09.13.
//  Copyright (c) 2013 OnTarget. All rights reserved.
//

#import "SendIssueTest.h"
#import "Issue.h"

@implementation SendIssueTest

-(void)testSuccess
{
    __block BOOL inCallback = NO;
    __block NSError* fault;
    Issue* issue = [[Issue alloc] initWithIssueType:IssueTypeBugReport andDescription:@"test"];
    [self.service sendIssue:issue callback:^(NSError *error) {
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
