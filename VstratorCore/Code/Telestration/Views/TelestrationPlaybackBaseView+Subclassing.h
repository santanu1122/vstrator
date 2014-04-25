//
//  TelestrationPlaybackBaseView_Subclassing.h
//  VstratorCore
//
//  Created by Admin1 on 23.08.13.
//  Copyright (c) 2013 OnTarget. All rights reserved.
//

#import "TelestrationPlaybackBaseView.h"

@class TelestrationScrollableBaseView;

@interface TelestrationPlaybackBaseView (Subclassing)

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) TelestrationScrollableBaseView *scrollableView;

- (void)callDelegateDidChange;
- (void)setup;

@end
