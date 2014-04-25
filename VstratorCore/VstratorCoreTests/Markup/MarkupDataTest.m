//
//  MarkupDataTest.m
//  VstratorApp
//
//  Created by akupr on 20.06.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <RestKit/RestKit.h>

#import "TestConsts.h"
#import "MarkupDataTest.h"

#import "MarkupData+Mapping.h"
#import "UIColor+Extensions.h"
#import "NSString+JSONString.h"

@implementation MarkupDataTest

-(void)test_Default_values
{
    MarkupData* data = [[MarkupData alloc] init];
    STAssertEquals(data.dataFormat, MarkupDataFormatFrame, @"DataFormat");
    STAssertEquals(data.inFrame, 0, @"InFrame");
    STAssertEquals(data.outFrame, -1, @"OutFrame");
    STAssertEquals(data.appScreenMode, ScreenModeNormal, @"AppScreenMode");
    STAssertEquals(data.drawingToolMode, ToolModeFreeHand, @"DrawingToolMode");
    STAssertEquals(data.actionTime, 0., @"ActionTime");
    STAssertEquals(data.markupTime, 0., @"MarkupTime");
    STAssertNil(data.primaryLayout, @"PrimaryLayout");
    STAssertNil(data.secondaryLayout, @"SecondaryLayout");
    STAssertNil(data.strokeObject, @"StrokeObject");
}

-(void)test_Serialization
{
    // Arrange
    MarkupData* data = [[MarkupData alloc] init];
    data.actionTime = 60 * 17 + 3 + .003; // 17m 3s 3ms
    data.markupTime = 0.01; // 0.01s
    data.dataFormat = MarkupDataFormatXaml;
    data.drawingToolMode = ToolModeRectangle;
    data.inFrame = 123;
    data.outFrame = 321;
    data.primaryLayout = [[LayoutInfo alloc] init];
    data.secondaryLayout = [[LayoutInfo alloc] init];
    data.strokeObject = [[StrokeInfo alloc] init];
    // Act
    NSDictionary* d = [self serialize:data withMapping:[MarkupData mapping]];
    // Assert
    expect(d[@"DataFormat"]).to.equal(@(MarkupDataFormatXaml));
    expect(d[@"DrawingToolMode"]).to.equal(@(ToolModeRectangle));
    expect(d[@"ActionTime"]).to.equal(@"PT17M3.003S");
    expect(d[@"MarkupTime"]).to.equal(@"PT0.01S");
    expect(d[@"InFrame"]).to.equal(@123);
    expect(d[@"OutFrame"]).to.equal(@321);
    expect(d[@"PrimaryLayout"]);
    expect(d[@"SecondaryLayout"]);
    expect(d[@"StrokeObject"]);
}

-(void)test_MarkupDataCollection_serialization
{
    // Arrange
    MarkupDataCollection* collection = [MarkupDataCollection new];
    [collection add:[MarkupData new]];
    [collection add:[MarkupData new]];
    [collection add:[MarkupData new]];
    // Act
    NSDictionary* d = [self serialize:collection withMapping:[MarkupDataCollection mapping]];
    // Assert
    NSArray* markup = d[@"markup"];
    STAssertNotNil(markup, @"markup");
    STAssertEquals(markup.count, 3u, @"count");
}

-(void)test_asJSONString
{
    // Arrange
    MarkupDataCollection* collection = [MarkupDataCollection new];
    [collection add:[MarkupData new]];
    [collection add:[MarkupData new]];
    [collection add:[MarkupData new]];
    // Act
    NSError* error = nil;
    NSString* s = [collection asJSONString:&error];
    // Assert
    STAssertNil(error, [NSString stringWithFormat:@"error: %@", error]);
    NSArray* object = [s objectFromJSONString];
    STAssertNotNil(object, @"object is nil");
    STAssertTrue([object isKindOfClass:[NSArray class]], @"object !isKindOf:NSArray");
    STAssertEquals(object.count, 3u, @"object.count");
}

-(void)test_initWithFrame
{
    NSDictionary* frame = @{@"index":@42, @"time":@23917};
    MarkupData* data = [[MarkupData alloc] initWithFrame:frame];
    STAssertEquals(data.dataFormat, MarkupDataFormatFrame, @"DataFormat");
    STAssertEqualsWithAccuracy(data.actionTime, 23.917, EPS, @"ActionTime");
    STAssertEquals(data.showFrame, 43, @"DataFormat"); // The showFrame should be indexed from 1
}

-(void)test_initWithShape_FreeHand
{
    NSDictionary* shape =
    @{@"shape": @0,
      @"color": @"3DFF",
      @"start_time": @2618,
      @"end_time": @12917,
      @"points":
          @[@{@"x" : @0.8000, @"y" : @0.6000},
            @{@"x" : @0.7632, @"y" : @0.6013},
            @{@"x" : @0.7463, @"y" : @0.5817},
            @{@"x" : @0.7291, @"y" : @0.6281},
            @{@"x" : @0.8123, @"y" : @0.6491},
            @{@"x" : @0.8245, @"y" : @0.6618}]};

    STAssertNotNil(shape, @"shape is nil");

    CGSize size = CGSizeMake(1024, 768);
    MarkupData* data = [[MarkupData alloc] initWithShape:shape size:size];

    STAssertEquals(data.dataFormat, MarkupDataFormatXaml, @"DataFormat");
    STAssertEqualsWithAccuracy(data.actionTime, 2.618, EPS, @"ActionTime");
    STAssertEquals(data.drawingToolMode, ToolModeFreeHand, @"DataFormat");
    STAssertNotNil(data.strokeObject, @"StrokeObject is nil");
    STAssertEqualObjects(data.strokeObject.color, [UIColor colorWithRrbaHex16:@"3DFF"], @"Color");

    STAssertNotNil(data.strokeObject.points, @"Points is nil");
    
    NSArray* originalPoints = shape[@"points"];
    STAssertEquals(originalPoints.count, data.strokeObject.points.count, @"Points count");
    if (originalPoints.count == data.strokeObject.points.count) {
        for (int i = 0; i < originalPoints.count; ++i) {
            NSDictionary* p = originalPoints[i];
            NSDictionary* p1 = (data.strokeObject.points)[i];
            STAssertEqualsWithAccuracy([p[@"x"] doubleValue] * size.width,
                                       [p1[@"X"] doubleValue],
                                       EPS,
                                       [NSString stringWithFormat:@"p[%d].X", i]);
            STAssertEqualsWithAccuracy([p[@"y"] doubleValue] * size.height,
                                       [p1[@"Y"] doubleValue],
                                       EPS,
                                       [NSString stringWithFormat:@"p[%d].Y", i]);
        }
    }
}

-(void)test_initWithShape_Line
{
    NSDictionary* shape =
    @{@"shape":@3,
      @"color":@"863F",
      @"start_time":@31415,
      @"end_time":@12917,
      @"points":
          @[@{@"x": @0.8000, @"y": @0.6000},
            @{@"x": @0.7632, @"y": @0.6013}]};
    
    STAssertNotNil(shape, @"shape is nil");
    
    CGSize size = CGSizeMake(1024, 768);
    MarkupData* data = [[MarkupData alloc] initWithShape:shape size:size];
    
    STAssertEquals(data.dataFormat, MarkupDataFormatXaml, @"DataFormat");
    STAssertEqualsWithAccuracy(data.actionTime, 31.415, EPS, @"ActionTime");
    STAssertEquals(data.drawingToolMode, ToolModeLine, @"DataFormat");
    STAssertNotNil(data.strokeObject, @"StrokeObject is nil");
    STAssertNotNil(data.strokeObject.points, @"Points is nil");
    STAssertEqualObjects(data.strokeObject.color, [UIColor colorWithRrbaHex16:@"863F"], @"Color");
}

@end
