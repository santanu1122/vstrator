//
//  TabProView.m
//  VstratorApp
//
//  Created by user on 03.05.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "TabProView.h"
#import "MediaListView.h"
#import "VstratorExtensions.h"
#import "VstratorStrings.h"
#import "TabProBarView.h"

@interface TabProView() <MediaListViewDelegate, RotatableViewProtocol, TabBarViewItemDelegate, TabProBarViewDelegate>

@property (nonatomic, strong) IBOutlet UIView *view;
@property (nonatomic, weak) IBOutlet UIView *containerView;
@property (strong, nonatomic) IBOutlet MediaListView *clipsView;
@property (strong, nonatomic) IBOutlet MediaListView *sessionsView;
@property (strong, nonatomic) IBOutlet MediaListView *interviewsView;

@property (nonatomic, strong, readonly) TabProBarView *tabProBarView;
@property (nonatomic, strong) NSDictionary* mediaListViews;

- (MediaListView *)currentView;

@end

@implementation TabProView

#pragma mark - Properties

@synthesize tabProBarView = _tabProBarView;

- (NSString *)queryString
{
    return [self currentView].queryString;
}

- (void)setQueryString:(NSString *)queryString
{
    [self currentView].queryString = queryString;
}

- (TabProBarView *)tabProBarView
{
    if (!_tabProBarView){
        _tabProBarView = [[TabProBarView alloc] initWithFrame:CGRectZero];
        _tabProBarView.frame = CGRectMake(0, 0, self.view.bounds.size.width, _tabProBarView.frame.size.height);
        _tabProBarView.delegate = self;
        _tabProBarView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
        [self.view addSubview:_tabProBarView];
    }
    return _tabProBarView;
}

- (void)setSelectedContentType:(TabProViewContentType)selectedContentType
{
    _selectedContentType = selectedContentType;
    BOOL hasChanges = NO;
    switch (self.selectedContentType) {
        case TabProViewContentTypeStrokes:
            if (self.clipsView.superview == nil) {
                [self.containerView switchViews:self.clipsView];
                hasChanges = YES;
            }
            break;
        case TabProViewContentTypeTutorials:
            if (self.sessionsView.superview == nil) {
                [self.containerView switchViews:self.sessionsView];
                hasChanges = YES;
            }
            break;
        case TabProViewContentTypeInterviews:
            if (self.interviewsView.superview == nil) {
                [self.containerView switchViews:self.interviewsView];
                hasChanges = YES;
            }
            break;
        default:
            break;
    }
    self.tabProBarView.contentType = self.selectedContentType;
    if (hasChanges && [self.delegate respondsToSelector:@selector(tabProView:didSwitchToContent:)])
        [self.delegate tabProView:self didSwitchToContent:self.selectedContentType];
}

#pragma mark - Business Logic

- (MediaListView *)currentView
{
    return self.mediaListViews[@(self.selectedContentType)];
}

#pragma mark - TabProBarViewDelegate

- (void) tabProBarView:(TabProBarView *)sender didSwitchToContent:(TabProViewContentType)type
{
    self.selectedContentType = type;
}

#pragma mark - MediaListViewDelegate

- (void)mediaListView:(MediaListView *)sender media:(Media *)media action:(MediaAction)action
{
    if ([self.delegate respondsToSelector:@selector(tabProView:media:action:)])
        [self.delegate tabProView:self media:media action:action];
}

- (void)mediaListViewNavigateToContentSetAction:(MediaListView *)sender
{
    if ([self.delegate respondsToSelector:@selector(tabProViewNavigateToContentSetAtion:)])
        [self.delegate tabProViewNavigateToContentSetAtion:self];
}

#pragma mark - Setup

- (void)setup
{
    self.backgroundColor = [UIColor clearColor];
    // NIB
	NSString* nib = NSStringFromClass(self.class);
    [[NSBundle mainBundle] loadNibNamed:nib owner:self options:nil];
    [self addSubview:self.view];
    self.view.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    
	self.mediaListViews = @{@(TabProViewContentTypeStrokes): self.clipsView,
                           @(TabProViewContentTypeTutorials): self.sessionsView,
                           @(TabProViewContentTypeInterviews): self.interviewsView};
    
    [self.clipsView setInfoWithNotExistText:VstratorStrings.MediaListProNoClipsExist
                                   notFoundText:VstratorStrings.MediaListProNoClipsFound];
    self.clipsView.delegate = self;
    self.clipsView.contentType = MediaListViewContentTypeProClips;
    //[self.clipsView checkForNewContent];
    
    [self.sessionsView setInfoWithNotExistText:VstratorStrings.MediaListProNoSessionsExist
                                   notFoundText:VstratorStrings.MediaListProNoSessionsFound];
    self.sessionsView.delegate = self;
    self.sessionsView.contentType = MediaListViewContentTypeProSessions;
    //[self.sessionsView checkForNewContent];
    
    [self.interviewsView setInfoWithNotExistText:VstratorStrings.MediaListProNoClipsExist
                                     notFoundText:VstratorStrings.MediaListProNoClipsFound];
    self.interviewsView.delegate = self;
    self.interviewsView.contentType = MediaListViewContentTypeProInterviews;
    //[self.interviewsView checkForNewContent];

    [self tabProBarView];
    
    self.selectedContentType = TabProViewContentTypeStrokes;
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
    self.containerView.frame = CGRectMake(0, self.tabProBarView.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - self.tabProBarView.frame.size.height);
}

@end
