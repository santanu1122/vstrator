//
//  MediaListViewProHeader.m
//  VstratorApp
//
//  Created by Lion User on 27/07/2012.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "MediaListViewProHeader.h"
#import "VstratorConstants.h"
#import "VstratorStrings.h"

@interface MediaListViewProHeader()

@property (strong, nonatomic) IBOutlet UIView *view;
@property (weak, nonatomic) IBOutlet UIButton *downloadButton;
@property (weak, nonatomic) IBOutlet UIImageView *downloadIcon;
@property (weak, nonatomic) IBOutlet UIImageView *arrowIcon;

@end

@implementation MediaListViewProHeader

#pragma mark Actions

- (IBAction)downloadAction:(id)sender {
    if ([self.delegate respondsToSelector:@selector(mediaListViewProHeaderSelectAction:)])
        [self.delegate mediaListViewProHeaderSelectAction:self];
}

#pragma mark Business Logic

- (void)setLocalizableStrings
{
    [self.downloadButton setTitle:VstratorStrings.MediaListViewProHeaderDownloadButtonTitle forState:UIControlStateNormal];
}

- (void)setup
{
    // NIB
    [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self.class) owner:self options:nil];
    NSAssert(self.view != nil, VstratorConstants.AssertionNibIsInvalid);
    [self addSubview:self.view];
    self.view.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    [self setLocalizableStrings];
}

#pragma mark RotatableViewProtocol

- (void)setOrientation:(UIInterfaceOrientation)orientation
{
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        CGRect frame = self.downloadIcon.frame;
        frame.origin.x = 100;
        frame.origin.y = 7;
        self.downloadIcon.frame = frame;
        
        frame = self.arrowIcon.frame;
        frame.origin.x = 380;
        frame.origin.y = 15;
        self.arrowIcon.frame = frame;
    } else {
        CGRect frame = self.downloadIcon.frame;
        frame.origin.x = 20;
        frame.origin.y = 7;
        self.downloadIcon.frame = frame;
        
        frame = self.arrowIcon.frame;
        frame.origin.x = 290;
        frame.origin.y = 15;
        self.arrowIcon.frame = frame;
    }
}

#pragma mark View Lifecycle

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
