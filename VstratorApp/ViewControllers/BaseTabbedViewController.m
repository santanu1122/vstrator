//
//  BaseTabbedViewController.m
//  VstratorApp
//
//  Created by Mac on 27.05.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "BaseTabbedViewController.h"
#import "SystemInformation.h"
#import "VstratorExtensions.h"
#import "VstratorStrings.h"

@interface BaseTabbedViewController () <TabBarViewDelegate, UISearchBarDelegate> {
    BOOL _searchBarObserverActive;
}

@end

@implementation BaseTabbedViewController

#pragma mark Properties

static const NSString *SearchBarCancelButtonEnabledObserver = @"SearchBarCancelButtonEnabledObserver";

@synthesize searchBar = _searchBar;
@synthesize tabBarView = _tabBarView;

- (UISearchBar *)searchBar
{
    if (_searchBar == nil) {
        // search bar
        _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, self.navigationBarView.hidden ? 0 : self.navigationBarView.frame.size.height, self.view.bounds.size.width, 50)];
        _searchBar.delegate = self;
        _searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
        _searchBar.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
        if ([SystemInformation isSystemVersionLessThan:@"7.0"]) {
            _searchBar.tintColor = [UIColor clearColor];
            // Hack for UISearchBar working like a filter (enable search empty string)
            [self fixSearchBar:^BOOL(UIView *subview) {
                if ([subview isKindOfClass:UITextField.class]) {
                    ((UITextField*)subview).enablesReturnKeyAutomatically = NO;
                    return YES;
                }
                return NO;
            }];
        } else {
            _searchBar.tintColor = [UIColor blackColor];
        }
        _searchBar.showsCancelButton = YES;
        [self addObserverForSearchBar];
    }
    return _searchBar;
}

- (TabBarView *)tabBarView
{
	if (_tabBarView == nil) {
        _tabBarView = [[TabBarView alloc] initWithFrame:CGRectZero];
        _tabBarView.frame = CGRectMake(0, self.view.bounds.size.height - _tabBarView.frame.size.height, self.view.bounds.size.width, _tabBarView.frame.size.height);
        _tabBarView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        _tabBarView.delegate = self;
        [self.view addSubview:_tabBarView];
    }
	return _tabBarView;
}

#pragma mark Tab Bar

- (void)navigationBarView:(NavigationBarView *)sender action:(NavigationBarViewAction)action
{
    if (action == NavigationBarViewActionSearch) {
        [self showSearchBar];
    } else {
        [super navigationBarView:sender action:action];
    }
}

- (void)tabBarView:(TabBarView *)sender action:(TabBarAction)action changesSelection:(BOOL)changesSelection
{
    // intentionally left blank
}

#pragma mark SearchBar

- (void)arrangeSearchBarViews
{
    // intentionally left blank
    //CGFloat searchBarHeight = self.searchBar.frame.size.height;
    //if (self.searchBar.superview == nil)
    //    searchBarHeight = -searchBarHeight;
    //for (UIView *view in self.view.subviews) {
    //    if (view == self.navigationBarView || view == self.tabBarView || view == self.searchBar)
    //        continue;
    //    view.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y + searchBarHeight, view.frame.size.width, view.frame.size.height - searchBarHeight);
    //}
}

- (void)hideSearchBar
{
    if (self.searchBar.superview == nil)
        return;
    [self.searchBar resignFirstResponder];
    [self.searchBar removeFromSuperview];
    [self arrangeSearchBarViews];
}

- (void)showSearchBar
{
    [self showSearchBar:YES];
}

- (void)showSearchBar:(BOOL)becomeFirstResponder
{
    // add search bar if invisible
    if (self.searchBar.superview == nil) {
        [self.view addSubview:self.searchBar];
        [self arrangeSearchBarViews];
    }
    // become first responder
    if (becomeFirstResponder)
        [self.searchBar becomeFirstResponder];
}

- (void)showOrHideSearchBar:(BOOL)becomeFirstResponder
{
    if ([NSString isNilOrWhitespace:self.searchBar.text]) {
        self.searchBar.text = nil;
        [self hideSearchBar];
    } else {
        [self showSearchBar:becomeFirstResponder];
    }
}

- (void)performSearch
{
    // intentionally left blank for the subclassing
}

- (void)fixSearchBar:(BOOL (^)(UIView* subview))fix
{
    UIView *view = self.searchBar;
    if ([SystemInformation isSystemVersionGreaterOrEqualTo:@"7.0"] && view.subviews.count > 0) {
        view = [view.subviews objectAtIndex:0];
    }
    for (UIView *subview in view.subviews) {
        if (fix(subview)) break;
    }
}

#pragma mark UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self performSearch];
}

- (void)searchBarSearchButtonClicked:(id)sender
{
    [self.searchBar resignFirstResponder];
    [self fixSearchBar:^BOOL(UIView *subview) {
        if ([subview isKindOfClass:UIButton.class]) {
            ((UIButton *)subview).enabled = YES;
            return YES;
        }
        return NO;
    }];
    [self performSearch];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    self.searchBar.text = nil;
    [self hideSearchBar];
    [self performSearch];
}

#pragma mark KVO

- (void)addObserverForSearchBar
{
    if (_searchBarObserverActive)
        return;
    for (UIView *subview in _searchBar.subviews) {
        if ([subview isKindOfClass:UIButton.class]) {
            [subview addObserver:self forKeyPath:@"enabled" options:NSKeyValueObservingOptionNew context:&SearchBarCancelButtonEnabledObserver];
            _searchBarObserverActive = YES;
            break;
        }
    }
}

- (void)removeObserverForSearchBar
{
    if (!_searchBarObserverActive)
        return;
    for (UIView *subview in _searchBar.subviews) {
        if ([subview isKindOfClass:UIButton.class]) {
            [subview removeObserver:self forKeyPath:@"enabled"];
            _searchBarObserverActive = NO;
            break;
        }
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == &SearchBarCancelButtonEnabledObserver) {
        if ([keyPath isEqualToString:@"enabled"] && [object isKindOfClass:UIButton.class]) {
            UIButton *button = (UIButton *)object;
            if (!button.enabled)
                button.enabled = YES;
        }
    }
}

#pragma mark - Rotations

- (void)rotate:(UIInterfaceOrientation)toInterfaceOrientation
{
    [super rotate:toInterfaceOrientation];
    [self.tabBarView setOrientation:toInterfaceOrientation];
}

#pragma mark View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationBarView.clipsToBounds = YES;
    [self tabBarView];
}

//- (void)viewWillAppear:(BOOL)animated
//{
//    [self.tabBarView setOrientation:self.interfaceOrientation];
//    [super viewWillAppear:animated];
//}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    //if (_searchBar != nil)
    //    self.searchBar.frame = CGRectMake(self.searchBar.frame.origin.x, self.searchBar.frame.origin.y, self.view.bounds.size.width, self.searchBar.frame.size.height);
    //self.tabBarView.frame = CGRectMake(self.tabBarView.frame.origin.x, self.view.bounds.size.height - self.tabBarView.frame.size.height, self.view.bounds.size.width, self.tabBarView.frame.size.height);
}

- (void)viewDidUnload
{
    // Release any retained subviews of the main view.
    if (_searchBar) {
        [self removeObserverForSearchBar];
        _searchBar = nil;
    }
    _tabBarView = nil;
    // Super
    [super viewDidUnload];
}

- (void)dealloc
{
    if (_searchBar) {
        [self removeObserverForSearchBar];
        _searchBar = nil;
    }
}

@end
