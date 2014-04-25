//
//  LayoutInfo.m
//  VstratorApp
//
//  Created by akupr on 19.06.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "LayoutInfo.h"

@implementation LayoutInfo

@synthesize imageIndex = _imageIndex;
@synthesize left = _left;
@synthesize top = _top;
@synthesize width = _width;
@synthesize height = _height;
@synthesize rotation = _rotation;
@synthesize clipKey = _clipKey;
@synthesize opacity = _opacity;

-(id)init
{
    self = [super init];
    if (self) {
        [self setupDefaults];
    }
    return self;
}

-(void)setupDefaults
{
    self.rotation = 0;
    self.opacity = 1.;
}

@end
