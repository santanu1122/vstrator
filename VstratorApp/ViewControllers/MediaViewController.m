//
//  MediaViewController.m
//  VstratorApp
//
//  Created by Mac on 28.05.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "AccountController2.h"
#import "AvailableMediaInfoView.h"
#import "FlurryLogger.h"
#import "Media+Extensions.h"
#import "MediaInfoView.h"
#import "MediaPropertiesViewController.h"
#import "MediaService.h"
#import "MediaViewController.h"
#import "ServiceFactory.h"
#import "SideBySideEditorViewController.h"
#import "TelestrationEditorViewController.h"
#import "TelestrationPlayerViewController.h"
#import "UploadRequest.h"
#import "VstratorExtensions.h"
#import "VstratorStrings.h"
#import "ShareViewController.h"
#import "UIAlertViewWrapper.h"

#define kvaMediaInfoFrame CGRectMake(0, 260, 320, 200)

typedef enum {
    MediaInfoViewNone,
    MediaInfoTypeExist,
    MediaInfoTypeAvailable
} MediaInfoType;

@interface MediaViewController() <AvailableMediaInfoViewDelegate, MediaPropertiesViewControllerDelegate, TelestrationEditorViewControllerDelegate, MediaInfoViewDelegate> {
    BOOL _mediaUploadQueued;
    NSTimer *_uploadStateTimer;
    NSString *_userIdentityOnInit;
}

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (nonatomic, weak) IBOutlet UIImageView *thumbnailImageView;
@property (nonatomic, weak) IBOutlet UIView *thumbnailView;
@property (nonatomic, weak) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIButton *trashButton;
@property (weak, nonatomic) IBOutlet UIView *sessionLogoView;
@property (weak, nonatomic) IBOutlet UIImageView *sessionLogoImage;
@property (weak, nonatomic) IBOutlet UILabel *sessionLogoTitle;

@property (nonatomic) MediaAction mediaAction;
@property (nonatomic, strong, readonly) MediaInfoView *infoView;
@property (nonatomic, strong, readonly) AvailableMediaInfoView *availableInfoView;

@property (nonatomic) MediaInfoType mediaInfoType;

@end

#pragma mark -

@implementation MediaViewController

#pragma mark Properties

@synthesize infoView = _infoView;
@synthesize availableInfoView = _availableInfoView;
@synthesize media = _media;

- (MediaInfoView *)infoView
{
    if (self.mediaInfoType != MediaInfoTypeExist) return nil;
    if (!_infoView) {
        _infoView = [[MediaInfoView alloc] initWithFrame:kvaMediaInfoFrame];
        _infoView.delegate = self;
        [self.view addSubview:_infoView];
    }
    return _infoView;
}

- (AvailableMediaInfoView *)availableInfoView
{
    if (self.mediaInfoType != MediaInfoTypeAvailable) return nil;
    if (!_availableInfoView) {
        _availableInfoView = [[AvailableMediaInfoView alloc] initWithFrame:kvaMediaInfoFrame];
        _availableInfoView.delegate = self;
        [self.view addSubview:_availableInfoView];
    }
    return _availableInfoView;
}

#pragma mark MediaPropertiesViewControllerDelegate

- (void)mediaPropertiesViewController:(MediaPropertiesViewController *)sender didAction:(MediaPropertiesAction)action
{
    // Properties
    if (action == MediaPropertiesActionSave) {
        // ...save
        [self showBGActivityIndicator:VstratorStrings.MediaClipSessionEditSavingMediaActivityTitle];
        [MediaService.mainThreadInstance findActionWithName:sender.mediaActionName sportName:sender.mediaSportName callback:^(NSError *error0, Action *mediaAction) {
            if (error0 == nil) {
                [[NSUserDefaults standardUserDefaults] setObject:mediaAction.sport.name forKey:RecentSportNameKey];
                [[NSUserDefaults standardUserDefaults] setObject:mediaAction.name forKey:RecentActionNameKey];
                [[NSUserDefaults standardUserDefaults] synchronize];
                self.media.title = sender.mediaTitle;
                self.media.action = mediaAction;
                self.media.note = sender.mediaNote;
                [MediaService.mainThreadInstance saveChanges:^(NSError *error1) {
                    [self hideBGActivityIndicator:error1];
                    [self loadMedia];
                }];
            } else {
                [self hideBGActivityIndicator:error0];
            }
        }];
    } else if (action == MediaPropertiesActionDelete) {
        // ...delete
        NSError* error0 = nil;
        [MediaService.mainThreadInstance deleteObject:self.media error:&error0];
        if (error0) {
            [self hideBGActivityIndicator:error0];
        } else {
            [MediaService.mainThreadInstance saveChanges:[self hideBGActivityCallback:^(NSError *error) {
                if (error == nil) {
                    [self dismissWithMediaAction:MediaActionDelete];
                }
            }]];
        }
    }
}

#pragma mark TelestrationEditorViewControllerDelegate

- (void)showSession:(Media *)media
{
    [self dismissViewControllerAnimated:NO completion:^{
        if ([self.delegate respondsToSelector:@selector(mediaViewController:didSelectSession:)])
            [self.delegate mediaViewController:self didSelectSession:media];
    }];
}

- (void)telestrationEditorViewControllerDidSave:(TelestrationEditorViewController *)sender session:(Session *)session
{
    [self showSession:session];
}

#pragma mark AvailableMediaInfoViewDelegate

- (void)availableMediaInfoViewDownloadAction:(AvailableMediaInfoView *)sender
{
    [self dismissViewControllerAnimated:NO completion:^{
        [self.media.download addToDownloadQueue];
    }];
}

#pragma mark MediaInfoViewDelegate

- (void)mediaInfoView:(MediaInfoView *)sender didAction:(MediaAction)action
{
    switch (action)
    {
        case MediaActionDetails:
        {
            UIViewController *vc = [[MediaPropertiesViewController alloc] initWithDelegate:self sourceURL:[NSURL URLWithString:self.media.url] title:self.media.title sportName:self.media.action.sport.name actionName:self.media.action.name note:self.media.note vstrationMode:NO];
            [self presentViewController:vc animated:NO completion:nil];
            break;
        }
        case MediaActionTrim:
        {
            // intentionally left blank
            break;
        }
        case MediaActionVstrate:
        {
            [self vstrateClip];
            break;
        }
        case MediaActionSideBySide:
        {
            [self dismissWithMediaAction:MediaActionSideBySide];
            break;
        }
        case MediaActionUpload:
        case MediaActionUploadRetry:
        {
            __block __weak MediaViewController *blockSelf = self;
            [self.loginManager login:LoginQuestionTypeDialog callback:^(NSError *error, BOOL userIdentityChanged) {
                if (!userIdentityChanged && error == nil) {
                    [FlurryLogger logTypedEvent:FlurryEventTypeVideoUpload];
                    [blockSelf addMediaToUploadQueueOrRetry];
                }
            }];
            break;
        }
        case MediaActionStop:
        {
            [[MediaService mainThreadInstance] stopUploading:self.media.uploadRequest callback:^(NSError *error) {
                if (error == nil) {
                    [self updateUploadState];
                    [self startUploadTimerIfEnabled];
                } else {
                    [UIAlertViewWrapper alertError:error];
                }
            }];
            break;
        }
        case MediaActionUploading:
        {
            // intentionally left blank
            break;
        }
        case MediaActionUploaded:
        {
            // intentionally left blank
            break;
        }
        case MediaActionShare:
        {
            if (!self.media.alreadyUploadedAndProcessed)
                [UIAlertViewWrapper alertString:VstratorStrings.ErrorUploadThisVideoFirst title:@""];
            else {
                [[[ServiceFactory sharedInstance] createUploadService] updateMedia:self.media callback:^(NSError* error) {
                    if (error) {
                        [UIAlertViewWrapper alertError:[NSError errorWithError:error text:VstratorStrings.ErrorCannotShareMedia]];
                        return;
                    }
                    ShareViewController *vc = [[ShareViewController alloc] initWithNibName:NSStringFromClass(ShareViewController.class) bundle:nil];
                    vc.shareType = ShareTypeMedia;
                    vc.messageParameter = self.media.publicURL;
                    vc.mediaTitle = self.media.title;
                    [self presentModalViewController:vc animated:NO];
                }];
            }
            break;
        }
        default:
            break;
    }
}

- (void)vstrateClip
{
    [self.media performBlockIfClip:^(Clip *clip) {
        NSError *error = nil;
        UIViewController *vc = [[TelestrationEditorViewController alloc] initWithClip:clip delegate:self error:&error];
        if (error == nil) {
            [self presentViewController:vc animated:NO completion:nil];
        } else {
            [UIAlertViewWrapper alertError:error];
        }
    }];
}

- (void)addMediaToUploadQueueOrRetry
{
    if (!self.media.uploadRequest)
    {
        [MediaService.mainThreadInstance addMediaToUploadQueue:self.media withVisibility:UploadRequestVisibilityPublic callback:^(NSError *error) {
            if (error == nil) {
                [self updateUploadState];
                [self startUploadTimerIfEnabled];
            } else {
                [UIAlertViewWrapper alertError:error];
            }
        }];
    } else {
        [MediaService.mainThreadInstance retryUploading:self.media.uploadRequest callback:^(NSError *error) {
            if (error == nil) {
                [self updateUploadState];
                [self startUploadTimerIfEnabled];
            } else {
                [UIAlertViewWrapper alertError:error];
            }
        }];
    }
}

#pragma mark Business Logic

- (void)loadMedia
{
    // skip if views are not loaded
    if (self.view == nil)
        return;
    // fill fields
	self.thumbnailImageView.image = [UIImage imageWithData:self.media.thumbnail];
	// Permissions & Visibility
    [self.infoView setMedia:self.media userIdentity:AccountController2.sharedInstance.userIdentity];
    [self.availableInfoView setMedia:self.media];
    self.sessionLogoView.hidden = ![self.media isKindOfClass:Session.class];
    [self updateUploadState];
}

- (void)updateUploadState
{
    dispatch_async(dispatch_get_main_queue(), ^{
        _mediaUploadQueued = self.media.isInUploadQueueOrNotProcessed;
        [self.infoView updateUploadState];
    });
}

- (void)dismissWithMediaAction:(MediaAction)action
{
    [self dismissViewControllerAnimated:NO completion:^{
        if ([self.delegate respondsToSelector:@selector(mediaViewController:didAction:)])
            [self.delegate mediaViewController:self didAction:action];
    }];
}

- (void)dismissWithCancel
{
    [self dismissViewControllerAnimated:NO completion:^{
        if ([self.delegate respondsToSelector:@selector(mediaViewControllerDidCancel:)])
            [self.delegate mediaViewControllerDidCancel:self];
    }];
}

#pragma mark Upload State

- (void)reloadUploadState:(NSTimer *)timer
{
    [self updateUploadState];
    if (!_mediaUploadQueued)
        [self stopUploadTimer];
}

- (void)stopUploadTimer
{
    if (_uploadStateTimer != nil) {
        [_uploadStateTimer invalidate];
        _uploadStateTimer = nil;
    }
}

- (void)startUploadTimerIfEnabled
{
    // stop timer(s)
    [self stopUploadTimer];
    // start timer(s)
    if (_mediaUploadQueued) {
        _uploadStateTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(reloadUploadState:) userInfo:nil repeats:YES];
    }
}

#pragma mark Actions

- (IBAction)playAction:(id)sender
{
    [self playMedia:self.media];
}

#pragma mark UIApplicationDelegate

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [self.infoView animateUploadingIcon];
}

#pragma mark View Lifecycle

- (id)initWithDelegate:(id<MediaViewControllerDelegate>)delegate media:(Media *)media mediaAction:(MediaAction)mediaAction
{
    self = [super initWithNibName:NSStringFromClass(self.class) bundle:nil];
    if (self) {
        self.delegate = delegate;
        _media = media;
        self.mediaAction = mediaAction;
        _userIdentityOnInit = AccountController2.sharedInstance.userIdentity;
        self.mediaInfoType = !media.download || media.download.status.intValue != DownloadContentStatusNew
            ? MediaInfoTypeExist : MediaInfoTypeAvailable;
    }
    return self;
}

- (void)viewDidLoad
{
    // super
    [super viewDidLoad];
    // autoresizing
    self.thumbnailView.autoresizingMask = UIViewAutoresizingNone;
    self.infoView.autoresizingMask = UIViewAutoresizingNone;
    self.availableInfoView.autoresizesSubviews = UIViewAutoresizingNone;
    // media
    [self loadMedia];
    // session logo
    [self.sessionLogoTitle setTransform:CGAffineTransformMakeRotation(-M_PI / 2)];
    self.sessionLogoTitle.text = VstratorStrings.MediaClipSessionViewSessionLogoTitle;
}

//- (void)viewWillAppear:(BOOL)animated
//{
//    // Super
//    [super viewWillAppear:animated];
//    // Rotation
//    [self rotate:self.interfaceOrientation];
//}

- (void)viewDidAppear:(BOOL)animated
{
    switch (self.mediaAction) {
        case MediaActionPlay: {
            self.mediaAction = MediaActionNon;
            [self playAction:self.playButton];
            break;
        }
        case MediaActionVstrate: {
            self.mediaAction = MediaActionNon;
            [self vstrateClip];
            break;
        }
        default:
            break;
    }
    
    [super viewDidAppear:animated];
    
    // Dismiss if user identity is changed
    if (![AccountController2.sharedInstance.userIdentity isEqualToString:_userIdentityOnInit]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self dismissWithCancel];
        });
        return;
    }
    // Upload buttons state & timers
    [self updateUploadState];
    [self startUploadTimerIfEnabled];
    [self.view bringSubviewToFront:self.trashButton];
    // Application events
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    // Timer
    [self stopUploadTimer];
    // Super
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    // Application events
    [NSNotificationCenter.defaultCenter removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    // Super
    [super viewDidDisappear:animated];
}

- (void)viewDidUnload
{
    // Over
    self.backgroundImageView = nil;
    self.thumbnailImageView = nil;
    self.thumbnailView = nil;
    self.playButton = nil;
    self.trashButton = nil;
    self.sessionLogoTitle = nil;
    self.sessionLogoView = nil;
    self.sessionLogoImage = nil;
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

- (void)rotate:(UIInterfaceOrientation)toInterfaceOrientation
{
    [super rotate:toInterfaceOrientation];
    
    CGFloat navBarHeight = self.navigationBarView.frame.size.height;
    CGSize viewSize = self.view.bounds.size;
    
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
        CGFloat x = 10;
        CGFloat thumbnailWidth = VstratorConstants.ScreenOfPlatform5e ? 330 : 242;
        CGFloat infoHeight = 185;
        CGFloat thumbnailHeight = VstratorConstants.ScreenOfPlatform5e ? infoHeight : 136;
        CGFloat y = navBarHeight + (viewSize.height - navBarHeight - infoHeight) / 2;
        self.thumbnailView.frame = CGRectMake(x, y, thumbnailWidth, thumbnailHeight);
        self.infoView.frame = self.availableInfoView.frame = CGRectMake(2 * x + thumbnailWidth,
                                                                        y,
                                                                        viewSize.width - 3 * x - thumbnailWidth,
                                                                        infoHeight);
    }
    else {
        CGFloat x = 12;
        CGFloat width = 296;
        CGFloat thumbnailHeight = 167;
        CGFloat thumbnailY = navBarHeight + (VstratorConstants.ScreenOfPlatform5e ? 36 : 12);
        CGFloat infoY = thumbnailY + thumbnailHeight + 16;
        self.thumbnailView.frame = CGRectMake(x, thumbnailY, width, thumbnailHeight);
        self.infoView.frame = self.availableInfoView.frame = CGRectMake(x, infoY, width, viewSize.height - infoY - 12);
    }
    // sessionLogo
    CGRect frame = self.sessionLogoImage.frame;
    frame.origin.y = self.sessionLogoView.frame.size.height / 2 + 50;
    self.sessionLogoImage.frame = frame;
    frame = self.sessionLogoTitle.frame;
    frame.origin.y = self.sessionLogoView.frame.size.height / 2 - 65;
    self.sessionLogoTitle.frame = frame;
}

@end
