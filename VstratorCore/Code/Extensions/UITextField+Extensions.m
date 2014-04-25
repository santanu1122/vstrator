//
//  UITextField+Extensions.m
//  VstratorCore
//
//  Created by Virtualler on 20.02.13.
//  Copyright (c) 2013 Futures. All rights reserved.
//

#import "UITextField+Extensions.h"

@implementation UITextField (Extensions)

- (void)setSidePaddings:(NSInteger)padding
{
    [self setLeftPadding:padding];
    [self setRightPadding:padding];
}

- (void)setLeftPadding:(NSInteger)padding
{
    // left padding
    if (padding > 0) {
        self.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, padding, self.frame.size.height)];
        self.leftView.autoresizingMask = UIViewAutoresizingNone;
        self.leftView.backgroundColor = UIColor.clearColor;
        self.leftView.userInteractionEnabled = NO;
        self.leftViewMode = UITextFieldViewModeAlways;
    } else if (self.leftView != nil) {
        if (self.leftView.superview != nil)
            [self.leftView removeFromSuperview];
        self.leftView = nil;
        self.leftViewMode = UITextFieldViewModeNever;
    }
}

- (void)setRightPadding:(NSInteger)padding
{
    [self setRightPadding:padding withImage:nil andImageOffset:UIOffsetZero];
}

- (void)setRightPadding:(NSInteger)padding withImage:(UIImage *)image
{
    UIOffset imageOffset = (padding <= 0 || image == nil) ? UIOffsetZero : UIOffsetMake((padding - image.size.width) / 2.0, (self.frame.size.height - image.size.height) / 2.0);
    [self setRightPadding:padding withImage:image andImageOffset:imageOffset];
}

- (void)setRightPadding:(NSInteger)padding withImage:(UIImage *)image andImageOffset:(UIOffset)offset
{
    UITextFieldViewMode rightPaddingViewMode = [self rightPaddingViewMode];
    if (rightPaddingViewMode != UITextFieldViewModeNever && padding > 0) {
        self.rightView = [[UIView alloc] initWithFrame:CGRectMake(self.frame.size.width - padding, 0, padding, self.frame.size.height)];
        self.rightView.autoresizingMask = UIViewAutoresizingNone;
        self.rightView.backgroundColor = UIColor.clearColor;
        self.rightView.userInteractionEnabled = NO;
        self.rightViewMode = rightPaddingViewMode;
        if (image != nil) {
            UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
            imageView.frame = CGRectMake(offset.horizontal, offset.vertical, imageView.frame.size.width, imageView.frame.size.height);
            [self.rightView addSubview:imageView];
        }
    } else if (self.rightView != nil) {
        if (self.rightView.superview != nil)
            [self.rightView removeFromSuperview];
        self.rightView = nil;
        self.rightViewMode = UITextFieldViewModeNever;
    }
}

- (UITextFieldViewMode)rightPaddingViewMode
{
    if (self.clearButtonMode == UITextFieldViewModeNever)
        return UITextFieldViewModeAlways;
    if (self.clearButtonMode == UITextFieldViewModeUnlessEditing)
        return UITextFieldViewModeWhileEditing;
    if (self.clearButtonMode == UITextFieldViewModeWhileEditing)
        return UITextFieldViewModeUnlessEditing;
    return UITextFieldViewModeNever;
}

@end
