//
//  BaseRotatableView.m
//  VstratorApp
//
//  Created by Lion User on 06/07/2012.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "BaseRotatableView.h"

#import "VstratorConstants.h"

@interface BaseRotatableView() {
    NSString *_loadedNibName;
}

@end

@implementation BaseRotatableView

#pragma mark Xibs

- (void)loadXibFor:(UIInterfaceOrientation) orientation
{
    NSString *nibPortraitName = NSStringFromClass(self.class);
    NSString *nibLandscapeName = [NSString stringWithFormat:@"%@%@", nibPortraitName, @"Landscape"];
    NSString *nibName = UIInterfaceOrientationIsLandscape(orientation) ? nibLandscapeName : nibPortraitName;
    if (_loadedNibName && [_loadedNibName isEqualToString:nibName])
        return;

    if (self.view) {
        [self.view removeFromSuperview];
        self.view = nil;
    }
    [self nilXibOutlets];
    
    [[NSBundle mainBundle] loadNibNamed:nibName owner:self options:nil];
    NSAssert(self.view != nil, VstratorConstants.AssertionNibIsInvalid);
    _loadedNibName = nibName;

    self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [self adjustXibFrame];
    [self addSubview:self.view];
}

#pragma mark Exposed Methods

- (void)adjustXibFrame
{
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height);
}

- (void)nilXibOutlets
{
    // intentionally left blank
}

- (void)setOrientation:(UIInterfaceOrientation)orientation
{
    [self loadXibFor:orientation];
}

- (void)setup
{
    // intentionally left blank
}

#pragma mark View Lifecycle

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self loadXibFor:UIInterfaceOrientationPortrait];
        [self setup];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self loadXibFor:UIInterfaceOrientationPortrait];
        [self setup];
    }
    return self;
}

@end
