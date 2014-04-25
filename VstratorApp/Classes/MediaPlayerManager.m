//
//  MediaPlayerManager.m
//  VstratorApp
//
//  Created by Virtualler on 29.08.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "MediaPlayerManager.h"
#import <MediaPlayer/MPMoviePlayerController.h>
#import <MediaPlayer/MPMoviePlayerViewController.h>
#import "UIAlertViewWrapper.h"
#import "VstratorStrings.h"

@interface MediaPlayerManager () {
    BOOL _introMode;
    BOOL _playerShown;
}

@property (nonatomic, strong) MPMoviePlayerController* moviePlayer;

@end

#pragma mark - MediaPlayerManager

@implementation MediaPlayerManager

#pragma mark Business Logic

- (void)presentPlayerWithURL:(NSURL *)url
                   introMode:(BOOL)introMode
                    animated:(BOOL)animated
{
    // Internal state
    _introMode = introMode;
    _playerShown = NO;
    // Initialize the movie player view controller with a video URL string
    MPMoviePlayerViewController *vc = [self safeMoviePlayerViewControllerWithContentURL:url];
    vc.moviePlayer.shouldAutoplay = YES;
    // Some prefs & vars
    if (_introMode)
        vc.moviePlayer.controlStyle = MPMovieControlStyleNone;
    self.moviePlayer = vc.moviePlayer;
    // Player Events
    [NSNotificationCenter.defaultCenter removeObserver:vc name:MPMoviePlayerPlaybackDidFinishNotification object:vc.moviePlayer];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(playerPlaybackDidFinish:) name:MPMoviePlayerPlaybackDidFinishNotification object:vc.moviePlayer];
    // Application Events
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(closePlayer) name:UIApplicationWillResignActiveNotification object:nil];
    // Present the movie player view controller
    self.delegate = self.viewController;
    [self.viewController presentViewController:vc animated:NO completion:nil];
    // State
    _playerShown = YES;
}

//
// Prevents generating a lot of error in the log console like this:
//
//    <Error>: CGContextSaveGState: invalid context 0x0
//
// see http://stackoverflow.com/a/14669166/1331118
//
-(MPMoviePlayerViewController*)safeMoviePlayerViewControllerWithContentURL:(NSURL*)url
{
    UIGraphicsBeginImageContext(CGSizeMake(1,1));
    MPMoviePlayerViewController *vc = [[MPMoviePlayerViewController alloc] initWithContentURL:url];
    UIGraphicsEndImageContext();
    return vc;
}

- (void)closePlayer
{
    // Application Events
    [NSNotificationCenter.defaultCenter removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    // Player Events
    [NSNotificationCenter.defaultCenter removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:self.moviePlayer];
    // Dismiss the view controller
    if (_playerShown) {
        _playerShown = NO;
        [self.viewController dismissModalViewControllerAnimated:NO];
    }
}

- (void)playerPlaybackDidFinish:(NSNotification*)notification
{
    // Obtain the reason why the movie playback finished
    NSNumber *finishReason = [notification userInfo][MPMoviePlayerPlaybackDidFinishReasonUserInfoKey];
    // Dismiss the view controller ONLY when the reason is not "playback ended"
    if (_introMode || finishReason.intValue != MPMovieFinishReasonPlaybackEnded) {
        [self closePlayer];
    }
    // Handle error
    if (!_introMode && finishReason.intValue == MPMovieFinishReasonPlaybackError) {
        NSError *error = [notification userInfo][@"error"];
        [UIAlertViewWrapper alertErrorOrString:error string:VstratorStrings.ErrorLoadingSelectedClip];
    }
    if ([self.delegate respondsToSelector:@selector(mediaPlayerManagerDidClosed:)])
        [self.delegate mediaPlayerManagerDidClosed:self];
}

@end
