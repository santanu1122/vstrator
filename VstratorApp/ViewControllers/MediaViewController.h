//
//  MediaViewController.h
//  VstratorApp
//
//  Created by Mac on 28.05.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "MediaListViewTypes.h"

@class Media;
@protocol MediaViewControllerDelegate;

@interface MediaViewController : BaseViewController

@property (nonatomic, weak) id<MediaViewControllerDelegate> delegate;
@property (nonatomic, strong, readonly) Media *media;

- (id)initWithDelegate:(id<MediaViewControllerDelegate>)delegate media:(Media *)media mediaAction:(MediaAction)mediaAction;

@end


@protocol MediaViewControllerDelegate <NSObject>

@optional
- (void)mediaViewController:(MediaViewController *)sender didAction:(MediaAction)action;
- (void)mediaViewController:(MediaViewController *)sender didSelectSession:(Media *)media;
- (void)mediaViewControllerDidCancel:(MediaViewController *)sender;

@end
