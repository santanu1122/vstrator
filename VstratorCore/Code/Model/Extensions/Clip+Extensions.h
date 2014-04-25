//
//  Clip+Extensions.h
//  VstratorApp
//
//  Created by user on 21.03.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "Clip.h"
#import "Callbacks.h"

@interface Clip (Extensions)

+ (NSURL *)urlWithFileURL:(NSURL *)fileURL identity:(NSString *)identity;
+ (NSString *)pathForPlaybackQualityForIdentity:(NSString *)identity;
+ (BOOL)existsPlaybackQualityForIdentity:(NSString *)identity;
- (NSString *)pathForPlaybackQuality;
- (BOOL)existsPlaybackQuality;

+ (Clip *)findClipWithIdentity:(NSString *)identity inContext:(NSManagedObjectContext *)context error:(NSError **)error;
- (void)setupURL:(NSURL*)url title:(NSString*)title authorIdentity:(NSString*)authorIdentity sportName:(NSString*)sportName actionName:(NSString*)actionName note:(NSString *)note callback:(ErrorCallback)callback;

@end
