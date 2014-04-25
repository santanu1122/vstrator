//
//  MarkupTestBase.h
//  VstratorCore
//
//  Created by akupr on 28.08.13.
//  Copyright (c) 2013 OnTarget. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

@class RKObjectMapping;

@interface MarkupTestBase : SenTestCase

-(id)serialize:(id)object withMapping:(RKObjectMapping*)mapping;

@end
