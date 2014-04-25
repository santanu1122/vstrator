//
//  LoginManager.h
//  VstratorApp
//
//  Created by Virtualler on 25.12.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Callbacks.h"

@class BaseViewController;

typedef enum {
    LoginQuestionTypeNone = 0,
    LoginQuestionTypeDialog
} LoginQuestionType;

typedef void (^LoginManagerCallback)(NSError *error, BOOL userIdentityChanged);


@interface LoginManager : NSObject

@property (nonatomic, weak) BaseViewController *viewController;

- (void)login:(LoginQuestionType)questionType callback:(LoginManagerCallback)callback;

@end
