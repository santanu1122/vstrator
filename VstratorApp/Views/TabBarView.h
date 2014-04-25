//
//  TabBarView.h
//  VstratorApp
//
//  Created by Mac on 01.04.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BaseRotatableView.h"
#import "TabBarViewTypes.h"

@protocol TabBarViewDelegate;


@interface TabBarView : BaseRotatableView

@property (nonatomic, weak) id<TabBarViewDelegate> delegate;
@property (nonatomic) TabBarAction selectedAction;

- (void)setSelectedActionAndFire:(TabBarAction)selectedAction;

@end


@protocol TabBarViewDelegate<NSObject>

@required
- (void)tabBarView:(TabBarView *)sender action:(TabBarAction)action changesSelection:(BOOL)changesSelection;

@end
