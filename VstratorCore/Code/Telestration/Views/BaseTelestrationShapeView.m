//
//  BaseTelestrationShapeView.m
//  VstratorApp
//
//  Created by user on 12.03.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "BaseTelestrationShapeView.h"
#import "UIColor+Extensions.h"

@implementation BaseTelestrationShapeView

@synthesize color = _color;
@synthesize startTime = _startTime;
@synthesize endTime = _endTime;
//@synthesize shape = _shape;
@synthesize lineWidth = _lineWidth;

+ (TelestrationShapes)shape
{
    return TelestrationShapeRectangle;
}

- (void)setup
{
    self.color = [UIColor yellowColor];
    self.backgroundColor = nil;
    self.opaque = NO;
    self.startTime = 0;
    self.endTime = -1;
    //self.shape = 0;
    self.lineWidth = 3.0f;
    self.contentMode = UIViewContentModeRedraw;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithDictionary:(NSDictionary *)data
{
    self = [super init];
    if(self) {
        [self setup];
        [self load:data];
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    BaseTelestrationShapeView *t = [[self.class allocWithZone:zone] initWithFrame:CGRectZero];
    if (t) {
        t.frame = self.frame;
        t.color = self.color;
        t.backgroundColor = nil;
        t.opaque = NO;
        t.startTime = self.startTime;
        t.endTime = self.endTime;
        //t.shape = self.shape;
    }
    return t;
}

- (float)scaleX:(float)x byPercentage:(float)percentage
{
    float fromCenter = (x - self.superview.center.x) * percentage;
    return self.superview.center.x + fromCenter;
}

- (float)scaleY:(float)y byPercentage:(float)percentage
{   
    float fromCenter = (y - self.superview.center.y) * percentage;
    return self.superview.center.y + fromCenter;
}

- (void)scaleByPercentage:(float)percentage withNavBarHeight:(float)barHeight
{
    NSLog(@"Starting frame: %@", NSStringFromCGRect(self.frame));
    float endX = self.frame.origin.x + self.frame.size.width;
    float newEndX = [self scaleX:endX byPercentage:percentage];
    float newStartX = [self scaleX:self.frame.origin.x byPercentage:percentage];
    float newWidth = newEndX - newStartX;
    
    float endY = self.frame.origin.y + self.frame.size.height;
    float newEndY = [self scaleY:endY byPercentage:percentage] - (barHeight/2.0f);
    float newStartY = [self scaleY:self.frame.origin.y byPercentage:percentage] - (barHeight/2.0f);
    float newHeight = newEndY - newStartY;
    NSLog(@"Old Y: %f",self.frame.origin.y);
    NSLog(@"Old Height: %f",self.frame.size.height);
    NSLog(@"New Y: %f",newStartY);
    NSLog(@"New Height: %f",newHeight);
    self.frame = CGRectMake(newStartX, newStartY, newWidth, newHeight);
//    self.frame = CGRectMake([self scaleX:self.frame.origin.x byPercentage:percentage], self.frame.origin.y * percentage, self.frame.size.width *percentage, self.frame.size.height * percentage);
//    self.center = CGPointMake(self.center.x * percentage, self.center.y * percentage);
    NSLog(@"Ending frame: %@", NSStringFromCGRect(self.frame));
}

#pragma mark - Points utils

-(CGPoint)scaledPoint:(CGPoint)original forSize:(CGSize) size
{
	NSAssert(size.width > 0.00001 && size.height > 0.00001, @"Cannot scale view point");
	return CGPointMake(original.x / size.width, original.y / size.height);
}

-(CGPoint)originalPoint:(CGPoint)scaled forSize:(CGSize) size
{
	return CGPointMake(scaled.x * size.width, scaled.y * size.height);
}

-(NSDictionary *)pointToDictionary:(CGPoint)point
{
	return @{@"x": @(point.x),@"y": @(point.y)};
}

-(CGPoint)dictionaryToPoint:(NSDictionary *)dict
{
	return CGPointMake([dict[@"x"] floatValue], [dict[@"y"] floatValue]);
}

-(NSArray*)frameToScaledPointsArray:(CGSize)frameSize
{
	CGSize size = self.frame.size;
	CGPoint lt = self.frame.origin;
	CGPoint rt = CGPointMake(lt.x+size.width, lt.y);
	CGPoint rb = CGPointMake(lt.x+size.width, lt.y+size.height);
	CGPoint lb = CGPointMake(lt.x, lt.y+size.height);
	return @[[self pointToDictionary:[self scaledPoint:lt forSize:frameSize]],
			[self pointToDictionary:[self scaledPoint:rt forSize:frameSize]],
			[self pointToDictionary:[self scaledPoint:rb forSize:frameSize]],
			[self pointToDictionary:[self scaledPoint:lb forSize:frameSize]]];
}

#pragma mark - Time stuff

-(int)startTimeInMS
{
	return self.startTime * 1000;
}

-(void)setStartTimeInMS:(int)time
{
	self.startTime = (NSTimeInterval) time / 1000;
}

-(int)endTimeInMS
{
	return self.endTime < 0 ? -1 : self.endTime * 1000;
}

-(void)setEndTimeInMS:(int)time
{
	self.endTime = time == -1 ? -1. : (NSTimeInterval) time / 1000;
}

#pragma mark - Export/Import

- (NSDictionary *)exportWithSize:(CGSize)superviewSize
{
    NSNumber* shape = [NSNumber numberWithInt:self.class.shape];
    NSNumber* start = @(self.startTimeInMS);
    NSNumber* end = @(self.endTimeInMS);
	NSString* color = self.color.rgbaHex16;

    NSNumber* startX = @(self.frame.origin.x);
    NSNumber* startY = @(self.frame.origin.y);
    NSNumber* width = @(self.frame.size.width);
    NSNumber* height = @(self.frame.size.height);
	
	NSNumber* frameWidth = @(superviewSize.width);
	NSNumber* frameHeight = @(superviewSize.height);

    return @{@"shape": shape,
						  @"start_time": start,
						  @"end_time": end,
						  @"color": color,
						  @"left": startX,
						  @"top": startY,
						  @"width": width,
						  @"height": height,
						  @"frameWidth": frameWidth,
						  @"frameHeight": frameHeight};
}

- (void)load:(NSDictionary *)object
{
    NSAssert(self.class.shape == [object[@"shape"] intValue], @"Incompatible shape");

    
    self.startTimeInMS = [object[@"start_time"] intValue];
    self.endTimeInMS = [object[@"end_time"] intValue];

	self.frame = CGRectMake([object[@"left"] floatValue],
							[object[@"top"] floatValue],
							[object[@"width"] floatValue],
							[object[@"height"] floatValue]);

	self.color = [UIColor colorWithRrbaHex16:object[@"color"]];
}

@end
