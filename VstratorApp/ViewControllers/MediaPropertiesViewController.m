//
//  MediaPropertiesViewController.m
//  VstratorApp
//
//  Created by Mac on 16.07.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "MediaPropertiesViewController.h"

#import "AccountController2.h"
#import "FlurryLogger.h"
#import "Media+Extensions.h"
#import "SportActionController.h"
#import "VstratorExtensions.h"
#import "VstratorStrings.h"

#import <AssetsLibrary/ALAssetsLibrary.h>
#import <MobileCoreServices/UTCoreTypes.h>

NSString* RecentSportNameKey = @"RecentSportName";
NSString* RecentActionNameKey = @"RecentActionName";

@interface MediaPropertiesViewController () <UITextFieldDelegate, UITextViewDelegate> {
    NSString *_userIdentityOnInit;
}

@property (nonatomic, weak) IBOutlet UIImageView *backgroundImageView;
@property (nonatomic, weak) IBOutlet UIView *thumbnailView;
@property (nonatomic, weak) IBOutlet UIImageView *thumbnailImageView;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UITextField *titleTextField;
@property (nonatomic, weak) IBOutlet UILabel *sportLabel;
@property (nonatomic, weak) IBOutlet UITextField *sportTextField;
@property (nonatomic, weak) IBOutlet UILabel *actionLabel;
@property (nonatomic, weak) IBOutlet UITextField *actionTextField;
@property (nonatomic, weak) IBOutlet UILabel *noteLabel;
@property (nonatomic, weak) IBOutlet UITextView *noteTextView;
@property (nonatomic, weak) IBOutlet UIButton *cancelButton;
@property (nonatomic, weak) IBOutlet UIButton *playButton;
@property (nonatomic, weak) IBOutlet UIButton *deleteButton;
@property (nonatomic, weak) IBOutlet UIButton *deleteAndRetryButton;
@property (nonatomic, weak) IBOutlet UIButton *saveButton;
@property (nonatomic, weak) IBOutlet UIButton *saveAndUseButton;
@property (nonatomic, weak) IBOutlet UIButton *saveAndVstateButton;
@property (nonatomic, weak) IBOutlet UIButton *saveAndRetryButton;
@property (nonatomic, strong, readonly) SportActionController *sportActionController;
@property (nonatomic, weak) IBOutlet UIImageView *delimiterImageView;

@property (nonatomic) NSInteger mediaImportCounter;
@property (nonatomic, readonly) BOOL createMode;
@property (nonatomic, readonly) BOOL vstrationMode;

@end

@implementation MediaPropertiesViewController

#pragma mark Defines

#define kVAMediaImportCounter    @"VAMediaImportCounter"

#pragma mark Properties

@synthesize mediaTitle = _mediaTitle;
@synthesize mediaSportName = _mediaSportName;
@synthesize mediaActionName = _mediaActionName;
@synthesize mediaNote = _mediaNote;

- (NSInteger)mediaImportCounter
{
    return [NSUserDefaults.standardUserDefaults integerForKey:[kVAMediaImportCounter stringByAppendingString:AccountController2.sharedInstance.userIdentity]];
}

- (void)setMediaImportCounter:(NSInteger)mediaImportCounter
{
    [NSUserDefaults.standardUserDefaults setInteger:mediaImportCounter forKey:[kVAMediaImportCounter stringByAppendingString:AccountController2.sharedInstance.userIdentity]];
}

- (void)setMediaTitle:(NSString *)mediaTitle
{
    _mediaTitle = [NSString stringWithStringOrNil:mediaTitle];
}

- (void)setMediaSportName:(NSString *)mediaSportName
{
    _mediaSportName = [NSString stringWithStringOrNil:mediaSportName];
}

- (void)setMediaActionName:(NSString *)mediaActionName
{
    _mediaActionName = [NSString stringWithStringOrNil:mediaActionName];
}

- (void)setMediaNote:(NSString *)mediaNote
{
    _mediaNote = [NSString stringWithStringOrNil:mediaNote];
}

#pragma mark Navigation/Tab Bar

- (void)navigationBarView:(NavigationBarView *)sender action:(NavigationBarViewAction)action
{
    if (action == NavigationBarViewActionBack) {
        [self cancelAction:self.cancelButton];
    } else {
        [super navigationBarView:sender action:action];
    }
}

#pragma mark Business Logic

- (void)validateAndPopWithAction:(MediaPropertiesAction)action
{
    // preprocess input
    NSString *title = self.titleTextField.text;
    title = [NSString trimmedStringOrNil:title];
    if (self.noteTextView != nil)
        self.noteTextView.text = [NSString trimmedStringOrNil:self.noteTextView.text];
    // validate
    NSString *errorString = nil;
    if ([ValidationHelper validateTitle:title outputString:&errorString] && [ValidationHelper validateSelectedSport:self.sportActionController.selectedSportName outputString:&errorString] && [ValidationHelper validateSelectedAction:self.sportActionController.selectedActionName outputString:&errorString]) {
        self.mediaTitle = title;
        self.mediaSportName = self.sportActionController.selectedSportName;
        self.mediaActionName = self.sportActionController.selectedActionName;
        self.mediaNote = self.noteTextView.text;
        self.mediaImportCounter++;
        [self closeAndPopWithAction:action];
    } else {
        [UIAlertViewWrapper alertInvalidInputString:errorString];
    }
}

- (void)closeAndPopWithAction:(MediaPropertiesAction)action
{
    [self dismissViewControllerAnimated:NO completion:^{
        if ([self.delegate respondsToSelector:@selector(mediaPropertiesViewController:didAction:)])
            [self.delegate mediaPropertiesViewController:self didAction:action];
    }];
}

- (IBAction)cancelAction:(id)sender
{
    [self dismissViewControllerAnimated:NO completion:^{
        if ([self.delegate respondsToSelector:@selector(mediaPropertiesViewControllerDidCancel:)])
            [self.delegate mediaPropertiesViewControllerDidCancel:self];
    }];
}

- (IBAction)playAction:(id)sender
{
    [self.mediaPlayerManager presentPlayerWithURL:self.sourceURL introMode:NO animated:NO];
}

- (IBAction)deleteAction:(id)sender
{
    __block __weak MediaPropertiesViewController *blockSelf = self;
    UIAlertViewWrapper *wrapper = [UIAlertViewWrapper wrapperWithCallback:^(id result) {
        if ([result isKindOfClass:NSNumber.class] && ((NSNumber *)result).intValue == 1) {
            [blockSelf closeAndPopWithAction:MediaPropertiesActionDelete];
        }
    }];
    [wrapper showMessage:VstratorStrings.MediaClipSessionEditDoYouWantToDelete
                   title:VstratorStrings.MediaClipSessionEditDeleteClipButtonTitle
       cancelButtonTitle:VstratorStrings.MediaClipSessionEditNoButtonTitle
       otherButtonTitles:VstratorStrings.MediaClipSessionEditYesButtonTitle, nil];
}

- (IBAction)deleteAndRetryAction:(id)sender
{
    [self closeAndPopWithAction:MediaPropertiesActionDeleteAndRetry];
}

- (IBAction)saveAction:(id)sender
{
    [self validateAndPopWithAction:MediaPropertiesActionSave];
}

- (IBAction)saveAndUseAction:(id)sender
{
    [FlurryLogger logTypedEvent:FlurryEventTypeVideoSaveAndUse];
    [self validateAndPopWithAction:MediaPropertiesActionSaveAndUse];
}

- (IBAction)saveAndVstrateAction:(id)sender
{
    [FlurryLogger logTypedEvent:FlurryEventTypeVideoSaveAndVstrate];
    [self validateAndPopWithAction:MediaPropertiesActionSaveAndVstrate];
}

- (IBAction)saveAndRetryAction:(id)sender
{
    [FlurryLogger logTypedEvent:FlurryEventTypeVideoSaveAndRetry];
    [self validateAndPopWithAction:MediaPropertiesActionSaveAndRetry];
}

#pragma mark Internal Helpers

- (void)showBGActivityIndicatorForThumbnailImageView
{
    [self hideBGActivityIndicatorForThumbnailImageView];
    // vars
    CGFloat selfWidth = self.thumbnailImageView.bounds.size.width;
    CGFloat selfHeight = self.thumbnailImageView.bounds.size.height;
    // activity indicator
    UIActivityIndicatorView * activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityIndicator.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    activityIndicator.frame = CGRectOffset(activityIndicator.frame, 0.5 * (selfWidth - activityIndicator.frame.size.width), 0.5 * (selfHeight - activityIndicator.frame.size.height));
    activityIndicator.hidden = NO;
    [activityIndicator startAnimating];
    // label
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.25 * selfWidth, activityIndicator.frame.origin.y + activityIndicator.frame.size.height + 20, 0.5 * selfWidth, 20)];
    label.adjustsFontSizeToFitWidth = YES;
    label.autoresizingMask = activityIndicator.autoresizingMask;
    label.backgroundColor = [UIColor clearColor];
    label.hidden = NO;
    label.text = VstratorStrings.MediaClipPlaybackLoadingActivityTitle;
    label.textAlignment = UITextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    // view
    UIView *activityOverlayView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, selfWidth, selfHeight)];
    activityOverlayView.alpha = 0.8;
    activityOverlayView.autoresizesSubviews = YES;
    activityOverlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    activityOverlayView.backgroundColor = UIColor.blackColor;
    activityOverlayView.opaque = YES;
    activityOverlayView.userInteractionEnabled = NO;
    [activityOverlayView addSubview:activityIndicator];
    [activityOverlayView addSubview:label];
    // show
    [self.thumbnailImageView addSubview:activityOverlayView];
}

- (void)hideBGActivityIndicatorForThumbnailImageView
{
    for (UIView *view in self.thumbnailImageView.subviews) {
        if (view.superview != nil)
            [view removeFromSuperview];
    }
}

#pragma mark UITextFieldDelegate/UITextViewDelegate

- (void)setupTextFieldPopupView:(TextFieldPopupView *)textFieldPopupView
{
    [super setupTextFieldPopupView:textFieldPopupView];
    textFieldPopupView.backgroundImage = self.backgroundImageView.image;
    textFieldPopupView.titleColor = self.sportLabel.textColor;
    textFieldPopupView.flashScrollIndicatorsForTextView = YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField == self.titleTextField)
        [self.textFieldPopupView showWithTextField:textField andTitle:VstratorStrings.MediaClipSessionEditTitleLabel inView:self.view];
    return NO;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if (textView == self.noteTextView)
        [self.textFieldPopupView showWithTextView:textView andTitle:VstratorStrings.MediaClipSessionEditNotesLabel inView:self.view];
    return NO;
}

#pragma mark Ctor

- (void)setupWithDelegate:(id<MediaPropertiesViewControllerDelegate>)delegate sourceURL:(NSURL *)sourceURL createMode:(BOOL)createMode vstrationMode:(BOOL)vstrationMode
{
    self.delegate = delegate;
    self.sourceURL = sourceURL;
    _createMode = createMode;
    _vstrationMode = vstrationMode;
    _sportActionController = [[SportActionController alloc] init];
    _userIdentityOnInit = AccountController2.sharedInstance.userIdentity;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    NSString *nibName = [NSStringFromClass(self.class) stringByAppendingString:@"_Create"];
    self = [super initWithNibName:nibName bundle:nil];
    if (self) {
        [self setupWithDelegate:nil sourceURL:nil createMode:YES vstrationMode:NO];
    }
    return self;
}

- (id)initWithDelegate:(id<MediaPropertiesViewControllerDelegate>)delegate sourceURL:(NSURL *)sourceURL
{
    NSString *nibName = [NSStringFromClass(self.class) stringByAppendingString:@"_Create"];
    self = [super initWithNibName:nibName bundle:nil];
    if (self) {
        [self setupWithDelegate:delegate sourceURL:sourceURL createMode:YES vstrationMode:NO];
        NSString* sport = [NSUserDefaults.standardUserDefaults objectForKey:RecentSportNameKey];
        self.mediaSportName = sport ? sport : VstratorConstants.DefaultSportName;
        NSString* action = [NSUserDefaults.standardUserDefaults objectForKey:RecentActionNameKey];
        if (action) {
            self.mediaActionName = action;
        }
    }
    return self;
}

- (id)initWithDelegate:(id<MediaPropertiesViewControllerDelegate>)delegate sourceURL:(NSURL *)sourceURL title:(NSString *)title sportName:(NSString *)sportName actionName:(NSString *)actionName note:(NSString *)note vstrationMode:(BOOL)vstrationMode
{
    NSString *nibName = [NSStringFromClass(self.class) stringByAppendingString:@"_Edit"];
    self = [super initWithNibName:nibName bundle:nil];
    if (self) {
        [self setupWithDelegate:delegate sourceURL:sourceURL createMode:NO vstrationMode:vstrationMode];
        self.mediaTitle = title;
        self.mediaSportName = sportName;
        self.mediaActionName = actionName;
        self.mediaNote = note;
    }
    return self;
}

#pragma mark Localization

- (void)setLocalizableStrings
{
    [self.cancelButton setTitle:VstratorStrings.MediaClipSessionEditCancelButtonTitle forState:UIControlStateNormal];
    [self.deleteAndRetryButton setTitle:VstratorStrings.MediaClipSessionEditDeleteAndShootButtonTitle forState:UIControlStateNormal];
    [self.saveAndUseButton setTitle:VstratorStrings.MediaClipSessionEditSaveAndUseButtonTitle forState:UIControlStateNormal];
    [self.saveAndRetryButton setTitle:VstratorStrings.MediaClipSessionEditSaveAndShootButtonTitle forState:UIControlStateNormal];
    [self.saveButton setTitle:(self.vstrationMode ? VstratorStrings.MediaClipSessionViewDoneButtonTitle : VstratorStrings.MediaClipSessionViewSaveButtonTitle) forState:UIControlStateNormal];
    [self.titleLabel setText:VstratorStrings.MediaClipSessionEditTitleLabel];
    [self.titleTextField setPlaceholder:VstratorStrings.MediaClipSessionEditTitleLabel];
    [self.sportLabel setText:VstratorStrings.MediaClipSessionEditSportLabel];
    [self.actionLabel setText:VstratorStrings.MediaClipSessionEditActionLabel];
    [self.noteLabel setText:VstratorStrings.MediaClipSessionEditNotesLabel];
    [self.actionTextField setPlaceholder:VstratorStrings.MediaClipSessionEditActionLabel];
    [self.sportTextField setPlaceholder:VstratorStrings.MediaClipSessionEditSportLabel];
    if (self.vstrationMode) {
        self.navigationBarView.title = self.title = VstratorStrings.MediaClipSessionEditTitleVstrationMode;
    } else if (!self.createMode) {
        self.navigationBarView.title = self.title = VstratorStrings.MediaClipSessionEditTitleEditMode;
    }
}

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // localization
    [self setLocalizableStrings];
    // navigation bar
    self.navigationBarView.hidden = self.createMode;
    self.navigationBarView.showBack = self.vstrationMode;
    self.cancelButton.hidden = self.createMode || self.vstrationMode;
    // fields
    self.titleTextField.text = self.createMode ? [NSString stringWithFormat:@"%@'s Video %d", AccountController2.sharedInstance.userAccount.firstName, self.mediaImportCounter + 1] : self.mediaTitle;
    self.noteTextView.text = self.mediaNote;
    self.sportActionController.controllerView = self.view;
    self.sportActionController.sportTextField = self.sportTextField;
    self.sportActionController.actionTextField = self.actionTextField;
    self.sportActionController.selectedSportName = self.mediaSportName;
    self.sportActionController.selectedActionName = self.mediaActionName;
    // images
    self.actionTextField.background = [UIImage resizableImageNamed:@"bt-dropdown"];
    [self.actionTextField setLeftPadding:6];
    [self.actionTextField setRightPadding:30];
    self.sportTextField.background = [UIImage resizableImageNamed:@"bt-dropdown"];
    [self.sportTextField setLeftPadding:6];
    [self.sportTextField setRightPadding:30];
    [self.titleTextField setBorderColor:[UIColor colorWithWhite:0.07 alpha:1] borderWidth:1.0 cornerRadius:3];
    [self.titleTextField setShadowWithColor:[UIColor colorWithWhite:0.26 alpha:1] offset:CGSizeMake(0, 1.0)];
    [self.titleTextField setSidePaddings:10];
    if (self.createMode) {
        [self.cancelButton setBackgroundImage:[UIImage resizableImageNamed:@"bt-grey-n-black-01"] forState:UIControlStateNormal];
        [self.cancelButton setBackgroundImage:[UIImage resizableImageNamed:@"bt-black-01"] forState:UIControlStateHighlighted];
        [self.deleteAndRetryButton setBackgroundImage:[UIImage resizableImageNamed:@"bt-grey-n-black-01"] forState:UIControlStateNormal];
        [self.deleteAndRetryButton setBackgroundImage:[UIImage resizableImageNamed:@"bt-black-01"] forState:UIControlStateHighlighted];
        [self.saveAndVstateButton setBackgroundImage:[UIImage resizableImageNamed:@"bt-green-n-black-01"] forState:UIControlStateNormal];
        [self.saveAndVstateButton setBackgroundImage:[UIImage resizableImageNamed:@"bt-black-01"] forState:UIControlStateHighlighted];
//        [self.saveAndUseButton setBackgroundImage:[UIImage resizableImageNamed:@"bt-grey-n-black-02"] forState:UIControlStateNormal];
        [self.saveAndUseButton setBackgroundImage:[UIImage resizableImageNamed:@"bt-black-01"] forState:UIControlStateHighlighted];
    } else {
        [self.deleteButton setBackgroundImage:[UIImage resizableImageNamed:@"bt-grey-n-black-h69"] forState:UIControlStateNormal];
        [self.deleteButton setBackgroundImage:[UIImage resizableImageNamed:@"bt-black-01"] forState:UIControlStateHighlighted];
        [self.noteTextView setBorderColor:[UIColor colorWithWhite:0.07 alpha:1] borderWidth:1.0 cornerRadius:3];
        //[self.noteTextView setShadowWithColor:[UIColor colorWithWhite:0.26 alpha:1] offset:CGSizeMake(0, 1.0)];
        [self.saveButton setBackgroundImage:[UIImage resizableImageNamed:@"bt-grey-n-black-h69"] forState:UIControlStateNormal];
        [self.saveButton setBackgroundImage:[UIImage resizableImageNamed:@"bt-black-01"] forState:UIControlStateHighlighted];
        [self.cancelButton setBackgroundImage:[UIImage resizableImageNamed:@"bt-grey-n-black-h69"] forState:UIControlStateNormal];
        [self.cancelButton setBackgroundImage:[UIImage resizableImageNamed:@"bt-black-01"] forState:UIControlStateHighlighted];
    }
    // process media
    [self showBGActivityIndicatorForThumbnailImageView];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [Media processMediaWithURL:self.sourceURL callback:^(NSError *error, NSData *thumbnail, NSNumber *duration, NSString *url, CGSize size) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hideBGActivityIndicatorForThumbnailImageView];
                if (error == nil && thumbnail != nil)
                    self.thumbnailImageView.image = [UIImage imageWithData:thumbnail];
            });
        }];
    });
}

- (void)viewDidAppear:(BOOL)animated
{
    // Super
    [super viewDidAppear:animated];
    // Dismiss if user identity is changed
    if (![AccountController2.sharedInstance.userIdentity isEqualToString:_userIdentityOnInit]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self cancelAction:self.cancelButton];
        });
    }
    [self.view bringSubviewToFront:self.deleteButton];
}

- (void)viewDidUnload
{
    // Release any retained subviews of the main view.
    self.backgroundImageView = nil;
    self.thumbnailView = nil;
    self.thumbnailImageView = nil;
    self.titleTextField = nil;
    self.sportLabel = nil;
    self.sportTextField = nil;
    self.titleLabel = nil;
    self.actionLabel = nil;
    self.actionTextField = nil;
    self.noteTextView = nil;
    self.noteLabel = nil;
    self.cancelButton = nil;
    self.playButton = nil;
    self.deleteButton = nil;
    self.deleteAndRetryButton = nil;
    self.saveButton = nil;
    self.saveAndUseButton = nil;
    self.saveAndVstateButton = nil;
    self.saveAndRetryButton = nil;
    self.sportActionController.controllerView = nil;
    self.sportActionController.sportTextField = nil;
    self.sportActionController.actionTextField = nil;
    self.delimiterImageView = nil;
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
    return toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
}

- (void)rotate:(UIInterfaceOrientation)orientation
{
    [super rotate:orientation];
    if (self.createMode) {
        if (UIInterfaceOrientationIsLandscape(orientation)) {
            if (VstratorConstants.ScreenOfPlatform5e)
                [self rotateForCreateModeLandscape5e];
            else
                [self rotateForCreateModeLandscape4m];
        } else {
            if (VstratorConstants.ScreenOfPlatform5e)
                [self rotateForCreateModePortrait5e];
            else
                [self rotateForCreateModePortrait4m];
        }
    } else {
        if (UIInterfaceOrientationIsLandscape(orientation)) {
            if (VstratorConstants.ScreenOfPlatform5e)
                [self rotateForEditModeLandscape5e];
            else
                [self rotateForEditModeLandscape4m];
        } else {
            if (VstratorConstants.ScreenOfPlatform5e)
                [self rotateForEditModePortrait5e];
            else
                [self rotateForEditModePortrait4m];
        }
    }
    [self.sportActionController syncViews];
}

- (void)rotateForEditModeLandscape5e
{
    self.titleLabel.frame = CGRectMake(12, 62, self.titleLabel.frame.size.width, self.titleLabel.frame.size.height);
    self.titleTextField.frame = CGRectMake(12, 81, self.titleTextField.frame.size.width, self.titleTextField.frame.size.height);
    self.noteLabel.frame = CGRectMake(12, 132, self.noteLabel.frame.size.width, self.noteLabel.frame.size.height);
    self.noteTextView.frame = CGRectMake(12, 151, self.noteTextView.frame.size.width, 130);
    self.sportLabel.frame = CGRectMake(333, 145, self.sportLabel.frame.size.width, self.sportLabel.frame.size.height);
    self.sportTextField.frame = CGRectMake(383, 140, 168, self.sportTextField.frame.size.height);
    self.actionLabel.frame = CGRectMake(326, 195, self.actionLabel.frame.size.width, self.actionLabel.frame.size.height);
    self.actionTextField.frame = CGRectMake(383, 190, 168, self.actionTextField.frame.size.height);
    self.cancelButton.frame = CGRectMake(325, 280 - self.cancelButton.frame.size.height, 84, self.cancelButton.frame.size.height);
    if (self.vstrationMode)
        self.saveButton.frame = CGRectMake(383, 280 - self.saveButton.frame.size.height, 168, self.saveButton.frame.size.height);
    else
        self.saveButton.frame = CGRectMake(420, 280 - self.saveButton.frame.size.height, 130, self.saveButton.frame.size.height);
    //self.deleteButton.frame = CGRectMake(429, 4, self.deleteButton.frame.size.width, self.deleteButton.frame.size.height);
}

- (void)rotateForEditModeLandscape4m
{
    self.titleLabel.frame = CGRectMake(12, 62, self.titleLabel.frame.size.width, self.titleLabel.frame.size.height);
    self.titleTextField.frame = CGRectMake(12, 81, self.titleTextField.frame.size.width, self.titleTextField.frame.size.height);
    self.noteLabel.frame = CGRectMake(12, 132, self.noteLabel.frame.size.width, self.noteLabel.frame.size.height);
    self.noteTextView.frame = CGRectMake(12, 151, self.noteTextView.frame.size.width, 130);
    self.sportLabel.frame = CGRectMake(335, 62, self.sportLabel.frame.size.width, self.sportLabel.frame.size.height);
    self.sportTextField.frame = CGRectMake(333, 82, 130, self.sportTextField.frame.size.height);
    self.actionLabel.frame = CGRectMake(335, 126, self.actionLabel.frame.size.width, self.actionLabel.frame.size.height);
    self.actionTextField.frame = CGRectMake(333, 146, 130, self.actionTextField.frame.size.height);
    self.cancelButton.frame = CGRectMake(333, 200, 130, self.cancelButton.frame.size.height);
    self.saveButton.frame = CGRectMake(333, 246, 130, self.saveButton.frame.size.height);
    //self.deleteButton.frame = CGRectMake(429, 4, self.deleteButton.frame.size.width, self.deleteButton.frame.size.height);
}

- (void)rotateForEditModePortrait5e
{
    [self rotateForEditModePortrait4m];
}

- (void)rotateForEditModePortrait4m
{
    self.titleLabel.frame = CGRectMake(14, 81, self.titleLabel.frame.size.width, self.titleLabel.frame.size.height);
    self.titleTextField.frame = CGRectMake(14, 100, self.titleTextField.frame.size.width, self.titleTextField.frame.size.height);
    self.sportLabel.frame = CGRectMake(14, 172, self.sportLabel.frame.size.width, self.sportLabel.frame.size.height);
    self.sportTextField.frame = CGRectMake(14, 192, 139, self.sportTextField.frame.size.height);
    self.actionLabel.frame = CGRectMake(167, 172, self.actionLabel.frame.size.width, self.actionLabel.frame.size.height);
    self.actionTextField.frame = CGRectMake(167, 192, 139, self.actionTextField.frame.size.height);
    self.noteLabel.frame = CGRectMake(14, 252, self.noteLabel.frame.size.width, self.noteLabel.frame.size.height);
    self.noteTextView.frame = CGRectMake(14, 271, self.noteTextView.frame.size.width, self.view.bounds.size.height - 262 - 114);
    self.cancelButton.frame = CGRectMake(14, self.view.bounds.size.height - 72, 116, self.cancelButton.frame.size.height);
    self.saveButton.frame = CGRectMake(141, self.view.bounds.size.height - 72, 164, self.saveButton.frame.size.height);
    //self.deleteButton.frame = CGRectMake(271, 4, self.deleteButton.frame.size.width, self.deleteButton.frame.size.height);
}

- (void)rotateForCreateModeLandscapeWithShift1:(NSInteger)shift1 shift2:(NSInteger)shift2
{
    self.deleteAndRetryButton.frame = CGRectMake(44 + shift1, 62, self.deleteAndRetryButton.frame.size.width, self.deleteAndRetryButton.frame.size.height);
    self.saveAndVstateButton.frame = CGRectMake(44 + shift1, 118, self.saveAndVstateButton.frame.size.width, self.saveAndVstateButton.frame.size.height);
    self.thumbnailView.frame = CGRectMake(230 + shift2, 24, self.thumbnailView.frame.size.width, self.thumbnailView.frame.size.height);
    self.titleTextField.frame = CGRectMake(230 + shift2, 200, self.titleTextField.frame.size.width, self.titleTextField.frame.size.height);
    self.sportLabel.frame = CGRectMake(230 + shift2, 251, self.sportLabel.frame.size.width, self.sportLabel.frame.size.height);
    self.sportTextField.frame = CGRectMake(278 + shift2, 247, self.sportTextField.frame.size.width, self.sportTextField.frame.size.height);
    self.actionLabel.frame = CGRectMake(230 + shift2, 283, self.actionLabel.frame.size.width, self.actionLabel.frame.size.height);
    self.actionTextField.frame = CGRectMake(278 + shift2, 280, self.actionTextField.frame.size.width, self.actionTextField.frame.size.height);
    self.saveAndUseButton.frame = CGRectMake(424 + shift2, 247, 100, 55);
}

- (void)rotateForCreateModeLandscape5e
{
    self.delimiterImageView.transform = CGAffineTransformMakeRotation(270 * M_PI / 180.0);
    self.delimiterImageView.frame = CGRectMake(194, 20, 4, self.view.bounds.size.height - 30);
    [self rotateForCreateModeLandscapeWithShift1:0 shift2:0];
}

- (void)rotateForCreateModeLandscape4m
{
    self.delimiterImageView.hidden = YES;
    [self rotateForCreateModeLandscapeWithShift1:-24 shift2:-70];
}

- (void)rotateForCreateModePortraitWithShift1:(NSInteger)shift1 shift2:(NSInteger)shift2
{
    self.deleteAndRetryButton.frame = CGRectMake(14, 38 + shift1, self.deleteAndRetryButton.frame.size.width, self.deleteAndRetryButton.frame.size.height);
    self.saveAndVstateButton.frame = CGRectMake(189, 38 + shift1, self.saveAndVstateButton.frame.size.width, self.saveAndVstateButton.frame.size.height);
    self.thumbnailView.frame = CGRectMake(14, 128 + shift2, self.thumbnailView.frame.size.width, self.thumbnailView.frame.size.height);
    self.titleTextField.frame = CGRectMake(14, 313 + shift2, self.titleTextField.frame.size.width, self.titleTextField.frame.size.height);
    self.sportLabel.frame = CGRectMake(16, 367 + shift2, self.sportLabel.frame.size.width, self.sportLabel.frame.size.height);
    self.sportTextField.frame = CGRectMake(14, 387 + shift2, self.sportTextField.frame.size.width, self.sportTextField.frame.size.height);
    self.actionLabel.frame = CGRectMake(178, 367 + shift2, self.sportLabel.frame.size.width, self.sportLabel.frame.size.height);
    self.actionTextField.frame = CGRectMake(176, 387 + shift2, self.actionTextField.frame.size.width, self.actionTextField.frame.size.height);
    self.saveAndUseButton.frame = CGRectMake(self.view.bounds.size.width - 120 - 14, self.view.bounds.size.height - 45 - 24, 120, 45);
}

- (void)rotateForCreateModePortrait5e
{
    self.delimiterImageView.transform = CGAffineTransformMakeRotation(0);
    self.delimiterImageView.frame = CGRectMake(13, 100, self.view.bounds.size.width - 26, 4);
    [self rotateForCreateModePortraitWithShift1:0 shift2:0];
}

- (void)rotateForCreateModePortrait4m
{
    self.delimiterImageView.hidden = YES;
    [self rotateForCreateModePortraitWithShift1:-10 shift2:-30];
}

@end
