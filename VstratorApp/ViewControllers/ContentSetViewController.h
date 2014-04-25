//
//  ContentSetControllerViewController.h
//  VstratorApp
//
//  Created by Admin on 03/04/2013.
//  Copyright (c) 2013 OnTarget. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "ContentSet.h"

@protocol ContentSetViewControllerDelegate;

@interface ContentSetViewController : BaseViewController

@property (nonatomic, weak) id<ContentSetViewControllerDelegate> delegate;

- (id)initWithDelegate:(id<ContentSetViewControllerDelegate>)delegate contentSet:(ContentSet *)contentSet;

@end

@protocol ContentSetViewControllerDelegate <NSObject>

@required
- (void)contentSetViewController:(ContentSetViewController *)sender downloadContentSet:(ContentSet *)contentSet;

@end
