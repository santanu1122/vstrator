//
//  MediaTypeInfoMappingTest.m
//  VstratorCore
//
//  Created by akupr on 17.09.13.
//  Copyright (c) 2013 OnTarget. All rights reserved.
//

#import "MediaTypeInfoMappingTest.h"
#import "MediaTypeInfo.h"

@interface MediaTypeInfoMappingTest() {
    id parsedJSON;
    RKMappingTest* mappingTest;
    MediaTypeInfo* result;
}

@end

@implementation MediaTypeInfoMappingTest

- (void)setUp
{
    [super setUp];
    result = [MediaTypeInfo new];
    parsedJSON = [RKTestFixture parsedObjectWithContentsOfFixture:@"MediaTypeInfo.json"];
    mappingTest = [RKMappingTest testForMapping:[MediaTypeInfo mapping] sourceObject:parsedJSON destinationObject:result];
}

-(void)testThatVstratorAppIDIsMapped
{
    [mappingTest addExpectation:[RKPropertyMappingTestExpectation expectationWithSourceKeyPath:@"VstratorAppID" destinationKeyPath:@"applicationId"]];
    expect([mappingTest evaluate]).to.beTruthy();
    expect(result.applicationId).to.equal(@"5249ff55-5084-4662-aa4d-d99bdf5e7415");
}

-(void)testThatMediaTypeIsMapped
{
    [mappingTest addExpectation:[RKPropertyMappingTestExpectation expectationWithSourceKeyPath:@"MediaType" destinationKeyPath:@"mediaType"]];
    expect([mappingTest evaluate]).to.beTruthy();
    expect(result.mediaType).to.equal(DownloadMediaTypeWorkouts);
}

-(void)testThatTitleIsMapped
{
    [mappingTest addExpectation:[RKPropertyMappingTestExpectation expectationWithSourceKeyPath:@"Title" destinationKeyPath:@"title"]];
    expect([mappingTest evaluate]).to.beTruthy();
    expect(result.title).to.equal(@"Workouts");
}

@end
