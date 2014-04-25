//
//  TutorialViewController.h
//  VstratorApp
//
//  Created by Ryan Latta on 10/20/11.
//  Copyright (c) 2011 Atlantic BT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@protocol TutorialViewControllerDelegate;



@interface TutorialViewController : BaseViewController

@property (nonatomic, weak) id<TutorialViewControllerDelegate> delegate;
@property (nonatomic) BOOL dontShowFlagHidden;
@property (nonatomic) BOOL dontShowFlagValue;

@end



@protocol TutorialViewControllerDelegate <NSObject>

@optional
- (void)tutorialViewControllerDidSkip:(TutorialViewController *)sender;

@end
