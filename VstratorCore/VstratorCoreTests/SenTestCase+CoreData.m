//
//  SenTestCase+CoreData.m
//  VstratorCore
//
//  Created by akupr on 13.09.13.
//  Copyright (c) 2013 OnTarget. All rights reserved.
//

#import "SenTestCase+CoreData.h"

@implementation SenTestCase (CoreData)

-(void)setupCoreDataStack
{
    NSString *bundlePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"VstratorModels" ofType:@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
    NSManagedObjectModel *model = [NSManagedObjectModel mergedModelFromBundles:[NSArray arrayWithObject:bundle]];
    [NSManagedObjectModel setDefaultManagedObjectModel:model];
	[MagicalRecord setupCoreDataStackWithInMemoryStore];
}

-(void)cleanupCoreDataStack
{
    [MagicalRecord cleanUp];
}


@end
