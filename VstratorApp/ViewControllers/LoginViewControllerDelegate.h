//
//  LoginViewControllerDelegate.h
//  VstratorApp
//
//  Created by Virtualler on 26.12.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

@class BaseViewController;

@protocol LoginViewControllerDelegate <NSObject>

@optional
- (void)loginViewControllerDidCancel:(BaseViewController *)sender;
@required
- (void)loginViewControllerDidLogin:(BaseViewController *)sender;

@end
