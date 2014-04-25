//
//  MediaSourceSelector.m
//  VstratorApp
//
//  Created by Mac on 24.03.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "MediaSourceSelector.h"
#import "VstratorConstants.h"
#import "VstratorStrings.h"

@implementation MediaSourceSelector

#pragma mark - Properties

@synthesize delegate = _delegate;
@synthesize mediaTypes = _mediaTypes;

#pragma mark - Init

- (id)initWithDelegate:(id<MediaSourceSelectorDelegate>)delegate
{
    self = [super init];
    if (self) {
        self.delegate = delegate;
        self.mediaTypes = nil;
    }
    return self;
}

- (id)initWithDelegate:(id<MediaSourceSelectorDelegate>)delegate mediaTypes:(NSArray *)mediaTypes
{
    self = [super init];
    if (self) {
        self.delegate = delegate;
        self.mediaTypes = mediaTypes;
    }
    return self;
}

#pragma mark - Business Logic

- (BOOL)availableMediaTypesForSourceType:(UIImagePickerControllerSourceType)sourceType
{
    if (self.mediaTypes == nil || self.mediaTypes.count <= 0)
        return YES;
    NSArray *availableMediaTypes = [UIImagePickerController availableMediaTypesForSourceType:sourceType];
    if (availableMediaTypes == nil || availableMediaTypes.count <= 0)
        return NO;
    for (NSString *mediaType in self.mediaTypes) {
        if (!([availableMediaTypes containsObject:mediaType]))
            return NO;
    }
    return YES;
}

- (void)showWithPreferable:(MediaSourcePreferable)preferable
{
    BOOL cameraIsAvailable = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] && [self availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
    BOOL libraryIsAvailable = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary] && [self availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    
    switch (preferable) {
        case MediaSourcePreferableCamera:
            if (cameraIsAvailable) [self showCamera];
            return;
        case MediaSourcePreferableLibrary:
            if (libraryIsAvailable) [self showLibrary];
            return;
        default:
            break;
    }
    
    if (cameraIsAvailable && libraryIsAvailable) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:VstratorStrings.HomeCaptureClipDialogTitle delegate:self cancelButtonTitle:VstratorStrings.HomeCaptureClipCloseButtonTitle destructiveButtonTitle:nil otherButtonTitles:VstratorStrings.HomeCaptureClipUseCameraButtonTitle, VstratorStrings.HomeCaptureClipPickFromLibraryButtonTitle, nil];
        [actionSheet showInView:self.delegate.view];
    }
    else if (cameraIsAvailable) {
        [self showCamera];
    }
    else if (libraryIsAvailable) {
        [self showLibrary];
    }
    else {
        [[[UIAlertView alloc] initWithTitle:VstratorStrings.ErrorGenericTitle message:VstratorStrings.ErrorNoMediaSourcesAvailableText delegate:nil cancelButtonTitle:VstratorConstants.GenericCloseActionName otherButtonTitles:nil] show];
    }
}

- (void)showCamera
{
    [self.delegate mediaSourceSelector:self selected:YES type:UIImagePickerControllerSourceTypeCamera];
}

- (void)showLibrary
{
    [self.delegate mediaSourceSelector:self selected:YES type:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    UIImagePickerControllerSourceType sourceType = buttonIndex == 0 ? UIImagePickerControllerSourceTypeCamera : UIImagePickerControllerSourceTypePhotoLibrary;
    BOOL selected = (buttonIndex == 0 || buttonIndex == 1);
    [self.delegate mediaSourceSelector:self selected:selected type:sourceType];
}

@end

