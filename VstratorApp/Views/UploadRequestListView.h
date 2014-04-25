//
//  UploadRequestListView.h
//  VstratorApp
//
//  Created by Lion User on 25/07/2012.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataSelector.h"
#import "UploadRequestListViewTypes.h"
#import "BaseListView.h"
#import "UploadRequestListViewCell.h"

@protocol UploadRequestListViewDelegate<NSObject>

- (void)uploadRequestListView:(UploadRequestListView *)sender uploadRequest:(UploadRequest *)uploadRequest action:(UploadRequestAction)action;

@end

@interface UploadRequestListView : BaseListView<UploadRequestListViewCellDelegate>

@property (nonatomic, weak) id<UploadRequestListViewDelegate> delegate;

- (void)renewPresentation;
- (void)setContentType:(UploadRequestContentType)contentType;

@end


