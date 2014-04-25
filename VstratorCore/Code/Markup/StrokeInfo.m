//
//  StrokeInfo.m
//  VstratorApp
//
//  Created by akupr on 19.06.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "StrokeInfo.h"

@interface StrokeInfo()

@property (nonatomic, readonly) NSArray* colorComponents32ForColor;
@property (nonatomic, readonly) NSArray* colorComponents32ForOutlineColor;
@property (nonatomic, readonly) CGFloat width;
@property (nonatomic, readonly) CGFloat height;

@end

const CGFloat DefaultStrokeWidth = 3.;
const CGFloat DefaultStrokeHeight = 3.;

#define NORMALIZE(x) ((uint)roundf(MIN(MAX((x), 0.f), 1.f) * 255))

@implementation StrokeInfo

@synthesize size = _size;
@synthesize color = _color;
@synthesize outlineColor = _outlineColor;
@synthesize points = _points;

-(void)setupDefaults
{
    self.size = CGSizeMake(DefaultStrokeWidth, DefaultStrokeHeight);
    self.outlineColor = [UIColor colorWithRed:0. green:0. blue:0. alpha:0.];
}

-(id)init
{
    self = [super init];
    if (self) {
        [self setupDefaults];
    }
    return self;
}

-(NSArray *)colorComponents32:(UIColor*)color
{
    CGFloat r, g, b, a;
    [color getRed:&r green:&g blue:&b alpha:&a];
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wshadow"
    return @[@NORMALIZE(a),
            @NORMALIZE(r),
            @NORMALIZE(g),
            @NORMALIZE(b)];
#pragma GCC diagnostic pop
}

-(NSArray*)colorComponents32ForColor
{
    return [self colorComponents32:self.color];
}

-(NSArray*)colorComponents32ForOutlineColor
{
    return [self colorComponents32:self.outlineColor];
}

-(CGFloat)width
{
    return self.size.width;
}

-(CGFloat)height
{
    return self.size.height;
}

@end
