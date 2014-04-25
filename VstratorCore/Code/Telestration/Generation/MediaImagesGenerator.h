//
//  MediaImagesGenerator
//  VstratorCore
//
//  Created by akupr on 05.10.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <Foundation/Foundation.h>
#import "Callbacks.h"

@interface MediaImagesGenerator : NSObject

- (void)generateImagesWithMediaURL:(NSURL*)url inFolder:(NSString*)folder callback:(void(^)(BOOL compleeted, NSError* error))callback;
- (void)stop;

@end

