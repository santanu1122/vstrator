//
//  TextFieldPopupView.h
//  VstratorApp
//
//  Created by Mac on 01.08.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RotatableViewProtocol.h"

@protocol TextFieldPopupViewDelegate;


@interface TextFieldPopupView : UIView <RotatableViewProtocol>

@property (nonatomic, weak) id<TextFieldPopupViewDelegate> delegate;
@property (nonatomic, weak) UIImage *backgroundImage;
@property (nonatomic, weak) UIColor *titleColor;
@property (nonatomic, weak) NSString *doneButtonTitle;
@property (nonatomic, weak) NSString *title;
@property (nonatomic) BOOL flashScrollIndicatorsForTextView;
@property (nonatomic) int maxCharactersCount;

- (void)showWithTextField:(UITextField *)textField
                   inView:(UIView *)view;
- (void)showWithTextField:(UITextField *)textField
                 andTitle:(NSString *)title
                   inView:(UIView *)view;

- (void)showWithTextView:(UITextView *)textView
                andTitle:(NSString *)title
                  inView:(UIView *)view;

- (void)showWithTextView:(UITextView *)textView
                andTitle:(NSString *)title
                  inView:(UIView *)view
         moveToBeginning:(BOOL)moveToBeginning;

- (void)showWithTextView:(UITextView *)textView
                andTitle:(NSString *)title
            andMaxLength:(int)maxLength
                  inView:(UIView *)view;

- (void)showWithTextView:(UITextView *)textView
                andTitle:(NSString *)title
            andMaxLength:(int)maxLength
                  inView:(UIView *)view
         moveToBeginning:(BOOL)moveToBeginning;

@end


@protocol TextFieldPopupViewDelegate <NSObject>

@optional
- (void)textFieldPopupViewDidFinish:(TextFieldPopupView *)sender;
- (void)textFieldPopupViewDidCancel:(TextFieldPopupView *)sender;

@end
