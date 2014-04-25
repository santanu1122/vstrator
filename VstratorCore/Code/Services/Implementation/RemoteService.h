//
//  RestService.h
//  VstratorApp
//
//  Created by user on 23.02.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <RestKit/RestKit.h>
#import <Foundation/Foundation.h>
#import "Callbacks.h"

@protocol RemoteServiceDelegate

@property (nonatomic, readonly) RKObjectManager* objectManager;
@property (nonatomic, readonly) NSDictionary* parameters;
@property (nonatomic, readonly) BOOL userIsLoggedIn;

@end

@interface RemoteService : NSObject

@property (nonatomic, weak) id<RemoteServiceDelegate> delegate;

-(id)initWithDelegate:(id<RemoteServiceDelegate>)delegate;
-(void(^)(AFHTTPRequestOperation*, id))jsonCallbackWrapper:(void(^)(id json, NSError* error))callback;
-(void(^)(id, NSError*))errorCallbackWrapper:(ErrorCallback)callback;
-(void(^)(id, NSError*))errorCallbackWrapper1:(void(^)(id object, NSError* error))callback;

@end
