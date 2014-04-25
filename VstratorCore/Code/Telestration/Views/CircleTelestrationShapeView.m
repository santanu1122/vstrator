//
//  CircleTelestration.m
//  VstratorApp
//
//  Created by user on 12.03.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "CircleTelestrationShapeView.h"

@implementation CircleTelestrationShapeView

+ (TelestrationShapes)shape
{
    return TelestrationShapeCircle;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    CGRect smaller = CGRectMake(rect.origin.x + 5, rect.origin.y + 5, rect.size.width - 7, rect.size.height - 7);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, self.lineWidth);
    CGContextSetStrokeColorWithColor(context, self.color.CGColor);
    CGContextAddEllipseInRect(context, smaller);
    CGContextStrokePath(context);
}

- (NSDictionary *)exportWithSize:(CGSize)superviewSize
{
    NSMutableDictionary *export = [NSMutableDictionary dictionaryWithDictionary:[super exportWithSize:superviewSize]];
	export[@"points"] = [self frameToScaledPointsArray:superviewSize];
    return export;
}

@end
