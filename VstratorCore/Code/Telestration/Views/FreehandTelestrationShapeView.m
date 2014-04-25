//
//  FreehandTelestrationShapeView.m
//  VstratorApp
//
//  Created by user on 12.03.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "FreehandTelestrationShapeView.h"


@interface FreehandTelestrationShapeView()

@property (strong, nonatomic, readonly) UIBezierPath *path;
- (void)addPoint:(CGPoint) point;

@end


@implementation FreehandTelestrationShapeView

@synthesize path = _path;
@synthesize points = _points;

+ (TelestrationShapes)shape
{
    return TelestrationShapeFreehand;
}

- (void)setup
{
    [super setup];
    _points = [[NSMutableArray alloc] init];
    _path = [[UIBezierPath alloc] init];
    [self.path setLineWidth:self.lineWidth];
}

- (id)copyWithZone:(NSZone *)zone
{
    FreehandTelestrationShapeView *s = [super copyWithZone:zone];
    if (s) {
        [s.points addObject:(self.points)[0]];
        for (int i = 1; i < self.points.count; ++i) {
            [s addPoint:[(NSValue *)(self.points)[i] CGPointValue]];
        }
    }
    return s;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    [self.color setStroke];
    [self.path stroke];
}

- (void)addPoint:(CGPoint) point
{
    CGPoint p = [[self.points lastObject] CGPointValue];
    [self.path moveToPoint:p];
    [self.points addObject:[NSValue valueWithCGPoint:point]];
    [self.path addLineToPoint:point];
}

- (void)scaleByPercentage:(float)percentage withNavBarHeight:(float)barHeight
{
    [self.path removeAllPoints];
    self.frame = self.superview.frame;
    NSArray *temp = [[NSArray alloc] initWithArray:self.points copyItems:YES];
    [self.points removeAllObjects];
    CGPoint p = [temp[0] CGPointValue];
    p = CGPointMake([self scaleX:p.x byPercentage:percentage], [self scaleY:p.y byPercentage:percentage] - (barHeight/2.0f));
    [self.points addObject:[NSValue valueWithCGPoint:p]];
    for (int i = 1; i < temp.count; ++i) {
        p = [temp[i] CGPointValue];
        p = CGPointMake([self scaleX:p.x byPercentage:percentage], [self scaleY:p.y byPercentage:percentage] - (barHeight/2.0f));
        [self addPoint:p];
    }
    [self setNeedsDisplay];
}

- (NSDictionary *)exportWithSize:(CGSize)superviewSize
{
    NSMutableDictionary *export = [NSMutableDictionary dictionaryWithDictionary:[super exportWithSize:superviewSize]];
    NSMutableArray *pointArray = [NSMutableArray arrayWithCapacity:self.points.count];
    for (NSValue *v in self.points) {
        CGPoint p = [self scaledPoint:v.CGPointValue forSize:superviewSize];
        [pointArray addObject:[self pointToDictionary:p]];
    }
    export[@"points"] = pointArray;
    return export;
}

- (void)load:(NSDictionary *)object
{
    [super load:object];

	CGSize size = CGSizeMake([object[@"frameWidth"] floatValue], [object[@"frameHeight"] floatValue]);

    NSArray *oldPoints = object[@"points"];
    for (int i = 0; i < oldPoints.count; ++i) {
        NSDictionary *t = oldPoints[i];
        CGPoint p = [self originalPoint:[self dictionaryToPoint:t] forSize:size];
        if (i == 0) {
            [self.points addObject:[NSValue valueWithCGPoint:p]];
        } else {
            [self addPoint:p];
        }
//        [points addObject:[NSValue valueWithCGPoint:p]];         
    }
//    NSLog(@"Freehand Points: %@", points);
}
@end
