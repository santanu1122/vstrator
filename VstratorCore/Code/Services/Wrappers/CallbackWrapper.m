//
//  Wrapper.m
//  VstratorApp
//
//  Created by user on 12.03.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "CallbackWrapper.h"
#import "Callbacks.h"

@implementation CallbackWrapper

#pragma mark - Properties

@synthesize callback = _callback;
@synthesize errorCallback = _errorCallback;
@synthesize saveSelf = _saveSelf;

-(Callback) callbackAndReleaseSelf
{
	Callback callback = self.callback;
	self.saveSelf = nil;
	return callback;
}

-(ErrorCallback) errorCallbackAndReleaseSelf
{
	ErrorCallback callback = self.errorCallback;
	self.saveSelf = nil;
	return callback;
}

#pragma mark - Business Logic

+ (id)wrapperWithCallback:(Callback)callback errorCallback:(ErrorCallback)errorCallback
{
	CallbackWrapper* wrapper = [[self alloc] init];
	wrapper.saveSelf = wrapper;
    [wrapper setCallback:callback errorCallback:errorCallback];
	return wrapper;
}

- (void)setCallback:(Callback)callback errorCallback:(ErrorCallback)errorCallback
{
	self.callback = callback == nil ? ^(id result) { } : callback;
	self.errorCallback = errorCallback == nil ? ^(NSError *error) { } : errorCallback;
}

@end
