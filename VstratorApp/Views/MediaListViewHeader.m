//
//  MediaListViewHeader.m
//  VstratorApp
//
//  Created by Admin on 01/04/2013.
//  Copyright (c) 2013 OnTarget. All rights reserved.
//

#import "MediaListViewHeader.h"
#import "VstratorConstants.h"
#import "VstratorStrings.h"

@interface MediaListViewHeader()

@property (strong, nonatomic) IBOutlet UIView *view;
@property (weak, nonatomic) IBOutlet UIButton *syncButton;
@property (weak, nonatomic) IBOutlet UIImageView *reloadIcon;

@end

@implementation MediaListViewHeader

- (IBAction)syncAction:(id)sender {
    if ([self.delegate respondsToSelector:@selector(mediaListViewHeaderSyncAction:)]) {
        [self.delegate mediaListViewHeaderSyncAction:self];
    }
}

#pragma mark RotatableViewProtocol

- (void)setOrientation:(UIInterfaceOrientation)orientation
{
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        CGRect frame = self.reloadIcon.frame;
        frame.origin.x = 100;
        frame.origin.y = 7;
        self.reloadIcon.frame = frame;
    } else {
        CGRect frame = self.reloadIcon.frame;
        frame.origin.x = 30;
        frame.origin.y = 9;
        self.reloadIcon.frame = frame;
    }
}

#pragma mark View Lifecycle

- (void)localizeStrings
{
    [self.syncButton setTitle:VstratorStrings.MediaListViewHeaderSyncButtonTitle forState:UIControlStateNormal];
}

- (void)setup
{
    [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self.class) owner:self options:nil];
    NSAssert(self.view != nil, VstratorConstants.AssertionNibIsInvalid);
    [self addSubview:self.view];
    self.view.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);

    [self localizeStrings];
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
