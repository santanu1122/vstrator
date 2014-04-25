//
//  LogoViewController.h
//  VstratorApp
//
//  Created by Mac on 11.03.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@protocol LogoViewControllerDelegate;


@interface LogoViewController : BaseViewController

@property (nonatomic, weak) IBOutlet id<LogoViewControllerDelegate> delegate;

@end


@protocol LogoViewControllerDelegate <NSObject>

@required
- (void)logoViewControllerDidLogo:(LogoViewController *)sender;

@end
