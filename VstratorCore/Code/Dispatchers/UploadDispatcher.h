//
//  UploadDispatcher.h
//  VstratorApp
//
//  Created by user on 15.05.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UploadDispatcher : NSObject

-(void)start;
-(void)stop;
-(void)resume;

+(UploadDispatcher*)sharedInstance;

@end
