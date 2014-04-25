//
//  FreehandTelestrationShapeView.h
//  VstratorApp
//
//  Created by user on 12.03.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseTelestrationShapeView.h"

@interface FreehandTelestrationShapeView : BaseTelestrationShapeView 

@property (strong, nonatomic, readonly) NSMutableArray *points;

- (void)addPoint:(CGPoint) point;

@end
