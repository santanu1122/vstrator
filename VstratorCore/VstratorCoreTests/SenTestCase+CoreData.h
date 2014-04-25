//
//  SenTestCase+CoreData.h
//  VstratorCore
//
//  Created by akupr on 13.09.13.
//  Copyright (c) 2013 OnTarget. All rights reserved.
//

#define MR_SHORTHAND
#import <MagicalRecord/CoreData+MagicalRecord.h>
#import <SenTestingKit/SenTestingKit.h>

@interface SenTestCase (CoreData)

-(void)setupCoreDataStack;
-(void)cleanupCoreDataStack;

@end
