//
//  MarkupDataCollection.m
//  VstratorApp
//
//  Created by akupr on 20.06.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <RestKit/RestKit.h>
#import <RestKit/ObjectMapping/RKObjectMappingOperationDataSource.h>

#import "MarkupData+Mapping.h"
#import "Media+Extensions.h"

#import "MarkupDataCollection.h"
#import "MarkupData.h"
#import "LayoutInfo.h"
#import "TransformInfo.h"

#import "Session+Extensions.h"
#import "Clip.h"

#import "TelestrationConstants.h"
#import "VstratorConstants.h"
#import "AVAsset+Extensions.h"

@interface MarkupDataCollection() {
    NSMutableArray* _markup;
    float _frameRate;
}

@end

@implementation MarkupDataCollection

@synthesize markup = _markup;

-(id)init
{
    self = [super init];
    if (self) {
        self.markup = [NSMutableArray new];
    }
    return self;
}

-(id)initWithSession:(Session*)session error:(NSError**)error
{
    self = [super init];
    if (self) {
        NSDictionary *telestrationData = [NSPropertyListSerialization propertyListWithData:session.telestrationData options:NSPropertyListImmutable format:nil error:error];
        if (*error) return nil;
//        CGSize size = CGSizeMake(session.width.intValue, session.height.intValue);
        self.markup = [NSMutableArray new];
        NSAssert(session.originalClip, @"Session has no originalClip");
        NSString* clipKey = session.originalClip.videoKey ? session.originalClip.videoKey : session.videoKey;
        if (!clipKey) {
            *error = [self makeErrorWithText:@"Internal program error. Error: originalClip.recordingKey is nil"];
            return nil;
        }
        CGSize clipSize = CGSizeMake(session.originalClip.width.intValue, session.originalClip.height.intValue);
        UIInterfaceOrientation orientation = [[AVURLAsset assetWithURL:[NSURL URLWithString:session.originalClip.url]] assetOrientation];
        NSString* clip2Key = nil;
        CGSize clip2Size = CGSizeZero;
        UIInterfaceOrientation orientation2 = orientation;
        if (session.isSideBySide) {
            if (!session.originalClip2) {
                *error = [self makeErrorWithText:@"Internal program error. Error: originalClip2 is nil"];
                return nil;
            }
            if (!session.originalClip2.videoKey) {
                *error = [self makeErrorWithText:@"Internal program error. Error: originalClip2.videoKey is nil"];
                return nil;
            }
            clip2Key = session.originalClip2.videoKey;
            clip2Size = CGSizeMake(session.originalClip2.width.intValue, session.originalClip2.height.intValue);
            orientation2 = [[AVURLAsset assetWithURL:[NSURL URLWithString:session.originalClip2.url]] assetOrientation];
        }
        [self loadFrames:telestrationData[@"frames"]
                 clipKey:clipKey clipSize:clipSize orientation:orientation
                clip2Key:clip2Key clip2Size:clip2Size orientation2:orientation2];
        _frameRate = TelestrationConstants.framesPerSecond;
        [self loadShapes:telestrationData[@"markup"]];
        [self sortMarkupByActionTime];
        if (session.isSideBySide) {
            for (MarkupData* data in self.markup) {
                data.appScreenMode = ScreenModeSplit;
            }
        }
    }
    return self;
}

-(NSError*)makeErrorWithText:(NSString*)text
{
    NSDictionary* dict = @{NSLocalizedDescriptionKey: text};
    return [NSError errorWithDomain:@"com.vstrator.MarkupDataCollection" code:-1 userInfo:dict];
}

-(void)sortMarkupByActionTime
{
    [_markup sortUsingDescriptors:@[[[NSSortDescriptor alloc] initWithKey:@"actionTime" ascending:YES]]];
}

-(void)loadShapes:(NSArray*)shapes
{
    CGSize size = CGSizeMake(VstratorConstants.MarkupScaleWidthForLandscape, VstratorConstants.MarkupScaleHeightForLandscape);
    for (NSDictionary* shape in shapes) {
        MarkupData* data = [[MarkupData alloc] initWithShape:shape size:size];
        data.inFrame = [self calcFrameByTime:[shape[@"start_time"] intValue]];
        data.outFrame = [self calcFrameByTime:[[shape valueForKey:@"end_time"] intValue]];
        [self add:data];
    }
}

-(void)loadFrames:(NSArray*)frames
          clipKey:(NSString*)clipKey
         clipSize:(CGSize)clipSize
      orientation:(UIInterfaceOrientation)orientation
         clip2Key:(NSString*)clip2Key
        clip2Size:(CGSize)clip2Size
    orientation2:(UIInterfaceOrientation)orientation2
{
    // Proceed
    for (NSDictionary* frame in frames) {
        MarkupData* data = [[MarkupData alloc] initWithFrame:frame];
        // Primary Layout
        LayoutInfo* layout = [[LayoutInfo alloc] init];
        layout.clipKey = clipKey;
        layout.imageIndex = data.showFrame;
        layout.rotation = [self orientation2rotation:orientation] + [self rotationFromFrameTransform:frame[@"transform"]];
        layout.transform = [self transformInfoFromFrameTransform:[self transformFromFrameTransform:frame[@"transform"]
                                                                            withOrientation:orientation]];
        [self updateLayout:layout clipSize:clipSize orientation:orientation sideBySide:clip2Key != nil frameTransform:frame[@"transform"]];
        data.primaryLayout = layout;
        //NSLog(@"loadFrames: primaryLayout: width %f, height %f", layout.width, layout.height);
        // Secondary layout
        if (clip2Key) {
            data.appScreenMode = ScreenModeSplit;
            NSNumber* index1 = frame[@"index1"];
            NSAssert(index1 && index1.intValue >= 0, @"Incorrect index1");
            layout = [[LayoutInfo alloc] init];
            layout.clipKey = clip2Key;
            layout.imageIndex = index1.intValue + 1;
            layout.rotation = [self orientation2rotation:orientation2] + [self rotationFromFrameTransform:frame[@"transform1"]];
            layout.transform = [self transformInfoFromFrameTransform:[self transformFromFrameTransform:frame[@"transform1"]
                                                                                       withOrientation:orientation2]];
            [self updateLayout:layout clipSize:clip2Size orientation:orientation2 sideBySide:clip2Key != nil frameTransform:frame[@"transform1"]];
            data.secondaryLayout = layout;
            //NSLog(@"loadFrames: secondaryLayout: width %f, height %f", layout.width, layout.height);
        }
        [self add:data];
    }
}

- (CGAffineTransform)transformFromFrameTransform:(NSDictionary *)frameTransform
                                 withOrientation:(UIInterfaceOrientation)orientation
{
    CGAffineTransform affineTransform = CGAffineTransformIdentity;
    if (frameTransform) affineTransform = CGAffineTransformFromString(frameTransform[@"transform"]);
    return CGAffineTransformRotate(affineTransform, [self orientation2rotation:orientation] * M_PI / 180);
}

- (TransformInfo *)transformInfoFromFrameTransform:(CGAffineTransform)transform
{
    TransformInfo *transformInfo = [[TransformInfo alloc] init];
    transformInfo.m11 = transform.a;
    transformInfo.m12 = transform.b;
    transformInfo.m21 = transform.c;
    transformInfo.m22 = transform.d;
    return transformInfo;
}

-(double)rotationFromFrameTransform:(NSDictionary *)frameTransform
{
    if (!frameTransform) return 0;
    CGAffineTransform transrorm = CGAffineTransformFromString(frameTransform[@"transform"]);
    return atan2(transrorm.b, transrorm.a) * 180 / M_PI;
}

-(double)orientation2rotation:(UIInterfaceOrientation)orientation
{
    switch (orientation) {
        case UIInterfaceOrientationPortrait:
            return 90;
        case UIInterfaceOrientationPortraitUpsideDown:
            return -90;
        case UIInterfaceOrientationLandscapeRight:
            return 180;
        default:
            return 0;
    }
}

-(void)updateLayout:(LayoutInfo*)layout
           clipSize:(CGSize)clipSize
        orientation:(UIInterfaceOrientation)orientation
         sideBySide:(BOOL)sideBySide
     frameTransform:(NSDictionary *)frameTransform
{
    if (!frameTransform) {
        frameTransform = @{ @"zoomScale": [NSNumber numberWithFloat:1],
                            @"contentOffset": NSStringFromCGPoint(CGPointMake(0, 0)) };
    }
    
    // fillSize is the size of the resulting view
    CGSize fillSize = CGSizeMake(VstratorConstants.MarkupScaleWidthForLandscape, VstratorConstants.MarkupScaleHeightForLandscape);
    if (sideBySide) fillSize.width /= 2;
    
    // Swap the size of the portret mode picture
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        CGFloat temp = clipSize.width;
        clipSize.width = clipSize.height;
        clipSize.height = temp;
    }

    // Calculate scale between clip size and layout
    double widthScale = fillSize.width / clipSize.width;
    double heightScale = fillSize.height / clipSize.height;
    double layoutScale = fmin(widthScale, heightScale);
    
    // zoomScale is the zoom of the frame in the iOS app
    float zoomScale = [frameTransform[@"zoomScale"] floatValue];

    // API operates with landscape clips only
    // portraitClipScale is the scale between landscape size and it`s portrait size
    double portraitClipScale = 1;
    if (UIInterfaceOrientationIsPortrait(orientation)){
        portraitClipScale = fillSize.height / fillSize.width;
    }
    
    // Calculate layout dimensions
    layout.width = round(clipSize.width * layoutScale * zoomScale * portraitClipScale);
    layout.height = round(clipSize.height * layoutScale * zoomScale * portraitClipScale);

    
    // contentOffset is the offset of the frame in the iOS app
    CGPoint contentOffset = CGPointFromString(frameTransform[@"contentOffset"]);

    // If size of the resulting image is less than the resulting view, center the image in the view
    if ((layout.width <= fillSize.width && layout.height <= fillSize.height) ||
        (layout.width <= fillSize.height && layout.height <= fillSize.width)) {
        layout.left = round((fillSize.width - layout.width) / 2);
        layout.top = round((fillSize.height - layout.height) / 2);
        return;
    }
    
    // Calculate scale between scroll view in the iOS app and the resulting view
    CGSize scrollViewSize = VstratorConstants.ScrollViewSizeForLandscape;
    if (sideBySide) scrollViewSize.width /= 2;
    double widthScrollScale = fillSize.width / scrollViewSize.width;
    double heightScrollScale = fillSize.height / scrollViewSize.height;
    
    // Calculate left and top of the layout
    layout.left = round((fillSize.width * zoomScale - fillSize.width) / 2 - (layout.width - fillSize.width) / 2 - contentOffset.x * widthScrollScale);
    layout.top = round((fillSize.height * zoomScale - fillSize.height) / 2 - (layout.height - fillSize.height) / 2 - contentOffset.y * heightScrollScale);
}

-(int)calcFrameByTime:(int)timeInMS
{
    if (timeInMS == -1) return -1;
    NSTimeInterval time = (NSTimeInterval) timeInMS / 1000;
    return time * _frameRate + 1;
}

-(void)add:(MarkupData *)data
{
    [_markup addObject:data];
}

-(NSArray*)serialize:(NSError**)error
{
    RKMappingOperation *operation = [[RKMappingOperation alloc] initWithSourceObject:self
                                                                   destinationObject:[NSMutableDictionary dictionary]
                                                                             mapping:[MarkupDataCollection mapping]];
    RKObjectMappingOperationDataSource* dataSource = [RKObjectMappingOperationDataSource new];
    operation.dataSource = dataSource;
    [operation performMapping:error];
    return *error ? nil : [operation.destinationObject objectForKey:@"markup"];
}

-(NSString *)asJSONString:(NSError**)error
{
    id array = [self serialize:error];
    if (array && !*error) {
        NSData* data = [NSJSONSerialization dataWithJSONObject:array options:0 error:error];
        if (data && !*error) {
            return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        }
    }
    return nil;
}

-(NSString *)asJSONString
{
    NSError* error = nil;
    return [self asJSONString:&error];
}

-(NSString *)description
{
    return [self asJSONString];
}

@end
