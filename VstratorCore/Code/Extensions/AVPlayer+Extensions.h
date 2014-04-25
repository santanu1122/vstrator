//
//  AVPlayer+Extensions.h
//  VstratorApp
//
//  Created by Mac on 24.05.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface AVPlayer (Extensions)

+ (id)dequeuePlayerWithURL:(NSURL *)url;

@end
