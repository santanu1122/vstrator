//
//  IssueSerializationTest.m
//  VstratorCore
//
//  Created by akupr on 11.09.13.
//  Copyright (c) 2013 OnTarget. All rights reserved.
//

#import "IssueSerializationTest.h"
#import "Issue.h"

@interface IssueSerializationTest() {
    RKMappingTest* mappingTest;
    Issue* source;
    id mockSource;
    NSMutableDictionary* result;
}

@end

@implementation IssueSerializationTest

- (void)setUp
{
    [super setUp];
    source = mockSource = [OCMockObject partialMockForObject:[Issue new]];
    result = [NSMutableDictionary new];
    mappingTest = [RKMappingTest testForMapping:[Issue serialization] sourceObject:source destinationObject:result];
}

-(void)testThatIssueTypeIsMapped
{
    source.issueType = IssueTypeBugReport;
    [mappingTest addExpectation:[RKPropertyMappingTestExpectation expectationWithSourceKeyPath:@"issueType" destinationKeyPath:@"issueType"]];
    expect([mappingTest evaluate]).to.beTruthy();
    expect(result[@"issueType"]).to.equal(@(IssueTypeBugReport));
}

-(void)testThatDescriptionIsMapped
{
    NSString* version = [[NSBundle bundleForClass:[Issue class]] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
    source.description = @"test";
    [mappingTest addExpectation:[RKPropertyMappingTestExpectation expectationWithSourceKeyPath:@"description" destinationKeyPath:@"description"]];
    expect([mappingTest evaluate]).to.beTruthy();
    expect(result[@"description"]).to.equal(([NSString stringWithFormat:@"%@\ntest", version]));
}

-(void)testThatLogFileIsMapped
{
    [[[mockSource stub] andReturn:@"--log--"] logFile];
    [mappingTest addExpectation:[RKPropertyMappingTestExpectation expectationWithSourceKeyPath:@"logFile" destinationKeyPath:@"logFile"]];
    expect([mappingTest evaluate]).to.beTruthy();
    expect(result[@"logFile"]).to.equal(@"--log--");
}

@end