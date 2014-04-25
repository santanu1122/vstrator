//
//  TelestrationModel.m
//  VstratorApp
//
//  Created by user on 12.03.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "TelestrationModel.h"

#import "ArrowTelestrationShapeView.h"
#import "TelestrationConstants.h"
#import "CircleTelestrationShapeView.h"
#import "FreehandTelestrationShapeView.h"
#import "LineTelestrationShapeView.h"
#import "SquareTelestrationShapeView.h"

@implementation TelestrationModel

-(id) copy
{
    TelestrationModel *model = [[TelestrationModel alloc] init];
    for (BaseTelestrationShapeView *shape in self.stack)
        [model.stack addObject:[shape copy]];
    model.index = self.index;
    model.reverseIndex = self.reverseIndex;
    return model;
}

- (NSArray *)createExportWithSize:(CGSize)superviewSize
{
    NSMutableArray *objects = [[NSMutableArray alloc] initWithCapacity:self.stack.count];
    for (BaseTelestrationShapeView *t in self.stack) {
        [objects addObject:[t exportWithSize:superviewSize]];
    }
    return [NSArray arrayWithArray:objects];
}

- (void)load:(NSArray *) telestrations
{
    for (NSDictionary *t in telestrations) {
        BaseTelestrationShapeView *telestrationView = nil;
        switch ([t[@"shape"] intValue]) {
            case TelestrationShapeLine:
                telestrationView = [[LineTelestrationShapeView alloc] initWithDictionary:t];
                break;
            case TelestrationShapeArrow:
                telestrationView = [[ArrowTelestrationShapeView alloc] initWithDictionary:t];
                break;
            case TelestrationShapeCircle:
                telestrationView = [[CircleTelestrationShapeView alloc] initWithDictionary:t];
                break;
            case TelestrationShapeRectangle:
                telestrationView = [[SquareTelestrationShapeView alloc] initWithDictionary:t];
                break;
            case TelestrationShapeFreehand:
                telestrationView = [[FreehandTelestrationShapeView alloc] initWithDictionary:t];
                break;
        }
        [self push:telestrationView];
    }
}

@end
