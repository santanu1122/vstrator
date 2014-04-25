//
//  LogoViewController.m
//  VstratorApp
//
//  Created by Mac on 11.03.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "LogoViewController.h"
#import "VstratorConstants.h"

@interface LogoViewController () {
    BOOL _didLogoAction;
    BOOL _didShowIntro;
    BOOL _shouldShowIntro;
}

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;

@end

#pragma mark -

@implementation LogoViewController

#pragma mark Properties

- (BOOL)statusBarHidden
{
    return YES;
}

#pragma mark Business Logic

- (IBAction)logoButtonPressed:(id)sender
{
    if (_didLogoAction)
        return;
    _didLogoAction = YES;
    if ([self.delegate respondsToSelector:@selector(logoViewControllerDidLogo:)])
        [self.delegate logoViewControllerDidLogo:self];
}

- (void)logoButtonTimeout
{
    [self performSelectorOnMainThread:@selector(logoButtonPressed:) withObject:nil waitUntilDone:NO];
}

#pragma mark Intro

- (BOOL)shouldShowIntro
{
#if TARGET_IPHONE_SIMULATOR
    return NO;
#else
    return [NSFileManager.defaultManager fileExistsAtPath:VstratorConstants.AppIntroMoviePath];
#endif
}

- (void)launchIntro
{
    // set launched status
    _didShowIntro = YES;
    _shouldShowIntro = NO;
    // delayed launch
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.mediaPlayerManager presentPlayerWithURL:[NSURL fileURLWithPath:VstratorConstants.AppIntroMoviePath] introMode:YES animated:NO];
        [self hideBlackoutView];
    });
}

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationBarView.hidden = YES;
    if (VstratorConstants.ScreenOfPlatform5e) {
        UIImage *sourceLogoImage = [UIImage imageNamed:@"Default-568h@2x"];
        if (sourceLogoImage != nil)
            self.backgroundImageView.image = [[UIImage alloc] initWithCGImage:sourceLogoImage.CGImage scale:2.0 orientation:UIImageOrientationUp];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // Intro
    _shouldShowIntro = !_didShowIntro && [self shouldShowIntro];
    if (_shouldShowIntro)
        [self showBlackoutView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // Intro/Logo
    if (_shouldShowIntro) {
        [self launchIntro];
    } else {
        [self performSelector:@selector(logoButtonTimeout) withObject:nil afterDelay:3.0];
    }
}

- (void)viewDidUnload
{
    [self setBackgroundImageView:nil];
    [super viewDidUnload];
}

@end
