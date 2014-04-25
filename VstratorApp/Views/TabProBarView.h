//
//  TabProBarView.h
//  VstratorApp
//
//  Created by Lion User on 04/07/2012.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RotatableView.h"
#import "TabProView.h"

@protocol TabProBarViewDelegate;

@interface TabProBarView : RotatableView

@property (nonatomic, weak) id<TabProBarViewDelegate> delegate;
@property (nonatomic) TabProViewContentType contentType;

@end

@protocol TabProBarViewDelegate<NSObject>

- (void) tabProBarView:(TabProBarView *)sender didSwitchToContent:(TabProViewContentType)type;

@end
