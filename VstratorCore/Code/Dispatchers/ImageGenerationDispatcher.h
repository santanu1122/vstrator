//
//  ImageGenerationDispatcher.h
//  VstratorCore
//
//  Created by akupr on 17.10.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Callbacks.h"

@interface ImageGenerationDispatcher : NSObject

+(ImageGenerationDispatcher*)sharedInstance;

@property (atomic, readonly) BOOL running;

-(void)start;
-(void)resume;
-(void)stop;

-(void)addMediaToProcessing:(Media*)media;

-(void)waitForIdentitiesProcessed:(NSArray*)identities callback:(ErrorCallback)callback;

+(BOOL)checkIdentityProcessedInFolder:(NSString*)folder;

@end
