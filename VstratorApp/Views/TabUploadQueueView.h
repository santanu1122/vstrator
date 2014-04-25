//
//  TabUploadQueueView.h
//  VstratorApp
//
//  Created by Lion User on 25/07/2012.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RotatableViewProtocol.h"
#import "UploadRequestListViewTypes.h"


@protocol TabUploadQueueViewDelegate;


@interface TabUploadQueueView : UIView<RotatableViewProtocol>

@property (nonatomic, weak) IBOutlet id<TabUploadQueueViewDelegate> delegate;
@property (nonatomic, copy) NSString *queryString;
@property (nonatomic) UploadRequestContentType contentType;

- (void)reload;

@end


@protocol TabUploadQueueViewDelegate<NSObject>

@required
- (void)tabUploadQueueView:(TabUploadQueueView *)sender uploadRequest:(UploadRequest *)uploadRequest action:(UploadRequestAction)action;
@optional
- (void)tabUploadQueueView:(TabUploadQueueView *)sender didSwitchToContent:(UploadRequestContentType)contentType;

@end