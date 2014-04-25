//
//  NavigationBarView.h
//  VstratorApp
//
//  Created by Mac on 01.04.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BaseRotatableView.h"

typedef enum {
    NavigationBarViewActionHome,
    NavigationBarViewActionBack,
    NavigationBarViewActionSearch,
    NavigationBarViewActionSettings
} NavigationBarViewAction;

@protocol NavigationBarViewDelegate;

@interface NavigationBarView : BaseRotatableView

@property (nonatomic, weak) IBOutlet id<NavigationBarViewDelegate> delegate;

@property (nonatomic, copy) NSString *title;
@property (nonatomic) BOOL showHome;
@property (nonatomic) BOOL showBack;
@property (nonatomic) BOOL showSearch;
@property (nonatomic) BOOL showSettings;

@end

@protocol NavigationBarViewDelegate<NSObject>

@required
- (void)navigationBarView:(NavigationBarView *)sender action:(NavigationBarViewAction)action;

@end
