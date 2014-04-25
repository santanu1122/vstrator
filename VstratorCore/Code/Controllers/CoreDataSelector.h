//
//  CoreDataSelector.h
//  VstratorApp
//
//  Created by Mac on 08.04.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@protocol CoreDataSelectorDelegate;



@interface CoreDataSelector : NSObject<NSFetchedResultsControllerDelegate>

@property (nonatomic, weak) id<CoreDataSelectorDelegate> delegate;

// The controller (this class fetches nothing if this is not set).
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

// Causes the fetchedResultsController to refetch the data.
// You almost certainly never need to call this.
// The NSFetchedResultsController class observes the context
//  (so if the objects in the context change, you do not need to call performFetch
//   since the NSFetchedResultsController will notice and update the table automatically).
// This will also automatically be called if you change the fetchedResultsController @property.
- (void)performFetch;

// Turn this on before making any changes in the managed object context that
//  are a one-for-one result of the user manipulating rows directly in the table view.
// Such changes cause the context to report them (after a brief delay),
//  and normally our fetchedResultsController would then try to update the table,
//  but that is unnecessary because the changes were made in the table already (by the user)
//  so the fetchedResultsController has nothing to do and needs to ignore those reports.
// Turn this back off after the user has finished the change.
// Note that the effect of setting this to NO actually gets delayed slightly
//  so as to ignore previously-posted, but not-yet-processed context-changed notifications,
//  therefore it is fine to set this to YES at the beginning of, e.g., tableView:moveRowAtIndexPath:toIndexPath:,
//  and then set it back to NO at the end of your implementation of that method.
// It is not necessary (in fact, not desirable) to set this during row deletion or insertion
//  (but definitely for row moves).
@property (nonatomic) BOOL suspendAutomaticTrackingOfChangesInManagedObjectContext;

// Set to YES to get some debugging output in the console.
@property (atomic) BOOL debug;

@end



@protocol CoreDataSelectorDelegate<NSObject>

@required
- (void)coreDataSelectorReloadData:(CoreDataSelector *)sender;
- (void)coreDataSelectorBeginUpdates:(CoreDataSelector *)sender;
- (void)coreDataSelectorEndUpdates:(CoreDataSelector *)sender;
- (void)coreDataSelector:(CoreDataSelector *)sender insertRowsAtIndexPaths:(NSArray *)indexPaths;
- (void)coreDataSelector:(CoreDataSelector *)sender deleteRowsAtIndexPaths:(NSArray *)indexPaths;
- (void)coreDataSelector:(CoreDataSelector *)sender reloadRowsAtIndexPaths:(NSArray *)indexPaths;
@optional
- (void)coreDataSelector:(CoreDataSelector *)sender insertSections:(NSIndexSet *)sections;
- (void)coreDataSelector:(CoreDataSelector *)sender deleteSections:(NSIndexSet *)sections;
- (void)coreDataSelectorWillReload:(CoreDataSelector *)sender;
- (void)coreDataSelectorDidReload:(CoreDataSelector *)sender error:(NSError *)error;

@end
