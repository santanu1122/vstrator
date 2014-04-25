//
//  LayoutInfoSerialization.m
//  VstratorApp
//
//  Created by akupr on 20.06.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <RestKit/RestKit.h>

#include "TestConsts.h"

#import "LayoutInfoTest.h"
#import "MarkupData+Mapping.h"

@interface LayoutInfoTest() {
    LayoutInfo* info;
}

@end

@implementation LayoutInfoTest

-(void)setUp
{
    info = [[LayoutInfo alloc] init];
}

-(void)test_Default_values
{
    expect(info.opacity).to.equal(1.);
    expect(info.rotation).to.equal(0.);
}

-(void)test_Serialization
{
    info.imageIndex = 31415;
    info.left = 100;
    info.top = 200;
    info.width = 300;
    info.height = 400;
    info.rotation = 500;
    info.opacity = 600;
    NSString* clipKey = info.clipKey = [[NSProcessInfo processInfo] globallyUniqueString];
    NSDictionary* d = [self serialize:info withMapping:[LayoutInfo mapping]];
    expect(d[@"ImageIndex"]).to.equal(@31415);
    expect(d[@"Left"]).to.equal(@100);
    expect(d[@"Top"]).to.equal(@200);
    expect(d[@"Width"]).to.equal(@300);
    expect(d[@"Height"]).to.equal(@400);
    expect(d[@"Rotation"]).to.equal(@500);
    expect(d[@"Opacity"]).to.equal(@600);
    expect(d[@"ClipKey"]).to.equal(clipKey);
}

@end
