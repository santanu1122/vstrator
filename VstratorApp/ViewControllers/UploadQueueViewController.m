//
//  UploadQueueViewController.m
//  VstratorApp
//
//  Created by Lion User on 25/07/2012.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "AccountController2.h"
#import "TabUploadQueueView.h"
#import "MediaService.h"
#import "UploadQueueViewController.h"
#import "VstratorConstants.h"
#import "VstratorStrings.h"

@interface UploadQueueViewController () <TabUploadQueueViewDelegate>

@property (nonatomic, weak) IBOutlet TabUploadQueueView *contentView;

@end

#pragma mark -

@implementation UploadQueueViewController

#pragma mark TabUploadQueueViewDelegate

- (void)tabUploadQueueView:(TabUploadQueueView *)sender uploadRequest:(UploadRequest *)uploadRequest action:(UploadRequestAction)action
{
    switch (action) {
        case UploadRequestActionRetry:
        {
            [self showBGActivityIndicator:VstratorStrings.UploadQueueRetryingActivityTitle];
            [[MediaService mainThreadInstance] retryUploading:uploadRequest callback:[self hideBGActivityCallback]];
            break;
        }
        case UploadRequestActionDelete:
        {
            NSError* error = nil;
            [MediaService.mainThreadInstance deleteObject:uploadRequest error:&error];
            if (error) {
                [self hideBGActivityIndicator:error];
            } else {
                [MediaService.mainThreadInstance saveChanges:[self hideBGActivityCallback]];
            }
            break;
        }
        case UploadRequestActionStop:
        {
            [[MediaService mainThreadInstance] stopUploading:uploadRequest callback:[self hideBGActivityCallback]];
            break;
        }
        default:
            break;
    }
}

#pragma mark Notifications

- (void)reloadContentView
{
    if (self.view != nil && self.contentView != nil)
        [self.contentView reload];
}

- (void)didReceiveUserIdentityChangedNotification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self reloadContentView];
    });
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [self reloadContentView];
}

#pragma mark Ctors/Dtors

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(didReceiveUserIdentityChangedNotification) name:VAUserIdentityChangedNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [NSNotificationCenter.defaultCenter removeObserver:self name:VAUserIdentityChangedNotification object:nil];
}

#pragma mark View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationBarView.title = self.title = VstratorStrings.TitleContentUploadQueue;
    self.navigationBarView.clipsToBounds = YES;
    self.contentView.autoresizingMask = UIViewAutoresizingNone;
}

- (void)viewDidUnload
{
    // Release any retained subviews of the main view.
    self.contentView = nil;
    // Super
    [super viewDidUnload];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [NSNotificationCenter.defaultCenter removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    [super viewDidDisappear:animated];
}

#pragma mark Orientations

- (BOOL)shouldAutorotate
{
    return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (void)rotate:(UIInterfaceOrientation)toInterfaceOrientation
{
    [super rotate:toInterfaceOrientation];
    self.contentView.frame = CGRectMake(0, self.navigationBarView.frame.size.height, self.view.bounds.size.width, self.view.bounds.size.height - self.navigationBarView.frame.size.height);
    //if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
    //    CGSize viewSize = self.viewSizeForLandscape;
    //    self.contentView.frame = CGRectMake(0, self.navigationBarView.frame.size.height, viewSize.width, viewSize.height - self.navigationBarView.frame.size.height);
    //} else {
    //    CGSize viewSize = self.viewSizeForPortrait;
    //    self.contentView.frame = CGRectMake(0, self.navigationBarView.frame.size.height, viewSize.width, viewSize.height - self.navigationBarView.frame.size.height);
    //}
}

@end
