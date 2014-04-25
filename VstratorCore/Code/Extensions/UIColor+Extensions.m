//
//  UIColor+Extensions.m
//  VstratorApp
//
//  Created by user on 27.05.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "UIColor+Extensions.h"

@implementation UIColor (Extensions)

- (BOOL)canProvideRGBComponents
{
	CGColorSpaceModel model = CGColorSpaceGetModel(CGColorGetColorSpace(self.CGColor));
	return model == kCGColorSpaceModelRGB || model == kCGColorSpaceModelMonochrome;
}

-(NSString *)rgbaHex16
{
	NSAssert([self canProvideRGBComponents], @"Must be a RGB color to use rgbHex");
	
	const CGFloat *components = CGColorGetComponents(self.CGColor);
	
	CGFloat r,g,b,a;
	
	CGColorSpaceModel model = CGColorSpaceGetModel(CGColorGetColorSpace(self.CGColor));
	switch (model) {
		case kCGColorSpaceModelMonochrome:
			r = g = b = components[0];
			a = components[1];
			break;
		case kCGColorSpaceModelRGB:
			r = components[0];
			g = components[1];
			b = components[2];
			a = components[3];
			break;
		default:	// We don't know how to handle this model
			return nil;
	}
	
#define NORMALIZE(x) ((uint)roundf(MIN(MAX((x), 0.f), 1.f) * 15))
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wshadow"

	uint hex = (NORMALIZE(r) << 12) | (NORMALIZE(g) << 8) | (NORMALIZE(b) << 4) | NORMALIZE(a);

#pragma GCC diagnostic pop
#undef NORMALIZE

	return [NSString stringWithFormat:@"%X", hex];
}

+(UIColor *)colorWithRrbaHex16:(NSString *)rgbaHex16
{
	uint rgbaHex;
	sscanf(rgbaHex16.UTF8String, "%X", &rgbaHex);
	
	CGFloat	red = ((rgbaHex >> 12) & 0xf)/15.f;
	CGFloat	green = ((rgbaHex >> 8) & 0xf)/15.f;
	CGFloat	blue = ((rgbaHex >> 4) & 0xf)/15.f;
	CGFloat	alpha = (rgbaHex & 0xf)/15.f;
    
	return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];

}


@end
