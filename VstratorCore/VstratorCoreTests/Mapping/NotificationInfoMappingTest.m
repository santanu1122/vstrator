//
//  NotificationinfoMappingTest.m
//  VstratorCore
//
//  Created by akupr on 17.09.13.
//  Copyright (c) 2013 OnTarget. All rights reserved.
//

#import "NotificationInfoMappingTest.h"
#import "NotificationInfo.h"

@interface NotificationInfoMappingTest() {
    id parsedJSON;
    RKMappingTest* mappingTest;
    NotificationInfo* result;
}

@end

@implementation NotificationInfoMappingTest

- (void)setUp
{
    [super setUp];
    result = [NotificationInfo new];
    parsedJSON = [RKTestFixture parsedObjectWithContentsOfFixture:@"NotificationInfo.json"];
    mappingTest = [RKMappingTest testForMapping:[NotificationInfo mapping] sourceObject:parsedJSON destinationObject:result];
}

-(void)testThatIdentityIsMapped
{
    [mappingTest addExpectation:[RKPropertyMappingTestExpectation expectationWithSourceKeyPath:@"ID" destinationKeyPath:@"identity"]];
    expect([mappingTest evaluate]).to.beTruthy();
    expect(result.identity).to.equal(@"7e0fbb96-44df-4874-889c-8624d126718f");
}

-(void)testThatTypeIsMapped
{
    [mappingTest addExpectation:[RKPropertyMappingTestExpectation expectationWithSourceKeyPath:@"NotificationType" destinationKeyPath:@"type"]];
    expect([mappingTest evaluate]).to.beTruthy();
    expect(result.type).to.equal(NotificationTypeApplication);
}

-(void)testThatContentTypeIsMapped
{
    [mappingTest addExpectation:[RKPropertyMappingTestExpectation expectationWithSourceKeyPath:@"ContentType" destinationKeyPath:@"contentType"]];
    expect([mappingTest evaluate]).to.beTruthy();
    expect(result.contentType).to.equal(NotificationContentTypePlainText);
}

-(void)testThatTitleIsMapped
{
    [mappingTest addExpectation:[RKPropertyMappingTestExpectation expectationWithSourceKeyPath:@"Title" destinationKeyPath:@"title"]];
    expect([mappingTest evaluate]).to.beTruthy();
    expect(result.title).to.equal(@"Test Title 2");
}

-(void)testThatBodyIsMapped
{
    [mappingTest addExpectation:[RKPropertyMappingTestExpectation expectationWithSourceKeyPath:@"Body" destinationKeyPath:@"body"]];
    expect([mappingTest evaluate]).to.beTruthy();
    expect(result.body).to.equal(@"Sample body text 2");
}

-(void)testThatImageURLIsMapped
{
    [mappingTest addExpectation:[RKPropertyMappingTestExpectation expectationWithSourceKeyPath:@"ImageURI" destinationKeyPath:@"imageURL"]];
    expect([mappingTest evaluate]).to.beTruthy();
    expect(result.imageURL).to.equal([NSURL URLWithString:@"http://www.vstrator.com"]);
}

-(void)testThatAdditionalNotificationIsMapped
{
    [mappingTest addExpectation:[RKPropertyMappingTestExpectation expectationWithSourceKeyPath:@"AdditionalNotification" destinationKeyPath:@"additionalNotification"]];
    expect([mappingTest evaluate]).to.beTruthy();
    expect(result.additionalNotification).to.equal(0);
}

-(void)testThatNotificationButtonsIsMapped
{
    [mappingTest addExpectation:[RKPropertyMappingTestExpectation expectationWithSourceKeyPath:@"NotificationButtons" destinationKeyPath:@"buttons"]];
    expect([mappingTest evaluate]).to.beTruthy();
    expect(result.buttons.count).to.equal(2);
}

@end
