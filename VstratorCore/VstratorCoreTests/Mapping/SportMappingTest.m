//
//  SportMappingTest.m
//  VstratorCore
//
//  Created by akupr on 29.08.13.
//  Copyright (c) 2013 OnTarget. All rights reserved.
//

#import "SportMappingTest.h"
#import "SportInfo.h"

@interface SportMappingTest() {
    id parsedJSON;
    RKMappingTest* mappingTest;
    SportInfo* result;
}

@end

@implementation SportMappingTest

- (void)setUp
{
    [super setUp];
    result = [SportInfo new];
    parsedJSON = [RKTestFixture parsedObjectWithContentsOfFixture:@"SportInfo.json"];
    mappingTest = [RKMappingTest testForMapping:[SportInfo mapping] sourceObject:parsedJSON destinationObject:result];
}

-(void)testThatIdIsMapped
{
    [mappingTest addExpectation:[RKPropertyMappingTestExpectation expectationWithSourceKeyPath:@"id" destinationKeyPath:@"identity"]];
    expect([mappingTest evaluate]).to.beTruthy();
    expect(result.identity).to.equal(@2);
}

-(void)testThatSportIsMapped
{
    [mappingTest addExpectation:[RKPropertyMappingTestExpectation expectationWithSourceKeyPath:@"sport" destinationKeyPath:@"sport"]];
    expect([mappingTest evaluate]).to.beTruthy();
    expect(result.sport).to.equal(@"Tennis");
}

-(void)testThatActionsIsMapped
{
    [mappingTest addExpectation:[RKPropertyMappingTestExpectation expectationWithSourceKeyPath:@"actions" destinationKeyPath:@"actions"]];
    expect([mappingTest evaluate]).to.beTruthy();
    expect(result.actions).toNot.beNil();
    expect(result.actions).to.beKindOf([NSArray class]);
    expect(result.actions.count).to.equal(11);
}

@end
