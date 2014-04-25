//
//  TextFieldPopupView.m
//  VstratorApp
//
//  Created by Mac on 01.08.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "TextFieldPopupView.h"
#import "NSString+Extensions.h"
#import "VstratorExtensions.h"
#import "VstratorConstants.h"
#import "VstratorStrings.h"

#import <QuartzCore/QuartzCore.h>

@interface TextFieldPopupView() <UITextFieldDelegate, UITextViewDelegate> {
    BOOL _shouldEndEditWithCancelMode;
    int _maxLength;
}

@property (nonatomic, weak) UITextField *sourceTextField;
@property (nonatomic, weak) UITextView *sourceTextView;

@property (nonatomic, strong) IBOutlet UIView *view;
@property (nonatomic, weak) IBOutlet UIImageView *backgroundImageView;
@property (nonatomic, weak) IBOutlet UIButton *hideButton;
@property (nonatomic, weak) IBOutlet UIView *navigationBarView;
@property (nonatomic, weak) IBOutlet UIImageView *navigationBarImageView;
@property (nonatomic, weak) IBOutlet UIButton *navigationBarCancelButton;
@property (nonatomic, weak) IBOutlet UIButton *navigationBarDoneButton;
@property (nonatomic, weak) IBOutlet UILabel *textLabel;
@property (nonatomic, weak) IBOutlet UILabel *countLabel;
@property (nonatomic, weak) IBOutlet UITextField *textField;
@property (nonatomic, weak) IBOutlet UITextView *textView;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;

@end

@implementation TextFieldPopupView

#pragma mark - Properties

- (UIImage *)backgroundImage
{
    return self.backgroundImageView.image;
}

- (void)setBackgroundImage:(UIImage *)backgroundImage
{
    if (self.backgroundImageView.image != backgroundImage)
        self.backgroundImageView.image = backgroundImage;
}

- (void)setTitle:(NSString *)title
{
    _title = title;
    self.titleLabel.text = self.title;
}

- (UIColor *)titleColor
{
    return self.textLabel.textColor;
}

- (void)setTitleColor:(UIColor *)titleColor
{
    self.textLabel.textColor = titleColor;
}

- (void)setDoneButtonTitle:(NSString *)doneButtonTitle
{
    _doneButtonTitle = doneButtonTitle;
    [self.navigationBarDoneButton setTitle:self.doneButtonTitle forState:UIControlStateNormal];
}

#pragma mark - Business Logic

- (NSString *)stripTextTitle:(NSString *)title
{
    if (title != nil && [title hasSuffix:@":"])
        title = [title substringWithRange:NSMakeRange(0, title.length - 1)];
    return title;
}

- (void)showWithTextField:(UITextField *)textField
                   inView:(UIView *)view
{
    [self showWithTextField:textField andTitle:textField.placeholder inView:view];
}

- (void)showWithTextField:(UITextField *)textField
                 andTitle:(NSString *)title
                   inView:(UIView *)view
{
    NSAssert(textField != nil && ![NSString isNilOrWhitespace:title] && view != nil, VstratorConstants.AssertionArgumentIsNilOrInvalid);
    if (self.superview != nil)
        return;
    // state
    self.textField.hidden = NO;
    self.textView.hidden = YES;
    // frames
    self.frame = CGRectMake(0, 0, view.bounds.size.width, view.bounds.size.height);
    self.view.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    // fill values
    title = [self stripTextTitle:title];
    self.sourceTextField = textField;
    self.textField.text = self.sourceTextField.clearsOnBeginEditing ? nil : self.sourceTextField.text;
    self.textField.secureTextEntry = self.sourceTextField.secureTextEntry;
    self.textField.placeholder = title;
    self.textLabel.text = [NSString stringWithFormat:@"%@:", title];
    self.countLabel.hidden = YES;
    _maxLength = 0;
    self.textField.keyboardType = self.sourceTextField.keyboardType;
    self.textField.keyboardAppearance = self.sourceTextField.keyboardAppearance;
    self.textField.autocapitalizationType = self.sourceTextField.autocapitalizationType;
    self.textField.autocorrectionType = self.sourceTextField.autocorrectionType;
    // show self
    [view addSubview:self];
    // first responder
    [self.textField becomeFirstResponder];
}

- (void)showWithTextView:(UITextView *)textView
                andTitle:(NSString *)title
                  inView:(UIView *)view
{
    [self showWithTextView:textView andTitle:title inView:view moveToBeginning:NO];
}

- (void)showWithTextView:(UITextView *)textView
                andTitle:(NSString *)title
                  inView:(UIView *)view
         moveToBeginning:(BOOL)moveToBeginning
{
    NSAssert(textView != nil && ![NSString isNilOrWhitespace:title] && view != nil, VstratorConstants.AssertionArgumentIsNilOrInvalid);
    if (self.superview != nil)
        return;
    // state
    self.textField.hidden = YES;
    self.textView.hidden = NO;
    // frames
    self.frame = CGRectMake(0, 0, view.bounds.size.width, view.bounds.size.height);
    //self.view.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    // fill values
    title = [self stripTextTitle:title];
    self.sourceTextView = textView;
    self.textView.text = self.sourceTextView.text;
    self.textView.secureTextEntry = self.sourceTextView.secureTextEntry;
    self.textLabel.text = [NSString stringWithFormat:@"%@:", title];
    self.countLabel.hidden = YES;
    _maxLength = 0;
    self.textView.keyboardAppearance = self.sourceTextView.keyboardAppearance;
    self.textView.keyboardType = self.sourceTextView.keyboardType;
    self.textView.autocapitalizationType = self.sourceTextView.autocapitalizationType;
    self.textView.autocorrectionType = self.sourceTextView.autocorrectionType;
    // show self
    [view addSubview:self];
    // first responder
    [self.textView becomeFirstResponder];
    if (moveToBeginning) self.textView.selectedRange = NSMakeRange(0, 0);
}

- (void)showWithTextView:(UITextView *)textView
                andTitle:(NSString *)title
            andMaxLength:(int)maxLength
                  inView:(UIView *)view
{
    [self showWithTextView:textView andTitle:title andMaxLength:maxLength inView:view moveToBeginning:NO];
}

- (void)showWithTextView:(UITextView *)textView
                andTitle:(NSString *)title
            andMaxLength:(int)maxLength
                  inView:(UIView *)view
         moveToBeginning:(BOOL)moveToBeginning;
{
    [self showWithTextView:textView andTitle:title inView:view moveToBeginning:moveToBeginning];
    self.countLabel.hidden = NO;
    _maxLength = maxLength;
    [self refreshCountLabel:[textView.text length]];
}

- (IBAction)doneAction:(id)sender
{
    _shouldEndEditWithCancelMode = (sender == self.navigationBarCancelButton);
    [self endEditing:YES];
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (_shouldEndEditWithCancelMode) {
        // cancel
        _shouldEndEditWithCancelMode = NO;
        if ([self.delegate respondsToSelector:@selector(textFieldPopupViewDidCancel:)])
            [self.delegate textFieldPopupViewDidCancel:self];
        else
            [self removeFromSuperview];
    } else {
        // finish
        self.sourceTextField.text = self.textField.text;
        if ([self.delegate respondsToSelector:@selector(textFieldPopupViewDidFinish:)])
            [self.delegate textFieldPopupViewDidFinish:self];
        else
            [self removeFromSuperview];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self endEditing:YES];
    return NO;
}

- (void)refreshCountLabel:(int)length
{
    self.countLabel.text = [NSString stringWithFormat:@"%i", _maxLength - length];
}

#pragma mark - UITextViewDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (self.maxCharactersCount <= 0) return YES;
    
    NSUInteger oldLength = [textField.text length];
    NSUInteger replacementLength = [string length];
    NSUInteger rangeLength = range.length;
    
    NSUInteger newLength = oldLength - rangeLength + replacementLength;
    
    BOOL returnKey = [string rangeOfString: @"\n"].location != NSNotFound;
    
    return newLength <= self.maxCharactersCount || returnKey;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if (_shouldEndEditWithCancelMode) {
        // cancel
        _shouldEndEditWithCancelMode = NO;
        if ([self.delegate respondsToSelector:@selector(textFieldPopupViewDidCancel:)])
            [self.delegate textFieldPopupViewDidCancel:self];
        else
            [self removeFromSuperview];
    } else {
        // finish
        self.sourceTextView.text = self.textView.text;
        if (self.flashScrollIndicatorsForTextView)
            [self.sourceTextView flashScrollIndicators];
        if ([self.delegate respondsToSelector:@selector(textFieldPopupViewDidFinish:)])
            [self.delegate textFieldPopupViewDidFinish:self];
        else
            [self removeFromSuperview];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if (_maxLength == 0 || [text length] == 0) {
        return YES;
    }
    else {
        if ([textView.text length] >= _maxLength) {
            return NO;
        }
        else {
            return YES;
        }
    }
}

- (void)textViewDidChange:(UITextView *)textView
{
    if (self.countLabel.hidden || _maxLength == 0)
        return;
    [self refreshCountLabel:[textView.text length]];
}

#pragma mark - Localization

- (void)setLocalizableStrings
{
    [self.navigationBarCancelButton setTitle:VstratorStrings.NavigationBarCancelButtonTitle forState:UIControlStateNormal];
    if (self.doneButtonTitle.length < 1)
        [self.navigationBarDoneButton setTitle:VstratorStrings.NavigationBarDoneButtonTitle forState:UIControlStateNormal];
    else
        [self.navigationBarDoneButton setTitle:self.doneButtonTitle forState:UIControlStateNormal];
}

#pragma mark - Setup

- (void)setup
{
    self.backgroundColor = [UIColor clearColor];
    self.autoresizesSubviews = YES;
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    // NIB
    [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self.class) owner:self options:nil];
    [self addSubview:self.view];
    self.view.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    // Text View/Field layout
    self.textView.layer.cornerRadius = 5.0;
    //[self.textField setSidePaddings:10];
    //[self.textField setBorderColor:[UIColor colorWithWhite:0.07 alpha:1] borderWidth:1.0 cornerRadius:3];
    //[self.textField setShadowWithColor:[UIColor colorWithWhite:0.26 alpha:1] offset:CGSizeMake(0, 1.0)];
    //[self.textView setBorderColor:[UIColor colorWithWhite:0.07 alpha:1] borderWidth:1.0 cornerRadius:3];
    //[self.textView setShadowWithColor:[UIColor colorWithWhite:0.26 alpha:1] offset:CGSizeMake(0, 1.0)];
    // localization
    [self setLocalizableStrings];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setOrientation:(UIInterfaceOrientation)orientation
{
    //TODO: check & remove it
}

@end
