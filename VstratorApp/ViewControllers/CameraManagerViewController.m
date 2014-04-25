//
//  CameraManagerViewController.m
//  VstratorApp
//
//  Created by Mac on 02.04.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "CameraManagerViewController.h"

#import "AccountController2.h"
#import "CameraViewController.h"
#import "FlurryLogger.h"
#import "ImageGenerationDispatcher.h"
#import "MediaPropertiesViewController.h"
#import "MediaService.h"
#import "MediaSourceSelector.h"
#import "TaskManager.h"
#import "VstratorExtensions.h"
#import "VstratorStrings.h"
#import "NSFileManager+Extensions.h"

#import <AssetsLibrary/ALAssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>
#import <MobileCoreServices/UTCoreTypes.h>

@interface CameraManagerViewController () <CameraViewControllerDelegate, MediaPropertiesViewControllerDelegate, MediaSourceSelectorDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
    BOOL _viewDidAppearOnce;
    BOOL _isRecordedClip;
}

@property (nonatomic, strong) MediaSourceSelector *mediaSourceSelector;
@property (nonatomic, copy) NSURL *clipFileURL;
@property (nonatomic, copy) NSURL *clipTempFileUrlQOrig;
@property (nonatomic, copy) NSURL *clipTempFileUrlQLow;
@property (nonatomic) UIImagePickerControllerSourceType clipSourceType;

@end

#pragma mark -

@implementation CameraManagerViewController

#pragma mark Navigation/Tab Bar

- (void)navigationBarView:(NavigationBarView *)sender action:(NavigationBarViewAction)action
{
    if (action == NavigationBarViewActionBack)
        [self removeClip];
    [super navigationBarView:sender action:action];
}

#pragma mark Dismiss methods

- (void)dismissWithCancel
{
    [self removeClip];
    [self dismissViewControllerAnimated:NO completion:^{
        if ([self.delegate respondsToSelector:@selector(cameraManagerViewControllerDidCancel:)])
            [self.delegate cameraManagerViewControllerDidCancel:self];
    }];
}

- (void)dismissWithClip:(Clip *)clip
{
    [self dismissWithClip:clip andAction:CameraManagerClipActionNon];
}

- (void)dismissWithClipAndVstrate:(Clip *)clip
{
    [self dismissWithClip:clip andAction:CameraManagerClipActionVstrate];
}

- (void)dismissWithClip:(Clip *)clip andAction:(CameraManagerClipAction)clipAction
{
    [self removeClip];
    //NOTE: do not animate here, as navigation transition with animation is expected in the delegate call
    [self dismissViewControllerAnimated:NO completion:^{
        if ([self.delegate respondsToSelector:@selector(cameraManagerViewControllerDidFinish:withLastClip:clipAction:)])
            [self.delegate cameraManagerViewControllerDidFinish:self withLastClip:clip clipAction:clipAction];
    }];
}

#pragma mark Media Operations

- (void)removeClipTempFiles
{
    NSURL *url = self.clipTempFileUrlQOrig;
    self.clipTempFileUrlQOrig = nil;
    [self removeClipTempFile:url];
    
    url = self.clipTempFileUrlQLow;
    self.clipTempFileUrlQLow = nil;
    [self removeClipTempFile:url];
}

- (void)removeClipTempFile:(NSURL*)fileUrl
{
    if (fileUrl != nil && fileUrl.path != nil && [NSFileManager.defaultManager fileExistsAtPath:fileUrl.path isDirectory:NO])
        [NSFileManager.defaultManager removeItemAtPath:fileUrl.path error:nil];
}

- (void)removeClip
{
    [self removeClipTempFiles];
    self.clipFileURL = nil;
    self.clipSourceType = UIImagePickerControllerSourceTypeCamera;
}

- (void)compressClip:(Clip *)clip saveSelector:(SEL)saveSelector
{
    [self showBGActivityIndicator:VstratorStrings.MediaClipSessionEditCompressingVideoMessage];
    [ImageGenerationDispatcher.sharedInstance addMediaToProcessing:clip];
    [self hideBGActivityCallback];
    if (saveSelector)
        [self performSelectorOnMainThread:saveSelector withObject:clip waitUntilDone:NO];
    return;
}

- (void)exportClipToPhotoLibrary:(Clip *)clip saveSelector:(SEL)saveSelector
{
    // create callback
    __weak CameraManagerViewController *blockSelf = self;
    Callback0 exportCallback = [^{ [blockSelf compressClip:clip saveSelector:saveSelector]; } copy];
    // process with export:
    if (self.clipSourceType == UIImagePickerControllerSourceTypeCamera) {
        ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
        if ([assetsLibrary videoAtPathIsCompatibleWithSavedPhotosAlbum:self.clipFileURL]) {
            [assetsLibrary writeVideoAtPathToSavedPhotosAlbum:self.clipFileURL completionBlock:^(NSURL *assetURL, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), exportCallback);
            }];
        } else {
            [self hideBGActivityIndicator:[NSError errorWithText:VstratorStrings.ErrorIncompatibleVideoType] withSelector:@selector(dismissWithCancel)];
        }
    } else {
        exportCallback();
    }
}

- (void)saveClipWithIdentity:(NSString *)identity title:(NSString *)title sportName:(NSString *)sportName actionName:(NSString *)actionName saveSelector:(SEL)saveSelector
{
    [MediaService.mainThreadInstance createClipWithURL:self.clipFileURL title:title sportName:sportName actionName:actionName note:nil authorIdentity:AccountController2.sharedInstance.userIdentity callback:^(NSError *error0, Clip *clip) {
        if (error0 == nil) {
            clip.identity = identity;
            [[NSUserDefaults standardUserDefaults] setObject:clip.action.sport.name forKey:RecentSportNameKey];
            [[NSUserDefaults standardUserDefaults] setObject:clip.action.name forKey:RecentActionNameKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [MediaService.mainThreadInstance saveChanges:^(NSError *error1) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (error1 == nil) {
                        NSDictionary *flurryLogParameters = @{ @"Duration": [FlurryLogger stringFromDouble:clip.duration.doubleValue] };
                        if (_isRecordedClip)
                            [FlurryLogger logTypedEvent:FlurryEventTypeVideoCapture withParameters:flurryLogParameters];
                        else
                            [FlurryLogger logTypedEvent:FlurryEventTypeVideoImport withParameters:flurryLogParameters];
                        [self exportClipToPhotoLibrary:clip saveSelector:saveSelector];
                    } else {
                        [self hideBGActivityIndicator:error1 withSelector:@selector(dismissWithCancel)];
                    }
                });
            }];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hideBGActivityIndicator:error0 withSelector:@selector(dismissWithCancel)];
            });
        }
    }];
}

- (void)prepareClipWithTitle:(NSString *)title sportName:(NSString *)sportName actionName:(NSString *)actionName saveSelector:(SEL)saveSelector
{
    [self showBGActivityIndicator:VstratorStrings.ProgressSavingVideo];

    if (![NSFileManager.defaultManager fileExistsAtPath:self.clipTempFileUrlQOrig.path isDirectory:NO]) {
        [self hideBGActivityIndicator:[NSError errorWithText:VstratorStrings.ErrorVideoFileDoesNotExists] withSelector:@selector(dismissWithCancel)];
        return;
    }

    NSError *error0 = nil;
    
    NSString *clipIdentity = [[NSProcessInfo processInfo] globallyUniqueString];
    self.clipFileURL = [Clip urlWithFileURL:self.clipTempFileUrlQOrig identity:clipIdentity];

    if (![NSFileManager.defaultManager moveItemAtURL:self.clipTempFileUrlQOrig toURL:self.clipFileURL error:&error0]) {
        [self hideBGActivityIndicator:error0 withSelector:@selector(dismissWithCancel)];
        return;
    }
    
    [[NSFileManager defaultManager] addSkipBackupAttributeToItemAtURL:self.clipFileURL error:&error0];
    if (error0) {
        NSLog(@"Cannot set skip backup attr for file '%@'", self.clipFileURL);
    }
    self.clipTempFileUrlQOrig = nil;

    if ([NSFileManager.defaultManager fileExistsAtPath:self.clipTempFileUrlQLow.path isDirectory:NO]) {
        NSURL *playbackQualityUrl = [NSURL fileURLWithPath:[Clip pathForPlaybackQualityForIdentity:clipIdentity]];
        if (![NSFileManager.defaultManager moveItemAtURL:self.clipTempFileUrlQLow toURL:playbackQualityUrl error:&error0]) {
            [NSFileManager.defaultManager removeItemAtURL:self.clipFileURL error:nil];
            [self hideBGActivityIndicator:error0 withSelector:@selector(dismissWithCancel)];
            return;
        }
        self.clipTempFileUrlQLow = nil;
    }
    
    [self saveClipWithIdentity:clipIdentity title:title sportName:sportName actionName:actionName saveSelector:saveSelector];
}

#pragma mark MediaSourceSelectorDelegate

- (void)mediaSourceSelector:(id)sender selected:(BOOL)selected type:(UIImagePickerControllerSourceType)sourceType
{
    if (!selected) {
        [self dismissWithCancel];
    } else if (sourceType == UIImagePickerControllerSourceTypeCamera) {
        [self showCamera];
    } else {
        [self showPhotoLibrary];
    }
}

#pragma mark MediaPropertiesViewControllerDelegate

- (void)mediaPropertiesViewControllerDidCancel:(MediaPropertiesViewController *)sender
{
    [self dismissWithCancel];
}

- (void)mediaPropertiesViewController:(MediaPropertiesViewController *)sender didAction:(MediaPropertiesAction)action
{
    SEL saveSelector = nil;
    switch (action)
    {
        case MediaPropertiesActionSaveAndRetry:
            saveSelector = @selector(showSourceSelectorWithPreferableCamera);
            break;
        case MediaPropertiesActionSaveAndUse:
            saveSelector = @selector(dismissWithClip:);
            break;
        case MediaPropertiesActionSaveAndVstrate:
            saveSelector = @selector(dismissWithClipAndVstrate:);
            break;
        default:
            [self removeClip];
            [self showSourceSelector];
            return;
    }
    [self prepareClipWithTitle:sender.mediaTitle sportName:sender.mediaSportName actionName:sender.mediaActionName saveSelector:saveSelector];
}

#pragma mark CameraViewControllerDelegate

- (void)cameraViewControllerDidCancel:(CameraViewController *)sender
{
    [self cameraDidCancel];
}

- (void)cameraViewControllerDidImport:(CameraViewController *)sender
{
    [self cameraDidImport];
}

- (void)cameraViewControllerDidCapture:(CameraViewController *)sender
                         videoUrlQOrig:(NSURL *)videoUrlQOrig
                          videoUrlQLow:(NSURL *)videoUrlQLow
{
    [self cameraDidCaptureWithTempFileUrlQOrig:videoUrlQOrig
                               tempFileUrlQLow:videoUrlQLow
                                    sourceType:UIImagePickerControllerSourceTypeCamera];
}

#pragma mark UIImagePickerControllerDelegate

- (NSArray *)imagePickerControllerRequiredMediaTypes:(BOOL)includeOptional
{
    if (includeOptional)
        return @[(NSString *)kUTTypeMovie, (NSString *)kUTTypeAudio];
    return @[(NSString *)kUTTypeMovie];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self cameraDidCancel];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSURL *tempFileURL = info[UIImagePickerControllerMediaURL];
    // load asset
    AVURLAsset *asset = [AVURLAsset assetWithURL:tempFileURL];
    if (asset == nil) {
        [picker dismissModalViewControllerAnimated:NO];
        [self showPhotoLibrary];
        return;
    }
    [asset loadValuesAsynchronouslyForKeys:@[@"duration"] completionHandler:^() {
        NSError *error = nil;
        AVKeyValueStatus tracksStatus = [asset statusOfValueForKey:@"duration" error:&error];
        dispatch_async(dispatch_get_main_queue(), ^{
            // process asset's duration
            switch (tracksStatus) {
                case AVKeyValueStatusLoaded: {
                    if (floor(CMTimeGetSeconds(asset.duration)) > VstratorConstants.ClipMaxDuration + 0.01) {
                        [self imagePickerDidFail:tempFileURL errorString:VstratorStrings.ErrorClipDurationExceedMaxText];
                    } else {
                        [self cameraDidCaptureWithTempFileUrlQOrig:tempFileURL
                                                   tempFileUrlQLow:nil
                                                        sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
                    }
                }
                    break;
                case AVKeyValueStatusFailed:
                case AVKeyValueStatusCancelled:
                default:
                    [self imagePickerDidFail:tempFileURL errorString:VstratorStrings.ErrorLoadingSelectedClip];
                    break;
            }
        });
    }];
}

- (void)imagePickerDidFail:(NSURL *)tempFileURL errorString:(NSString *)errorString
{
    // remove clip
    self.clipTempFileUrlQOrig = tempFileURL;
    [self removeClip];
    // show error & library
    UIAlertViewWrapper *wrapper = [UIAlertViewWrapper wrapperWithCallback:^(id result) {
        [self cameraDidImport];
    }];
    [wrapper alertString:errorString];
}

#pragma mark Camera Logic

- (void)showSourceSelector
{
    [self removeClip];
    [self.mediaSourceSelector showWithPreferable:MediaSourcePreferableNon];
}

- (void)showSourceSelectorWithPreferableCamera
{
    [self.mediaSourceSelector showWithPreferable:MediaSourcePreferableCamera];
}

- (void)showCamera
{
    _isRecordedClip = YES;
    CameraViewController *vc = [[CameraViewController alloc] init];
    vc.delegate = self;
    vc.videoMaximumDuration = VstratorConstants.ClipMaxDuration;
    vc.captureMode = CameraViewControllerCaptureModeVideo;
    [self presentViewController:vc animated:NO completion:nil];
}

- (void)showPhotoLibrary
{
    _isRecordedClip = NO;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        picker.mediaTypes = [self imagePickerControllerRequiredMediaTypes:YES];
        picker.allowsEditing = YES;
        picker.videoMaximumDuration = VstratorConstants.ClipMaxDuration;
        picker.videoQuality = UIImagePickerControllerQualityTypeIFrame1280x720;
        [self presentViewController:picker animated:YES completion:nil];
    } else {
        [UIAlertViewWrapper alertString:VstratorStrings.ErrorPhotoLibraryIsUnavailable title:@""];
        [self dismissWithCancel];
    }
}

- (void)cameraDidImport
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        [self dismissViewControllerAnimated:NO completion:nil];
        [self showPhotoLibrary];
    } else {
        [UIAlertViewWrapper alertString:VstratorStrings.ErrorPhotoLibraryIsUnavailable title:@""];
    }
}

- (void)cameraDidCancel
{
    [self dismissViewControllerAnimated:NO completion:nil];
    [self dismissWithCancel];
}

- (void)cameraDidCaptureWithTempFileUrlQOrig:(NSURL *)tempFileUrlQOrig
                             tempFileUrlQLow:(NSURL*)tempFileUrlQLow
                                  sourceType:(UIImagePickerControllerSourceType)sourceType
{
    // dismiss
    [self dismissViewControllerAnimated:NO completion:nil];
    // save media URL
    self.clipFileURL = nil;
    self.clipTempFileUrlQOrig = tempFileUrlQOrig;
    self.clipTempFileUrlQLow = tempFileUrlQLow;
    self.clipSourceType = sourceType;
    // properties
    UIViewController *vc = [[MediaPropertiesViewController alloc] initWithDelegate:self sourceURL:self.clipTempFileUrlQOrig];
    [self presentViewController:vc animated:NO completion:nil];
}

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:227 green:226 blue:226 alpha:1.0];
    self.mediaSourceSelector = [[MediaSourceSelector alloc] initWithDelegate:self mediaTypes:[self imagePickerControllerRequiredMediaTypes:NO]];
}

- (void)viewDidAppear:(BOOL)animated
{
    // Super
    [super viewDidAppear:animated];
    // Launch following processing only once
    if (_viewDidAppearOnce)
        return;
    _viewDidAppearOnce = YES;
    // Select media
#if !TARGET_IPHONE_SIMULATOR
    [self showSourceSelector];
    //[self showCamera];
#else
    // Emulator: ...file
    NSString *string = [NSHomeDirectory() stringByAppendingString:@"/Documents/video.mp4"];
    self.clipTempFileUrlQOrig = [NSURL fileURLWithPath:string];
    self.clipSourceType = UIImagePickerControllerSourceTypeCamera;
    // ...save
    UIViewController *vc = [[MediaPropertiesViewController alloc] initWithDelegate:self sourceURL:self.clipTempFileUrlQOrig];
    [self presentViewController:vc animated:NO completion:nil];
#endif
}

#pragma mark Orientations

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
