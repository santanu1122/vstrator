//
//  NotificationDispatcher.h
//  VstratorCore
//
//  Created by akupr on 23.10.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NotificationDispatcher : NSObject

-(void)start;
-(void)stop;

+(NotificationDispatcher*)sharedInstance;

@end
