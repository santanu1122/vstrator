//
//  RemoteServiceTest.h
//  VstratorCore
//
//  Created by akupr on 06.07.13.
//  Copyright (c) 2013 MLM. All rights reserved.
//

#import "RemoteServiceTest.h"
#import "ServiceFactory.h"

@implementation RemoteServiceTest

-(void)setUp
{
    ServiceFactory* factory = [ServiceFactory new];
    factory.baseURL = [NSURL URLWithString:@"http://localhost:4567/"];
    _objectManager = factory.objectManager;
    _mockDelegate = [OCMockObject partialMockForObject:factory];
    [[[_mockDelegate stub] andReturn:self.objectManager] objectManager];
    [[[_mockDelegate stub] andReturn:nil] parameters];
}

@end
