//
//  LayoutInfo.h
//  VstratorApp
//
//  Created by akupr on 19.06.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TransformInfo;

@interface LayoutInfo : NSObject

@property (nonatomic) int imageIndex;
@property (nonatomic) double left;
@property (nonatomic) double top;
@property (nonatomic) double width;
@property (nonatomic) double height;
@property (nonatomic) double rotation;
@property (nonatomic, copy) NSString* clipKey;
@property (nonatomic) double opacity;
@property (nonatomic) TransformInfo *transform;

@end
