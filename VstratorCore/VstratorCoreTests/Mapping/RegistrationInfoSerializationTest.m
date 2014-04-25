//
//  RegistrationInfoSerializationTest.m
//  VstratorCore
//
//  Created by akupr on 10.09.13.
//  Copyright (c) 2013 OnTarget. All rights reserved.
//

#import "RegistrationInfoSerializationTest.h"
#import "RegistrationInfo.h"

@interface RegistrationInfoSerializationTest() {
    RKMappingTest* mappingTest;
    RegistrationInfo* source;
    NSMutableDictionary* result;
}

@end

@implementation RegistrationInfoSerializationTest

- (void)setUp
{
    [super setUp];
    source = [RegistrationInfo new];
    result = [NSMutableDictionary new];
    mappingTest = [RKMappingTest testForMapping:[RegistrationInfo serialization] sourceObject:source destinationObject:result];
}

-(void)testThatEmailIsMapped
{
    source.email = @"foo@bar.com";
    [mappingTest addExpectation:[RKPropertyMappingTestExpectation expectationWithSourceKeyPath:@"email" destinationKeyPath:@"email"]];
    expect([mappingTest evaluate]).to.beTruthy();
    expect(result[@"email"]).to.equal(@"foo@bar.com");
}

-(void)testThatPasswordIsMapped
{
    source.password = @"secret";
    [mappingTest addExpectation:[RKPropertyMappingTestExpectation expectationWithSourceKeyPath:@"password" destinationKeyPath:@"password"]];
    expect([mappingTest evaluate]).to.beTruthy();
    expect(result[@"password"]).to.equal(@"secret");
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

@end
