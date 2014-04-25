//
//  BaseListView.m
//  VstratorApp
//
//  Created by Lion User on 16/07/2012.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "BaseListView.h"
#import "VstratorExtensions.h"
#import "VstratorStrings.h"

@interface BaseListView()

@property (nonatomic, strong) IBOutlet UIView *view;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UIView *emptyView;
@property (nonatomic, weak) IBOutlet UILabel *emptyMessageLabel;

@end

@implementation BaseListView

@synthesize queryString = _queryString;
@synthesize contentType = _contentType;

@synthesize infoNotExistText = _infoNotExistText;
@synthesize infoNotFoundText = _infoNotFoundText;

@synthesize view = _view;
@synthesize tableView = _tableView;
@synthesize emptyView = _emptyView;
@synthesize emptyMessageLabel = _emptyMessageLabel;

@synthesize coreDataSelector = _coreDataSelector;

#pragma mark - Properties

- (void)setQueryString:(NSString *)queryString
{
    queryString = [NSString trimmedStringOrNil:queryString];
	if (_queryString == queryString || [_queryString isEqualToString:queryString])
        return;
    _queryString = queryString;
    [self reload];
}

- (void)setContentType:(NSInteger)contentType
{
    if (self.contentType != contentType) {
        _contentType = contentType;
        [self reload];
    }
}

- (UITableView *)tableView
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (void)setTableView:(UITableView *)tableView
{
    [self doesNotRecognizeSelector:_cmd];
}

- (UIView *)emptyView
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (void)setEmptyView:(UIView *)emptyView
{
    [self doesNotRecognizeSelector:_cmd];
}

- (UIView *)emptyMessageLabel
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (void)setEmptyMessageLabel:(UILabel *)emptyMessageLabel
{
    [self doesNotRecognizeSelector:_cmd];
}

- (CoreDataSelector *)coreDataSelector
{
    if (_coreDataSelector == nil) {
        _coreDataSelector = [[CoreDataSelector alloc] init];
        _coreDataSelector.delegate = self;
#ifdef DEBUG_CORE_DATA
        _coreDataSelector.debug = YES;
#endif
    }
    return _coreDataSelector;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.coreDataSelector.fetchedResultsController.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.coreDataSelector.fetchedResultsController.sections objectAtIndex:section] numberOfObjects];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [[self.coreDataSelector.fetchedResultsController.sections objectAtIndex:section] name];
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
    [self doesNotRecognizeSelector:_cmd];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark - CoreDataSelector

- (void)coreDataSelectorReloadData:(CoreDataSelector *)sender
{
    [self.tableView reloadData];
}

- (void)coreDataSelectorBeginUpdates:(CoreDataSelector *)sender
{
    [self.tableView beginUpdates];
}

- (void)coreDataSelectorEndUpdates:(CoreDataSelector *)sender
{
    [self.tableView endUpdates];
    [self switchViewsByCoreData];
}

- (void)coreDataSelectorDidReload:(CoreDataSelector *)sender error:(NSError *)error
{
    [self switchViewsByCoreData];
}

- (void)coreDataSelector:(CoreDataSelector *)sender insertRowsAtIndexPaths:(NSArray *)indexPaths
{
    [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
}

- (void)coreDataSelector:(CoreDataSelector *)sender deleteRowsAtIndexPaths:(NSArray *)indexPaths
{
// This code crashes the app. Don't know why...
//    for (NSIndexPath* path in indexPaths) {
//        Media *media = (Media *)[self.coreDataSelector.fetchedResultsController objectAtIndexPath:path];
//        NSAssert(media, VstratorConstants.AssertionArgumentIsNilOrInvalid);
//        NSError* error = nil;
//        if (![media validateDelete:&error]) {
//            [UIAlertViewWrapper alertError:error];
//            return;
//        }
//    }
    [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
}

- (void)coreDataSelector:(CoreDataSelector *)sender reloadRowsAtIndexPaths:(NSArray *)indexPaths
{
    [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
}

- (void)coreDataSelector:(CoreDataSelector *)sender insertSections:(NSIndexSet *)sections
{
    [self.tableView insertSections:sections withRowAnimation:UITableViewRowAnimationFade];
}

- (void)coreDataSelector:(CoreDataSelector *)sender deleteSections:(NSIndexSet *)sections
{
    [self.tableView deleteSections:sections withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark - Business Logic

- (NSInteger)numberOfRows
{
    return [[self.coreDataSelector.fetchedResultsController.sections objectAtIndex:0] numberOfObjects];
}

- (void)switchViewsByCoreData
{
    int count = [self numberOfRows];
    if (count > 0) {
        if (self.tableView.superview == nil) {
            [self.emptyView removeFromSuperview];
            [self.view addSubview:self.tableView];
            self.tableView.frame = self.view.frame;
        }
    } else {
        if (self.emptyView.superview == nil) {
            [self refreshEmptyLabels];
            [self.tableView removeFromSuperview];
            [self.view addSubview:self.emptyView];
            self.emptyView.frame = self.view.frame;
        }
    }
}

- (void)refreshEmptyLabels
{
    NSString *messageText = @"";
    if (self.queryString == nil) {
        // list
        if (self.infoNotExistText == nil)
            messageText = VstratorStrings.MediaListAllNoClipsExist;
        else
            messageText = self.infoNotExistText;
    } else {
        // search
        if (self.infoNotFoundText == nil)
            messageText = VstratorStrings.MediaListAllNoClipsFound;
        else
            messageText = self.infoNotFoundText;
    }
    // set
    self.emptyMessageLabel.text = [messageText stringByAppendingString:@"\n\n\n\n\n\n"];
}

- (void)setInfoWithNotExistText:(NSString *)notExistText
                   notFoundText:(NSString *)notFoundText
{
    _infoNotExistText = [NSString stringWithStringOrNil:notExistText];
    _infoNotFoundText = [NSString stringWithStringOrNil:notFoundText];
    [self refreshEmptyLabels];
}

- (void)reload
{
    [self doesNotRecognizeSelector:_cmd];
}

- (void)refreshTable
{
    [self.tableView reloadData];
    [self switchViewsByCoreData];
}

- (id)objectByCell:(id)sender
{
    NSAssert(sender != nil, VstratorConstants.AssertionArgumentIsNilOrInvalid);
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    NSAssert(indexPath != nil, VstratorConstants.AssertionArgumentIsNilOrInvalid);
    id object = [self objectAtIndexPath:indexPath];
    NSAssert(object != nil, VstratorConstants.AssertionArgumentIsNilOrInvalid);
    return object;
}

- (id)objectAtIndexPath:(NSIndexPath*)indexPath
{
    return [self.coreDataSelector.fetchedResultsController objectAtIndexPath:indexPath];
}

- (void)setContentTypeField:(NSInteger)contentType
{
    _contentType = contentType;
}

#pragma mark - View Lifecycle

- (void)setup
{
    self.backgroundColor = [UIColor clearColor];
    // NIB
    [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self.class) owner:self options:nil];
    NSAssert(self.view != nil, VstratorConstants.AssertionNibIsInvalid);
    [self addSubview:self.view];
    self.view.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    // views
    [self refreshEmptyLabels];
    [self.view addSubview:self.emptyView];
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

@end
