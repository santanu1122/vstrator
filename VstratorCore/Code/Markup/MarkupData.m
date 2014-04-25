//
//  MarkupData.m
//  VstratorApp
//
//  Created by akupr on 19.06.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "MarkupData.h"
#import "StrokeInfo.h"
#import "LayoutInfo.h"

#import "TelestrationConstants.h"
#import "VstratorConstants.h"

#import "UIColor+Extensions.h"

@interface MarkupData()
@property (nonatomic, readonly) NSString* actionTimeSpan;
@property (nonatomic, readonly) NSString* markupTimeSpan;
@end

@implementation MarkupData

@synthesize actionTime = _actionTime;
@synthesize markupTime = _markupTime;
@synthesize appScreenMode = _appScreenMode;
@synthesize drawingToolMode = _drawingToolMode;
@synthesize dataFormat = _dataFormat;
@synthesize showFrame = _showFrame;
@synthesize inFrame = _inFrame;
@synthesize outFrame = _outFrame;
@synthesize primaryLayout = _primaryLayout;
@synthesize secondaryLayout = _secondaryLayout;
@synthesize strokeObject = _strokeObject;

- (void)setupDefaults
{
    self.OutFrame = -1;
    self.appScreenMode = ScreenModeNormal;
    self.markupTime = 0;
}

-(id)init
{
    self = [super init];
    if (self) {
        [self setupDefaults];
    }
    return self;
}

-(id)initWithFrame:(NSDictionary*)frame
{
    self = [super init];
    if (self) {
        [self setupDefaults];
        NSNumber* timeMs = frame[@"time"];
        self.actionTime = (NSTimeInterval) timeMs.intValue / 1000;
        NSNumber* index = frame[@"index"];
        self.showFrame = index.intValue + 1;
    }
    return self;
}

-(id)initWithShape:(NSDictionary*)shape size:(CGSize)size
{
    self = [super init];
    if (self) {
        [self setupDefaults];
        self.dataFormat = MarkupDataFormatXaml;
        NSNumber* number = shape[@"start_time"];
        self.actionTime = (NSTimeInterval) number.intValue / 1000;
        self.strokeObject = [[StrokeInfo alloc] init];
        self.DrawingToolMode = [self shapeToToolMode:[shape[@"shape"] intValue]];
        self.strokeObject.color = [UIColor colorWithRrbaHex16:shape[@"color"]];
        NSArray* originalPoints = shape[@"points"];
        NSMutableArray* points = [NSMutableArray new];
        for (NSDictionary* original in originalPoints) {
            double x = [original[@"x"] doubleValue] * size.width;
            double y = [original[@"y"] doubleValue] * size.height;
            NSDictionary* point = @{@"X": @(x),
                                   @"Y": @(y)};
            [points addObject:point];
        }
        self.strokeObject.points = points;
    }
    return self;
}

-(ToolMode)shapeToToolMode:(TelestrationShapes)shape
{
    switch (shape) {
        case TelestrationShapeLine:
            return ToolModeLine;
        case TelestrationShapeRectangle:
            return ToolModeRectangle;
        case TelestrationShapeCircle:
            return ToolModeEllipse;
        case TelestrationShapeArrow:
            return ToolModeArrow;
        case TelestrationShapeFreehand:
        default:
            return ToolModeFreeHand;
    }
}

-(NSString*)timeSpan:(NSTimeInterval)time
{
    int min = time / 60;
    NSString* s = [NSString stringWithFormat:@"%lg", time - min * 60];
    return min > 0 ? [NSString stringWithFormat:@"PT%dM%@S", min, s] : [NSString stringWithFormat:@"PT%@S", s];
}

-(NSString*)actionTimeSpan
{
    return [self timeSpan:self.actionTime];
}

-(NSString*)markupTimeSpan
{
    return [self timeSpan:self.markupTime];
}

@end
