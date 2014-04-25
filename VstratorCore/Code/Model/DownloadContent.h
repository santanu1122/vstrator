//
//  DownloadContent.h
//  VstratorCore
//
//  Created by akupr on 11.02.13.
//  Copyright (c) 2013 OnTarget. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ContentSet, Exercise, Media, Workout;

@interface DownloadContent : NSManagedObject

@property (nonatomic, retain) NSString * identity;
@property (nonatomic, retain) NSNumber * status;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSSet *contentSets;
@property (nonatomic, retain) Exercise *exercise;
@property (nonatomic, retain) Media *media;
@property (nonatomic, retain) Workout *workout;
@end

@interface DownloadContent (CoreDataGeneratedAccessors)

- (void)addContentSetsObject:(ContentSet *)value;
- (void)removeContentSetsObject:(ContentSet *)value;
- (void)addContentSets:(NSSet *)values;
- (void)removeContentSets:(NSSet *)values;

@end
