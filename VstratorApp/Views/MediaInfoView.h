//
//  MediaInfoView.h
//  VstratorApp
//
//  Created by User on 31.08.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RotatableView.h"
#import "Media+Extensions.h"
#import "MediaListViewTypes.h"

@protocol MediaInfoViewDelegate;

@interface MediaInfoView : RotatableView

@property (nonatomic, weak) IBOutlet id<MediaInfoViewDelegate> delegate;

- (void)setMedia:(Media *)media userIdentity:(NSString *)userIdentity;
- (void)updateUploadState;
- (void)animateUploadingIcon;

@end

@protocol MediaInfoViewDelegate <NSObject>

@optional
- (void)mediaInfoView:(MediaInfoView *)sender didAction:(MediaAction)action;

@end
