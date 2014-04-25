//
//  NotificationServiceTest.m
//  VstratorCore
//
//  Created by akupr on 17.09.13.
//  Copyright (c) 2013 OnTarget. All rights reserved.
//

#import "NotificationServiceTest.h"

@interface NotificationServiceTest() {
    BOOL inCallback;
    NSError* fault;
}

@end

@implementation NotificationServiceTest

-(void)setUp
{
    [super setUp];
    _service = [[RestNotificationService alloc] init];
    _service.delegate = self.mockDelegate;

    BOOL logged = YES;
    [[[self.mockDelegate stub] andReturnValue:OCMOCK_VALUE(logged)] userIsLoggedIn];
}

-(void)testThatGetNotificationSucceeded
{
    __block NotificationInfo* result = nil;
    [self.service getNotification:^(NotificationInfo *notification, NSError *error) {
        inCallback = YES;
        result = notification;
        fault = error;
    }];
    RKObjectRequestOperation* operation = [self.objectManager.operationQueue.operations lastObject];
    [self.objectManager.operationQueue waitUntilAllOperationsAreFinished];
    expect(operation.HTTPRequestOperation.response.statusCode).to.equal(200);
    expect(inCallback).will.beTruthy();
    expect(result).toNot.beNil();
    expect(fault).to.beNil();
    [self.mockDelegate verify];
}

-(void)testThatPushNotificationButtonSucceeded
{
    [self.service pushTheButtonWithIdentity:@"123123123" callback:^(NSError *error) {
        inCallback = YES;
        fault = error;
    }];
    RKObjectRequestOperation* operation = [self.objectManager.operationQueue.operations lastObject];
    [self.objectManager.operationQueue waitUntilAllOperationsAreFinished];
    expect(operation.HTTPRequestOperation.response.statusCode).to.equal(200);
    expect(inCallback).will.beTruthy();
    expect(fault).to.beNil();
    [self.mockDelegate verify];
}

@end
