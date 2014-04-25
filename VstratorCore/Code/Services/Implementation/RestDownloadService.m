//
//  RestDownloadService.m
//  VstratorApp
//
//  Created by akupr on 31.07.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "CallbackWrapper.h"
#import "ContentSet.h"
#import "RestDownloadService.h"
#import "Media.h"
#import "MediaTypeInfo.h"
#import "NSError+Extensions.h"

@implementation RestDownloadService

-(void)downloadDataByURL:(NSURL*)url callback:(void(^)(NSData *data, NSError *error))callback
{
    NSParameterAssert(url);
    NSParameterAssert(callback);
    NSParameterAssert(self.delegate);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"GET";
    AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        callback(operation.responseData, nil);
    } failure:[self errorCallbackWrapper1:callback]];
    [[self.delegate objectManager].HTTPClient enqueueHTTPRequestOperation:requestOperation];
}

-(void)getAvailableMediaTypesWithCallback:(void (^)(NSArray *types, NSError *error))callback
{
    NSParameterAssert(callback);
    NSParameterAssert(self.delegate);
    [[self.delegate objectManager] getObjectsAtPath:@"contentdownloads" parameters:[self.delegate parameters] success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        callback(mappingResult.array, nil);
    } failure:[self errorCallbackWrapper1:callback]];
}

-(void)getMediaListForType:(DownloadMediaType)type callback:(void(^)(NSArray* mediaList, NSError* error))callback
{
    NSParameterAssert(callback);
    NSParameterAssert(self.delegate);
    NSMutableURLRequest *request = [[self.delegate objectManager].HTTPClient requestWithMethod:@"GET" path:[NSString stringWithFormat:@"contentdownloads/%d", type] parameters:[self.delegate parameters]];
    AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [requestOperation setCompletionBlockWithSuccess:[self jsonCallbackWrapper:callback] failure:[self errorCallbackWrapper1:callback]];
    [[self.delegate objectManager].HTTPClient enqueueHTTPRequestOperation:requestOperation];
}

-(void)getContentSets:(void (^)(NSArray *, NSError *))callback
{
    NSParameterAssert(callback);
    NSParameterAssert(self.delegate);
    NSMutableURLRequest *request = [[self.delegate objectManager].HTTPClient requestWithMethod:@"GET" path:@"contentsets" parameters:[self.delegate parameters]];
    AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [requestOperation setCompletionBlockWithSuccess:[self jsonCallbackWrapper:callback] failure:[self errorCallbackWrapper1:callback]];
    [[self.delegate objectManager].HTTPClient enqueueHTTPRequestOperation:requestOperation];
}

-(void)validateReceipt:(NSData*)receipt forContentSetIdentity:(NSString*)identity callback:(void(^)(NSDictionary* object, NSError* error))callback
{
    NSParameterAssert(receipt);
    NSParameterAssert(identity);
    NSParameterAssert(callback);
    NSParameterAssert(self.delegate);
    NSMutableURLRequest *request = [[self.delegate objectManager].HTTPClient requestWithMethod:@"POST" path:[@"contentsets" stringByAppendingPathComponent:identity] parameters:[self.delegate parameters]];
    request.HTTPBody = receipt;
    [request setValue:RKMIMETypeJSON forHTTPHeaderField:@"Content-Type"];
    AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [requestOperation setCompletionBlockWithSuccess:[self jsonCallbackWrapper:callback] failure:[self errorCallbackWrapper1:callback]];
    [[self.delegate objectManager].HTTPClient enqueueHTTPRequestOperation:requestOperation];
}

-(void)getContentSetWithIdentity:(NSString*)identity callback:(void(^)(NSDictionary* object, NSError* error))callback
{
    NSParameterAssert(callback);
  
}

@end
