//
//  MarkupData.h
//  VstratorApp
//
//  Created by akupr on 19.06.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum MarkupDataFormat
{
    MarkupDataFormatFrame = 0,
    MarkupDataFormatStroke = 1,
    MarkupDataFormatClear = 2,
    MarkupDataFormatXaml = 3,
    MarkupDataFormatHeader = 4,
    MarkupDataFormatIgnore = 5
} MarkupDataFormat;

typedef enum ToolMode
{
    ToolModeFreeHand = 0,
    ToolModeLine = 1,
    ToolModeRectangle = 2,
    ToolModeEllipse = 3,
    ToolModeArrow = 4
} ToolMode;

typedef enum ScreenMode
{
    ScreenModeNormal = 0,
    ScreenModeSplit = 1,
    ScreenModeOverlay = 2
} ScreenMode;

@class StrokeInfo, LayoutInfo;

@interface MarkupData : NSObject

@property (nonatomic) NSTimeInterval actionTime;
@property (nonatomic) NSTimeInterval markupTime; // deprecated
@property (nonatomic) ScreenMode appScreenMode;
@property (nonatomic) ToolMode drawingToolMode;
@property (nonatomic) MarkupDataFormat dataFormat;
@property (nonatomic) int showFrame;
@property (nonatomic) int inFrame;
@property (nonatomic) int outFrame;
@property (nonatomic, strong) LayoutInfo* primaryLayout;
@property (nonatomic, strong) LayoutInfo* secondaryLayout;
@property (nonatomic, strong) StrokeInfo* strokeObject;

-(id)initWithFrame:(NSDictionary*)frame;
-(id)initWithShape:(NSDictionary*)shape size:(CGSize)size;

@end
