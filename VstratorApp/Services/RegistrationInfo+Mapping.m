//
//  RegistrationInfo+Mapping.m
//  VstratorApp
//
//  Created by Mac on 22.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RegistrationInfo+Mapping.h"

@implementation RegistrationInfo (Mapping)

+(RKObjectMapping*) mapping
{
	RKObjectMapping* mapping = [RKObjectMapping mappingForClass:[RegistrationInfo class]];
    [mapping mapKeyPathsToAttributes:
        @"firstName", @"firstName",
        @"lastName", @"lastName",
        @"email", @"email",
        @"password", @"password",
        @"primarySport", @"primarySport",
        nil];
	return mapping;
}

@end
