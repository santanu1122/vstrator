//
//  VideoStatusInfoMappingTest.m
//  VstratorCore
//
//  Created by akupr on 12.09.13.
//  Copyright (c) 2013 OnTarget. All rights reserved.
//

#import "VideoStatusInfoMappingTest.h"
#import "VideoStatusInfo.h"

@interface VideoStatusInfoMappingTest() {
    id parsedJSON;
    RKMappingTest* mappingTest;
    VideoStatusInfo* result;
}

@end

@implementation VideoStatusInfoMappingTest

- (void)setUp
{
    [super setUp];
    result = [VideoStatusInfo new];
    parsedJSON = [RKTestFixture parsedObjectWithContentsOfFixture:@"VideoStatusInfo.json"];
    mappingTest = [RKMappingTest testForMapping:[VideoStatusInfo mapping] sourceObject:parsedJSON destinationObject:result];
}

-(void)testThatEncodingStatusIsMapped
{
    [mappingTest addExpectation:[RKPropertyMappingTestExpectation expectationWithSourceKeyPath:@"encodingStatus" destinationKeyPath:@"encodingStatus"]];
    expect([mappingTest evaluate]).to.beTruthy();
    expect(result.encodingStatus).to.equal(2);
}

-(void)testThatTitleIsMapped
{
    [mappingTest addExpectation:[RKPropertyMappingTestExpectation expectationWithSourceKeyPath:@"title" destinationKeyPath:@"title"]];
    expect([mappingTest evaluate]).to.beTruthy();
    expect(result.title).to.equal(@"Rafa's ace");
}

-(void)testThatVideoDateIsMapped
{
#warning Incomplete testing
//    [mappingTest addExpectation:[RKPropertyMappingTestExpectation expectationWithSourceKeyPath:@"videoDate" destinationKeyPath:@"videoDate"]];
//    expect([mappingTest evaluate]).to.beTruthy();
//    expect(result.videoDate).to.equal([formatter dateFromString:@"2013-09-10T03:06Z"]);
}

-(void)testThatVideoKeyIsMapped
{
    [mappingTest addExpectation:[RKPropertyMappingTestExpectation expectationWithSourceKeyPath:@"videoKey" destinationKeyPath:@"videoKey"]];
    expect([mappingTest evaluate]).to.beTruthy();
    expect(result.videoKey).to.equal(@"c02e6739-a890-4283-b346-4ddc765d09db");
}

-(void)testThatVideoKeyTypeIsMapped
{
    [mappingTest addExpectation:[RKPropertyMappingTestExpectation expectationWithSourceKeyPath:@"videoKeyType" destinationKeyPath:@"videoKeyType"]];
    expect([mappingTest evaluate]).to.beTruthy();
    expect(result.videoKeyType).to.equal(VideoKeyTypeSession);
}

-(void)testThatVideoURLIsMapped
{
    [mappingTest addExpectation:[RKPropertyMappingTestExpectation expectationWithSourceKeyPath:@"videoUrl" destinationKeyPath:@"videoURL"]];
    expect([mappingTest evaluate]).to.beTruthy();
    expect(result.videoURL).to.equal([NSURL URLWithString:@"https://www.vstrator.com/video/clips/c02e6739-a890-4283-b346-4ddc765d09db"]);
}

//"":"\/Date(1337884929723-0400)\/",

@end
