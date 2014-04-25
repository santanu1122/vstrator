//
//  TabUploadQueueView.m
//  VstratorApp
//
//  Created by Lion User on 25/07/2012.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "UploadRequestListView.h"
#import "TabUploadQueueBarView.h"
#import "TabUploadQueueView.h"
#import "UIView+Extensions.h"
#import "VstratorStrings.h"

@interface TabUploadQueueView() <UploadRequestListViewDelegate, TabQueueVarViewDelegate>

@property (strong, nonatomic) IBOutlet UIView *view;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (strong, nonatomic) IBOutlet UploadRequestListView *allView;
@property (strong, nonatomic) IBOutlet UploadRequestListView *inProgressView;
@property (strong, nonatomic) IBOutlet UploadRequestListView *completedView;

@property (nonatomic, strong) NSDictionary* uploadRequestListViews;
@property (nonatomic, strong, readonly) UploadRequestListView *contentView;
@property (nonatomic, strong, readonly) TabUploadQueueBarView *tabBarView;

@end

@implementation TabUploadQueueView

#pragma mark Properties

@synthesize delegate = _delegate;
@synthesize queryString = _queryString;

@synthesize view = _view;
@synthesize containerView = _containerView;
@synthesize allView = _allView;
@synthesize inProgressView = _inProgressView;
@synthesize completedView = _completedView;

@synthesize uploadRequestListViews = _uploadRequestListViews;
@synthesize tabBarView = _tabBarView;

- (UploadRequestListView *)contentView
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

- (TabUploadQueueBarView *)tabBarView
{
    if (_tabBarView == nil) {
        _tabBarView = [[TabUploadQueueBarView alloc] initWithFrame:CGRectZero];
        _tabBarView.frame = CGRectMake(0, 0, self.view.bounds.size.width, _tabBarView.frame.size.height);
        _tabBarView.delegate = self;
        _tabBarView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
        [self.view addSubview:_tabBarView];
    }
    return _tabBarView;
}

- (UploadRequestContentType)contentType
{
    return self.contentView.contentType;
}

- (void)setContentType:(UploadRequestContentType)contentType
{
    UploadRequestListView *view = (self.uploadRequestListViews)[@(contentType)];
    if (self.contentView == view)
        return;
    // views
    [self.containerView switchViews:view];
    self.tabBarView.contentType = contentType;
    [view renewPresentation];
    // delegate
    if ([self.delegate respondsToSelector:@selector(tabUploadQueueView:didSwitchToContent:)])
        [self.delegate tabUploadQueueView:self didSwitchToContent:contentType];
}

#pragma mark TabQueueBarViewDelegate

- (void)tabUploadQueueBarView:(TabUploadQueueBarView *)view didSwitchToContentType:(UploadRequestContentType)contentType
{
    self.contentType = contentType;
}

#pragma mark UploadRequestListViewDelegate

- (void)uploadRequestListView:(UploadRequestListView *)sender uploadRequest:(UploadRequest *)uploadRequest action:(UploadRequestAction)action
{
    if ([self.delegate respondsToSelector:@selector(tabUploadQueueView:uploadRequest:action:)])
        [self.delegate tabUploadQueueView:self uploadRequest:uploadRequest action:action];
}

#pragma mark Business Logic

- (void)reload
{
	for (NSNumber* key in self.uploadRequestListViews)
		[(self.uploadRequestListViews)[key] reload];
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
	self.uploadRequestListViews = @{@(UploadRequestContentTypeAll): self.allView,
                           @(UploadRequestContentTypeInProgress): self.inProgressView,
                           @(UploadRequestContentTypeCompleted): self.completedView};
    
	// Views: all
    [self.allView setInfoWithNotExistText:VstratorStrings.UploadQueueListEmptyText
        notFoundText:VstratorStrings.UploadQueueListNotFoundText];
	self.allView.delegate = self;
	self.allView.contentType = UploadRequestContentTypeAll;
    // in progress
    [self.inProgressView setInfoWithNotExistText:VstratorStrings.UploadQueueListEmptyText
        notFoundText:VstratorStrings.UploadQueueListNotFoundText];
	self.inProgressView.delegate = self;
	self.inProgressView.contentType = UploadRequestContentTypeInProgress;
    // completed
    [self.completedView setInfoWithNotExistText:VstratorStrings.UploadQueueListEmptyText
        notFoundText:VstratorStrings.UploadQueueListNotFoundText];
	self.completedView.delegate = self;
	self.completedView.contentType = UploadRequestContentTypeCompleted;
    // create tab bar
    [self tabBarView];
    // select default view
    self.contentType = UploadRequestContentTypeAll;
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
    self.containerView.frame = CGRectMake(0, self.tabBarView.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - self.tabBarView.frame.size.height);
}

@end
