//
//  NavigationMenuView.h
//  VstratorApp
//
//  Created by Admin1 on 03.09.13.
//  Copyright (c) 2013 OnTarget. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    NavigationMenuViewActionAccountInfo,
    NavigationMenuViewActionTutorial,
    NavigationMenuViewActionSupportSite,
    NavigationMenuViewActionFeedback,
    NavigationMenuViewActionUploads,
    NavigationMenuViewActionUploadQuality,
    NavigationMenuViewActionRateApp,
    NavigationMenuViewActionInviteFriends,
    NavigationMenuViewActionAboutApp,
    NavigationMenuViewActionLogout
} NavigationMenuViewAction;

@protocol NavigationMenuViewDelegate;

@interface NavigationMenuView : UIView

@property (nonatomic, weak) id<NavigationMenuViewDelegate> delegate;

- (void)refreshMenu:(BOOL)isUserLoggedIn;

@end

@protocol NavigationMenuViewDelegate <NSObject>

- (void)navigatinMenuView:(NavigationMenuView*)sender didAction:(NavigationMenuViewAction)action;

@end