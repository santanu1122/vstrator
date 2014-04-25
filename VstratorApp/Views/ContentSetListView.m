//
//  ContentSetListView.m
//  VstratorApp
//
//  Created by Lion User on 27/07/2012.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "AccountController2.h"
#import "ContentSetListView.h"
#import "ContentSetListViewCell.h"
#import "ContentSetListViewHeader.h"
#import "MediaService.h"
#import "VstratorConstants.h"
#import "VstratorExtensions.h"
#import "VstratorStrings.h"

@interface ContentSetListView()

@property (nonatomic, strong, readonly) CoreDataSelector *coreDataSelector;

@property (nonatomic, strong) IBOutlet UIView *view;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UIView *emptyView;
@property (nonatomic, weak) IBOutlet UILabel *emptyMessageLabel;

@property (nonatomic, strong, readonly) ContentSetListViewHeader *header;

@end

@implementation ContentSetListView

@synthesize coreDataSelector = _coreDataSelector;
@synthesize header = _header;

#pragma mark - Properties

- (ContentSetListViewHeader *)header
{
    if (!_header) {
        _header = [[ContentSetListViewHeader alloc] initWithFrame:CGRectZero];
        _header.frame = CGRectMake(0, 0, self.bounds.size.width, _header.frame.size.height);
        _header.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    }
    return _header;
}

#pragma mark - Query and presentation

- (void)reload
{
    [MediaService.mainThreadInstance fetchContentSets:^(NSError *error, NSFetchedResultsController *result) {
        if (error) {
            [UIAlertViewWrapper alertError:error];
        } else {
            self.coreDataSelector.fetchedResultsController = result;
        }
    }];
}

#pragma mark - UITableViewDataSource

- (Class)contentSetListViewCellClass
{
	return [ContentSetListViewCell class];
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
	ContentSet *contentSet = [self.coreDataSelector.fetchedResultsController objectAtIndexPath:indexPath];
    if ([self.delegate respondsToSelector:@selector(contentSetListView:didSelectContentSet:)])
        [self.delegate contentSetListView:self didSelectContentSet:contentSet];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ContentSetListViewCell *cell = (ContentSetListViewCell *)[self.tableView dequeueReusableCellWithIdentifier:ContentSetListViewCell.reuseIdentifier];
	if (cell == nil) {
        cell = [[[self contentSetListViewCellClass] alloc] init];
	}
	ContentSet *contentSet = [self.coreDataSelector.fetchedResultsController objectAtIndexPath:indexPath];
    [cell configureForData:contentSet];
	return cell;
}

#pragma mark - View Lifecycle

- (void)setup
{
    [super setup];
    // views
    self.tableView.rowHeight = [[self contentSetListViewCellClass] rowHeight];
    self.tableView.tableHeaderView = self.header;
    [self reload];
}

@end
