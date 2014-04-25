//
//  BaseViewController.h
//  VstratorApp
//
//  Created by Mac on 07.04.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Callbacks.h"
#import "LoginManager.h"
#import "MediaPlayerManager.h"
#import "NavigationBarView.h"
#import "TextFieldPopupView.h"

@interface BaseViewController : UIViewController<NavigationBarViewDelegate, TextFieldPopupViewDelegate>

#pragma mark Properties

@property (nonatomic, strong, readonly) LoginManager *loginManager;
@property (nonatomic, strong, readonly) MediaPlayerManager *mediaPlayerManager;
@property (nonatomic, strong, readonly) NavigationBarView *navigationBarView;
@property (nonatomic, strong, readonly) TextFieldPopupView *textFieldPopupView;
@property (nonatomic, readonly) BOOL statusBarHidden;

//@property (nonatomic, readonly) CGSize viewSizeForPortrait;
//@property (nonatomic, readonly) CGSize viewSizeForLandscape;

#pragma mark Navigation Bar

- (void)navigationBarView:(NavigationBarView *)sender action:(NavigationBarViewAction)action;

#pragma mark TextFieldPopupView

- (void)setupTextFieldPopupView:(TextFieldPopupView *)textFieldPopupView;

#pragma mark Helpers:Indicators

- (void)showBGActivityIndicator:(NSString *)title;
- (void)showBGActivityIndicator:(NSString *)title lockViews:(BOOL)lockViews;
- (void)updateBGActivityIndicator:(NSString *)title;
- (void)updateBGActivityIndicator:(NSString *)title lockViews:(BOOL)lockViews;
- (ErrorCallback)hideBGActivityCallback;
- (ErrorCallback)hideBGActivityCallback:(ErrorCallback)callback;
- (void)hideBGActivityIndicator;
- (void)hideBGActivityIndicator:(NSError *)error;
- (void)hideBGActivityIndicator:(NSError *)error withCallback:(ErrorCallback)callback;
- (void)hideBGActivityIndicator:(NSError *)error withSelector:(SEL)selector;

- (void)showBlackoutView;
- (void)hideBlackoutView;

#pragma mark Helpers:Views

+ (void)switchViews:(UIView *)contentView containerView:(UIView *)containerView;
- (void)setOrientation:(UIInterfaceOrientation)orientation forView:(UIView*)view;
- (void)setOrientation:(UIInterfaceOrientation)orientation forViewInt:(UIView *)view;

#pragma mark Helpers:MoviePlayer

- (void)playMedia:(Media*)media;
- (void)mediaPlayerManagerDidClosed:(MediaPlayerManager *)sender;

#pragma mark - Rotations

- (void)rotate:(UIInterfaceOrientation)toInterfaceOrientation;

@end
