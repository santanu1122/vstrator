//
//  BaseTabbedViewController.h
//  VstratorApp
//
//  Created by Mac on 27.05.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "BaseViewController.h"
#import "TabBarView.h"

@interface BaseTabbedViewController : BaseViewController

#pragma mark Properties

@property (nonatomic, strong, readonly) UISearchBar *searchBar;
@property (nonatomic, strong, readonly) TabBarView *tabBarView;

#pragma mark Tab Bar

- (void)tabBarView:(TabBarView *)sender action:(TabBarAction)action changesSelection:(BOOL)changesSelection;

#pragma mark Search Bar

- (void)arrangeSearchBarViews;
- (void)hideSearchBar;
- (void)showSearchBar;
- (void)showSearchBar:(BOOL)becomeFirstResponder;
- (void)showOrHideSearchBar:(BOOL)becomeFirstResponder;
- (void)performSearch;

@end
