//
//  NotificationButtonInfoMappingTest.m
//  VstratorCore
//
//  Created by akupr on 17.09.13.
//  Copyright (c) 2013 OnTarget. All rights reserved.
//

#import "NotificationButtonInfoMappingTest.h"
#import "NotificationButtonInfo.h"

@interface NotificationButtonInfoMappingTest() {
    id parsedJSON;
    RKMappingTest* mappingTest;
    NotificationButtonInfo* result;
}

@end

@implementation NotificationButtonInfoMappingTest

- (void)setUp
{
    [super setUp];
    result = [NotificationButtonInfo new];
    parsedJSON = [RKTestFixture parsedObjectWithContentsOfFixture:@"NotificationButtonInfo.json"];
    mappingTest = [RKMappingTest testForMapping:[NotificationButtonInfo mapping] sourceObject:parsedJSON destinationObject:result];
}

-(void)testThatIdentityIsMapped
{
    [mappingTest addExpectation:[RKPropertyMappingTestExpectation expectationWithSourceKeyPath:@"ID" destinationKeyPath:@"identity"]];
    expect([mappingTest evaluate]).to.beTruthy();
    expect(result.identity).to.equal(@"66fe13ff-2051-414a-80f7-57dabbc70bad");
}

-(void)testThatTextIsMapped
{
    [mappingTest addExpectation:[RKPropertyMappingTestExpectation expectationWithSourceKeyPath:@"ButtonText" destinationKeyPath:@"text"]];
    expect([mappingTest evaluate]).to.beTruthy();
    expect(result.text).to.equal(@"Download");
}

-(void)testThatTypeIsMapped
{
    [mappingTest addExpectation:[RKPropertyMappingTestExpectation expectationWithSourceKeyPath:@"ButtonType" destinationKeyPath:@"type"]];
    expect([mappingTest evaluate]).to.beTruthy();
    expect(result.type).to.equal(NotificationButtonTypeMediaDownload);
}

-(void)testThatMediaTypeIsMapped
{
    [mappingTest addExpectation:[RKPropertyMappingTestExpectation expectationWithSourceKeyPath:@"MediaType" destinationKeyPath:@"mediaType"]];
    expect([mappingTest evaluate]).to.beTruthy();
    expect(result.mediaType).to.equal(DownloadMediaTypeVstratedClips);
}

-(void)testThatMediaIdentityIsMapped
{
    [mappingTest addExpectation:[RKPropertyMappingTestExpectation expectationWithSourceKeyPath:@"MediaID" destinationKeyPath:@"mediaIdentity"]];
    expect([mappingTest evaluate]).to.beTruthy();
    expect(result.mediaIdentity).to.equal(@"789013ff-2051-414a-80f7-57dabbc70bd4");
}

-(void)testThatClickURLIsMapped
{
    [mappingTest addExpectation:[RKPropertyMappingTestExpectation expectationWithSourceKeyPath:@"ClickURI" destinationKeyPath:@"clickURL"]];
    expect([mappingTest evaluate]).to.beTruthy();
    expect(result.clickURL).to.equal([NSURL URLWithString:@"http://foobar.com/click"]);
}

@end
