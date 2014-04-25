//
//  GetHelpViewController.m
//  VstratorApp
//
//  Created by Mac on 12.03.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "FeedbackViewController.h"

#import "AccountController2.h"
#import "IssueTypeSelectorView.h"
#import "VstratorExtensions.h"
#import "VstratorStrings.h"

@interface FeedbackViewController() <UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet IssueTypeSelectorView *issueTypeSelectorView;
@property (weak, nonatomic) IBOutlet UITextView *issueTextField;
@property (weak, nonatomic) IBOutlet UILabel *issueDescriptionLabel;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet UILabel *feedbackTypeLabel;

@end

@implementation FeedbackViewController

#pragma mark - Business Logic

- (BOOL)issueFieldsValidate:(NSString **)outputString
{
    // preprocess input
    self.issueTextField.text = [NSString trimmedStringOrNil:self.issueTextField.text];
    // validate
    return [ValidationHelper validateIssueDescription:self.issueTextField.text outputString:outputString];
}

- (IBAction)sendButtonPressed:(id)sender
{
    NSString *errorString = nil;
    if ([self issueFieldsValidate:&errorString]) {
        [self showBGActivityIndicator:VstratorStrings.UserInfoGetHelpSendingIssueActivityTitle];
        [AccountController2.sharedInstance sendIssueWithType:self.issueTypeSelectorView.selectedIssueTypeKey
                                                 description:self.issueTextField.text
                                                    callback:[self hideBGActivityCallback:^(NSError *error) {
            if (error == nil) {
                UIAlertViewWrapper *wrapper = [UIAlertViewWrapper wrapperWithCallback:^(id result) { 
                    [self dismissViewControllerAnimated:NO completion:nil];
                }];
                [wrapper alertString:VstratorStrings.UserInfoGetHelpIssueSentMessage 
                               title:VstratorStrings.UserInfoGetHelpIssueSentMessageTitle];
            }
        }]];
    } else {
        [UIAlertViewWrapper alertInvalidInputString:errorString];
    }
}

#pragma mark - UITextViewDelegate

- (void)setupTextFieldPopupView:(TextFieldPopupView *)textFieldPopupView
{
    [super setupTextFieldPopupView:textFieldPopupView];
    textFieldPopupView.backgroundImage = self.backgroundImageView.image;
    textFieldPopupView.titleColor = self.issueDescriptionLabel.textColor;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    [self.textFieldPopupView showWithTextView:textView andTitle:self.issueDescriptionLabel.text inView:self.view];
    return NO;
}

#pragma mark - Localization

- (void)setLocalizableStrings
{
    [self.sendButton setTitle:VstratorStrings.UserInfoGetHelpSendButtonTitle forState:UIControlStateNormal];
    [self.issueDescriptionLabel setText:[NSString stringWithFormat:@"%@:", VstratorStrings.UserInfoGetHelpIssueDescriptionLabel]];
    self.feedbackTypeLabel.text = VstratorStrings.UserInfoFeedbackTypeLabel;
}

#pragma mark - View lifecycle

-(void)viewDidLoad
{
    [super viewDidLoad];
    [self setLocalizableStrings];
    [self setResizableImages];
    self.navigationBarView.title = self.title = VstratorConstants.NavigationBarLogoTitle;
}

- (void)setResizableImages
{
    [self.sendButton setBackgroundImage:[UIImage resizableImageNamed:@"bt-grey-n-black-h69"] forState:UIControlStateNormal];
    [self.sendButton setBackgroundImage:[UIImage resizableImageNamed:@"bt-black-01"] forState:UIControlStateHighlighted];
}

- (void)viewDidUnload
{
    // Release any retained subviews of the main view.
    [self setBackgroundImageView:nil];
    [self setIssueTypeSelectorView:nil];
    [self setIssueTextField:nil];
    [self setIssueDescriptionLabel:nil];
    [self setSendButton:nil];
    [self setFeedbackTypeLabel:nil];
    // Super
    [super viewDidUnload];
}

@end
