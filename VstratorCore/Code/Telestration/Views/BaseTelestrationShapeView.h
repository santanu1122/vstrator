//
//  BaseTelestrationShapeView.h
//  VstratorApp
//
//  Created by user on 12.03.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TelestrationConstants.h"
#import "VstratorConstants.h"

@protocol TelestrationShapeProtocol <NSObject, NSCopying>

- (NSDictionary *)exportWithSize:(CGSize)superviewSize;
- (void)load:(NSDictionary *) object;
- (void)scaleByPercentage:(float)percentage withNavBarHeight:(float)barHeight;

@end


@interface BaseTelestrationShapeView : UIView<TelestrationShapeProtocol>

@property (nonatomic, strong) UIColor *color;
@property (nonatomic) NSTimeInterval startTime;
@property (nonatomic) NSTimeInterval endTime;
@property (nonatomic) float lineWidth;

+ (TelestrationShapes)shape;

- (void)setup;
- (id)initWithDictionary:(NSDictionary *) data;
- (id)copyWithZone:(NSZone *)zone;
- (float)scaleX:(float)x byPercentage:(float)percentage;
- (float)scaleY:(float)y byPercentage:(float)percentage;
- (NSDictionary *)exportWithSize:(CGSize)superviewSize;

-(CGPoint)originalPoint:(CGPoint)scaled forSize:(CGSize) size;
-(CGPoint)scaledPoint:(CGPoint)original forSize:(CGSize) size;
-(NSDictionary*)pointToDictionary:(CGPoint)point;
-(CGPoint)dictionaryToPoint:(NSDictionary*)dict;
-(NSArray*)frameToScaledPointsArray:(CGSize)frameSize;

@end



