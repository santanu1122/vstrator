//
//  UpdateMediaTest.m
//  VstratorCore
//
//  Created by akupr on 13.09.13.
//  Copyright (c) 2013 OnTarget. All rights reserved.
//

#import "Action+Extensions.h"
#import "Clip.h"
#import "SenTestCase+CoreData.h"
#import "UpdateMediaTest.h"

@implementation UpdateMediaTest

-(void)setUp
{
    [super setUp];
    [self setupCoreDataStack];
}

-(void)tearDown
{
    [self cleanupCoreDataStack];
}

-(void)testSuccess
{
    NSError* error = nil;
    __block BOOL inCallback = NO;
    __block NSError* fault;
    Clip* clip = [Clip createEntity];
    clip.title = @"Rafa's ace";
    clip.action = [Action actionWithName:@"Serve" sportName:@"Tennis" inContext:clip.managedObjectContext error:&error];
    expect(error).to.beNil();
    [self.service updateMedia:clip callback:^(NSError *updateError) {
        inCallback = YES;
        fault = updateError;
    }];
    RKObjectRequestOperation* operation = [self.objectManager.operationQueue.operations lastObject];
    [self.objectManager.operationQueue waitUntilAllOperationsAreFinished];
    expect(operation.HTTPRequestOperation.response.statusCode).to.equal(200);
    expect(inCallback).will.beTruthy();
    expect(fault).to.beNil();
    [self.mockDelegate verify];
}

@end
