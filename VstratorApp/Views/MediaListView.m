//
//  MediaListView.m
//  VstratorApp
//
//  Created by Mac on 03.04.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "MediaListView.h"
#import "AccountController2.h"
#import "MediaListViewCell.h"
#import "MediaListViewHeader.h"
#import "MediaListViewProHeader.h"
#import "MediaService.h"
#import "VstratorConstants.h"
#import "VstratorExtensions.h"
#import "VstratorStrings.h"

#define kvaHeaderFrame CGRectMake(0, 0, 320, 44)

@interface MediaListView() <MediaListViewHeaderDelegate, MediaListViewProHeaderDelegate>

@property (nonatomic, strong, readonly) CoreDataSelector *coreDataSelector;

@property (nonatomic, strong) IBOutlet UIView *view;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UIView *emptyView;
@property (nonatomic, weak) IBOutlet UILabel *emptyMessageLabel;
@property (nonatomic, strong, readonly) MediaListViewHeader *header;
@property (nonatomic, strong, readonly) MediaListViewProHeader *proHeader;

// UITableViewDataSource, UITableViewDelegate
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView;
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index;
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;

@end

@implementation MediaListView

#pragma mark Properties

@synthesize delegate = _delegate;
@synthesize selectionMode = _selectionMode;

@synthesize view = _view;
@synthesize tableView = _tableView;
@synthesize emptyView = _emptyView;
@synthesize emptyMessageLabel = _emptyMessageLabel;
@synthesize header = _header;
@synthesize proHeader = _proHeader;

- (void)setSelectionMode:(BOOL)selectionMode
{
    if (self.selectionMode != selectionMode) {
        _selectionMode = selectionMode;
        [self reload];
    }
}

- (void)setContentType:(MediaListViewContentType)contentType
      andSelectionMode:(BOOL)selectionMode
{
    if (self.contentType != contentType || self.selectionMode != selectionMode) {
        [super setContentTypeField:contentType];
        _selectionMode = selectionMode;
        [self reload];
    }
}

- (MediaListViewHeader *)header
{
    if (!_header) {
        _header = [[MediaListViewHeader alloc] initWithFrame:kvaHeaderFrame];
        _header.delegate = self;
    }
    return _header;
}

- (MediaListViewProHeader *)proHeader
{
    if (!_proHeader) {
        _proHeader = [[MediaListViewProHeader alloc] initWithFrame:kvaHeaderFrame];
        _proHeader.delegate = self;
    }
    return _proHeader;
}

#pragma mark Query and presentation

- (void)reload
{
	NSMutableArray* authorIdentities = [NSMutableArray array];
    SearchMediaType mediaType = SearchMediaTypeClips;
    MediaType type = MediaTypeUsual;

    switch (self.contentType) {
        case MediaListViewContentTypeUserClips:
            [authorIdentities addObject:AccountController2.sharedInstance.userIdentity];
            mediaType = SearchMediaTypeClips;
            break;
        case MediaListViewContentTypeUserSessions:
            [authorIdentities addObject:AccountController2.sharedInstance.userIdentity];
            mediaType = SearchMediaTypeSessions;
            break;
        case MediaListViewContentTypeUserAllClipsAndSessions:
            [authorIdentities addObject:AccountController2.sharedInstance.userIdentity];
            mediaType = SearchMediaTypeAll;
            break;
        case MediaListViewContentTypeProClips:
            [authorIdentities addObject:VstratorConstants.ProUserIdentity];
            mediaType = SearchMediaTypeClips;
            break;
        case MediaListViewContentTypeProSessions:
            [authorIdentities addObject:VstratorConstants.ProUserIdentity];
            mediaType = SearchMediaTypeSessions;
            break;
        case MediaListViewContentTypeAllClips:
            [authorIdentities addObject:AccountController2.sharedInstance.userIdentity];
            [authorIdentities addObject:VstratorConstants.ProUserIdentity];
            mediaType = SearchMediaTypeClips;
            break;
        case MediaListViewContentTypeAllSessions:
            [authorIdentities addObject:AccountController2.sharedInstance.userIdentity];
            [authorIdentities addObject:VstratorConstants.ProUserIdentity];
            mediaType = SearchMediaTypeSessions;
            break;
        case MediaListViewContentTypeAllClipsAndSessions:
            [authorIdentities addObject:AccountController2.sharedInstance.userIdentity];
            [authorIdentities addObject:VstratorConstants.ProUserIdentity];
            mediaType = SearchMediaTypeAll;
            break;
        case MediaListViewContentTypeProInterviews:
        case MediaListViewContentTypeProTutorials:
            [authorIdentities addObject:VstratorConstants.ProUserIdentity];
            mediaType = SearchMediaTypeAll;
            type = MediaTypeFeaturedVideo;
            break;
        case MediaListViewContentTypeNotSet:
        default:
            break;
    }

	[MediaService.mainThreadInstance searchMedia:mediaType
                                authorIdentities:authorIdentities
                                     queryString:self.queryString
                                            type:type
                                  skipIncomplete:YES
                                        callback:^(NSError *error, NSFetchedResultsController *result) {
                                            if (error == nil) {
                                                self.coreDataSelector.fetchedResultsController = result;
                                                [self checkForNewContent];
                                            } else {
                                                [UIAlertViewWrapper alertError:error];
                                            }
                                        }];
}

- (void)checkForNewUserContent
{
    [self checkForNewContent:@[AccountController2.sharedInstance.userIdentity] callback:^{
        self.tableView.tableHeaderView = self.header;
        if (self.tableView.superview == nil) {
            [self switchViews:self.tableView];
        }
    }];
}

- (void)checkForNewProContent
{
    [self checkForNewContent:@[VstratorConstants.ProUserIdentity] callback:^{
        self.tableView.tableHeaderView = self.proHeader;
        if (self.tableView.superview == nil) {
            [self switchViews:self.tableView];
        }
    }];
}

- (void)checkForNewContent
{
    switch (self.contentType) {
        case MediaListViewContentTypeProClips:
        case MediaListViewContentTypeProInterviews:
        case MediaListViewContentTypeProSessions:
        case MediaListViewContentTypeProTutorials:
            [self checkForNewProContent];
            break;
        default:
            [self checkForNewUserContent];
            break;
    }
}

- (void)checkForNewContent:(NSArray *)authorIdentites callback:(void(^)())callback
{
    [MediaService.mainThreadInstance downloadContentWithStatus:DownloadContentStatusNew
                                              authorIdentities:authorIdentites
                                                      callback:^(NSError *error, NSFetchedResultsController *result) {
                                                          if (error) {
                                                              [UIAlertViewWrapper alertError:error];
                                                              return;
                                                          }
                                                          NSError *error2 = nil;
                                                          @try {
                                                              [result performFetch:&error2];
                                                          }
                                                          @finally {
                                                              if (error2) {
#ifdef DEBUG_CORE_DATA
                                                                  NSLog(@"[%@ %@] %@ (%@)", NSStringFromClass([self class]), NSStringFromSelector(_cmd), [error2 localizedDescription], [error2 localizedFailureReason]);
#endif
                                                              }
                                                          }
                                                          if (result.fetchedObjects.count == 0) return;
                                                          callback();
                                                      }];
}

#pragma mark UITableViewDataSource

- (Class)mediaListViewCellClass
{
	return [MediaListViewCell class];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.coreDataSelector.fetchedResultsController.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [(self.coreDataSelector.fetchedResultsController.sections)[section] numberOfObjects];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [(self.coreDataSelector.fetchedResultsController.sections)[section] name];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    return [self.coreDataSelector.fetchedResultsController sectionForSectionIndexTitle:title atIndex:index];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return self.coreDataSelector.fetchedResultsController.sectionIndexTitles;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	Media *media = [self.coreDataSelector.fetchedResultsController objectAtIndexPath:indexPath];
    if ([self.delegate respondsToSelector:@selector(mediaListView:media:action:)])
        [self.delegate mediaListView:self media:media action:MediaActionSelect];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MediaListViewCell *cell = (MediaListViewCell *)[self.tableView dequeueReusableCellWithIdentifier:MediaListViewCell.reuseIdentifier];
	if (cell == nil) {
        cell = [[[self mediaListViewCellClass] alloc] initWithDelegate:self];
	}
	Media *media = [self.coreDataSelector.fetchedResultsController objectAtIndexPath:indexPath];
    [cell configureForData:media authorIdentity:AccountController2.sharedInstance.userIdentity selectionMode:self.selectionMode contentType:self.contentType tableView:tableView indexPath:indexPath];
	return cell;
}

#pragma mark MediaListViewCellDelegate

- (Media *)mediaByCell:(MediaListViewCell *)sender
{
    NSAssert(sender != nil, VstratorConstants.AssertionArgumentIsNilOrInvalid);
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    NSAssert(indexPath != nil, VstratorConstants.AssertionArgumentIsNilOrInvalid);
    Media *media = (Media *)[self.coreDataSelector.fetchedResultsController objectAtIndexPath:indexPath];
    NSAssert(media != nil, VstratorConstants.AssertionArgumentIsNilOrInvalid);
    return media;
}

- (void)mediaListViewCell:(MediaListViewCell *)sender action:(MediaAction)action
{
    if ([self.delegate respondsToSelector:@selector(mediaListView:media:action:)])
        [self.delegate mediaListView:self media:[self mediaByCell:sender] action:action];
}

#pragma mark MediaListViewHeaderDelegate

- (void)mediaListViewHeaderSyncAction:(MediaListViewHeader *)sender
{
    if ([self.delegate respondsToSelector:@selector(mediaListViewSyncAction:)])
        [self.delegate mediaListViewSyncAction:self];
}

#pragma mark MediaListViewProHeaderDelegate

- (void)mediaListViewProHeaderSelectAction:(MediaListViewProHeader *)sender
{
    if ([self.delegate respondsToSelector:@selector(mediaListViewNavigateToContentSetAction:)])
        [self.delegate mediaListViewNavigateToContentSetAction:self];
}

#pragma mark UISwipeGestureRecognizer Action

- (IBAction)swipeAction:(UISwipeGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded) {
        CGPoint swipeLocation = [sender locationInView:self.tableView];
        NSIndexPath *swipedIndexPath = [self.tableView indexPathForRowAtPoint:swipeLocation];
        UITableViewCell* swipedCell = [self.tableView cellForRowAtIndexPath:swipedIndexPath];
        if ([swipedCell isKindOfClass:MediaListViewCell.class]) {
            MediaListViewCell *cell = (MediaListViewCell *)swipedCell;
            if (sender.direction == UISwipeGestureRecognizerDirectionRight) {
                [cell showDeleteButton];
            } else if (sender.direction == UISwipeGestureRecognizerDirectionLeft) {
                [cell hideDeleteButton];
            }
        }
    }
}

#pragma mark View Lifecycle

- (void)setup
{
    [super setup];
    // views
    self.tableView.rowHeight = [[self mediaListViewCellClass] rowHeight];
    // gesture recognizer
    UISwipeGestureRecognizer *gr = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeAction:)];
    gr.direction = UISwipeGestureRecognizerDirectionRight;
    [self addGestureRecognizer:gr];
    gr = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeAction:)];
    gr.direction = UISwipeGestureRecognizerDirectionLeft;
    [self addGestureRecognizer:gr];
}

@end
