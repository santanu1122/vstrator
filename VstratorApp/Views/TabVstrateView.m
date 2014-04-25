//
//  TabVstrateView.m
//  VstratorApp
//
//  Created by user on 03.05.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "TabVstrateView.h"
#import "MediaListView.h"
#import "VstratorExtensions.h"
#import "TabVstrateBarView.h"
#import "VstratorStrings.h"

@interface TabVstrateView() <TabVstrateBarViewDelegate>

@property (nonatomic, strong) IBOutlet UIView *view;
@property (nonatomic, weak) IBOutlet UIView *containerView;
@property (nonatomic, weak, readonly) MediaListView *contentView;

@property (nonatomic, strong) IBOutlet MediaListView *allClipsView;
@property (nonatomic, strong) IBOutlet MediaListView *myClipsView;
@property (nonatomic, strong) IBOutlet MediaListView *proClipsView;
@property (nonatomic, strong) IBOutlet MediaListView *sessionsView;
@property (nonatomic, strong) NSDictionary* mediaListViews;

@property (nonatomic, strong, readonly) TabVstrateBarView *tabVstrateBarView;

@end

@implementation TabVstrateView

#pragma mark Properties

@synthesize delegate = _delegate;

@synthesize view = _view;
@synthesize containerView = _containerView;

@synthesize allClipsView = _allClipsView;
@synthesize myClipsView = _myClipsView;
@synthesize proClipsView = _proClipsView;
@synthesize sessionsView = _sessionsView;
@synthesize mediaListViews = _mediaListViews;

@synthesize tabVstrateBarView = _tabVstrateBarView;

- (MediaListView *)contentView
{
    return [self.containerView.subviews lastObject];
}

- (NSString *)queryString
{
	return self.contentView.queryString;
}

- (void)setQueryString:(NSString *)queryString
{
	self.contentView.queryString = queryString;
}

- (TabVstrateBarView *)tabVstrateBarView
{
    if (_tabVstrateBarView == nil) {
        _tabVstrateBarView = [[TabVstrateBarView alloc] initWithFrame:CGRectZero];
        _tabVstrateBarView.frame = CGRectMake(0, 0, self.view.bounds.size.width, _tabVstrateBarView.frame.size.height);
        _tabVstrateBarView.delegate = self;
        _tabVstrateBarView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
        [self.view addSubview:_tabVstrateBarView];
    }
    return _tabVstrateBarView;
}

- (MediaListViewContentType)selectedContentType
{
    return self.contentView.contentType;
}

- (void)setSelectedContentType:(MediaListViewContentType)selectedContentType
{
    MediaListView *view = (self.mediaListViews)[@(selectedContentType)];
    if (self.contentView == view)
        return;
    // views
    [self.containerView switchViews:view];
    self.tabVstrateBarView.contentType = selectedContentType;
    // delegate
    if ([self.delegate respondsToSelector:@selector(tabVstrateView:didSwitchToContent:)])
        [self.delegate tabVstrateView:self didSwitchToContent:selectedContentType];
}

#pragma mark TabVstrateBarViewDelegate

- (void) tabVstrateBarView:(TabVstrateBarView *)sender didSwitchToContent:(MediaListViewContentType)type
{
    self.selectedContentType = type;
}

#pragma mark Business Logic

- (void)reload
{
	for (NSNumber* key in self.mediaListViews)
		[(self.mediaListViews)[key] reload];
}

#pragma mark MediaListViewDelegate

- (void)mediaListView:(MediaListView *)sender media:(Media *)media action:(MediaAction)action
{
    if ([self.delegate respondsToSelector:@selector(tabVstrateView:media:action:)])
        [self.delegate tabVstrateView:self media:media action:action];
}

- (void)mediaListViewSyncAction:(MediaListView *)sender
{
    if ([self.delegate respondsToSelector:@selector(tabVstrateViewSyncAction:)])
        [self.delegate tabVstrateViewSyncAction:self];
}

#pragma mark View Lifecycle

- (void)setup
{
    self.backgroundColor = [UIColor clearColor];

    // NIB
	NSString* nib = NSStringFromClass(self.class);
    [[NSBundle mainBundle] loadNibNamed:nib owner:self options:nil];
    [self addSubview:self.view];
    self.view.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);

	// Array of views
	self.mediaListViews =
    @{@(MediaListViewContentTypeUserAllClipsAndSessions): self.allClipsView,
    @(MediaListViewContentTypeUserClips): self.myClipsView,
    @(MediaListViewContentTypeProClips): self.proClipsView,
    @(MediaListViewContentTypeUserSessions): self.sessionsView};
    
	// Views: all
    [self.allClipsView setInfoWithNotExistText:VstratorStrings.MediaListAllNoClipsExist
                                  notFoundText:VstratorStrings.MediaListAllNoClipsFound];
	self.allClipsView.delegate = self;
	self.allClipsView.contentType = MediaListViewContentTypeUserAllClipsAndSessions;
    // my clips
    [self.myClipsView setInfoWithNotExistText:VstratorStrings.MediaListUserNoClipsExist
                                 notFoundText:VstratorStrings.MediaListUserNoClipsFound];
	self.myClipsView.delegate = self;
	self.myClipsView.contentType = MediaListViewContentTypeUserClips;
    // pro clips
    [self.proClipsView setInfoWithNotExistText:VstratorStrings.MediaListProNoClipsExist
                                  notFoundText:VstratorStrings.MediaListProNoClipsFound];
	self.proClipsView.delegate = self;
	self.proClipsView.contentType = MediaListViewContentTypeProClips;
    // sessions
    [self.sessionsView setInfoWithNotExistText:VstratorStrings.MediaListUserNoSessionsExist
                                  notFoundText:VstratorStrings.MediaListUserNoSessionsFound];
	self.sessionsView.delegate = self;
	self.sessionsView.contentType = MediaListViewContentTypeUserSessions;

    [self tabVstrateBarView];
    
    // select default view
    self.selectedContentType = MediaListViewContentTypeUserClips;
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
    self.containerView.frame = CGRectMake(0, self.tabVstrateBarView.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - self.tabVstrateBarView.frame.size.height);
}

@end
