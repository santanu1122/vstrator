//
//  StrokeInfoSerialization.m
//  VstratorApp
//
//  Created by akupr on 20.06.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <RestKit/RestKit.h>

#include "TestConsts.h"
#import "StrokeInfoTest.h"
#import "MarkupData+Mapping.h"

const double DefaultStrokeSize = 3.;

@interface StrokeInfoTest() {
    StrokeInfo* info;
}

@end

@implementation StrokeInfoTest

-(void)setUp
{
    info = [[StrokeInfo alloc] init];
}

-(id)serialize
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    RKMappingOperation *operation = [[RKMappingOperation alloc] initWithSourceObject:info
                                                                   destinationObject:dict
                                                                             mapping:[StrokeInfo mapping]];
    NSError *error = nil;
    [operation performMapping:&error];
    expect(error).to.beNil();
    return error ? nil : dict;
}

-(void)test_Default_values
{
    expect(info.size).to.equal(CGSizeMake(DefaultStrokeSize, DefaultStrokeSize));
    expect(info.outlineColor).to.equal([UIColor colorWithRed:0. green:0. blue:0. alpha:0.]);
    expect(info.points).to.beNil();
}

-(void)test_Serialization
{
    info.size = CGSizeMake(10, 20);
    info.color = [UIColor colorWithRed:1. green:0. blue:1. alpha:0.];
    info.outlineColor = [UIColor colorWithRed:0. green:1. blue:0. alpha:1.];
    info.points = @[@{@"X":@1, @"Y":@2}, @{@"X":@3,@"Y":@4}];
    NSDictionary* d = [self serialize:info withMapping:[StrokeInfo mapping]];
    expect([d objectForKey:@"Width"]).to.equal([NSNumber numberWithInt:10]);
    expect([d objectForKey:@"Height"]).to.equal([NSNumber numberWithInt:20]);
    expect([d objectForKey:@"Color"]).to.equal((@[@0, @255, @0, @255]));
    expect([d objectForKey:@"OutlineColor"]).to.equal((@[@255, @0, @255, @0]));
    expect([d objectForKey:@"Points"]).to.equal((@[@{@"X":@1, @"Y":@2}, @{@"X":@3,@"Y":@4}]));
}

@end
