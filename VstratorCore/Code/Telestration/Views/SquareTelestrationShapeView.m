//
//  SquareTelestrationShapeView.m
//  VstratorApp
//
//  Created by user on 12.03.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "SquareTelestrationShapeView.h"


@implementation SquareTelestrationShapeView

+ (TelestrationShapes)shape
{
    return TelestrationShapeRectangle;
}

- (void)setup
{
    [super setup];
    self.lineWidth = 6.0f;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, self.lineWidth);
    CGContextSetStrokeColorWithColor(context, self.color.CGColor);
    CGContextAddRect(context, rect);
    CGContextStrokePath(context);
}

- (NSDictionary *)exportWithSize:(CGSize)superviewSize
{
    NSMutableDictionary *export = [NSMutableDictionary dictionaryWithDictionary:[super exportWithSize:superviewSize]];
	export[@"points"] = [self frameToScaledPointsArray:superviewSize];
    return export;
}

@end
