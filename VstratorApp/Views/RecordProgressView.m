//
//  RecordProgressView.m
//  VstratorApp
//
//  Created by user on 12.03.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "RecordProgressView.h"

#define FULL_RADIANS 6.28

@implementation RecordProgressView

@synthesize progress = _progress;

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    if (self.progress > 0) {
        UIBezierPath *path = [[UIBezierPath alloc] init];
        [path moveToPoint:CGPointMake(rect.size.width/2, rect.size.height/2)];
        [path addArcWithCenter:CGPointMake(rect.size.width/2, rect.size.height/2) radius:rect.size.width/2-1.0f startAngle:0 endAngle:(FULL_RADIANS * self.progress) clockwise:YES];
        UIColor *color = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.6f];
        [color setStroke];
        [color setFill];
        [path stroke];
        [path fill];
        [path closePath];
    }
}

@end
