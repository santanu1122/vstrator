//
//  NavigationBarView.m
//  VstratorApp
//
//  Created by Mac on 01.04.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "NavigationBarView.h"
#import "NSString+Extensions.h"
#import "VstratorConstants.h"
#import "UIView+Extensions.h"
#import "VstratorStrings.h"

@interface NavigationBarView()

@property (strong, nonatomic) IBOutlet UIView *view;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *homeButton;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;
@property (weak, nonatomic) IBOutlet UIButton *settingsButton;
@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;

@end

@implementation NavigationBarView

#pragma mark Properties

- (void)setTitle:(NSString *)title
{
    _title = [[NSString stringWithStringOrNil:title] uppercaseString];
    self.titleLabel.hidden = ([_title isEqualToString:[[VstratorConstants NavigationBarLogoTitle] uppercaseString]]);
    self.logoImageView.hidden = !self.titleLabel.hidden;
    self.titleLabel.text = _title == nil ? @"" : _title;
}

- (void)setShowHome:(BOOL)showHome
{
    _showHome = showHome;
    self.homeButton.hidden = !showHome;
    if (showHome)
        self.showBack = NO;
}

- (void)setShowBack:(BOOL)showBack
{
    _showBack = showBack;
    self.backButton.hidden = !showBack;
    if (showBack)
        self.showHome = NO;
}

- (void)setShowSettings:(BOOL)showSettings
{
    _showSettings = showSettings;
    self.settingsButton.hidden = !showSettings;
}

- (void)setShowSearch:(BOOL)showSearch
{
    _showSearch = showSearch;
    self.searchButton.hidden = !showSearch;
}

- (void)setTagForButtons
{
    self.homeButton.tag = NavigationBarViewActionHome;
    self.backButton.tag = NavigationBarViewActionBack;
    self.settingsButton.tag = NavigationBarViewActionSettings;
    self.searchButton.tag = NavigationBarViewActionSearch;
}

#pragma mark Actions

- (IBAction)buttonAction:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(navigationBarView:action:)] && [sender isKindOfClass:UIButton.class]) {
        [self.delegate navigationBarView:self action:((UIButton *)sender).tag];
    }
}

#pragma mark Localization

- (void)setLocalizableStrings
{
    [self.backButton setTitle:VstratorStrings.NavigationBarBackButtonTitle forState:UIControlStateNormal];
}

#pragma mark BaseRotatableView

- (void)setup
{
    [super setup];
    self.backgroundColor = [UIColor clearColor];
    [self setLocalizableStrings];
    [self setTagForButtons];
    self.showBack = YES;
    self.showHome = NO;
    self.showSearch = NO;
    self.showSettings = NO;
    self.title = nil;
}

- (void)adjustXibFrame
{
    if (!CGRectIsEmpty(self.bounds))
        self.view.frame = CGRectMake(0, 0, self.bounds.size.width, self.view.frame.size.height);
    [super adjustXibFrame];
}

- (void)nilXibOutlets
{
    [super nilXibOutlets];
    self.view = nil;
    self.titleLabel = nil;
    self.homeButton = nil;
    self.backButton = nil;
    self.searchButton = nil;
    self.settingsButton = nil;
    self.logoImageView = nil;
}

- (void)setResizableImages
{
    [self.settingsButton setBackgroundImage:[UIImage resizableImageNamed:@"bt-grey-t01-normal"] forState:UIControlStateNormal];
    [self.settingsButton setBackgroundImage:[UIImage resizableImageNamed:@"bt-grey-t01-sel"] forState:UIControlStateHighlighted];
}

- (void)setOrientation:(UIInterfaceOrientation)orientation
{
    [super setOrientation:orientation];
    [self setLocalizableStrings];
    [self setTagForButtons];
    [self setResizableImages];
    // Restore settings
    self.showHome = self.showHome;
    self.showBack = self.showBack;
    self.showSearch = self.showSearch;
    self.showSettings = self.showSettings;
    self.title = self.title;
}

@end
