//
//  NavigationMenuView.m
//  VstratorApp
//
//  Created by Admin1 on 03.09.13.
//  Copyright (c) 2013 OnTarget. All rights reserved.
//

#import "NavigationMenuListViewCell.h"
#import "NavigationMenuView.h"
#import "VstratorConstants.h"
#import "VstratorStrings.h"

@interface NavigationMenuView() <NavigationMenuListViewCellDelegate, UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UIView *view;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *logoutButton;
@property (weak, nonatomic) IBOutlet UILabel *sectionHeaderLabel;

@property (strong, nonatomic) NSDictionary *commands;

@end

@implementation NavigationMenuView

#pragma mark UITableViewDataSource, UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.commands.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NavigationMenuListViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:NavigationMenuListViewCell.reuseIdentifier];
	if (!cell) {
        cell = [[NavigationMenuListViewCell alloc] initWithDelegate:self];
	}
    [cell configureWithTitle:[self.commands valueForKey:@(indexPath.row).stringValue] tag:indexPath.row];
	return cell;
}

#pragma mark NavigationMenuListViewCellDelegate

- (void)navigationMenuListViewCell:(NavigationMenuListViewCell *)sender didSelectWithTag:(int)tag
{
    if ([self.delegate respondsToSelector:@selector(navigatinMenuView:didAction:)])
        [self.delegate navigatinMenuView:self didAction:tag];
}

#pragma mark Actions

- (IBAction)logoutAction:(id)sender {
    if ([self.delegate respondsToSelector:@selector(navigatinMenuView:didAction:)])
        [self.delegate navigatinMenuView:self didAction:NavigationMenuViewActionLogout];
}

#pragma mark Internal

- (void)refreshMenu:(BOOL)isUserLoggedIn
{
    self.logoutButton.hidden = !isUserLoggedIn;
    CGRect frame = self.tableView.frame;
    if (!isUserLoggedIn) {
        frame.size.height = self.view.frame.size.height - self.headerView.frame.size.height;
    } else {
        frame.size.height = self.view.frame.size.height - self.headerView.frame.size.height - self.logoutButton.frame.size.height;
    }
    self.tableView.frame = frame;
}

- (void)setLocalizableStrings
{
    self.sectionHeaderLabel.text = @"SETTINGS";
    [self.logoutButton setTitle:@"Logout" forState:UIControlStateNormal];
}

- (void)setup
{
    [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self.class) owner:self options:nil];
    NSAssert(self.view != nil, VstratorConstants.AssertionNibIsInvalid);
    [self adjustXibFrame];
    [self addSubview:self.view];
    
    self.tableView.rowHeight = [NavigationMenuListViewCell rowHeight];
    self.logoutButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    self.logoutButton.titleEdgeInsets = UIEdgeInsetsMake(0, 40, 0, 0);
    
    self.commands = @{ @(NavigationMenuViewActionAccountInfo).stringValue: VstratorStrings.UserInfoViewAccountInfoButtonTitle,
                       @(NavigationMenuViewActionTutorial).stringValue: VstratorStrings.UserInfoTutorialButtonTitle,
                       @(NavigationMenuViewActionSupportSite).stringValue: VstratorStrings.UserInfoSupportSiteButtonTitle,
                       @(NavigationMenuViewActionFeedback).stringValue: VstratorStrings.UserInfoGetHelpButtonTitle,
                       @(NavigationMenuViewActionUploads).stringValue: VstratorStrings.UserInfoUploadQueueButtonTitle,
                       @(NavigationMenuViewActionUploadQuality).stringValue: VstratorStrings.UserInfoUploadQualityButtonTitle,
                       @(NavigationMenuViewActionRateApp).stringValue: VstratorStrings.UserInfoRateThisAppButtonTitle,
                       @(NavigationMenuViewActionInviteFriends).stringValue: VstratorStrings.UserInfoInviteFriendsButtonTitle,
                       @(NavigationMenuViewActionAboutApp).stringValue: VstratorStrings.UserInfoAboutThisAppButtonTitle };
}

- (void)adjustXibFrame
{
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height);
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

@end
