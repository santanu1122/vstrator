//
//  LineTelestration.m
//  VstratorApp
//
//  Created by user on 12.03.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "LineTelestrationShapeView.h"

@implementation LineTelestrationShapeView

@synthesize start = _start;
@synthesize end = _end;

+ (TelestrationShapes)shape
{
    return TelestrationShapeLine;
}

- (id)copyWithZone:(NSZone *)zone
{
    LineTelestrationShapeView *s = [super copyWithZone:zone];
    if (s) {
        s.start = self.start;
        s.end = self.end;
    }
    return s;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, self.lineWidth);
    CGContextSetStrokeColorWithColor(context, self.color.CGColor);
    CGContextMoveToPoint(context, self.start.x, self.start.y);
    CGContextAddLineToPoint(context, self.end.x, self.end.y);
    CGContextStrokePath(context);
}

- (void)setStart:(CGPoint)theStart
{
    _start = _end = theStart;
}

- (void)scaleByPercentage:(float)percentage withNavBarHeight:(float)barHeight
{
    self.frame = self.superview.frame;
    _start = CGPointMake([self scaleX:self.start.x byPercentage:percentage], [self scaleY:self.start.y byPercentage:percentage] - (barHeight/2.0f));
    _end = CGPointMake([self scaleX:self.end.x byPercentage:percentage], [self scaleY:self.end.y byPercentage:percentage] - (barHeight/2.0f));
//    [self setNeedsDisplay];
}

- (NSDictionary *)exportWithSize:(CGSize)superviewSize
{
    NSMutableDictionary *export = [NSMutableDictionary dictionaryWithDictionary:[super exportWithSize:superviewSize]];
    NSDictionary *startPoint = [self pointToDictionary:[self scaledPoint:self.start forSize:superviewSize]];
    NSDictionary *endPoint = [self pointToDictionary:[self scaledPoint:self.end forSize:superviewSize]];
	export[@"points"] = @[startPoint, endPoint];
    return export;
}

- (void)load:(NSDictionary *)object
{
    [super load:object];
	CGSize size = CGSizeMake([object[@"frameWidth"] floatValue], [object[@"frameHeight"] floatValue]);
	NSArray* points = object[@"points"];
    self.start = [self originalPoint:[self dictionaryToPoint:points[0]] forSize:size];
    self.end = [self originalPoint:[self dictionaryToPoint:points[1]] forSize:size];
}

@end
