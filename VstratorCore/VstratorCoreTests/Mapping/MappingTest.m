//
//  MappingTest.m
//  VstratorCore
//
//  Created by akupr on 29.08.13.
//  Copyright (c) 2013 OnTarget. All rights reserved.
//

#import "MappingTest.h"

@implementation MappingTest

-(void)setUp
{
    // Configure RKTestFixture
	NSBundle* testTargetBundle = [NSBundle bundleWithIdentifier:@"com.vstrator.VstratorCoreTests"];
    expect(testTargetBundle).toNot.beNil();
	[RKTestFixture setFixtureBundle:testTargetBundle];
}

@end
