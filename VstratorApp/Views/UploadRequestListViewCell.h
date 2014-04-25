//
//  UploadRequestListViewCell.h
//  VstratorApp
//
//  Created by Lion User on 25/07/2012.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UploadRequestListViewTypes.h"
#import "BaseListViewCell.h"

@protocol UploadRequestListViewCellDelegate;


@interface UploadRequestListViewCell : BaseListViewCell

+ (CGFloat)rowHeight;

@property (nonatomic, weak) id<UploadRequestListViewCellDelegate> delegate;

- (id)initWithDelegate:(id<UploadRequestListViewCellDelegate>)delegate;

- (void)configureForData:(UploadRequest*)uploadRequest;
- (void)renewAnimations;
- (void)showDeleteButton;
- (void)hideDeleteButton;
- (void)showStopButton;
- (void)hideStopButton;

@end


@protocol UploadRequestListViewCellDelegate<NSObject>

- (void)uploadRequestListViewCell:(UploadRequestListViewCell *)sender action:(UploadRequestAction)action;

@end
