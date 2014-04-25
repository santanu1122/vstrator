//
//  TelestrationScrollableVideoView.m
//  VstratorCore
//
//  Created by Admin on 31/01/2013.
//  Copyright (c) 2013 OnTarget. All rights reserved.
//

#import "TelestrationScrollableBaseView+Subclassing.h"
#import "TelestrationScrollableVideoView.h"

@interface TelestrationScrollableVideoView()

@property (nonatomic, strong) UIView *playerView;

@end

@implementation TelestrationScrollableVideoView

@synthesize viewTransform = _viewTransform;

- (UIView *)playerView
{
    if (!_playerView) {
        _playerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        _playerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return _playerView;
}

- (void)setImage:(UIImage *)image
{
    self.imageView.image = image;
    if (self.imageView.image) {
        if (!self.imageView.superview) {
            [self addSubview:self.imageView];
        }
    } else {
        [self.imageView removeFromSuperview];
    }
}

- (void)setPlayer:(AVPlayer *)player
{
    if (_player == player) return;
    _player = player;
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
    playerLayer.frame = self.playerView.frame;
    playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    [self.playerView.layer addSublayer:playerLayer];
}

- (void)setViewTransform:(CGAffineTransform)viewTransform
{
    _viewTransform = viewTransform;
    self.playerView.transform = self.imageView.transform = _viewTransform;
}

- (void)appendViewTransform:(CGAffineTransform)viewTransform
{
    self.viewTransform = CGAffineTransformConcat(self.viewTransform, viewTransform);
    self.playerView.transform = self.imageView.transform = self.viewTransform;
}

- (void)setup {
    [super setup];
    self.backgroundColor = UIColor.clearColor;
    _viewTransform = CGAffineTransformIdentity;
    [self imageView];
    [self addSubview:self.playerView];
}

@end
