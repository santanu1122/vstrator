//
//  CoreDataSelector.m
//  VstratorApp
//
//  Created by Mac on 08.04.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "CoreDataSelector.h"

@interface CoreDataSelector()

@property (nonatomic) BOOL beganUpdates;

@end

@implementation CoreDataSelector

#pragma mark - Properties

@synthesize delegate = _delegate;

@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize suspendAutomaticTrackingOfChangesInManagedObjectContext = _suspendAutomaticTrackingOfChangesInManagedObjectContext;
@synthesize debug = _debug;
@synthesize beganUpdates = _beganUpdates;

#pragma mark - Fetching

- (void)performFetch
{
    if (self.fetchedResultsController) {
        // debug
        if (self.debug) {
            if (self.fetchedResultsController.fetchRequest.predicate) {
                NSLog(@"[%@ %@] fetching %@ with predicate: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), self.fetchedResultsController.fetchRequest.entityName, self.fetchedResultsController.fetchRequest.predicate);
            } else {
                NSLog(@"[%@ %@] fetching all %@ (i.e., no predicate)", NSStringFromClass([self class]), NSStringFromSelector(_cmd), self.fetchedResultsController.fetchRequest.entityName);
            }
        }
        // perform
        if ([self.delegate respondsToSelector:@selector(coreDataSelectorWillReload:)])
            [self.delegate coreDataSelectorWillReload:self];
        NSError *error = nil;
        @try {
            [self.fetchedResultsController performFetch:&error];
        }
        @finally {
            if (self.debug && error != nil) {
                NSLog(@"[%@ %@] %@ (%@)", NSStringFromClass([self class]), NSStringFromSelector(_cmd), [error localizedDescription], [error localizedFailureReason]);
            }
            if ([self.delegate respondsToSelector:@selector(coreDataSelectorDidReload:error:)])
                [self.delegate coreDataSelectorDidReload:self error:error];
        }
    } else {
        if (self.debug) {
            NSLog(@"[%@ %@] no NSFetchedResultsController (yet?)", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
        }
    }
    [self.delegate coreDataSelectorReloadData:self];
}

- (void)setFetchedResultsController:(NSFetchedResultsController *)newfrc
{
    NSFetchedResultsController *oldfrc = _fetchedResultsController;
    if (newfrc != oldfrc) {
        _fetchedResultsController = newfrc;
        if (newfrc) {
            newfrc.delegate = self;
            if (self.debug) {
                NSLog(@"[%@ %@] %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), oldfrc ? @"updated" : @"set");
            }
            [self performFetch]; 
        } 
        else {
            if (self.debug) {
                NSLog(@"[%@ %@] reset to nil", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
            }
            [self.delegate coreDataSelectorReloadData:self];
        }
    }
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    if (!self.suspendAutomaticTrackingOfChangesInManagedObjectContext) {
        [self.delegate coreDataSelectorBeginUpdates:self];
        self.beganUpdates = YES;
    }
}

- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
		   atIndex:(NSUInteger)sectionIndex
	 forChangeType:(NSFetchedResultsChangeType)type
{
    if (!self.suspendAutomaticTrackingOfChangesInManagedObjectContext)
    {
        switch(type)
        {
            case NSFetchedResultsChangeInsert:
                if ([self.delegate respondsToSelector:@selector(coreDataSelector:insertSections:)])
                    [self.delegate coreDataSelector:self insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]];
                break;
            case NSFetchedResultsChangeDelete:
                if ([self.delegate respondsToSelector:@selector(coreDataSelector:deleteSections:)])
                    [self.delegate coreDataSelector:self deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]];
                break;
        }
    }
}

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
	   atIndexPath:(NSIndexPath *)indexPath
	 forChangeType:(NSFetchedResultsChangeType)type
	  newIndexPath:(NSIndexPath *)newIndexPath
{		
    if (!self.suspendAutomaticTrackingOfChangesInManagedObjectContext)
    {
        switch(type)
        {
            case NSFetchedResultsChangeInsert:
                [self.delegate coreDataSelector:self insertRowsAtIndexPaths:@[newIndexPath]];
                break;
            case NSFetchedResultsChangeDelete:
                [self.delegate coreDataSelector:self deleteRowsAtIndexPaths:@[indexPath]];
                break;
            case NSFetchedResultsChangeUpdate:
                [self.delegate coreDataSelector:self reloadRowsAtIndexPaths:@[indexPath]];
                break;
            case NSFetchedResultsChangeMove:
                [self.delegate coreDataSelector:self deleteRowsAtIndexPaths:@[indexPath]];
                [self.delegate coreDataSelector:self insertRowsAtIndexPaths:@[newIndexPath]];
                break;
        }
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    if (self.beganUpdates) {
        [self.delegate coreDataSelectorEndUpdates:self];
    }
}

- (void)endSuspensionOfUpdatesDueToContextChanges
{
    _suspendAutomaticTrackingOfChangesInManagedObjectContext = NO;
}

- (void)setSuspendAutomaticTrackingOfChangesInManagedObjectContext:(BOOL)suspend
{
    if (suspend) {
        _suspendAutomaticTrackingOfChangesInManagedObjectContext = YES;
    } else {
        [self performSelector:@selector(endSuspensionOfUpdatesDueToContextChanges) withObject:0 afterDelay:0];
    }
}

@end

