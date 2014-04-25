//
//  UploadRequestListView.m
//  VstratorApp
//
//  Created by Lion User on 25/07/2012.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "AccountController2.h"
#import "MediaService.h"
#import "UploadRequestListView.h"
#import "UploadRequestListViewCell.h"
#import "VstratorExtensions.h"
#import "VstratorStrings.h"

@interface UploadRequestListView()

@property (nonatomic, strong, readonly) CoreDataSelector *coreDataSelector;

@property (nonatomic, strong) IBOutlet UIView *view;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UIView *emptyView;
@property (nonatomic, weak) IBOutlet UILabel *emptyMessageLabel;

@end

@implementation UploadRequestListView

@synthesize delegate = _delegate;

@synthesize view = _view;
@synthesize tableView = _tableView;
@synthesize emptyView = _emptyView;
@synthesize emptyMessageLabel = _emptyMessageLabel;

#pragma mark Properties

- (void)setContentType:(UploadRequestContentType)contentType
{
    [super setContentType:contentType];
}

#pragma mark Query and presentation

- (void)reload
{
    UploadRequestStatus status;
    switch (self.contentType) {
        case UploadRequestContentTypeCompleted:
            status = UploadRequestStatusCompleeted;
            break;
        case UploadRequestContentTypeInProgress:
            status = UploadRequestStatusInProgress;
            break;
        default:
            status = UploadRequestStatusAll;
            break;
    }
    NSArray *authorIdentities = @[ VstratorConstants.ProUserIdentity, AccountController2.sharedInstance.userIdentity ];
	[MediaService.mainThreadInstance uploadRequestsWithStatus:status authorIdentities:authorIdentities callback:^(NSError *error, NSFetchedResultsController *result) {
        if (error == nil) {
            self.coreDataSelector.fetchedResultsController = result;
        } else {
            [UIAlertViewWrapper alertError:error];
        }
    }];
}

- (void)renewPresentation
{
    NSArray *visibleCells = [self.tableView visibleCells];
    for (UITableViewCell *visibleCell in visibleCells) {
        if ([visibleCell isKindOfClass:UploadRequestListViewCell.class])
            [((UploadRequestListViewCell *)visibleCell) renewAnimations];
    }
}

#pragma mark UITableViewDataSource

- (Class)uploadRequestListViewCellClass
{
    return [UploadRequestListViewCell class];
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UploadRequestListViewCell *cell = (UploadRequestListViewCell *)[self.tableView dequeueReusableCellWithIdentifier:UploadRequestListViewCell.reuseIdentifier];
    if (cell == nil) {
        cell = [[[self uploadRequestListViewCellClass] alloc] initWithDelegate:self];
    }
    UploadRequest *UploadRequest = [self.coreDataSelector.fetchedResultsController objectAtIndexPath:indexPath];
    [cell configureForData:UploadRequest];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

#pragma mark MediaListViewCellDelegate

- (UploadRequest *)uploadRequestByCell:(UploadRequestListViewCell *)sender
{
    NSAssert(sender != nil, VstratorConstants.AssertionArgumentIsNilOrInvalid);
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    NSAssert(indexPath != nil, VstratorConstants.AssertionArgumentIsNilOrInvalid);
    UploadRequest *uploadRequest = (UploadRequest *)[self.coreDataSelector.fetchedResultsController objectAtIndexPath:indexPath];
    NSAssert(uploadRequest != nil, VstratorConstants.AssertionArgumentIsNilOrInvalid);
    return uploadRequest;
}

- (void)uploadRequestListViewCell:(UploadRequestListViewCell *)sender action:(UploadRequestAction)action
{
    if ([self.delegate respondsToSelector:@selector(uploadRequestListView:uploadRequest:action:)])
        [self.delegate uploadRequestListView:self uploadRequest:[self uploadRequestByCell:sender] action:action];
}

#pragma mark UISwipeGestureRecognizer Action

- (IBAction)swipeAction:(UISwipeGestureRecognizer *)sender
{
    if (sender.state != UIGestureRecognizerStateEnded) return;
    CGPoint swipeLocation = [sender locationInView:self.tableView];
    NSIndexPath *swipedIndexPath = [self.tableView indexPathForRowAtPoint:swipeLocation];
    UITableViewCell* swipedCell = [self.tableView cellForRowAtIndexPath:swipedIndexPath];
    if (![swipedCell isKindOfClass:UploadRequestListViewCell.class]) return;
    UploadRequestListViewCell *cell = (UploadRequestListViewCell *)swipedCell;
    if (sender.direction == UISwipeGestureRecognizerDirectionRight) {
        [cell showStopButton];
    } else if (sender.direction == UISwipeGestureRecognizerDirectionLeft) {
        [cell hideStopButton];
    }
}

#pragma mark View Lifecycle

- (void)setup
{
    [super setup];
    self.tableView.rowHeight = [[self uploadRequestListViewCellClass] rowHeight];
    [super setContentTypeField:-1];
    // gesture recognizer
    UISwipeGestureRecognizer *gr = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeAction:)];
    gr.direction = UISwipeGestureRecognizerDirectionRight;
    [self addGestureRecognizer:gr];
    gr = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeAction:)];
    gr.direction = UISwipeGestureRecognizerDirectionLeft;
    [self addGestureRecognizer:gr];
}

@end
