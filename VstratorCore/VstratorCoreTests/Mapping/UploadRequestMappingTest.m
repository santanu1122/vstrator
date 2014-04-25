//
//  UploadRequestMappingTest.m
//  VstratorCore
//
//  Created by akupr on 12.09.13.
//  Copyright (c) 2013 OnTarget. All rights reserved.
//

#import "UploadRequestMappingTest.h"
#import "UploadRequestInfo.h"

@interface UploadRequestMappingTest() {
    id parsedJSON;
    RKMappingTest* mappingTest;
    UploadRequestInfo* result;
}

@end

@implementation UploadRequestMappingTest

- (void)setUp
{
    [super setUp];
    result = [UploadRequestInfo new];
    parsedJSON = [RKTestFixture parsedObjectWithContentsOfFixture:@"UploadRequestInfo.json"];
    mappingTest = [RKMappingTest testForMapping:[UploadRequestInfo mapping] sourceObject:parsedJSON destinationObject:result];
}

-(void)testThatRecordingKeyIsMapped
{
    [mappingTest addExpectation:[RKPropertyMappingTestExpectation expectationWithSourceKeyPath:@"recordingKey" destinationKeyPath:@"recordingKey"]];
    expect([mappingTest evaluate]).to.beTruthy();
    expect(result.recordingKey).to.equal(@"123123123");
}

-(void)testThatUploadURLIsMapped
{
    [mappingTest addExpectation:[RKPropertyMappingTestExpectation expectationWithSourceKeyPath:@"uploadUrl" destinationKeyPath:@"uploadURL"]];
    expect([mappingTest evaluate]).to.beTruthy();
    expect(result.uploadURL).to.equal([NSURL URLWithString:@"http://foobar.com/upload"]);
}

@end
