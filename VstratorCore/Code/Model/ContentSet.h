//
//  ContentSet.h
//  VstratorCore
//
//  Created by akupr on 04.02.13.
//  Copyright (c) 2013 OnTarget. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DownloadContent;

@interface ContentSet : NSManagedObject

@property (nonatomic, retain) NSString * identity;
@property (nonatomic, retain) NSString * inAppPurchaseID;
@property (nonatomic, retain) NSNumber * isPurchased;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSString * price;
@property (nonatomic, retain) NSSet *contents;
@end

@interface ContentSet (CoreDataGeneratedAccessors)

- (void)addContentsObject:(DownloadContent *)value;
- (void)removeContentsObject:(DownloadContent *)value;
- (void)addContents:(NSSet *)values;
- (void)removeContents:(NSSet *)values;

@end
