//
//  TabVstrateBarView.h
//  VstratorApp
//
//  Created by Lion User on 04/07/2012.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RotatableView.h"
#import "MediaListViewTypes.h"

@protocol TabVstrateBarViewDelegate;

@interface TabVstrateBarView : RotatableView

@property (nonatomic, weak) id<TabVstrateBarViewDelegate> delegate;
@property (nonatomic) MediaListViewContentType contentType;

@end

@protocol TabVstrateBarViewDelegate<NSObject>

- (void) tabVstrateBarView:(TabVstrateBarView *)sender didSwitchToContent:(MediaListViewContentType)type;

@end
