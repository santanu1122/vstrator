//
//  RecordIndicatorView+Subclassing.h
//  VstratorApp
//
//  Created by Virtualler on 01.11.12.
//  Copyright (c) 2012 Virtualler. All rights reserved.
//

#import "RecordIndicatorView.h"

@interface RecordIndicatorView ()

@property (nonatomic, readonly, strong) NSTimer *timer;
@property (nonatomic, readonly) BOOL timerDirection;
@property (nonatomic, readonly) NSInteger timerStartValue;
@property (nonatomic, readonly) NSInteger timerEndValue;
@property (nonatomic, readonly) NSInteger timerValue;

@property (nonatomic, readonly) BOOL hideOnFinish;

@property (nonatomic, strong) IBOutlet UIView *view;
@property (nonatomic, weak) IBOutlet UIImageView *counterImageView;
@property (nonatomic, weak) IBOutlet UILabel *counterLabel;

- (void)setup;
- (void)setupViewsOnStart;
- (void)updateViews;

@end
