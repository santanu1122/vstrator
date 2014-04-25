//
//  Fault.m
//  VstratorApp
//
//  Created by akupr on 09.06.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "Fault.h"

@implementation Fault

@synthesize message = _message;

+(RKObjectMapping *)mapping
{
	RKObjectMapping* mapping = [RKObjectMapping mappingForClass:[Fault class]];
    [mapping addAttributeMappingsFromArray:@[@"message"]];
	return mapping;
}

-(NSString *)description
{
    return self.message;
}

@end
