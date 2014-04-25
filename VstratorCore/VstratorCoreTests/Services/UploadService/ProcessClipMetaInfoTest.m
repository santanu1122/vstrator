//
//  ProcessClipMetaInfoTest.m
//  VstratorCore
//
//  Created by akupr on 12.09.13.
//  Copyright (c) 2013 OnTarget. All rights reserved.
//

#import "ProcessClipMetaInfoTest.h"
#import "ClipMetaInfo.h"
#import "VideoStatusInfo.h"

@implementation ProcessClipMetaInfoTest

-(void)testSuccess
{
    __block BOOL inCallback = NO;
    __block VideoStatusInfo* result;
    __block NSError* fault;
    ClipMetaInfo* info = [ClipMetaInfo new];
    info.title = @"Rafa's ace";
    info.sport = @"Tennis";
    info.action = @"Serve";
    info.recordingKey = @"123123123";
    [self.service processClipMetaInfo:info isVstration:NO callback:^(VideoStatusInfo *videoStatusInfo, NSError *error) {
        inCallback = YES;
        fault = error;
        result = videoStatusInfo;
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
