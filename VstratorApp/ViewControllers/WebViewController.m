//
//  WebViewController.m
//  VstratorApp
//
//  Created by Virtualler on 27.09.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "WebViewController.h"
#import "VstratorExtensions.h"
#import "VstratorStrings.h"

@interface WebViewController () <UIWebViewDelegate>

@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *webActivityIndicatorView;
@property (nonatomic, weak) IBOutlet UIWebView *webView;

@end

#pragma mark -

@implementation WebViewController

#pragma mark NavigationBar

- (void)navigationBarView:(NavigationBarView *)sender action:(NavigationBarViewAction)action
{
    if (action == NavigationBarViewActionBack || action == NavigationBarViewActionHome) {
        [self hideWebActivityIndicators];
        [self dismissViewControllerAnimated:NO completion:^{
            if ([self.delegate respondsToSelector:@selector(webViewControllerDidClose:)])
                [self.delegate webViewControllerDidClose:self];
        }];
    } else {
        [super navigationBarView:sender action:action];
    }
}

#pragma mark UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self showWebActivityIndicators];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self hideWebActivityIndicators];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error0
{
    [self hideWebActivityIndicators];
    NSError *error1 = [NSError errorWithError:error0 text:VstratorStrings.ErrorUnableToOpenURL];
    [UIAlertViewWrapper alertError:error1];
}

#pragma mark Indicators

- (void)showWebActivityIndicators
{
    UIApplication.sharedApplication.networkActivityIndicatorVisible = YES;
    [self.webActivityIndicatorView startAnimating];
    self.webActivityIndicatorView.hidden = NO;
}

- (void)hideWebActivityIndicators
{
    UIApplication.sharedApplication.networkActivityIndicatorVisible = NO;
    self.webActivityIndicatorView.hidden = YES;
    [self.webActivityIndicatorView stopAnimating];
}

#pragma mark View Lifecycle

- (void)viewDidLoad
{
    // Super
    [super viewDidLoad];
    // Custom
    [self.view bringSubviewToFront:self.webActivityIndicatorView];
}

- (void)viewWillAppear:(BOOL)animated
{
    // Super
    [super viewWillAppear:animated];
    // Custom
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:self.url];
    [self.webView loadRequest:urlRequest];
}

- (void)viewDidUnload
{
    // Release any retained subviews of the main view.
    self.webView = nil;
    self.webActivityIndicatorView = nil;
    // Super
    [super viewDidUnload];
}

#pragma mark Orientation

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

@end
