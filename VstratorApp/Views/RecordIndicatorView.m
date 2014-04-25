//
//  RecordIndicatorView.m
//  VstratorApp
//
//  Created by Virtualler on 10.09.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "RecordIndicatorView+Protected.h"
#import "VstratorConstants.h"

#import <QuartzCore/QuartzCore.h>

@implementation RecordIndicatorView

#pragma mark Properties

- (BOOL)hideOnFinish
{
    return YES;
}

- (BOOL)active
{
    return self.timer != nil;
}

#pragma mark Business Logic

- (void)removeFromSuperview
{
    [self stop];
    [super removeFromSuperview];
}

- (void)resume
{
    if (self.started) {
        [self startWithStartValue:self.timerStartValue endValue:self.timerEndValue value:self.timerValue];
    } else {
        [self start];
    }
}

- (void)pause
{
    // timer
    if (self.timer) {
        [self.timer invalidate];
        _timer = nil;
    }
    // views
    if (self.hideOnFinish)
        self.view.hidden = YES;
}

- (void)start
{
    [self startWithStartValue:0 endValue:0 value:0];
}

- (void)startWithStartValue:(NSInteger)startValue endValue:(NSInteger)endValue
{
    [self startWithStartValue:startValue endValue:endValue value:startValue];
}

- (void)startWithStartValue:(NSInteger)startValue endValue:(NSInteger)endValue value:(NSInteger)value
{
    // stop
    [self stop];
    // show
    self.view.hidden = NO;
    // setup
    _started = YES;
    _timerDirection = (startValue < endValue);
    _timerStartValue = startValue;
    _timerEndValue = endValue;
    _timerValue = value; //TODO: fix value for [endValue;startValue] to avoid infinite loops
    [self setupViewsOnStart];
    // perform
    [self timerAction];
    _timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(timerAction) userInfo:nil repeats:YES];
}

- (void)stop
{
    // pause
    [self pause];
    // flush vars
    _timerStartValue = _timerEndValue = _timerValue = 0;
    _started = NO;
}

- (void)timerAction
{
    NSInteger timerDiff = (self.timerDirection ? self.timerEndValue - self.timerValue : self.timerValue - self.timerEndValue);
    if (timerDiff > 0) {
        if (self.timerDirection)
            _timerValue++;
        self.counterLabel.text = [NSString stringWithFormat:@"%d", self.timerValue];
        [self updateViews];
        if (!self.timerDirection)
            _timerValue--;
    } else {
        [self stop];
        if ([self.delegate respondsToSelector:@selector(recordIndicatorViewDidFinish:)])
            [self.delegate recordIndicatorViewDidFinish:self];
    }
}

#pragma mark Views

- (void)setupViewsOnStart
{
    // intentionally left blank
}

- (void)updateViews
{
    NSInteger shownCounter = self.timerValue;
    // fix frame
    CGPoint desiredOrigin = (shownCounter < 10) ? CGPointMake(12, 10) : CGPointMake(11, 5);
    if (fabs(desiredOrigin.x - self.counterLabel.frame.origin.x) > 0.1 || fabs(desiredOrigin.y - self.counterLabel.frame.origin.y) > 0.1) {
        CGRect frame = self.counterLabel.frame;
        frame.origin = desiredOrigin;
        self.counterLabel.frame = frame;
    }
    // spin
    [self spinLayer:self.counterImageView.layer duration:1.0f direction:1.0];
}

/* http://mobiledevelopertips.com/user-interface/rotate-an-image-or-button-with-animation-part-2.html */
- (void)spinLayer:(CALayer *)inLayer duration:(CFTimeInterval)inDuration direction:(int)direction
{
    // Rotate about the z axis
    CABasicAnimation* rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    // Rotate 360 degress, in direction specified
    rotationAnimation.toValue = @(M_PI * 2.0 * direction);
    // Perform the rotation over this many seconds
    rotationAnimation.duration = inDuration;
    // Set the pacing of the animation
    rotationAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    // Add animation to the layer and make it so
    [inLayer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

#pragma mark View Lifecycle

- (void)setup
{
    self.backgroundColor = [UIColor clearColor];
    // NIB
    [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self.class) owner:self options:nil];
    NSAssert(self.view != nil, VstratorConstants.AssertionNibIsInvalid);
    // Views
    [self addSubview:self.view];
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height);
    self.view.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    if (self.hideOnFinish)
        self.view.hidden = YES;
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
