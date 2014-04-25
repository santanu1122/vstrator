//
//  ShareViewController.m
//  VstratorApp
//
//  Created by Admin on 23/01/2013.
//  Copyright (c) 2013 OnTarget. All rights reserved.
//

#import <MessageUI/MessageUI.h>

#import "AccountController2+Facebook.h"
#import "FlurryLogger.h"
#import "ShareViewController.h"
#import "VstratorConstants.h"
#import "VstratorExtensions.h"
#import "VstratorStrings.h"

typedef enum {
    MediaShareTypeFacebook = 1,
    MediaShareTypeTwitter,
    MediaShareTypeMail,
    MediaShareTypeChat,
    MediaShareTypeSms,
    MediaShareTypeVstrator
} MediaShareType;

@interface ShareViewController () <MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate, UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *containerView;

@property (nonatomic, strong) IBOutlet UIView *shareSelectionView;
@property (nonatomic, weak) IBOutlet UILabel *shareSelectionLabel;
@property (nonatomic, weak) IBOutlet UIView *shareSelectionButtonsView;
@property (weak, nonatomic) IBOutlet UIImageView *shareSelectionButtonsImageView;
@property (nonatomic, weak) IBOutlet UIButton *shareSelectionFacebookButton;
@property (nonatomic, weak) IBOutlet UIButton *shareSelectionTwitterButton;
@property (nonatomic, weak) IBOutlet UIButton *shareSelectionMailButton;
@property (nonatomic, weak) IBOutlet UIButton *shareSelectionChatButton;
@property (nonatomic, weak) IBOutlet UIButton *shareSelectionVstratorButton;
@property (nonatomic, weak) IBOutlet UIButton *shareSelectionSmsButton;
@property (nonatomic, weak) IBOutlet UIImageView *shareSelectionBackgoundImage;
@property (weak, nonatomic) IBOutlet UIButton *shareSelectionHideButton;

@property (nonatomic, strong) IBOutlet UIView *shareFinishView;
@property (nonatomic, weak) IBOutlet UIImageView *shareFinishImageView;
@property (nonatomic, weak) IBOutlet UILabel *shareFinishMessageLabel;
@property (nonatomic, weak) IBOutlet UITextView *shareFinishMessageTextView;
@property (nonatomic, weak) IBOutlet UIButton *shareFinishCancelButton;
@property (nonatomic, weak) IBOutlet UIButton *shareFinishSubmitButton;

@end

@implementation ShareViewController

#pragma mark Actions

- (void)dismissWithAction
{
    [self dismissViewControllerAnimated:NO completion:^{
        if ([self.delegate respondsToSelector:@selector(shareViewControllerDidFinish:)])
            [self.delegate shareViewControllerDidFinish:self];
    }];
}

- (IBAction)hideShareAction:(UIButton *)sender
{
    [self dismissWithAction];
}

- (IBAction)selectShareAction:(UIButton *)sender
{
    [self.shareSelectionView removeFromSuperview];
    self.shareFinishView.tag = sender.tag;
    self.shareFinishMessageTextView.text = [self getDefaultMessage];
    switch ((MediaShareType)self.shareFinishView.tag) {
        case MediaShareTypeFacebook:
        {
            [self updateShareFinishLabel:VstratorStrings.MediaClipSessionViewFacebookMessageLabel
                               andButton:VstratorStrings.MediaClipSessionViewFacebookSubmitButtonTitle];
            break;
        }
        case MediaShareTypeTwitter:
        {
            [self updateShareFinishLabel:VstratorStrings.MediaClipSessionViewTwitterMessageLabel
                               andButton:VstratorStrings.MediaClipSessionViewTwitterSubmitButtonTitle];
            break;
        }
        case MediaShareTypeMail:
        case MediaShareTypeSms:
        {
            [self finishAndSubmitShareAction:self.shareFinishSubmitButton];
            return;
        }
        default:
            return;
    }
    self.shareFinishImageView.image = [sender backgroundImageForState:UIControlStateNormal];
    self.shareFinishView.frame = CGRectMake(0, 0, self.containerView.bounds.size.width, self.containerView.bounds.size.height);
    [self.containerView addSubview:self.shareFinishView];
    [self.shareFinishMessageTextView becomeFirstResponder];
}

- (IBAction)finishAndSubmitShareAction:(UIButton *)sender
{
    __block NSString *shareMessage = self.shareFinishMessageTextView.text;
    MediaShareType shareType = self.shareFinishView.tag;
    [self showBGActivityIndicator:VstratorStrings.MediaClipSessionViewShareActivityTitle];
    switch (shareType) {
        case MediaShareTypeFacebook:
        {
            [self shareToFacebook:shareMessage];
            break;
        }
        case MediaShareTypeTwitter:
        {
            [self shareToTwitter:shareMessage];
            break;
        }
        case MediaShareTypeMail:
        {
            [self shareByMail:shareMessage];
            break;
        }
        case MediaShareTypeSms:
        {
            [self shareBySms:shareMessage];
            break;
        }
        default:
            [self hideBGActivityIndicatorAndDismiss:nil];
            return;
    }
}

- (IBAction)finishAndCancelShareAction:(UIButton *)sender
{
    self.shareFinishImageView.image = nil;
    self.shareFinishMessageTextView.text = nil;
    [self dismissWithAction];
}

#pragma mark MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    dispatch_async(dispatch_get_main_queue(), ^{
        __block __weak ShareViewController *blockSelf = self;
        [controller dismissViewControllerAnimated:NO completion:^{
            if (result == MFMailComposeResultSent) {
                [UIAlertViewWrapper alertString:[VstratorStrings ShareMediaConfirmation] title:[VstratorStrings SharePopupTitle]];
            }
            [FlurryLogger logTypedEvent:FlurryEventTypeVideoShareByMail];
            [blockSelf hideBGActivityIndicatorAndDismiss:error];
        }];
    });
}

#pragma mark MFMessageComposeViewControllerDelegate

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    dispatch_async(dispatch_get_main_queue(), ^{
        __block __weak ShareViewController *blockSelf = self;
        [controller dismissViewControllerAnimated:NO completion:^{
            if (result == MFMailComposeResultSent) {
                [UIAlertViewWrapper alertString:[VstratorStrings ShareMediaConfirmation] title:[VstratorStrings SharePopupTitle]];
            }
            [FlurryLogger logTypedEvent:FlurryEventTypeVideoShareBySms];
            [blockSelf hideBGActivityIndicatorAndDismiss:nil];
        }];
    });
}

#pragma mark UITextViewDelegate

- (void)setupTextFieldPopupView:(TextFieldPopupView *)textFieldPopupView
{
    [super setupTextFieldPopupView:textFieldPopupView];
    textFieldPopupView.backgroundColor = self.shareFinishMessageLabel.superview.backgroundColor;
    textFieldPopupView.titleColor = self.shareFinishMessageLabel.textColor;
    textFieldPopupView.doneButtonTitle = VstratorStrings.SharePopupDoneButtonTitle;
    textFieldPopupView.title = [self getTextFieldPopupTitle];
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    MediaShareType shareType = self.shareFinishView.tag;
    if (shareType == MediaShareTypeTwitter) {
        [self.textFieldPopupView showWithTextView:textView
                                         andTitle:self.shareFinishMessageLabel.text
                                     andMaxLength:140
                                           inView:self.view
                                  moveToBeginning:YES];
    } else {
        [self.textFieldPopupView showWithTextView:textView
                                         andTitle:self.shareFinishMessageLabel.text
                                           inView:self.view
                                  moveToBeginning:YES];
    }
    return NO;
}

- (void)textFieldPopupViewDidFinish:(TextFieldPopupView *)sender
{
    [sender removeFromSuperview];
    [self finishAndSubmitShareAction:self.shareFinishSubmitButton];
}

- (void)textFieldPopupViewDidCancel:(TextFieldPopupView *)sender
{
    [sender removeFromSuperview];
    [self finishAndCancelShareAction:self.shareFinishCancelButton];
}

#pragma mark Business Logic

- (NSString *)getTextFieldPopupTitle
{
    switch (self.shareType) {
        case ShareTypeMedia:
            return VstratorStrings.SharePopupTitle;
        case ShareTypeInviteFriends:
            return VstratorStrings.InviteFriendsPopupTitle;
        case ShareTypeWorkout:
            return VstratorStrings.ShareWorkoutTitle;
        default:
            return @"";
    }
}

- (void)updateShareFinishLabel:(NSString *)labelText andButton:(NSString *)buttonText
{
    [self.shareFinishMessageLabel setText:labelText];
    [self.shareFinishSubmitButton setTitle:buttonText forState:UIControlStateNormal];
}

- (void)shareToFacebook:(NSString *)shareMessage
{
    shareMessage = [self shareMessage:shareMessage orDefault:VstratorStrings.MediaClipShareFacebookMessage];
    [AccountController2.sharedInstance postOnFacebookWall:shareMessage callback:^(NSError *error) {
        if (!error) {
            switch (self.shareType) {
            case ShareTypeMedia:
                [UIAlertViewWrapper alertString:[VstratorStrings ShareMediaConfirmation] title:[VstratorStrings SharePopupTitle]];
                break;
            case ShareTypeInviteFriends:
                [UIAlertViewWrapper alertString:[VstratorStrings InviteFriendsConfirmation] title:[VstratorStrings InviteFriendsPopupTitle]];
                break;
            default:
                break;
            }
        }
        [FlurryLogger logTypedEvent:FlurryEventTypeVideoShareToFacebook];
        [self hideBGActivityIndicatorAndDismiss:error];
    }];
}

- (void)shareToTwitter:(NSString *)shareMessage
{
    shareMessage = [self shareMessage:shareMessage orDefault:VstratorStrings.MediaClipShareTwitterMessage];
    [AccountController2.sharedInstance tweet:shareMessage inView:self.view callback:^(NSError *error) {
        if (!error) {
            [UIAlertViewWrapper alertString:[VstratorStrings ShareMediaConfirmation] title:[VstratorStrings SharePopupTitle]];
        }
        [FlurryLogger logTypedEvent:FlurryEventTypeVideoShareToTwitter];
        [self hideBGActivityIndicatorAndDismiss:error];
    }];
}

- (void)shareByMail:(NSString *)shareMessage
{
    if (![MFMailComposeViewController canSendMail]) {
        [self hideBGActivityIndicatorAndDismiss:[NSError errorWithText:VstratorStrings.ErrorCannotSendMail]];
        return;
    }
    MFMailComposeViewController *vc = [[MFMailComposeViewController alloc] init];
    shareMessage = [self shareMessage:shareMessage orDefault:VstratorStrings.MediaClipShareMailMessage];
    if (self.mediaTitle) vc.subject = [NSString stringWithFormat:[VstratorStrings MediaClipShareMailSubjectFormat], self.mediaTitle];
    [vc setMessageBody:shareMessage isHTML:NO];
    vc.mailComposeDelegate = self;
    [self presentViewController:vc animated:NO completion:nil];
}

- (void)shareBySms:(NSString *)shareMessage
{
    if (![MFMessageComposeViewController canSendText]) {
        [self hideBGActivityIndicatorAndDismiss:[NSError errorWithText:VstratorStrings.ErrorCannotSendSms]];
        return;
    }
    MFMessageComposeViewController *vc = [[MFMessageComposeViewController alloc] init];
    shareMessage = [self shareMessage:shareMessage orDefault:VstratorStrings.MediaClipShareMailMessage];
    vc.body = shareMessage;
    vc.messageComposeDelegate = self;
    [self presentViewController:vc animated:NO completion:nil];
}

- (void)hideBGActivityIndicatorAndDismiss:(NSError *)error
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self hideBGActivityIndicator:error withCallback:^(NSError *error1) {
            [self finishAndCancelShareAction:nil];
        }];
    });
}

- (NSString *)getDefaultMessage
{
    switch (self.shareType) {
        case ShareTypeMedia:
            return [NSString stringWithFormat:@" %@", self.messageParameter];
        case ShareTypeInviteFriends:
            return [NSString stringWithFormat:@"%@\n%@", VstratorStrings.InviteFriendsShareMessage, self.messageParameter];
        case ShareTypeWorkout:
            return [NSString stringWithFormat:VstratorStrings.ShareWorkoutMessage, self.messageParameter];
        default:
            return @"";
    }
}

- (NSString *)shareMessage:(NSString *)message orDefault:(NSString *)defaultMessage
{
    if (self.shareType == ShareTypeMedia)
        return [NSString isNilOrWhitespace:message] ? [NSString stringWithFormat:@"%@: %@", NSDate.date, defaultMessage] : message;
    return [NSString isNilOrWhitespace:message] ? [self getDefaultMessage] : message;
}

- (void) setLocalizableStrings
{
    [self.shareSelectionLabel setText:[VstratorStrings.MediaClipSessionViewShareLabel capitalizedString]];
    [self.shareSelectionHideButton setTitle:VstratorStrings.InviteFriendsBackButtonTitle forState:UIControlStateNormal];
}

#pragma mark View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setLocalizableStrings];
    [self setResizableImages];
    self.navigationBarView.hidden = YES;
    [self setTagsForButtons];
    self.shareSelectionView.frame = CGRectMake(0, 0, self.containerView.bounds.size.width, self.containerView.bounds.size.height);
    [self.containerView addSubview:self.shareSelectionView];
}

- (void)setTagsForButtons
{
    self.shareSelectionFacebookButton.tag = MediaShareTypeFacebook;
    self.shareSelectionTwitterButton.tag = MediaShareTypeTwitter;
    self.shareSelectionMailButton.tag = MediaShareTypeMail;
    self.shareSelectionChatButton.tag = MediaShareTypeChat;
    self.shareSelectionSmsButton.tag = MediaShareTypeSms;
    self.shareSelectionVstratorButton.tag = MediaShareTypeVstrator;
}

- (void)setResizableImages
{
    UIImage *btGreyNBlackh69 = [UIImage resizableImageNamed:@"bt-grey-n-black-h69"];
    UIImage *btBlack01 = [UIImage resizableImageNamed:@"bt-black-01"];

    [self.shareFinishCancelButton setBackgroundImage:btGreyNBlackh69 forState:UIControlStateNormal];
    [self.shareFinishCancelButton setBackgroundImage:btBlack01 forState:UIControlStateHighlighted];
    
    [self.shareFinishSubmitButton setBackgroundImage:btGreyNBlackh69 forState:UIControlStateNormal];
    [self.shareFinishSubmitButton setBackgroundImage:btBlack01 forState:UIControlStateHighlighted];
    
    self.shareSelectionButtonsImageView.image = [UIImage resizableImageNamed:@"bg-share-line"];
}

//- (void)viewWillAppear:(BOOL)animated
//{
//    [super viewWillAppear:animated];
//    [self rotate:self.interfaceOrientation];
//}

- (void)viewDidUnload
{
    self.shareSelectionView = nil;
    self.shareSelectionBackgoundImage = nil;
    self.shareSelectionHideButton = nil;
    self.shareSelectionLabel = nil;
    self.shareSelectionButtonsView = nil;
    self.shareSelectionFacebookButton = nil;
    self.shareSelectionTwitterButton = nil;
    self.shareSelectionMailButton = nil;
    self.shareSelectionChatButton = nil;
    self.shareSelectionSmsButton =nil;
    self.shareSelectionVstratorButton = nil;
    self.shareFinishView = nil;
    self.shareFinishImageView = nil;
    self.shareFinishMessageLabel = nil;
    self.shareFinishMessageTextView = nil;
    self.shareFinishCancelButton = nil;
    self.shareFinishSubmitButton = nil;
    self.containerView = nil;
    [self setShareSelectionButtonsImageView:nil];
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
    
    BOOL isLandscape = UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
    CGRect shareSelectionLabelFrame = self.shareSelectionLabel.frame;
    shareSelectionLabelFrame.origin = isLandscape ? CGPointMake(119, 54) : CGPointMake(39, 128);
    self.shareSelectionLabel.frame = shareSelectionLabelFrame;
    self.shareSelectionButtonsView.frame = CGRectMake(self.shareSelectionButtonsView.frame.origin.x, shareSelectionLabelFrame.origin.y + 36, self.shareSelectionButtonsView.frame.size.width, self.shareSelectionButtonsView.frame.size.height);
    self.shareSelectionBackgoundImage.image = [UIImage imageNamed:(isLandscape ? @"bg-page-logo-h" : @"bg-page-logo-v")];
}

@end
