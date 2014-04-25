//
//  MediaInfoView.m
//  VstratorApp
//
//  Created by User on 31.08.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "Action.h"
#import "MediaInfoView.h"
#import "Media+Extensions.h"
#import "Sport.h"
#import "UIView+Extensions.h"
#import "VstratorStrings.h"

#import <QuartzCore/CALayer.h>

@interface MediaInfoView()

@property (strong, nonatomic) IBOutlet UIView *view;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *sportLabel;
@property (weak, nonatomic) IBOutlet UILabel *actionLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailsLabel;
@property (nonatomic, weak) IBOutlet UIButton *detailsButton;
@property (nonatomic, weak) IBOutlet UIButton *vstrateButton;
@property (nonatomic, weak) IBOutlet UIButton *sideBySideButton;
@property (nonatomic, weak) IBOutlet UIButton *uploadButton;
@property (nonatomic, weak) IBOutlet UIButton *uploadingButton;
@property (nonatomic, weak) IBOutlet UIButton *uploadedButton;
@property (nonatomic, weak) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UIButton *uploadRetryButton;
@property (nonatomic, weak) IBOutlet UIImageView *uploadingIconImageView;

@property (nonatomic, strong) Media *media;
@property (nonatomic, strong) NSString *userIdentity;

@end

@implementation MediaInfoView

#pragma mark Business Logic

- (void)loadMediaValues
{
    if (self.media == nil)
        return;
    self.titleLabel.text = [NSString stringWithFormat:@"%@\n\n\n", self.media.title ];
	self.dateLabel.text = [NSDateFormatter localizedStringFromDate:self.media.date dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterNoStyle];
    self.detailsLabel.text = self.media.sportAndActionTitle;
	self.actionLabel.text = self.media.action.name;
    self.sportLabel.text = self.media.action.sport.name;
	self.vstrateButton.hidden = self.sideBySideButton.hidden = ![self.media canVstrate:self.userIdentity];
}

- (void)setMedia:(Media *)media userIdentity:(NSString *)userIdentity
{
    self.media = media;
    self.userIdentity = userIdentity;
    [self loadMediaValues];
}

- (void)updateUploadState
{
    // vars
    BOOL mediaCanShare = self.media && [self.media canShare:self.userIdentity];
    BOOL mediaCanUpload = self.media && [self.media canUpload:self.userIdentity];
    BOOL mediaUploaded = self.media && self.media.alreadyUploadedAndProcessed;
    BOOL _mediaUploadQueued = self.media && self.media.isInUploadQueueOrNotProcessed;
    BOOL mediaUploadedWithErrors = self.media && self.media.isUploadedWithErrors;
    // button
    self.uploadingButton.hidden = !_mediaUploadQueued;
    self.uploadingIconImageView.hidden = !_mediaUploadQueued;
    self.uploadedButton.hidden = !mediaUploaded || _mediaUploadQueued;
    self.uploadButton.hidden = !mediaCanUpload || _mediaUploadQueued || mediaUploaded;
    self.shareButton.hidden = !mediaCanShare;
    self.uploadRetryButton.hidden = !mediaUploadedWithErrors;
    
    [self animateUploadingIcon];
}

- (void)setTagForButtons
{
    self.detailsButton.tag = MediaActionDetails;
    self.vstrateButton.tag = MediaActionVstrate;
    self.sideBySideButton.tag = MediaActionSideBySide;
    self.uploadButton.tag = MediaActionUpload;
    self.uploadingButton.tag = MediaActionUploading;
    self.uploadedButton.tag = MediaActionUploaded;
    self.shareButton.tag = MediaActionShare;
    self.uploadRetryButton.tag = MediaActionUploadRetry;
}

- (void)animateUploadingIcon
{
    [self.uploadingIconImageView animateFadeInOutLoopWithDuration:1.0 minAlpha:0.2 maxAlpha:1.0];
}

- (void)setResizableImages
{
    [self.detailsButton setBackgroundImage:[UIImage resizableImageNamed:@"bt-grey-n-black-h69"] forState:UIControlStateNormal];
    [self.detailsButton setBackgroundImage:[UIImage resizableImageNamed:@"bt-black-01"] forState:UIControlStateHighlighted];
}

- (void)setButtonsLocation:(UIInterfaceOrientation)orientation
{
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        [self.media performBlockIfSession:^(Session *session) {
            [self moveUploadButtonsToX:75 uploadingIconToX:96];
        }];
    } else {
        [self.media performBlockIfSession:^(Session *session) {
            [self moveUploadButtonsToX:160 uploadingIconToX:181];
        }];
    }
}

- (void)moveUploadButtonsToX:(CGFloat)buttonX uploadingIconToX:(CGFloat)uploadingIconX
{
    CGPoint origin = CGPointMake(buttonX, self.uploadButton.frame.origin.y);
    CGRect frame = self.uploadButton.frame;
    frame.origin = origin;
    self.uploadButton.frame = self.uploadingButton.frame = self.uploadedButton.frame = self.uploadRetryButton.frame = frame;
    frame = self.uploadingIconImageView.frame;
    self.uploadingIconImageView.frame = CGRectMake(uploadingIconX, frame.origin.y, frame.size.width, frame.size.height);
}

#pragma mark Actions

- (IBAction)buttonAction:(UIButton *)sender
{
    [self.delegate mediaInfoView:self didAction:sender.tag];
}

#pragma mark Localization

- (void) setLocalizableStrings
{
    [self.detailsButton setTitle:VstratorStrings.MediaClipSessionViewDetailsButtonTitle forState:UIControlStateNormal];
    [self.vstrateButton setTitle:VstratorStrings.MediaClipSessionViewVstrateButtonTitle forState:UIControlStateNormal];
    [self.shareButton setTitle:VstratorStrings.MediaClipSessionViewShareButtonTitle forState:UIControlStateNormal];
    [self.sideBySideButton setTitle:VstratorStrings.MediaClipSessionViewSideBySideButtonTitle forState:UIControlStateNormal];
    [self.uploadButton setTitle:VstratorStrings.MediaClipSessionViewUploadButtonTitle forState:UIControlStateNormal];
    [self.uploadingButton setTitle:VstratorStrings.MediaClipSessionViewUploadingButtonTitle forState:UIControlStateNormal];
    [self.uploadedButton setTitle:VstratorStrings.MediaClipSessionViewUploadedButtonTitle forState:UIControlStateNormal];
    [self.uploadRetryButton setTitle:VstratorStrings.MediaClipSessionViewUploadRetryButtonTitle forState:UIControlStateNormal];
}

#pragma mark RotatableView

- (void)nilXibOutlets
{
    // Custom
    self.titleLabel = nil;
    self.dateLabel = nil;
    self.detailsLabel = nil;
    self.sportLabel = nil;
    self.actionLabel = nil;
    self.detailsButton = nil;
    self.vstrateButton = nil;
    self.sideBySideButton = nil;
    self.uploadButton = nil;
    self.uploadingButton = nil;
    self.uploadedButton = nil;
    self.shareButton = nil;
    self.uploadRetryButton = nil;
    self.uploadingIconImageView = nil;
    // Super
    [super nilXibOutlets];
}

- (void)adjustXibFrame
{
    if (!CGRectIsEmpty(self.bounds))
        self.view.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    [super adjustXibFrame];
}

- (void)setOrientation:(UIInterfaceOrientation)orientation
{
    [super setOrientation:orientation];
    [self animateUploadingIcon];
    [self setLocalizableStrings];
    [self setTagForButtons];
    [self loadMediaValues];
    [self updateUploadState];
    [self setResizableImages];
    [self setButtonsLocation:orientation];
}

@end
