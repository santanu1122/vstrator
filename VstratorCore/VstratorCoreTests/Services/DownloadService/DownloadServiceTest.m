//
//  DownloadServiceTest.m
//  VstratorCore
//
//  Created by akupr on 17.09.13.
//  Copyright (c) 2013 OnTarget. All rights reserved.
//

#import "DownloadServiceTest.h"
#import "MediaTypeInfo.h"

@interface DownloadServiceTest() {
    BOOL inCallback;
    NSError* fault;
}

@end

@implementation DownloadServiceTest

-(void)setUp
{
    [super setUp];
    _service = [[RestDownloadService alloc] init];
    _service.delegate = self.mockDelegate;
}

-(void)testThatGetAvailableMediaTypesSucceeded
{
    __block NSArray* result = nil;
    [self.service getAvailableMediaTypesWithCallback:^(NSArray *types, NSError *error) {
        inCallback = YES;
        result = types;
        fault = error;
    }];
    RKObjectRequestOperation* operation = [self.objectManager.operationQueue.operations lastObject];
    [self.objectManager.operationQueue waitUntilAllOperationsAreFinished];
    expect(operation.HTTPRequestOperation.response.statusCode).to.equal(200);
    expect(inCallback).will.beTruthy();
    expect(result.count).to.equal(4);
    expect(fault).to.beNil();
    [self.mockDelegate verify];
}

-(void)testThatGetMediaListSucceeded
{
#warning TODO: implement RestKit mapping
    __block NSArray* result = nil;
    [self.service getMediaListForType:DownloadMediaTypeClips callback:^(NSArray *mediaList, NSError *error) {
        inCallback = YES;
        result = mediaList;
        fault = error;
    }];
    AFHTTPRequestOperation* operation = [self.objectManager.HTTPClient.operationQueue.operations lastObject];
    [self.objectManager.HTTPClient.operationQueue waitUntilAllOperationsAreFinished];
    expect(operation.response.statusCode).to.equal(200);
    expect(inCallback).will.beTruthy();
    expect(result.count).to.equal(3);
    expect(fault).to.beNil();
    [self.mockDelegate verify];
}

-(void)testThatGetContentSetsSucceeded
{
#warning TODO: implement RestKit mapping
    __block NSArray* result = nil;
    [self.service getContentSets:^(NSArray *array, NSError *error) {
        inCallback = YES;
        result = array;
        fault = error;
    }];
    AFHTTPRequestOperation* operation = [self.objectManager.HTTPClient.operationQueue.operations lastObject];
    [self.objectManager.HTTPClient.operationQueue waitUntilAllOperationsAreFinished];
    expect(operation.response.statusCode).to.equal(200);
    expect(inCallback).will.beTruthy();
    expect(result.count).to.equal(1);
    expect(fault).to.beNil();
    [self.mockDelegate verify];
}

-(void)testThatValidateReceiptSucceeded
{
#warning TODO: implement RestKit mapping
    __block NSDictionary* result = nil;
    NSError* dontUsed = nil;
    NSData* data = [NSJSONSerialization dataWithJSONObject:@{@"foo":@"bar"} options:0 error:&dontUsed];
    [self.service validateReceipt:data forContentSetIdentity:@"123123123" callback:^(NSDictionary *object, NSError *error) {
        inCallback = YES;
        result = object;
        fault = error;
    }];
    AFHTTPRequestOperation* operation = [self.objectManager.HTTPClient.operationQueue.operations lastObject];
    [self.objectManager.HTTPClient.operationQueue waitUntilAllOperationsAreFinished];
    expect(operation.response.statusCode).to.equal(200);
    expect(inCallback).will.beTruthy();
    expect(result).toNot.beNil();
    expect(fault).to.beNil();
    [self.mockDelegate verify];
}

@end
