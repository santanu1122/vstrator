//
//  StrokeInfo.h
//  VstratorApp
//
//  Created by akupr on 19.06.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StrokeInfo : NSObject

@property (nonatomic) CGSize size;
@property (nonatomic, strong) UIColor* color;
@property (nonatomic, strong) UIColor* outlineColor;
@property (nonatomic, strong) NSArray* points;

@end
