//
//  Wrapper.h
//  VstratorApp
//
//  Created by user on 12.03.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Callbacks.h"

@interface CallbackWrapper : NSObject

@property (nonatomic, copy) Callback callback;
@property (nonatomic, copy) ErrorCallback errorCallback;

@property (nonatomic, strong) CallbackWrapper* saveSelf;
@property (nonatomic, readonly) Callback callbackAndReleaseSelf;
@property (nonatomic, readonly) ErrorCallback errorCallbackAndReleaseSelf;

- (void)setCallback:(Callback)callback errorCallback:(ErrorCallback)errorCallback;

+ (id)wrapperWithCallback:(Callback)callback errorCallback:(ErrorCallback)errorCallback;

@end
