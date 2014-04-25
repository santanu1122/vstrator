//
//  RemoteServiceTest.h
//  VstratorCore
//
//  Created by akupr on 06.07.13.
//  Copyright (c) 2013 OnTarget. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#define EXP_SHORTHAND
#import <Expecta/Expecta.h>
#import <RestKit/Testing.h>
#import <OCMock/OCMock.h>

#import "RemoteService.h"

@interface RemoteServiceTest : SenTestCase

@property (nonatomic, strong, readonly) id mockDelegate;
@property (nonatomic, strong, readonly) RKObjectManager* objectManager;

@end
