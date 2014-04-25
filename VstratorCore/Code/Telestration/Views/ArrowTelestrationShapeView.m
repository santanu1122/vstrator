//
//  ArrowTelestrationShapeView.m
//  VstratorCore
//
//  Created by Admin on 01/02/2013.
//  Copyright (c) 2013 OnTarget. All rights reserved.
//

#import "ArrowTelestrationShapeView.h"

@implementation ArrowTelestrationShapeView

+ (TelestrationShapes)shape
{
    return TelestrationShapeArrow;
}

- (id)copyWithZone:(NSZone *)zone
{
    ArrowTelestrationShapeView *s = [super copyWithZone:zone];
    if (s) {
        s.start = self.start;
        s.end = self.end;
    }
    return s;
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    double length = 15.0;
    double width = 10.0;
    
    double slopy = atan2((self.start.y - self.end.y), (self.start.x - self.end.x));
    double cosy = cos(slopy);
    double siny = sin(slopy);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextMoveToPoint(context, self.end.x, self.end.y);
    CGContextAddLineToPoint(context,
                            self.end.x +  (length * cosy - ( width / 2.0 * siny )),
                            self.end.y +  (length * siny + ( width / 2.0 * cosy )));

    CGContextMoveToPoint(context, self.end.x, self.end.y);
    CGContextAddLineToPoint(context,
                            self.end.x +  (length * cosy + width / 2.0 * siny),
                            self.end.y -  (width / 2.0 * cosy - length * siny));
    
    CGContextStrokePath(context);
}

@end
