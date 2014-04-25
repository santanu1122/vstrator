//
//  LoginMethodsViewController.h
//  VstratorApp
//
//  Created by Mac on 26.02.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "LoginViewControllerDelegate.h"


@interface LoginMethodsViewController : BaseViewController

@property (nonatomic, weak) id<LoginViewControllerDelegate> delegate;
@property (nonatomic) BOOL dialogMode;

@end
