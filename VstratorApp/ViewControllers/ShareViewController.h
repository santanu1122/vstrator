//
//  ShareViewController.h
//  VstratorApp
//
//  Created by Admin on 23/01/2013.
//  Copyright (c) 2013 OnTarget. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BaseViewController.h"
#import "Media.h"

typedef enum {
    ShareTypeMedia,
    ShareTypeInviteFriends,
    ShareTypeWorkout
} ShareType;

@protocol ShareViewControllerDelegate;

@interface ShareViewController : BaseViewController

@property (nonatomic, weak) id<ShareViewControllerDelegate> delegate;
@property (nonatomic) ShareType shareType;
@property (nonatomic, strong) NSString *messageParameter;
@property (nonatomic, copy) NSString* mediaTitle;

@end

@protocol ShareViewControllerDelegate <NSObject>

@required
-(void)shareViewControllerDidFinish:(ShareViewController *)sender;

@end