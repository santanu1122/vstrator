//
//  TelestrationPlaybackBaseView.m
//  VstratorCore
//
//  Created by Admin1 on 23.08.13.
//  Copyright (c) 2013 OnTarget. All rights reserved.
//

#import "TelestrationPlaybackBaseView.h"
#import "TelestrationScrollableBaseView.h"
#import "VstratorConstants.h"

@interface TelestrationPlaybackBaseView() <UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) TelestrationScrollableBaseView *scrollableView;

@end

@implementation TelestrationPlaybackBaseView

#pragma mark TelestrationPlaybackViewProtocol

- (void)seekToStart
{
}

- (void)setViewsToNil
{
}

- (void)pause
{
}

- (void)play
{
}

- (void)seekToNextFrame
{
}

- (void)seekToPrevFrame
{
}

- (void)seekToNextFrameContinuously
{
}

- (void)seekToPrevFrameContinuously
{
}

- (void)seekToSliderPosition:(BOOL)isLastPosition
{
}

- (void)flipCurrentFrame
{
}

- (void)setCurrentFrameZoom:(float)zoom contentOffset:(CGPoint)offset
{
    self.scrollView.zoomScale = zoom;
    self.scrollView.contentOffset = offset;
}

- (void)savePlayerTime
{
}

- (void)restorePlayerTime
{
}

#pragma mark TelestrationPlaybackBaseView

- (FrameTransform *)currentFrameTransform
{
    return [FrameTransform frameTransformWith:self.scrollableView.viewTransform
                                contentOffset:self.scrollView.contentOffset
                                    zoomScale:self.scrollView.zoomScale];
}

- (void)setCurrentFrameTransform:(FrameTransform *)currentFrameTransform
{
    [self setCurrentFrameTransform:currentFrameTransform animated:YES];
}

- (void)setCurrentFrameTransform:(FrameTransform *)currentFrameTransform animated:(BOOL)animated
{
    if (!currentFrameTransform) return;
    self.scrollableView.viewTransform = currentFrameTransform.transform;
    [self.scrollView setZoomScale:currentFrameTransform.zoomScale animated:animated];
    [self.scrollView setContentOffset:currentFrameTransform.contentOffset animated:animated];
}

- (UIScrollView *)scrollView
{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        _scrollView.minimumZoomScale = VstratorConstants.TelestrationMinimumZoomScale;
        _scrollView.maximumZoomScale = VstratorConstants.TelestrationMaximumZoomScale;
        _scrollView.delegate = self;
        _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return _scrollView;
}

- (void)callDelegateDidChange
{
    if ([self.delegate respondsToSelector:@selector(telestrationPlaybackViewDidChange:)])
        [self.delegate telestrationPlaybackViewDidChange:self];
}

#pragma mark UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.scrollableView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    CGFloat width = self.scrollView.bounds.size.width;
    CGFloat height = self.scrollView.bounds.size.height;
    CGFloat contentWidth = self.scrollView.contentSize.width;
    CGFloat contentHeight = self.scrollView.contentSize.height;
    
    CGFloat offsetX = (width > contentWidth) ? (width - contentWidth) * 0.5 : 0.0;
    CGFloat offsetY = (height > contentHeight) ? (height - contentHeight) * 0.5 : 0.0;
    
    self.scrollableView.center = CGPointMake(contentWidth * 0.5 + offsetX, contentHeight * 0.5 + offsetY);
}

#pragma mark Setup

- (void)setup
{
    self.backgroundColor = UIColor.blackColor;
    
    [self.scrollView addSubview:self.scrollableView];
    [self addSubview:self.scrollView];
    
    UIRotationGestureRecognizer *rotationRecognizer = [[UIRotationGestureRecognizer alloc] initWithTarget:self.scrollableView action:@selector(rotate:)];
    [rotationRecognizer setDelegate:self.scrollableView];
    [self.scrollableView addGestureRecognizer:rotationRecognizer];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)dealloc
{
    self.scrollView.delegate = nil;
}

@end
