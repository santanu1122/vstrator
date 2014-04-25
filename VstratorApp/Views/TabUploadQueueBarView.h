//
//  TabUploadQueueBarView.h
//  VstratorApp
//
//  Created by Lion User on 25/07/2012.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RotatableView.h"
#import "UploadRequestListViewTypes.h"

@protocol TabQueueVarViewDelegate;

@interface TabUploadQueueBarView : RotatableView

@property (nonatomic, weak) id<TabQueueVarViewDelegate> delegate;
@property (nonatomic) UploadRequestContentType contentType;

@end

@protocol TabQueueVarViewDelegate <NSObject>

- (void)tabUploadQueueBarView:(TabUploadQueueBarView *)view didSwitchToContentType:(UploadRequestContentType)contentType;

@end
