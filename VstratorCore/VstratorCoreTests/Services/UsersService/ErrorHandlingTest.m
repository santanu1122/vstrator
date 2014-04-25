//
//  ErrorHandlingTest.m
//  VstratorCore
//
//  Created by akupr on 11.09.13.
//  Copyright (c) 2013 OnTarget. All rights reserved.
//

#import "ErrorHandlingTest.h"
#import "Callbacks.h"

@interface ErrorHandlingTest() {
    BOOL inCallback;
    NSError* fault;
    NSInteger code;
    NSString* message;
    NSString* path;
}

@end

@implementation ErrorHandlingTest

-(void)tearDown
{
    [self.objectManager getObjectsAtPath:path parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        inCallback = YES;
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        inCallback = YES;
        fault = error;
    }];
    RKObjectRequestOperation* operation = [self.objectManager.operationQueue.operations lastObject];
    [self.objectManager.operationQueue waitUntilAllOperationsAreFinished];
    expect(operation.HTTPRequestOperation.response.statusCode).to.equal(code);
    expect(inCallback).will.beTruthy();
    expect(fault).notTo.beNil();
    expect(fault.localizedDescription).to.equal(message);
    [self.mockDelegate verify];
}

-(void)test401
{
    code = 401;
    message = @"Unauthorized";
    path = @"/unauthorized";
}

-(void)test403
{
    code = 403;
    message = @"Forbidden";
    path = @"/forbidden";
}

-(void)test404
{
    code = 404;
    message = @"Not found";
    path = @"/not_found";
}

@end
