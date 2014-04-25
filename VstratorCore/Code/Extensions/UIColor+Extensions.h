//
//  UIColor+Extensions.h
//  VstratorApp
//
//  Created by user on 27.05.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Extensions)

- (BOOL)canProvideRGBComponents;

@property (nonatomic, readonly) NSString* rgbaHex16;

+(UIColor*) colorWithRrbaHex16:(NSString*)rgbaHex16;

@end
