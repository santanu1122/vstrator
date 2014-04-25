//
//  UploadServiceTest.m
//  VstratorCore
//
//  Created by akupr on 11.09.13.
//  Copyright (c) 2013 OnTarget. All rights reserved.
//

#import "UploadServiceTest.h"

@implementation UploadServiceTest

-(void)setUp
{
    [super setUp];
    _service = [[RestUploadService alloc] init];
    _service.delegate = self.mockDelegate;
}

@end

