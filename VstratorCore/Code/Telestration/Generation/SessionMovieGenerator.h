//
//  SessionMovieGenerator.h
//  VstratorCore
//
//  Created by akupr on 05.10.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Callbacks.h"

#define SESSION_MOVIE_GENERATION

@class Session;

@interface SessionMovieGenerator : NSObject

@property (nonatomic) CGFloat width;
@property (nonatomic) CGFloat height;
@property (nonatomic, strong) Session* session;

-(void)generateAsync:(ErrorCallback)callback;
+(void)generateImagesByMediaURL:(NSURL*)url inFolder:(NSString*)folder callback:(ErrorCallback)callback;

-(id)initWithSession:(Session*)session;
+(SessionMovieGenerator*)generatorWithSession:(Session*)session;

@end
