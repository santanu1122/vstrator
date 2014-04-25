//
//  MediaListViewCell.m
//  VstratorApp
//
//  Created by Mac on 08.04.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "MediaListViewCell.h"

#import "Action.h"
#import "DownloadContent+Extensions.h"
#import "Media+Extensions.h"
#import "Session+Extensions.h"
#import "Sport.h"
#import "UIAlertViewWrapper.h"
#import "VstratorConstants.h"
#import "VstratorStrings.h"

#define CLIP_TITLE_LABEL_RIGHT_MARGIN 10

@interface MediaListViewCell() {
    BOOL _mediaCanDelete;
}

@property (strong, nonatomic) IBOutlet UIView *view;
@property (weak, nonatomic) IBOutlet UIImageView *clipBackgroundView;
@property (weak, nonatomic) IBOutlet UIView *clipPlayerView;
@property (weak, nonatomic) IBOutlet UIImageView *clipThumbnailView;
@property (weak, nonatomic) IBOutlet UIImageView *clipIndiSideBySideImageView;
@property (weak, nonatomic) IBOutlet UIImageView *clipIndiSessionImageView;
@property (weak, nonatomic) IBOutlet UIButton *clipPlayButton;
@property (weak, nonatomic) IBOutlet UILabel *clipTitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *clipSelectButton;
@property (weak, nonatomic) IBOutlet UIImageView *clipSelectImageView;
@property (weak, nonatomic) IBOutlet UIButton *clipDeleteButton;
@property (weak, nonatomic) IBOutlet UIImageView *availableClipImageView;

@end

@implementation MediaListViewCell
{
    bool _wasInSelectionMode;
}

#pragma mark - Properties

@synthesize delegate = _delegate;
@synthesize view = _view;
@synthesize clipBackgroundView = _clipBackgroundView;
@synthesize clipPlayerView = _clipPlayerView;
@synthesize clipThumbnailView = _clipThumbnailView;
@synthesize clipIndiSideBySideImageView = _clipIndiSideBySideImageView;
@synthesize clipIndiSessionImageView = _clipIndiSessionImageView;
@synthesize clipPlayButton = _clipPlayButton;
@synthesize clipTitleLabel = _clipTitleLabel;
@synthesize clipSelectButton = _clipSelectButton;
@synthesize clipSelectImageView = _clipSelectImageView;
@synthesize clipDeleteButton = _clipDeleteButton;

+ (CGFloat)rowHeight
{
    static CGFloat rowHeightValue = -1;
	if (rowHeightValue == -1) {
        MediaListViewCell *cellInstance = [[self.class alloc] init];
        rowHeightValue = cellInstance.view.bounds.size.height;
	}
    return rowHeightValue;
}

#pragma mark - Cell Logic

- (void)configureForData:(Media *)media
          authorIdentity:(NSString *)authorIdentity
           selectionMode:(BOOL)selectionMode
             contentType:(MediaListViewContentType)contentType
               tableView:(UITableView *)tableView
               indexPath:(NSIndexPath *)indexPath
{
    // check for passed object(s)
    NSAssert(media, VstratorConstants.AssertionArgumentIsNilOrInvalid);
    // set data
    //TODO: worth to add default thumbnail?
    self.clipThumbnailView.image = media.thumbnail == nil ? nil : [UIImage imageWithData:media.thumbnail];
    self.clipSelectImageView.hidden = selectionMode;
    int delta = self.frame.size.width - self.clipSelectButton.frame.origin.x - CLIP_TITLE_LABEL_RIGHT_MARGIN;
    if (selectionMode) {
        if (!_wasInSelectionMode) {
            CGRect clipTitleLabelFrame = self.clipTitleLabel.frame;
            clipTitleLabelFrame.size.width -= delta;
            self.clipTitleLabel.frame = clipTitleLabelFrame;
            _wasInSelectionMode = YES;
        }
        self.clipSelectButton.hidden = NO;
    } else {
        if (_wasInSelectionMode) {
            CGRect clipTitleLabelFrame = self.clipTitleLabel.frame;
            clipTitleLabelFrame.size.width += delta;
            self.clipTitleLabel.frame = clipTitleLabelFrame;
            _wasInSelectionMode = NO;
        }
        self.clipSelectButton.hidden = YES;
    }
    self.clipDeleteButton.hidden = YES;
    // permissions
    _mediaCanDelete = [media canDelete:authorIdentity];
    // indicators
    BOOL mediaIsSession = [media isKindOfClass:Session.class];
    BOOL mediaIsSideBySide = mediaIsSession && ((Session *)media).isSideBySide;
    self.clipIndiSideBySideImageView.hidden = !mediaIsSideBySide;
    self.clipIndiSessionImageView.hidden = mediaIsSideBySide || !mediaIsSession;
    self.clipTitleLabel.text = [NSString stringWithFormat:@"%@\n%@, %@", media.title, media.action.sport.name, media.action.name];
    self.availableClipImageView.hidden = media.isProMedia || !media.download || media.download.status.intValue != DownloadContentStatusNew;
}

- (void)showDeleteButton
{
    if (!_mediaCanDelete)
        return;
    self.clipSelectButton.tag = self.clipSelectButton.hidden;
    self.clipSelectImageView.tag = self.clipSelectImageView.hidden;
    self.clipSelectButton.hidden = self.clipSelectImageView.hidden = YES;
    self.clipDeleteButton.hidden = NO;
}

- (void)hideDeleteButton
{
    if (self.clipDeleteButton.hidden)
        return;
    self.clipSelectButton.hidden = self.clipSelectButton.tag;
    self.clipSelectImageView.hidden = self.clipSelectImageView.tag;
    self.clipDeleteButton.hidden = YES;
}

#pragma mark Touches

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    self.clipBackgroundView.highlighted = self.clipSelectImageView.highlighted = YES;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.clipBackgroundView.highlighted = self.clipSelectImageView.highlighted = NO;
    [super touchesCancelled:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.clipBackgroundView.highlighted = self.clipSelectImageView.highlighted = NO;
    [super touchesEnded:touches withEvent:event];
}

#pragma mark - Cell Events

- (IBAction)clipPlayAction:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(mediaListViewCell:action:)])
        [self.delegate mediaListViewCell:self action:MediaActionPlay];
}

- (IBAction)clipSelectAction:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(mediaListViewCell:action:)])
        [self.delegate mediaListViewCell:self action:MediaActionSelect];
}

- (IBAction)clipDeleteAction:(id)sender
{
    [self hideDeleteButton];
    if ([self.delegate respondsToSelector:@selector(mediaListViewCell:action:)])
        [self.delegate mediaListViewCell:self action:MediaActionDelete];
}

#pragma mark - Localization

- (void)setLocalizableStrings
{
    [self.clipSelectButton setTitle:VstratorStrings.MediaListViewCellSelectButtonTitle forState:UIControlStateNormal];
    [self.clipDeleteButton setTitle:VstratorStrings.MediaListViewCellDeleteButtonTitle forState:UIControlStateNormal];
}

#pragma mark - View Lifecycle

- (void)setupWithDelegate:(id<MediaListViewCellDelegate>)delegate
{
    [super setupWithDelegate:delegate];
    [self setLocalizableStrings];
    self.delegate = delegate;
}

@end
