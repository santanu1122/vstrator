//
//  DownloadDispatcher.h
//  VstratorApp
//
//  Created by akupr on 21.07.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DownloadDispatcher : NSObject

-(void)start;
-(void)stop;

+(DownloadDispatcher*)sharedInstance;

@end
