//
//  BackgroundTaskWrapper.h
//  VstratorCore
//
//  Created by akupr on 11.03.13.
//  Copyright (c) 2013 OnTarget. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Callbacks.h"

@interface BackgroundTaskWrapper : NSObject

-(id)initWithTask:(Callback0)task;
-(id)initWithTask:(Callback0)task expirationHandler:(Callback0)handler;
-(void)run;

+(BackgroundTaskWrapper*)wrapperWithTask:(Callback0)task;
+(BackgroundTaskWrapper*)wrapperWithTask:(Callback0)task expirationHandler:(Callback0)handler;

@end
