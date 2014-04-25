//
//  BaseRotatableView.h
//  VstratorApp
//
//  Created by Lion User on 06/07/2012.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RotatableViewProtocol.h"

@interface BaseRotatableView : UIView

@property (nonatomic, strong) IBOutlet UIView *view;

- (void)adjustXibFrame;
- (void)nilXibOutlets;
- (void)setOrientation:(UIInterfaceOrientation)orientation;
- (void)setup;

@end
