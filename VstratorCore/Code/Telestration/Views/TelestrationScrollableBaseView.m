//
//  TelestrationScrollableBaseView.m
//  VstratorCore
//
//  Created by Admin1 on 23.08.13.
//  Copyright (c) 2013 OnTarget. All rights reserved.
//

#import "TelestrationScrollableBaseView.h"

#define kvaRotationStep (45 * M_PI / 180)
#define kvaRotationAngle (90 * M_PI / 180)

@interface TelestrationScrollableBaseView()

@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation TelestrationScrollableBaseView

int _lastRotationStep;

#pragma mark Properties

- (UIImage *)image
{
    return self.imageView.image;
}

- (void)setImage:(UIImage *)image
{
    self.imageView.image = image;
}

- (UIImageView *)imageView
{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        _imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _imageView.backgroundColor = UIColor.clearColor;
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _imageView;
}

#pragma mark UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (void)rotate:(UIRotationGestureRecognizer*)sender
{
    if(sender.state == UIGestureRecognizerStateEnded) {
        _lastRotationStep = -1;
        return;
    }
    
    CGFloat currentRotation = sender.rotation;
    int step = abs((int)(currentRotation / kvaRotationStep));
    
    if ((_lastRotationStep == step) ||
        (step % 2 == 0 && _lastRotationStep < step) ||
        (step % 2 != 0 && _lastRotationStep > step)) return;
    
    int sign = currentRotation < 0 ? -1 : 1;
    sign *= step > _lastRotationStep ? 1 : -1;
    [self appendViewTransform:CGAffineTransformMakeRotation(sign * kvaRotationAngle)];
    _lastRotationStep = step;
}

- (void)appendViewTransform:(CGAffineTransform)viewTransform
{
}

- (void)setup
{
    _lastRotationStep = -1;
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

@end
