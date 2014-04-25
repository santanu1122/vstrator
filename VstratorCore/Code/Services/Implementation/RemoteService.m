//
//  RestService.m
//  VstratorApp
//
//  Created by user on 23.02.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "RemoteService.h"

@implementation RemoteService

-(id)initWithDelegate:(id<RemoteServiceDelegate>)delegate
{
    self = [self init];
    if (self) {
        _delegate = delegate;
    }
    return self;
}

-(void (^)(id, NSError *))errorCallbackWrapper:(ErrorCallback)callback
{
    return ^(id operation, NSError* error) {
        // TODO: log the error
        callback(error);
    };
}

-(void (^)(id, NSError *))errorCallbackWrapper1:(void (^)(id, NSError *))callback
{
    return [self errorCallbackWrapper:^(NSError *error) {
        callback(nil, error);
    }];
}

-(void (^)(AFHTTPRequestOperation *, id))jsonCallbackWrapper:(void (^)(id, NSError *))callback
{
    return ^(AFHTTPRequestOperation* operation, id responseObject) {
        NSError* error = nil;
        id json = [NSJSONSerialization JSONObjectWithData:operation.responseData options:0 error:&error];
        [self errorCallbackWrapper:^(NSError *wrapperError) { callback(json, wrapperError); }](operation, error);
    };
}

@end
