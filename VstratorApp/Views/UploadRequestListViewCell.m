//
//  UploadRequestListViewCell.m
//  VstratorApp
//
//  Created by Lion User on 25/07/2012.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "Action.h"
#import "Media.h"
#import "Media+Extensions.h"
#import "Session+Extensions.h"
#import "Sport.h"
#import "UploadRequest.h"
#import "UploadRequest+Extensions.h"
#import "UploadRequestListViewCell.h"
#import "UIView+Extensions.h"
#import "VstratorConstants.h"
#import "VstratorStrings.h"

#import <QuartzCore/CALayer.h>
#import <QuartzCore/CAAnimation.h>

@interface UploadRequestListViewCell() {
    BOOL _canDelete;
}

@property (strong, nonatomic) IBOutlet UIView *view;
@property (weak, nonatomic) IBOutlet UIImageView *clipBackgroundView;
@property (weak, nonatomic) IBOutlet UIView *clipPlayerView;
@property (weak, nonatomic) IBOutlet UIImageView *clipThumbnailView;
@property (weak, nonatomic) IBOutlet UIImageView *clipIndiSideBySideImageView;
@property (weak, nonatomic) IBOutlet UIImageView *clipIndiSessionImageView;
@property (weak, nonatomic) IBOutlet UIButton *clipPlayButton;
@property (weak, nonatomic) IBOutlet UILabel *clipTitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *clipRetryButton;
@property (weak, nonatomic) IBOutlet UIImageView *completedImageView;
@property (weak, nonatomic) IBOutlet UIImageView *inProgressImageView;
@property (weak, nonatomic) IBOutlet UIImageView *failedImageView;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UIButton *clipStopButton;

@property (strong, nonatomic) UploadRequest *uploadRequest;

@end

@implementation UploadRequestListViewCell

#pragma mark Properties

+ (CGFloat)rowHeight
{
    static CGFloat rowHeightValue = -1;
	if (rowHeightValue == -1) {
        UploadRequestListViewCell *cellInstance = [[self.class alloc] init];
        rowHeightValue = cellInstance.view.bounds.size.height;
	}
    return rowHeightValue;
}

#pragma mark Cell Logic

- (void)configureForData:(UploadRequest *)uploadRequest
{
    NSAssert(uploadRequest, VstratorConstants.AssertionArgumentIsNilOrInvalid);
    self.uploadRequest = uploadRequest;
    //NSString *dateString = [NSDateFormatter localizedStringFromDate:uploadRequest.media.datedateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterShortStyle];
    //self.clipTitleLabel.text = [NSString stringWithFormat:@"%@\n%@, %@\n%@, %d %@", uploadRequest.media.title, uploadRequest.media.action.sport.name, uploadRequest.media.action.name, dateString, uploadRequest.media.duration.intValue, VstratorStrings.SecondsText];
    self.clipTitleLabel.text = [NSString stringWithFormat:@"%@\n%@, %@", uploadRequest.media.title, uploadRequest.media.action.sport.name, uploadRequest.media.action.name];
    //TODO: worth to add default thumbnail?
    self.clipThumbnailView.image = uploadRequest.media.thumbnail == nil ? nil : [UIImage imageWithData:uploadRequest.media.thumbnail];
    BOOL mediaIsSession = [uploadRequest.media isKindOfClass:Session.class];
    BOOL mediaIsSideBySide = mediaIsSession && ((Session *)uploadRequest.media).isSideBySide;
    self.clipIndiSideBySideImageView.hidden = !mediaIsSideBySide;
    self.clipIndiSessionImageView.hidden = mediaIsSideBySide || !mediaIsSession;
    // Status
    UploadRequestStatus reqStatus = uploadRequest.status.intValue;
    self.clipRetryButton.hidden = self.failedImageView.hidden = !(reqStatus == UploadRequestStatusUploadedWithError ||
                                                                  reqStatus == UploadRequestStatusProcessedWithError ||
                                                                  reqStatus == UploadRequestStatusStopped);
    self.completedImageView.hidden = !(reqStatus == UploadRequestStatusCompleeted);
    self.inProgressImageView.hidden = !(reqStatus == UploadRequestStatusUploading ||
                                        reqStatus == UploadRequestStatusProcessing ||
                                        reqStatus == UploadRequestStatusNotStarted ||
                                        reqStatus == UploadRequestStatusAwaitingOriginalClipProcessing);
    self.deleteButton.hidden = self.clipStopButton.hidden = YES;
    [self renewAnimations];
    _canDelete = uploadRequest.status.intValue == UploadRequestStatusCompleeted;
    self.clipPlayButton.hidden = YES;
}

- (void)renewAnimations
{
    if (!self.inProgressImageView.hidden)
        [self.inProgressImageView animateFadeInOutLoopWithDuration:1.0 minAlpha:0.2 maxAlpha:1.0];
}

- (void)showDeleteButton
{
    if (!_canDelete) return;
    self.deleteButton.hidden = NO;
}

- (void)hideDeleteButton
{
    self.deleteButton.hidden = YES;
}

- (void)showStopButton
{
    switch (self.uploadRequest.status.intValue) {
    case UploadRequestStatusNotStarted:
    case UploadRequestStatusAwaitingOriginalClipProcessing:
    case UploadRequestStatusInProgress:
    case UploadRequestStatusUploading:
    case UploadRequestStatusProcessing:
        self.clipStopButton.hidden = NO;
        break;
    default:
        return;
    }
}

- (void)hideStopButton
{
    self.clipStopButton.hidden = YES;
}

#pragma mark Cell Events

- (IBAction)clipPlayAction:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(uploadRequestListViewCell:action:)])
        [self.delegate uploadRequestListViewCell:self action:UploadRequestActionPlayMedia];
}

- (IBAction) retryAction:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(uploadRequestListViewCell:action:)])
        [self.delegate uploadRequestListViewCell:self action:UploadRequestActionRetry];
}

- (IBAction)deleteButtonAction:(id)sender {
    [self hideDeleteButton];
    if ([self.delegate respondsToSelector:@selector(uploadRequestListViewCell:action:)])
        [self.delegate uploadRequestListViewCell:self action:UploadRequestActionDelete];
}

- (IBAction)stopAction:(id)sender {
    if ([self.delegate respondsToSelector:@selector(uploadRequestListViewCell:action:)])
        [self.delegate uploadRequestListViewCell:self action:UploadRequestActionStop];
}

#pragma mark Localization

- (void)setLocalizableStrings
{
    [self.clipRetryButton setTitle:VstratorStrings.UploadRequestListViewCellRetryButtonTitle forState:UIControlStateNormal];
    [self.deleteButton setTitle:VstratorStrings.MediaListViewCellDeleteButtonTitle forState:UIControlStateNormal];
}

#pragma mark View Lifecycle

- (void)setupWithDelegate:(id<UploadRequestListViewCellDelegate>)delegate
{
    [super setupWithDelegate:delegate];
    // localization
    [self setLocalizableStrings];
    // delegate
    self.delegate = delegate;
}


- (id)initWithDelegate:(id<UploadRequestListViewCellDelegate>)delegate
{
    return [super initWithNibName:nil delegate:delegate];
}

@end
