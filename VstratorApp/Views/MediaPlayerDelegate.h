//
//  MediaPlayerDelegate.h
//  VstratorApp
//
//  Created by Mac on 15.04.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

//#import <Foundation/Foundation.h>

@protocol MediaPlayerDelegate<NSObject>

- (UIView *)view;

- (void)pause;
- (void)play;
- (void)stop;

@end
