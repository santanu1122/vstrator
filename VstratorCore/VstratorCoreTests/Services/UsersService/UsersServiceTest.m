//
//  UsersServiceTest.m
//  VstratorCore
//
//  Created by akupr on 02.09.13.
//  Copyright (c) 2013 OnTarget. All rights reserved.
//

#import "UsersServiceTest.h"

@implementation UsersServiceTest

-(void)setUp
{
    [super setUp];
    _service = [[RestUsersService alloc] init];
    _service.delegate = self.mockDelegate;
}

@end
