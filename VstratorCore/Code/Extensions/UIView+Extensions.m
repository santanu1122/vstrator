//
//  UIViewCategory.m
//  VstratorApp
//
//  Created by Mac on 08.04.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "UIView+Extensions.h"
#import "VstratorConstants.h"
#import "VstratorStrings.h"

#import <QuartzCore/CALayer.h>

@implementation UIView (Extensions)

#pragma mark Switchers

+ (void)switchViews:(UIView *)contentView containerView:(UIView *)containerView;
{
    [UIView switchViews:contentView containerView:containerView setFrame:YES];
}

+ (void)switchViews:(UIView *)contentView containerView:(UIView *)containerView setFrame:(BOOL)setFrame
{
    NSAssert(containerView != nil, VstratorStrings.ErrorInvalidParameterValue);
    // hide current view
    if (containerView.subviews != nil) {
        for (UIView *view in containerView.subviews) {
            [view removeFromSuperview];
        }
    }
    // set new
    if (contentView != nil) {
        [containerView addSubview:contentView];
        if (setFrame) {
            contentView.frame = CGRectMake(0, 0, containerView.frame.size.width, containerView.frame.size.height);
        }
    }
}

- (void)switchViews:(UIView *)contentView
{
    [UIView switchViews:contentView containerView:self];
}

- (void)switchViews:(UIView *)contentView setFrame:(BOOL)setFrame
{
    [UIView switchViews:contentView containerView:self setFrame:YES];
}

#pragma mark Animations

- (void)animateFadeInOutLoopWithDuration:(CGFloat)duration minAlpha:(CGFloat)minAlpha maxAlpha:(CGFloat)maxAlpha
{
    [self removeAllLayersAnimations];
    self.alpha = maxAlpha;
    [UIView animateWithDuration:duration
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionCurveLinear | UIViewAnimationOptionRepeat
                     animations:^{
                         self.alpha = minAlpha;
                     }
                     completion:nil];
}

- (void)removeAllLayersAnimations
{
    [self.layer removeAllAnimations];
    for (CALayer *layer1 in self.layer.sublayers)
        [layer1 removeAllAnimations];
}

#pragma mark Layer

- (void)setBorderColor:(UIColor *)borderColor borderWidth:(CGFloat)borderWidth cornerRadius:(CGFloat)cornerRadius
{
    self.layer.borderColor = borderColor.CGColor;
    self.layer.borderWidth = borderWidth;
    self.layer.cornerRadius = cornerRadius;
}

- (void)setShadowWithColor:(UIColor *)color offset:(CGSize)offset
{
    [self setShadowWithColor:color offset:offset opacity:1.0 radius:0];
}

- (void)setShadowWithColor:(UIColor *)color offset:(CGSize)offset opacity:(CGFloat)opacity radius:(CGFloat)radius
{
    self.layer.masksToBounds = NO;
    self.layer.shadowColor = color.CGColor;
    self.layer.shadowOffset = offset;
    self.layer.shadowOpacity = opacity;
    self.layer.shadowRadius = radius;
}

@end
