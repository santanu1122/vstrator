//
//  ContentQuickStartViewController.h
//  VstratorApp
//
//  Created by Mac on 18.05.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseTabbedViewController.h"
#import "TabBarViewTypes.h"

@protocol ContentQuickStartViewControllerDelegate;


@interface ContentQuickStartViewController : BaseTabbedViewController

@property (nonatomic, weak) id<ContentQuickStartViewControllerDelegate> delegate;
@property (nonatomic) BOOL firstTimeMode;

@end


@protocol ContentQuickStartViewControllerDelegate <NSObject>

- (void)contentQuickStartViewController:(ContentQuickStartViewController *)sender
                              didTabBar:(TabBarAction)action;

@end
