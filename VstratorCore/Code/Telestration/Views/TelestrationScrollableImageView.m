//
//  TelestrationScrollableImageView.m
//  VstratorCore
//
//  Created by Admin on 31/01/2013.
//  Copyright (c) 2013 OnTarget. All rights reserved.
//

#import "TelestrationScrollableBaseView+Subclassing.h"
#import "TelestrationScrollableImageView.h"

@implementation TelestrationScrollableImageView

- (CGAffineTransform)viewTransform
{
    return self.imageView.transform;
}

- (void)setViewTransform:(CGAffineTransform)viewTransform
{
    self.imageView.transform = viewTransform;
}

- (void)appendViewTransform:(CGAffineTransform)viewTransform
{
    self.imageView.transform = CGAffineTransformConcat(self.imageView.transform, viewTransform);
}

- (void)setup {
    [super setup];
    self.backgroundColor = UIColor.clearColor;
    [self addSubview:self.imageView];
}

@end
