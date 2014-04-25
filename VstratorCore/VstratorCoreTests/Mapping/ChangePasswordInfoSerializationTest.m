//
//  ChangePasswordInfoSerializationTest.m
//  VstratorCore
//
//  Created by akupr on 10.09.13.
//  Copyright (c) 2013 OnTarget. All rights reserved.
//

#import "ChangePasswordInfoSerializationTest.h"
#import "ChangePasswordInfo.h"

@interface ChangePasswordInfoSerializationTest() {
    RKMappingTest* mappingTest;
    ChangePasswordInfo* source;
    NSMutableDictionary* result;
}

@end

@implementation ChangePasswordInfoSerializationTest

- (void)setUp
{
    [super setUp];
    source = [ChangePasswordInfo new];
    result = [NSMutableDictionary new];
    mappingTest = [RKMappingTest testForMapping:[ChangePasswordInfo serialization] sourceObject:source destinationObject:result];
}

-(void)testThatOldPasswordIsMapped
{
    source.oldPassword = @"secret";
    [mappingTest addExpectation:[RKPropertyMappingTestExpectation expectationWithSourceKeyPath:@"oldPassword" destinationKeyPath:@"oldPassword"]];
    expect([mappingTest evaluate]).to.beTruthy();
    expect(result[@"oldPassword"]).to.equal(@"secret");
}

-(void)testThatNewPasswordIsMapped
{
    source.password = @"secret";
    [mappingTest addExpectation:[RKPropertyMappingTestExpectation expectationWithSourceKeyPath:@"password" destinationKeyPath:@"newPassword"]];
    expect([mappingTest evaluate]).to.beTruthy();
    expect(result[@"newPassword"]).to.equal(@"secret");
}

@end
