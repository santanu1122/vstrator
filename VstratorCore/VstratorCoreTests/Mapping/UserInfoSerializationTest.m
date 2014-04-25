//
//  UserInfoSerializationTest.m
//  VstratorCore
//
//  Created by akupr on 10.09.13.
//  Copyright (c) 2013 OnTarget. All rights reserved.
//

#import "UserInfoSerializationTest.h"
#import "VstratorUserInfo.h"

@interface UserInfoSerializationTest() {
    RKMappingTest* mappingTest;
    VstratorUserInfo* source;
    NSMutableDictionary* result;
}

@end

@implementation UserInfoSerializationTest

- (void)setUp
{
    [super setUp];
    source = [VstratorUserInfo new];
    result = [NSMutableDictionary new];
    mappingTest = [RKMappingTest testForMapping:[VstratorUserInfo serialization] sourceObject:source destinationObject:result];
}

-(void)testThatEmailIsMapped
{
    source.email = @"foo@bar.com";
    [mappingTest addExpectation:[RKPropertyMappingTestExpectation expectationWithSourceKeyPath:@"email" destinationKeyPath:@"email"]];
    expect([mappingTest evaluate]).to.beTruthy();
    expect(result[@"email"]).to.equal(@"foo@bar.com");
}

-(void)testThatFirstNameIsMapped
{
    source.firstName = @"Foo";
    [mappingTest addExpectation:[RKPropertyMappingTestExpectation expectationWithSourceKeyPath:@"firstName" destinationKeyPath:@"firstName"]];
    expect([mappingTest evaluate]).to.beTruthy();
    expect(result[@"firstName"]).to.equal(@"Foo");
}

-(void)testThatLastNameIsMapped
{
    source.lastName = @"Bar";
    [mappingTest addExpectation:[RKPropertyMappingTestExpectation expectationWithSourceKeyPath:@"lastName" destinationKeyPath:@"lastName"]];
    expect([mappingTest evaluate]).to.beTruthy();
    expect(result[@"lastName"]).to.equal(@"Bar");
}

-(void)testThatFacebookIdentityIsMapped
{
    source.facebookIdentity = @"1231231232";
    [mappingTest addExpectation:[RKPropertyMappingTestExpectation expectationWithSourceKeyPath:@"facebookIdentity" destinationKeyPath:@"socialMediaId"]];
    expect([mappingTest evaluate]).to.beTruthy();
    expect(result[@"socialMediaId"]).to.equal(@"1231231232");
}

-(void)testThatPrimarySportNameIsMapped
{
    source.primarySportName = @"Tennis";
    [mappingTest addExpectation:[RKPropertyMappingTestExpectation expectationWithSourceKeyPath:@"primarySportName" destinationKeyPath:@"primarySport"]];
    expect([mappingTest evaluate]).to.beTruthy();
    expect(result[@"primarySport"]).to.equal(@"Tennis");
}

-(void)testThatUserKeyIsMapped
{
    source.vstratorIdentity = @"123123123";
    [mappingTest addExpectation:[RKPropertyMappingTestExpectation expectationWithSourceKeyPath:@"vstratorIdentity" destinationKeyPath:@"userKey"]];
    expect([mappingTest evaluate]).to.beTruthy();
    expect(result[@"userKey"]).to.equal(@"123123123");
}

-(void)testThatUserNameIsMapped
{
    source.vstratorUserName = @"321321321";
    [mappingTest addExpectation:[RKPropertyMappingTestExpectation expectationWithSourceKeyPath:@"vstratorUserName" destinationKeyPath:@"userName"]];
    expect([mappingTest evaluate]).to.beTruthy();
    expect(result[@"userName"]).to.equal(@"321321321");
}

@end

