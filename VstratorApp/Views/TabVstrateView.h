//
//  TabVstrateView.h
//  VstratorApp
//
//  Created by user on 03.05.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MediaListViewTypes.h"
#import "RotatableViewProtocol.h"
#import "TabBarViewTypes.h"


@protocol TabVstrateViewDelegate;


@interface TabVstrateView : UIView<MediaListViewDelegate, TabBarViewItemDelegate, RotatableViewProtocol>

@property (nonatomic, weak) id<TabVstrateViewDelegate> delegate;
@property (nonatomic, copy) NSString *queryString;
@property (nonatomic) MediaListViewContentType selectedContentType;

- (void) reload;
  
@end


@protocol TabVstrateViewDelegate<NSObject>

@required
-(void) tabVstrateView:(TabVstrateView *)sender media:(Media *)media action:(MediaAction)action;
@optional
-(void) tabVstrateViewSyncAction:(TabVstrateView *)sender;
-(void) tabVstrateView:(TabVstrateView *)sender didSwitchToContent:(MediaListViewContentType)contentType;

@end
