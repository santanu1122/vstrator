//
//  TabSideBySideView.m
//  VstratorApp
//
//  Created by Mac on 27.05.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "TabSideBySideView.h"

#import "AccountController2.h"
#import "Media.h"
#import "MediaListView.h"
#import "MediaService.h"
#import "SideBySideEditorViewController.h"
#import "VstratorExtensions.h"
#import "VstratorStrings.h"

@interface TabSideBySideView()

@property (nonatomic) NSInteger clipNumberForAction;

@property (nonatomic, strong) IBOutlet UIView *view;
@property (nonatomic, strong) IBOutlet UIView *selectorView;
@property (nonatomic, strong) IBOutlet MediaListView *mediaListView;

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UIView *clipsView;
@property (weak, nonatomic) IBOutlet UIImageView *clipImageView;
//@property (weak, nonatomic) IBOutlet UILabel *clipTitleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *clip2ImageView;
//@property (weak, nonatomic) IBOutlet UILabel *clip2TitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *selectClipButton;
@property (weak, nonatomic) IBOutlet UIButton *captureClipButton;
@property (weak, nonatomic) IBOutlet UIButton *selectClip2Button;
@property (weak, nonatomic) IBOutlet UIButton *captureClip2Button;
@property (weak, nonatomic) IBOutlet UIButton *startSideBySideButton;

// Actions
- (IBAction)clipImageAction:(id)sender;
- (IBAction)clipSelectAction:(id)sender;
- (IBAction)clipCaptureAction:(id)sender;
- (IBAction)clip2ImageAction:(id)sender;
- (IBAction)clip2SelectAction:(id)sender;
- (IBAction)clip2CaptureAction:(id)sender;
- (IBAction)startSideBySideAction:(id)sender;

@end

@implementation TabSideBySideView

#pragma mark - Properties

@synthesize delegate = _delegate;
@synthesize clip = _clip;
@synthesize clip2 = _clip2;
@synthesize clipNumberForAction = _clipNumberForAction;
@synthesize selectedContentType = _selectedContentType;

@synthesize view = _view;
@synthesize selectorView = _selectorView;
@synthesize mediaListView = _mediaListView;

@synthesize clipsView = _clipsView;
@synthesize clipImageView = _clipImageView;
//@synthesize clipTitleLabel = _clipTitleLabel;
@synthesize clip2ImageView = _clip2ImageView;
//@synthesize clip2TitleLabel = _clip2TitleLabel;
@synthesize selectClipButton = _selectClipButton;
@synthesize captureClipButton = _captureClipButton;
@synthesize selectClip2Button = _selectClip2Button;
@synthesize captureClip2Button = _captureClip2Button;
@synthesize startSideBySideButton = _startSideBySide;

- (void)setClip:(Clip *)clip
{
    _clip = clip;
    [self updateClipViews];
}

- (void)setClip2:(Clip *)clip2
{
    _clip2 = clip2;
    [self updateClip2Views];
}

- (NSString *)queryString
{
    if (self.selectedContentType == TabSideBySideViewContentTypeMedia)
        return self.mediaListView.queryString;
    return nil;
}

- (void)setQueryString:(NSString *)queryString
{
    if (self.selectedContentType == TabSideBySideViewContentTypeMedia)
        self.mediaListView.queryString = queryString;
}

- (void)setSelectedContentType:(TabSideBySideViewContentType)selectedContentType
{
    // save value
    _selectedContentType = selectedContentType;
    // views
    BOOL hasChanges = YES;
    if (self.selectedContentType == TabSideBySideViewContentTypeSelector) {
        if (self.selectorView.superview == nil) {
            [self.view switchViews:self.selectorView];
            hasChanges = YES;
        }
    } else if (self.selectedContentType == TabSideBySideViewContentTypeMedia) {
        if (self.mediaListView.superview == nil) {
            [self.view switchViews:self.mediaListView];
            hasChanges = YES;
        }
    }
    // delegate
    if (hasChanges && [self.delegate respondsToSelector:@selector(tabSideBySideView:didSwitchToContent:)])
        [self.delegate tabSideBySideView:self didSwitchToContent:self.selectedContentType];
}

#pragma mark - Business Logic

- (void)updateClipViews
{
    if (self.clip == nil) {
        self.clipImageView.image = nil;
        //self.clipTitleLabel.text = VstratorStrings.HomeSideBySideSelectClipLabel;
    } else {
        self.clipImageView.image = (self.clip.thumbnail == nil) ? nil : [UIImage imageWithData:self.clip.thumbnail];
        //self.clipTitleLabel.text = self.clip.title;
    }
}

- (void)updateClip2Views
{
    if (self.clip2 == nil) {
        self.clip2ImageView.image = nil;
        //self.clip2TitleLabel.text = VstratorStrings.HomeSideBySideSelectClipLabel;
    } else {
        self.clip2ImageView.image = (self.clip2.thumbnail == nil) ? nil : [UIImage imageWithData:self.clip2.thumbnail];
        //self.clip2TitleLabel.text = self.clip2.title;
    }
}

- (IBAction)clipImageAction:(id)sender
{
    [self clipSelectAction:sender];
}

- (IBAction)clipSelectAction:(id)sender
{
    self.clipNumberForAction = 0;
    self.selectedContentType = TabSideBySideViewContentTypeMedia;
}

- (IBAction)clipCaptureAction:(id)sender
{
    __block __weak TabSideBySideView *blockSelf = self;
    if ([self.delegate respondsToSelector:@selector(tabSideBySideView:captureClipWithCallback:)])
        [self.delegate tabSideBySideView:self captureClipWithCallback:^(NSError *error, Clip *clip) {
            if (error == nil || clip != nil) blockSelf.clip = clip;
        }];
}

- (IBAction)clip2ImageAction:(id)sender
{
    [self clip2SelectAction:sender];
}

- (IBAction)clip2SelectAction:(id)sender
{
    self.clipNumberForAction = 1;
    self.selectedContentType = TabSideBySideViewContentTypeMedia;
}

- (IBAction)clip2CaptureAction:(id)sender
{
    __block __weak TabSideBySideView *blockSelf = self;
    if ([self.delegate respondsToSelector:@selector(tabSideBySideView:captureClipWithCallback:)])
        [self.delegate tabSideBySideView:self captureClipWithCallback:^(NSError *error, Clip *clip) {
            if (error == nil || clip != nil) blockSelf.clip2 = clip;
        }];
}

- (IBAction)startSideBySideAction:(id)sender
{
    if (self.clip == nil || self.clip2 == nil) {
        [UIAlertViewWrapper alertString:VstratorStrings.ErrorSideBySideClipsAreNotSelectedText title:@""];
    } else {
        if ([self.delegate respondsToSelector:@selector(tabSideBySideView:vstrateClip:withClip2:)])
            [self.delegate tabSideBySideView:self vstrateClip:self.clip withClip2:self.clip2];
    }
}

#pragma mark - MediaListViewDelegate

- (void)mediaListView:(MediaListView *)sender media:(Media *)media action:(MediaAction)action
{
	[media performBlockIfClip:^(Clip *clip) {
		if (self.clipNumberForAction == 0) {
			self.clip = clip;
		} else if (self.clipNumberForAction == 1) {
			self.clip2 = clip;
		}
		self.selectedContentType = TabSideBySideViewContentTypeSelector;
	}];
}

#pragma mark - Localization

- (void)setLocalizableStrings
{
    [self.captureClipButton setTitle:VstratorStrings.HomeSideBySideCaptureClipButtonTitle forState:UIControlStateNormal];
    [self.selectClipButton setTitle:VstratorStrings.HomeSideBySideSelectClipButtonTitle forState:UIControlStateNormal];
    [self.startSideBySideButton setTitle:VstratorStrings.HomeSideBySideStartSideBySideClipButtonTitle forState:UIControlStateNormal];
    [self.captureClip2Button setTitle:VstratorStrings.HomeSideBySideCaptureClipButtonTitle forState:UIControlStateNormal];
    [self.selectClip2Button setTitle:VstratorStrings.HomeSideBySideSelectClipButtonTitle forState:UIControlStateNormal];    
}

#pragma mark - Ctor

- (void)setup
{
    self.backgroundColor = [UIColor clearColor];
    // NIB
	NSString* nib = NSStringFromClass(self.class);
    [[NSBundle mainBundle] loadNibNamed:nib owner:self options:nil];
    [self addSubview:self.view];
    self.view.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    // localization
    [self setLocalizableStrings];
    // media list
	self.mediaListView.delegate = self;
    [self.mediaListView setContentType:MediaListViewContentTypeAllClips andSelectionMode:YES];
    [self.mediaListView setInfoWithNotExistText:VstratorStrings.MediaListAllNoClipsExist
                                   notFoundText:VstratorStrings.MediaListAllNoClipsFound];
    // clips
    [self updateClipViews];
    [self updateClip2Views];
    // selector
    self.selectedContentType = TabSideBySideViewContentTypeSelector;
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

- (void)setOrientation:(UIInterfaceOrientation)orientation
{
    CGSize clipsViewSize = self.clipsView.frame.size;
    CGSize startButtonSize = self.startSideBySideButton.frame.size;
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        self.clipsView.frame = CGRectMake(22, 27, clipsViewSize.width, clipsViewSize.height);
        self.startSideBySideButton.frame = CGRectMake(370, 75, startButtonSize.width, startButtonSize.height);
    } else {
        self.clipsView.frame = CGRectMake(7, 18, clipsViewSize.width, clipsViewSize.height);
        self.startSideBySideButton.frame = CGRectMake(126, 284, startButtonSize.width, startButtonSize.height);
    }
}

@end
