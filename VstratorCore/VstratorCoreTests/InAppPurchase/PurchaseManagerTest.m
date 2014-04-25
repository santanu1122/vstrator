//
//  PurchaseManagerTest.m
//  VstratorCore
//
//  Created by akupr on 12.02.13.
//  Copyright (c) 2013 OnTarget. All rights reserved.
//

#import "PurchaseManagerTest.h"
#import "PurchaseManager.h"
#import "ContentSet.h"

@interface PurchaseManagerTest() {
    NSManagedObjectModel *model;
    NSPersistentStoreCoordinator *coordinator;
    NSPersistentStore *store;
    NSManagedObjectContext *context;
}
@end

@implementation PurchaseManagerTest

-(NSManagedObjectModel*)createModel
{
    static NSString *testTargetName = @"VstratorCoreTests";
    NSBundle *modelBundle = nil;
    for (NSBundle *bundle in [NSBundle allBundles]) {
        if ([[bundle objectForInfoDictionaryKey:@"CFBundleExecutable"] isEqualToString:testTargetName]) {
            modelBundle = [NSBundle bundleWithPath:[bundle pathForResource:@"VstratorModels" ofType:@"bundle"]];
            break;
        }
    }
    NSURL *modelURL = [NSURL fileURLWithPath:[modelBundle pathForResource:@"VstratorDataModel" ofType:@"momd"]];
    return [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
}

- (void)setUp
{ 
    model = [self createModel];
    coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
    store = [coordinator addPersistentStoreWithType: NSInMemoryStoreType
                                      configuration: nil
                                                URL: nil
                                            options: nil
                                              error: NULL];
    context = [[NSManagedObjectContext alloc] init];
    context.persistentStoreCoordinator = coordinator;
}

-(void)test1
{
    ContentSet* set = [NSEntityDescription insertNewObjectForEntityForName:@"ContentSet" inManagedObjectContext:context];
    set.inAppPurchaseID = @"foo";
    PurchaseManager* manager = [PurchaseManager new];
    [manager purchaseContentSet:set callback:^(NSError *error) {
        
    }];
}

@end
