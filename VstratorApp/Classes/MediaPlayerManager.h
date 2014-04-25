//
//  MediaPlayerManager.h
//  VstratorApp
//
//  Created by Virtualler on 29.08.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MediaPlayerManagerDelegate;

@interface MediaPlayerManager : NSObject

@property (nonatomic, weak) UIViewController<MediaPlayerManagerDelegate> *viewController;
@property (nonatomic, weak) id<MediaPlayerManagerDelegate> delegate;

- (void)presentPlayerWithURL:(NSURL *)url
                   introMode:(BOOL)introMode
                    animated:(BOOL)animated;

@end

@protocol MediaPlayerManagerDelegate <NSObject>

@optional
- (void)mediaPlayerManagerDidClosed:(MediaPlayerManager *)sender;

@end
