//
//  UIAlertViewWrapper.h
//  VstratorApp
//
//  Created by Mac on 09.04.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CallbackWrapper.h"

@interface UIAlertViewWrapper : CallbackWrapper<UIAlertViewDelegate>

// Static alerts
+ (void)alertError:(NSError *)error;
+ (void)alertError:(NSError *)error title:(NSString *)title;
+ (void)alertString:(NSString *)string;
+ (void)alertString:(NSString *)string title:(NSString *)title;
+ (void)alertErrorOrString:(NSError *)error string:(NSString *)string;
+ (void)alertErrorOrString:(NSError *)error string:(NSString *)string title:(NSString *)title;
+ (void)alertInvalidInputString:(NSString *)string;

// Instance alerts
- (void)alertError:(NSError *)error;
- (void)alertError:(NSError *)error title:(NSString *)title;
- (void)alertString:(NSString *)string;
- (void)alertString:(NSString *)string title:(NSString *)title;
- (void)alertErrorOrString:(NSError *)error string:(NSString *)string;
- (void)alertErrorOrString:(NSError *)error string:(NSString *)string title:(NSString *)title;
- (void)alertInvalidInputString:(NSString *)string;
- (void)showMessage:(NSString *)message title:(NSString *)title cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ...;

// Instance
+ (id)wrapperWithCallback:(Callback)callback;

@end
