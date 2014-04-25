//
//  UserInfoMappingTest.m
//  VstratorCore
//
//  Created by akupr on 09.09.13.
//  Copyright (c) 2013 OnTarget. All rights reserved.
//

#import "UserInfoMappingTest.h"
#import "VstratorUserInfo.h"

@interface UserInfoMappingTest() {
    id parsedJSON;
    RKMappingTest* mappingTest;
    VstratorUserInfo* result;
}

@end

@implementation UserInfoMappingTest

- (void)setUp
{
    [super setUp];
    result = [VstratorUserInfo new];
    parsedJSON = [RKTestFixture parsedObjectWithContentsOfFixture:@"UserInfo.json"];
    mappingTest = [RKMappingTest testForMapping:[VstratorUserInfo mapping] sourceObject:parsedJSON destinationObject:result];
}

-(void)testThatFacebookIdentityIsMapped
{
    [mappingTest addExpectation:[RKPropertyMappingTestExpectation expectationWithSourceKeyPath:@"socialMediaID" destinationKeyPath:@"facebookIdentity"]];
    expect([mappingTest evaluate]).to.beTruthy();
    expect(result.facebookIdentity).to.equal(@"100003929805234");
}

-(void)testThatFirstNameIsMapped
{
    [mappingTest addExpectation:[RKPropertyMappingTestExpectation expectationWithSourceKeyPath:@"firstName" destinationKeyPath:@"firstName"]];
    expect([mappingTest evaluate]).to.beTruthy();
    expect(result.firstName).to.equal(@"John");
}

-(void)testThatLastNameIsMapped
{
    [mappingTest addExpectation:[RKPropertyMappingTestExpectation expectationWithSourceKeyPath:@"lastName" destinationKeyPath:@"lastName"]];
    expect([mappingTest evaluate]).to.beTruthy();
    expect(result.lastName).to.equal(@"Doe");
}

-(void)testThatEmailIsMapped
{
    [mappingTest addExpectation:[RKPropertyMappingTestExpectation expectationWithSourceKeyPath:@"email" destinationKeyPath:@"email"]];
    expect([mappingTest evaluate]).to.beTruthy();
    expect(result.email).to.equal(@"user@example.com");
}

-(void)testThatProfilePictureURLIsMapped
{
    [mappingTest addExpectation:[RKPropertyMappingTestExpectation expectationWithSourceKeyPath:@"profilePictureUrl" destinationKeyPath:@"pictureUrl"]];
    expect([mappingTest evaluate]).to.beTruthy();
    expect(result.pictureUrl).to.equal(@"http://foobar.com/image.jpg");
}

-(void)testThatPromarySportIsMapped
{
    [mappingTest addExpectation:[RKPropertyMappingTestExpectation expectationWithSourceKeyPath:@"primarySport" destinationKeyPath:@"primarySportName"]];
    expect([mappingTest evaluate]).to.beTruthy();
    expect(result.primarySportName).to.equal(@"Other");
}

-(void)testThatVstratorIdentityIsMapped
{
    [mappingTest addExpectation:[RKPropertyMappingTestExpectation expectationWithSourceKeyPath:@"userKey" destinationKeyPath:@"vstratorIdentity"]];
    expect([mappingTest evaluate]).to.beTruthy();
    expect(result.vstratorIdentity).to.equal(@"641a4b6d-6c28-4c86-9195-02287898291c");
}

-(void)testThatVstratorUserNameIsMapped
{
    [mappingTest addExpectation:[RKPropertyMappingTestExpectation expectationWithSourceKeyPath:@"userName" destinationKeyPath:@"vstratorUserName"]];
    expect([mappingTest evaluate]).to.beTruthy();
    expect(result.vstratorUserName).to.equal(@"user@example.com");
}

@end
