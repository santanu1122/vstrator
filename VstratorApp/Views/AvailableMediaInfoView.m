//
//  AvailableMediaInfoView.m
//  VstratorApp
//
//  Created by Admin on 01/04/2013.
//  Copyright (c) 2013 OnTarget. All rights reserved.
//

#import "AvailableMediaInfoView.h"
#import "VstratorStrings.h"

@interface AvailableMediaInfoView()

@property (strong, nonatomic) IBOutlet UIView *view;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailsLabel;
@property (weak, nonatomic) IBOutlet UIButton *downloadButton;

@property (nonatomic, strong) Media *media;

@end

@implementation AvailableMediaInfoView

#pragma mark Actions

- (IBAction)downloadAction:(id)sender {
    if ([self.delegate respondsToSelector:@selector(availableMediaInfoViewDownloadAction:)])
        [self.delegate availableMediaInfoViewDownloadAction:self];
}

#pragma mark Business Logic

- (void)setMedia:(Media *)media
{
    _media = media;
    [self loadMediaValues];
}

- (void)setLocalizableStrings
{
    [self.downloadButton setTitle:VstratorStrings.MediaClipSessionViewDownloadButtonTitle forState:UIControlStateNormal];
}

- (void)loadMediaValues
{
    if (self.media == nil) return;
    self.titleLabel.text = self.media.title;
    self.detailsLabel.text = self.media.note;
}

#pragma mark RotatableView

- (void)nilXibOutlets
{
    self.titleLabel = nil;
    self.detailsLabel = nil;
    self.downloadButton = nil;
    [super nilXibOutlets];
}

- (void)setOrientation:(UIInterfaceOrientation)orientation
{
    [super setOrientation:orientation];
    [self setLocalizableStrings];
    [self loadMediaValues];
}

@end
