//
//  AvailableMediaInfoView.h
//  VstratorApp
//
//  Created by Admin on 01/04/2013.
//  Copyright (c) 2013 OnTarget. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RotatableView.h"
#import "Media.h"

@protocol AvailableMediaInfoViewDelegate;

@interface AvailableMediaInfoView : RotatableView

@property (nonatomic, weak) id<AvailableMediaInfoViewDelegate> delegate;

- (void)setMedia:(Media *)media;

@end

@protocol AvailableMediaInfoViewDelegate <NSObject>

@optional
- (void)availableMediaInfoViewDownloadAction:(AvailableMediaInfoView *)sender;

@end