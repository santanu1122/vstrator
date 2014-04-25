//
//  UIViewCategory.h
//  VstratorApp
//
//  Created by Mac on 08.04.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIView (Extensions)

// Switchers
+ (void)switchViews:(UIView *)contentView containerView:(UIView *)containerView;
+ (void)switchViews:(UIView *)contentView containerView:(UIView *)containerView setFrame:(BOOL)setFrame;
- (void)switchViews:(UIView *)contentView;
- (void)switchViews:(UIView *)contentView setFrame:(BOOL)setFrame;

// Animations
- (void)animateFadeInOutLoopWithDuration:(CGFloat)duration minAlpha:(CGFloat)minAlpha maxAlpha:(CGFloat)maxAlpha;
- (void)removeAllLayersAnimations;

// Layer shortcuts
- (void)setBorderColor:(UIColor *)borderColor borderWidth:(CGFloat)borderWidth cornerRadius:(CGFloat)cornerRadius;
- (void)setShadowWithColor:(UIColor *)color offset:(CGSize)offset;
- (void)setShadowWithColor:(UIColor *)color offset:(CGSize)offset opacity:(CGFloat)opacity radius:(CGFloat)radius;


@end
