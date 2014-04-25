//
//  VstratorLabels.m
//  VstratorApp
//
//  Created by Oleg Bragin on 14.07.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "VstratorStrings.h"
#import "VstratorConstants.h"

@implementation VstratorStrings

+ (NSString * const) ProUserName { return NSLocalizedString(@"ProUserName", @"Text for user name"); }
+ (NSString * const) UnknownUserName { return NSLocalizedString(@"UnknownUserName", @"Text for user name"); }

/* Screen Titles */
+ (NSString * const) TitleLogin { return NSLocalizedString(@"TitleLogin", @"Text on the top of login screen"); }
+ (NSString * const) TitleRegistration { return NSLocalizedString(@"TitleRegistration", @"Text on the top of registration screen"); }
+ (NSString * const) TitleContentPro { return self.class.ProUserName; }
+ (NSString * const) TitleContentVstrate { return NSLocalizedString(@"TitleContentVstrate", @"Text on the top of vstrate screen"); }
+ (NSString * const) TitleContentSideBySide { return NSLocalizedString(@"TitleContentSideBySide", @"Text on the top of side by side screen"); }
+ (NSString * const) TitleContentUploadQueue { return NSLocalizedString(@"TitleContentUploadQueue", @"Text on the top of queue screen"); }
+ (NSString * const) TitleSearch { return NSLocalizedString(@"TitleSearch", @"Text on the top of search screen"); }

/* Feedback Type */
+ (NSString * const) IssueTypeBugReportName  { return NSLocalizedString(@"IssueTypeBugReportName", @"Bug Report"); }
+ (NSString * const) IssueTypeFeedbackName { return NSLocalizedString(@"IssueTypeFeedbackName", @"Feedback"); }
+ (NSString * const) IssueTypeSuggestionName { return NSLocalizedString(@"IssueTypeSuggestionName", @"Suggestion"); }
+ (NSString * const) IssueTypeEmpty { return NSLocalizedString(@"IssueTypeEmpty", @"Issue type"); }

/* Quality */
+ (NSString * const) UploadQualityHighName { return NSLocalizedString(@"UploadQualityHighName", @""); }
+ (NSString * const) UploadQualityLowName { return NSLocalizedString(@"UploadQualityLowName", @""); }

// Upload options
+ (NSString * const) UploadOnlyOnWiFiName { return NSLocalizedString(@"UploadOnlyOnWiFiName", @"Upload only on WiFi"); }
+ (NSString * const) UploadOnWWANName { return NSLocalizedString(@"UploadOnWWANName", @"Allow upload over WWAN"); }

/* Home \ Quick start */
+ (NSString * const) HomeQuickStartVstrateLabel { return NSLocalizedString(@"HomeQuickStartVstrateLabel", @"VSTRATE"); };
+ (NSString * const) HomeQuickStartVstrateSubLabel1 { return NSLocalizedString(@"HomeQuickStartVstrateSubLabel1", @"Power your game with video analysis"); };
+ (NSString * const) HomeQuickStartVstrateSubLabel2 { return NSLocalizedString(@"HomeQuickStartVstrateSubLabel2", @"tools and side-by-side comparison"); };
+ (NSString * const) HomeQuickStartProLabel { return NSLocalizedString(@"HomeQuickStartProLabel", @"LEARN WITH RAFA"); };
+ (NSString * const) HomeQuickStartProSubLabel1 { return NSLocalizedString(@"HomeQuickStartProSubLabel1", @"Power up and play like a pro with"); };
+ (NSString * const) HomeQuickStartProSubLabel2 { return NSLocalizedString(@"HomeQuickStartProSubLabel2", @"in-depth tutorials and commentary"); };

/* Home \ Pro */
+ (NSString * const) HomeProUserNoExtrasLabel { return NSLocalizedString(@"HomeProUserNoExtrasLabel", @"There are no extras now!"); };
+ (NSString * const) HomeProUserNoClipsLabel { return NSLocalizedString(@"HomeProUserNoClipsLabel", @"You don't have any clips here! Let's change it!"); };

/* Home \ Side-by-Side */
+ (NSString * const) HomeSideBySideSelectClipLabel { return NSLocalizedString(@"HomeSideBySideSelectClipLabel", @"Please select clip"); };
+ (NSString * const) HomeSideBySideLabel { return NSLocalizedString(@"HomeSideBySideLabel", @"Side by side"); };

/* Home \ Vstrate */
+ (NSString * const) HomeVstrateLabel { return NSLocalizedString(@"HomeVstrateLabel", @"Vstrate"); };

/* Media \ Clip Playback */
+ (NSString * const) MediaClipPlaybackLoadingActivityTitle { return NSLocalizedString(@"MediaClipPlaybackLoadingActivityTitle", @"Loading..."); };
+ (NSString * const) MediaClipPlaybackProcessingActivityTitle { return NSLocalizedString(@"MediaClipPlaybackProcessingActivityTitle", @"Processing..."); };

/* Media \ Clip/Session Creation */
+ (NSString * const) MediaClipSessionCreationSavingSessionActivityTitle { return NSLocalizedString(@"MediaClipSessionCreationSavingSessionActivityTitle", @"Saving session..."); };
+ (NSString * const) ProgressSavingVideo { return NSLocalizedString(@"ProgressSavingVideo", @"Saving video..."); }

/* Media \ Clip/Session Edit */
+ (NSString * const) MediaClipSessionEditSavingMediaActivityTitle { return NSLocalizedString(@"MediaClipSessionEditSavingMediaActivityTitle", @"Saving media"); };
+ (NSString * const) MediaClipSessionEditClipTitleField { return NSLocalizedString(@"MediaClipSessionEditClipTitleField", @"Clip's title"); };
+ (NSString * const) MediaClipSessionEditTitleLabel { return NSLocalizedString(@"MediaClipSessionEditTitleLabel", @"Title"); };
+ (NSString * const) MediaClipSessionEditActionLabel { return NSLocalizedString(@"MediaClipSessionEditActionLabel", @"Action"); };
+ (NSString * const) MediaClipSessionEditSportActionLabel { return NSLocalizedString(@"MediaClipSessionEditSportActionLabel", @"Action"); };
+ (NSString * const) MediaClipSessionEditSportLabel { return NSLocalizedString(@"MediaClipSessionEditSportLabel", @"Sport/Action"); };
+ (NSString * const) MediaClipSessionEditSelectActionLabel { return NSLocalizedString(@"MediaClipSessionEditSelectActionLabel", @"Select Action"); };
+ (NSString * const) MediaClipSessionEditSelectSportLabel { return NSLocalizedString(@"MediaClipSessionEditSelectSportLabel", @"Select Sport"); };
+ (NSString * const) MediaClipSessionEditNotesLabel { return NSLocalizedString(@"MediaClipSessionEditNotesLabel", @"Notes"); };
+ (NSString * const) MediaClipSessionEditCompressingVideoMessage { return NSLocalizedString(@"MediaClipSessionEditCompressingVideoMessage", @"Compressing video..."); };
+ (NSString * const) MediaClipSessionEditDoYouWantToCancel { return NSLocalizedString(@"MediaClipSessionEditDoYouWantToCancel", @"Do you want to cancel this session?"); };

/* Media \ Clip/Session View (Open) */
+ (NSString * const) MediaClipSessionViewSideBySide { return NSLocalizedString(@"MediaClipSessionViewSideBySide", @"Side by Side"); };
+ (NSString * const) MediaClipSessionViewClipTitleAndActionLabel { return NSLocalizedString(@"MediaClipSessionViewClipTitleAndActionLabel", @"clip's title and action"); };
+ (NSString * const) MediaClipSessionViewShareLabel { return NSLocalizedString(@"MediaClipSessionViewShareLabel", @"Share"); };
+ (NSString * const) MediaClipSessionViewTwitterSubmitButtonTitle { return NSLocalizedString(@"MediaClipSessionViewTwitterSubmitButtonTitle", @"Post on Twitter"); };
+ (NSString * const) MediaClipSessionViewTwitterMessageLabel { return NSLocalizedString(@"MediaClipSessionViewTwitterMessageLabel", @"Your Tweet"); };
+ (NSString * const) MediaClipSessionViewFacebookSubmitButtonTitle { return NSLocalizedString(@"MediaClipSessionViewFacebookSubmitButtonTitle", @"Share on Facebook"); };
+ (NSString * const) MediaClipSessionViewFacebookMessageLabel { return NSLocalizedString(@"MediaClipSessionViewFacebookMessageLabel", @"Message for your post"); };
+ (NSString * const) MediaClipSessionViewMailSubmitButtonTitle { return NSLocalizedString(@"MediaClipSessionViewMailSubmitButtonTitle", @"Share on mail"); };
+ (NSString * const) MediaClipSessionViewMailMessageLabel { return NSLocalizedString(@"MediaClipSessionViewMailMessageLabel", @"Message for your post"); };
+(NSString *const)MediaClipShareMailSubjectFormat { return NSLocalizedString(@"MediaClipShareMailSubjectFormat", @"Vstrator video: %@"); }
+(NSString *const)ShareMediaConfirmation { return NSLocalizedString(@"ShareMediaConfirmation", @"Your video has been shared"); }
+(NSString *const)InviteFriendsConfirmation { return NSLocalizedString(@"InviteFriendsConfirmation", @"Your invitation has been posted"); }

+ (NSString * const) MediaClipSessionViewSmsSubmitButtonTitle { return NSLocalizedString(@"MediaClipSessionViewSmsSubmitButtonTitle", @"Share on sms"); };
+ (NSString * const) MediaClipSessionViewSmsMessageLabel { return NSLocalizedString(@"MediaClipSessionViewSmsMessageLabel", @"Message for your post"); };
+ (NSString * const) MediaClipSessionViewShareActivityTitle { return NSLocalizedString(@"MediaClipSessionViewShareActivityTitle", @"Sharing..."); };
+ (NSString * const) MediaClipSessionViewSessionLogoTitle { return NSLocalizedString(@"MediaClipSessionViewSessionLogoTitle", @"VSTRATED VIDEO"); };

/* Media \ Lists */
+ (NSString * const) MediaListAllNoClipsExist { return NSLocalizedString(@"MediaListAllNoClipsExist", @"You don't have any clips here!"); }
+ (NSString * const) MediaListAllNoClipsFound { return NSLocalizedString(@"MediaListAllNoClipsFound", @"No clips were found!"); }
+ (NSString * const) MediaListAllNoSessionsExist { return NSLocalizedString(@"MediaListAllNoSessionsExist", @"You don't have any sessions here!"); }
+ (NSString * const) MediaListAllNoSessionsFound { return NSLocalizedString(@"MediaListAllNoSessionsFound", @"No sessions were found!"); }
+ (NSString * const) MediaListUserNoClipsExist { return NSLocalizedString(@"MediaListUserNoClipsExist", @"You don't have any clips yet!"); }
+ (NSString * const) MediaListUserNoClipsFound { return NSLocalizedString(@"MediaListUserNoClipsFound", @"No clips were found!"); }
+ (NSString * const) MediaListUserNoSessionsExist { return NSLocalizedString(@"MediaListUserNoSessionsExist", @"You don't have any sessions yet!"); }
+ (NSString * const) MediaListUserNoSessionsFound { return NSLocalizedString(@"MediaListUserNoSessionsFound", @"No sessions were found!"); }
+ (NSString * const) MediaListProNoClipsExist { return NSLocalizedString(@"MediaListProNoClipsExist", @" don't have any clips here!"); }
+ (NSString * const) MediaListProNoClipsFound { return NSLocalizedString(@"MediaListProNoClipsFound", @"No clips were found!"); }
+ (NSString * const) MediaListProNoSessionsExist { return NSLocalizedString(@"MediaListProNoSessionsExist", @" don't have any sessions here!"); }
+ (NSString * const) MediaListProNoSessionsFound { return NSLocalizedString(@"MediaListProNoSessionsFound", @"No sessions were found!"); }

/* Media \ Share Twitter */
+ (NSString * const) MediaClipShareTwitterMessage { return NSLocalizedString(@"MediaClipShareTwitterMessage", @"I've uploaded smth new to my Vstrator!"); };
+ (NSString * const) MediaClipShareFacebookMessage { return NSLocalizedString(@"MediaClipShareFacebookMessage", @"I've uploaded smth new to my Vstrator!"); };
+ (NSString * const) MediaClipShareMailMessage { return NSLocalizedString(@"MediaClipShareMailMessage", @"I've uploaded smth new to my Vstrator!"); };
+ (NSString * const) MediaClipShareSmsMessage { return NSLocalizedString(@"MediaClipShareSmsMessage", @"I've uploaded smth new to my Vstrator!"); };
+ (NSString * const) InviteFriendsShareMessage { return NSLocalizedString(@"InviteFriendsShareMessage", @""); };
+ (NSString * const) SharePopupDoneButtonTitle { return NSLocalizedString(@"TextPopupDoneButtonTitle", @""); }
+ (NSString * const) SharePopupTitle { return NSLocalizedString(@"SharePopupTitle", @""); }
+ (NSString * const) InviteFriendsPopupTitle { return NSLocalizedString(@"InviteFriendsPopupTitle", @"Please check out the new Vstrator app that I have been using to improve my game"); }
+ (NSString * const) InviteFriendsBackButtonTitle { return NSLocalizedString(@"InviteFriendsBackButtonTitle", @"Cancel"); }
+ (NSString * const) ShareWorkoutTitle { return NSLocalizedString(@"ShareWorkoutTitle", @""); }
+ (NSString * const) ShareWorkoutMessage { return NSLocalizedString(@"ShareWorkoutMessage", @""); };

/* User Info \ Get Help */
+ (NSString * const) UserInfoGetHelpSendingIssueActivityTitle { return NSLocalizedString(@"UserInfoGetHelpSendingIssueActivityTitle", @"Sending issue"); };
+ (NSString * const) UserInfoGetHelpIssueDescriptionLabel { return NSLocalizedString(@"UserInfoGetHelpIssueDescriptionLabel", @"Description of the Issue"); };
+ (NSString * const) UserInfoGetHelpIssueSentMessage { return NSLocalizedString(@"UserInfoGetHelpIssueSentMessage", @"Your issue has been successfully sent!"); };
+ (NSString * const) UserInfoGetHelpIssueSentMessageTitle { return NSLocalizedString(@"UserInfoGetHelpIssueSentMessageTitle", @"Issue has been sent!"); };

/* User Info \ Version of the App */
+ (NSString * const) UserInfoVersionOfTheAppLabel { return NSLocalizedString(@"UserInfoVersionOfTheAppLabel", @"Version 1.2 of the App"); };
+ (NSString * const) UserInfoLicenseOfTheAppLabel { return NSLocalizedString(@"UserInfoLicenseOfTheAppLabel", @"Lorem ipsum..."); };

/* User Info \ View Account Info */
+ (NSString * const) UserInfoViewAccountInfoUpdatingProfileActivityTitle { return NSLocalizedString(@"UserInfoViewAccountInfoUpdatingProfileActivityTitle", @"Updating profile"); };
+ (NSString * const) UserInfoViewAccountInfoProfileUpdatedMessage { return NSLocalizedString(@"UserInfoViewAccountInfoProfileUpdatedMessage", @"Your profile has been successfully updated"); };
+ (NSString * const) UserInfoViewAccountInfoProfileUpdatedMessageTitle { return NSLocalizedString(@"UserInfoViewAccountInfoProfileUpdatedMessageTitle", @"Profile updated!"); };
+ (NSString * const) UserInfoViewAccountInfoPasswordUpdatedMessage { return NSLocalizedString(@"UserInfoViewAccountInfoPasswordUpdatedMessage", @"Your profile has been successfully updated"); };
+ (NSString * const) UserInfoViewAccountInfoPasswordUpdatedMessageTitle { return NSLocalizedString(@"UserInfoViewAccountInfoPasswordUpdatedMessageTitle", @"Profile updated!"); };

/* User Info \ View Account Info \ Change Password */
+ (NSString * const) UserInfoViewAccountInfoChangePasswordUpdatingPasswordActivityTitle { return NSLocalizedString(@"UserInfoViewAccountInfoChangePasswordUpdatingPasswordActivityTitle", @"Updating password"); };
+ (NSString * const) UserInfoViewAccountInfoChangePasswordConfirmNewPasswordField { return NSLocalizedString(@"UserInfoViewAccountInfoChangePasswordConfirmNewPasswordField", @"Confirm new password"); };
+ (NSString * const) UserInfoViewAccountInfoChangePasswordCurrentPasswordField { return NSLocalizedString(@"UserInfoViewAccountInfoChangePasswordCurrentPasswordField", @"Current password"); };
+ (NSString * const) UserInfoViewAccountInfoChangePasswordNewPasswordField { return NSLocalizedString(@"UserInfoViewAccountInfoChangePasswordNewPasswordField", @"New password"); };

/* User Info \ View Account Info \ Change Picture */
+ (NSString * const) UserInfoViewAccountInfoChangePictureUpdatingProfileActivityTitle { return NSLocalizedString(@"UserInfoViewAccountInfoChangePictureUpdatingProfileActivityTitle", @"Updating profile"); };

/* User Info \ View Account Info \ Change Picture \ Use Camera */
+ (NSString * const) UserInfoViewAccountInfoChangePictureUseCameraPreviewLabel { return NSLocalizedString(@"UserInfoViewAccountInfoChangePictureUseCameraPreviewLabel", @"Preview"); };

/* User Login */
+ (NSString * const) UserLoginLoggingInActivityTitle { return NSLocalizedString(@"UserLoginLoggingInActivityTitle", @"Logging in..."); };
+ (NSString * const) UserLoginLoggingInFacebookActivityTitle { return NSLocalizedString(@"UserLoginLoggingInFacebookActivityTitle", @"Logging in with Facebook"); };
+ (NSString * const) UserLoginLoggingOutActivityTitle { return NSLocalizedString(@"UserLoginLoggingOutActivityTitle", @"Logging out..."); };
+ (NSString * const) UserLoginEmailAddressField { return NSLocalizedString(@"UserLoginEmailAddressField", @"Email Address"); };
+ (NSString * const) UserLoginPasswordField { return NSLocalizedString(@"UserLoginPasswordField", @"Password"); };
+ (NSString * const) UserLoginLoginLabel { return NSLocalizedString(@"UserLoginLoginLabel", @"Login"); };
+ (NSString * const) UserLoginOrLabel { return NSLocalizedString(@"UserLoginOrLabel", @"Or"); };

/* User Login Methods */
+ (NSString * const) UserLoginMethodsLoggingInFacebookActivityTitle { return NSLocalizedString(@"UserLoginMethodsLoggingInFacebookActivityTitle", @"Logging in with Facebook"); };

/* User Registration */
+ (NSString * const) UserRegistrationRegisteringUserActivityTitle { return NSLocalizedString(@"UserRegistrationRegisteringUserActivityTitle", @"Registering user"); };
+ (NSString * const) UserRegistrationConfirmPasswordField { return NSLocalizedString(@"UserRegistrationConfirmPasswordField", @"Confirm Password"); };
+ (NSString * const) UserRegistrationEmailAddressField { return NSLocalizedString(@"UserRegistrationEmailAddressField", @"Email Address"); };
+ (NSString * const) UserRegistrationFirstNameField { return NSLocalizedString(@"UserRegistrationFirstNameField", @"First Name"); };
+ (NSString * const) UserRegistrationLastNameField { return NSLocalizedString(@"UserRegistrationLastNameField", @"Last Name"); };
+ (NSString * const) UserRegistrationPasswordField { return NSLocalizedString(@"UserRegistrationPasswordField", @"Password"); };
+ (NSString * const) UserRegistrationRegistrationLabel { return NSLocalizedString(@"UserRegistrationRegistrationLabel", @"Registration"); };

/* Notifications */
+ (NSString * const) ProcessingNotificationButtonActivityTitle { return NSLocalizedString(@"ProcessingNotificationButtonActivityTitle", @"Processing..."); };

/* Misc */
+ (NSString * const) LoadingActivityTitle { return NSLocalizedString(@"LoadingActivityTitle", @"Loading..."); };
+ (NSString * const) SecondsText { return NSLocalizedString(@"SecondsText", @"secs"); };

/* Button titles */

/* Home \ Pro */
+ (NSString * const) HomeProUserStrokesButtonTitle { return NSLocalizedString(@"homeProUserStrokesButtonTitle", @""); }
+ (NSString * const) HomeProUserTutorialsButtonTitle { return NSLocalizedString(@"homeProUserTutorialsButtonTitle", @""); }
+ (NSString * const) HomeProUserInterviewsButtonTitle { return NSLocalizedString(@"homeProUserInterviewsButtonTitle", @""); }

/* Home \ Capture Clip */
+ (NSString * const) HomeCaptureClipDialogTitle { return NSLocalizedString(@"homeCaptureClipDialogTitle", @""); }
+ (NSString * const) HomeCaptureClipCancelButtonTitle { return NSLocalizedString(@"homeCaptureClipCancelButtonTitle", @""); }
+ (NSString * const) HomeCaptureClipImportButtonTitle { return NSLocalizedString(@"homeCaptureClipImportButtonTitle", @""); }
+ (NSString * const) HomeCaptureClipCloseButtonTitle { return NSLocalizedString(@"homeCaptureClipCloseButtonTitle", @""); }
+ (NSString * const) HomeCaptureClipShowGuidesButtonTitle { return NSLocalizedString(@"homeCaptureClipShowGuidesButtonTitle", @""); }
+ (NSString * const) HomeCaptureClipPickFromLibraryButtonTitle { return NSLocalizedString(@"homeCaptureClipPickFromLibraryButtonTitle", @""); }
+ (NSString * const) HomeCaptureClipUseCameraButtonTitle { return NSLocalizedString(@"homeCaptureClipUseCameraButtonTitle", @""); }
+ (NSString * const) HomeCaptureClipFpsLabel { return NSLocalizedString(@"homeCaptureClipFpsLabel", @""); }

/* Home \ Side-by-Side */
+ (NSString * const) HomeSideBySideCaptureClipButtonTitle { return NSLocalizedString(@"homeSideBySideCaptureClipButtonTitle", @""); }
+ (NSString * const) HomeSideBySideSelectClipButtonTitle { return NSLocalizedString(@"homeSideBySideSelectClipButtonTitle", @""); }
+ (NSString * const) HomeSideBySideStartSideBySideClipButtonTitle { return NSLocalizedString(@"homeSideBySideStartSideBySideClipButtonTitle", @""); }

/* Home \ Vstrate */
+ (NSString * const) HomeVstrateAllButtonTitle { return NSLocalizedString(@"homeVstrateAllButtonTitle", @""); }
+ (NSString * const) HomeVstrateProContentButtonTitle { return NSLocalizedString(@"homeVstrateProContentButtonTitle", @""); }
+ (NSString * const) HomeVstrateProClipsButtonTitle { return NSLocalizedString(@"homeVstrateProClipsButtonTitle", @""); }
+ (NSString * const) HomeVstrateCaptureClipButtonTitle { return NSLocalizedString(@"homeVstrateCaptureClipButtonTitle", @""); }
+ (NSString * const) HomeVstrateMyClipsButtonTitle { return NSLocalizedString(@"homeVstrateMyClipsButtonTitle", @""); }
+ (NSString * const) HomeVstrateSideBySideButtonTitle { return NSLocalizedString(@"homeVstrateSideBySideButtonTitle", @""); }
+ (NSString * const) HomeVstrateVstrateButtonTitle { return NSLocalizedString(@"homeVstrateVstrateButtonTitle", @""); }
+ (NSString * const) HomeVstrateVstratedClipsButtonTitle { return NSLocalizedString(@"homeVstrateVstratedClipsButtonTitle", @""); }

/* Media \ Clip Playback */
+ (NSString * const) MediaClipPlaybackDoneButtonTitle { return NSLocalizedString(@"mediaClipPlaybackDoneButtonTitle", @""); }

/* Media \ Clip/Session Edit */
+ (NSString * const) MediaClipSessionEditCancelButtonTitle { return NSLocalizedString(@"mediaClipSessionEditCancelButtonTitle", @""); }
+ (NSString * const) MediaClipSessionEditYesButtonTitle { return NSLocalizedString(@"mediaClipSessionEditYesButtonTitle", @""); }
+ (NSString * const) MediaClipSessionEditNoButtonTitle { return NSLocalizedString(@"mediaClipSessionEditNoButtonTitle", @""); }
+ (NSString * const) MediaClipSessionEditDeleteClipButtonTitle { return NSLocalizedString(@"mediaClipSessionEditDeleteClipButtonTitle", @""); }
+ (NSString * const) MediaClipSessionEditSaveAndShootButtonTitle { return NSLocalizedString(@"mediaClipSessionEditSaveAndShootButtonTitle", @""); }
+ (NSString * const) MediaClipSessionEditSaveAndUseButtonTitle { return NSLocalizedString(@"mediaClipSessionEditSaveAndUseButtonTitle", @""); }
+ (NSString * const) MediaClipSessionEditDeleteAndShootButtonTitle { return NSLocalizedString(@"mediaClipSessionEditDeleteAndShootButtonTitle", @""); }
+ (NSString * const) MediaClipSessionEditDoYouWantToDelete { return NSLocalizedString(@"mediaClipSessionEditDoYouWantToDelete", @""); }
+ (NSString * const) MediaClipSessionEditTitleEditMode { return NSLocalizedString(@"mediaClipSessionEditTitleEditMode", @""); }
+ (NSString * const) MediaClipSessionEditTitleVstrationMode { return NSLocalizedString(@"mediaClipSessionEditTitleVstrationMode", @""); }

/* Media \ Clip/Session View (Open) */
+ (NSString * const) MediaClipSessionViewCancelButtonTitle { return NSLocalizedString(@"mediaClipSessionViewCancelButtonTitle", @""); }
+ (NSString * const) MediaClipSessionViewDetailsButtonTitle { return NSLocalizedString(@"mediaClipSessionViewDetailsButtonTitle", @""); }
+ (NSString * const) MediaClipSessionViewDoneButtonTitle { return NSLocalizedString(@"mediaClipSessionViewDoneButtonTitle", @""); }
+ (NSString * const) MediaClipSessionViewSaveButtonTitle { return NSLocalizedString(@"mediaClipSessionViewSaveButtonTitle", @""); }
+ (NSString * const) MediaClipSessionViewShareButtonTitle { return NSLocalizedString(@"mediaClipSessionViewShareButtonTitle", @""); }
+ (NSString * const) MediaClipSessionViewSideBySideButtonTitle { return NSLocalizedString(@"mediaClipSessionViewSideBySideButtonTitle", @""); }
+ (NSString * const) MediaClipSessionViewTrimButtonTitle { return NSLocalizedString(@"mediaClipSessionViewTrimButtonTitle", @""); }
+ (NSString * const) MediaClipSessionViewUploadButtonTitle { return NSLocalizedString(@"mediaClipSessionViewUploadButtonTitle", @""); }
+ (NSString * const) MediaClipSessionViewUploadingButtonTitle { return NSLocalizedString(@"mediaClipSessionViewUploadingButtonTitle", @""); }
+ (NSString * const) MediaClipSessionViewUploadedButtonTitle { return NSLocalizedString(@"mediaClipSessionViewUploadedButtonTitle", @""); }
+ (NSString * const) MediaClipSessionViewUploadRetryButtonTitle { return NSLocalizedString(@"MediaClipSessionViewUploadRetryButtonTitle", @""); }
+ (NSString * const) MediaClipSessionViewVstrateButtonTitle { return NSLocalizedString(@"mediaClipSessionViewVstrateButtonTitle", @""); }
+ (NSString * const) MediaClipSessionViewDownloadButtonTitle { return NSLocalizedString(@"mediaClipSessionViewDownloadButtonTitle", @""); }

/* Download Content */

+ (NSString * const) DownloadContentTitleText { return NSLocalizedString(@"downloadContentTitleText", @""); }

/* Media \ Session Creation */

+ (NSString * const) MediaClipSessionCreationColorsButtonTitle { return NSLocalizedString(@"mediaClipSessionCreationColorsButtonTitle", @""); }
+ (NSString * const) MediaClipSessionCreationStartButtonTitle { return NSLocalizedString(@"mediaClipSessionCreationStartButtonTitle", @""); }
+ (NSString * const) MediaClipSessionCreationStopButtonTitle { return NSLocalizedString(@"mediaClipSessionCreationStopButtonTitle", @""); }
+ (NSString * const) MediaClipSessionCreationToolsButtonTitle { return NSLocalizedString(@"mediaClipSessionCreationToolsButtonTitle", @""); }
+ (NSString * const) MediaClipSessionCreationUndoButtonTitle { return NSLocalizedString(@"mediaClipSessionCreationUndoButtonTitle", @""); }
+ (NSString * const) MediaClipSessionCreationBackButtonTitle { return NSLocalizedString(@"mediaClipSessionCreationBackButtonTitle", @""); }
+ (NSString * const) MediaClipSessionCreationTimelineButtonTitle { return NSLocalizedString(@"mediaClipSessionCreationTimelineButtonTitle", @""); }
+ (NSString * const) MediaClipSessionCreationZoomButtonTitle { return NSLocalizedString(@"mediaClipSessionCreationZoomButtonTitle", @""); }

/* Media \ Session Playback */
+ (NSString * const) MediaSessionPlaybackRedoButtonTitle { return NSLocalizedString(@"mediaSessionPlaybackRedoButtonTitle", @""); }
+ (NSString * const) MediaSessionPlaybackSaveButtonTitle { return NSLocalizedString(@"mediaSessionPlaybackSaveButtonTitle", @""); }

/* Media \ List/Cells */

+ (NSString * const) MediaListViewCellSelectButtonTitle { return NSLocalizedString(@"mediaListViewCellSelectButtonTitle", @""); }
+ (NSString * const) MediaListViewCellDeleteButtonTitle { return NSLocalizedString(@"mediaListViewCellDeleteButtonTitle", @""); }
+ (NSString * const) MediaListViewHeaderSyncButtonTitle { return NSLocalizedString(@"mediaListViewHeaderSyncButtonTitle", @""); }
+ (NSString * const) MediaListViewProHeaderDownloadButtonTitle { return NSLocalizedString(@"mediaListViewProHeaderDownloadButtonTitle", @""); }

/* Navigation Bar */
+ (NSString * const) NavigationBarBackButtonTitle { return NSLocalizedString(@"navigationBarBackButtonTitle", @""); }
+ (NSString * const) NavigationBarCancelButtonTitle { return NSLocalizedString(@"navigationBarCancelButtonTitle", @""); }
+ (NSString * const) NavigationBarDoneButtonTitle { return NSLocalizedString(@"navigationBarDoneButtonTitle", @""); }
+ (NSString * const) NavigationBarInfoButtonTitle { return NSLocalizedString(@"navigationBarInfoButtonTitle", @""); }
+ (NSString * const) NavigationBarSearchButtonTitle { return NSLocalizedString(@"navigationBarSearchButtonTitle", @""); }

/* User Info */
+ (NSString * const) UserInfoAboutThisAppButtonTitle { return NSLocalizedString(@"userInfoAboutThisAppButtonTitle", @""); }
+ (NSString * const) UserInfoGetHelpButtonTitle { return NSLocalizedString(@"userInfoGetHelpButtonTitle", @""); }
+ (NSString * const) UserInfoLogoutButtonTitle { return NSLocalizedString(@"userInfoLogoutButtonTitle", @""); }
+ (NSString * const) UserInfoRateThisAppButtonTitle { return NSLocalizedString(@"userInfoRateThisAppButtonTitle", @""); }
+ (NSString * const) UserInfoSupportSiteButtonTitle { return NSLocalizedString(@"userInfoSupportSiteButtonTitle", @""); }
+ (NSString * const) UserInfoTermsOfUseButtonTitle { return NSLocalizedString(@"userInfoTermsOfUseButtonTitle", @""); }
+ (NSString * const) UserInfoTutorialButtonTitle { return NSLocalizedString(@"userInfoTutorialButtonTitle", @""); }
+ (NSString * const) UserInfoViewAccountInfoButtonTitle { return NSLocalizedString(@"userInfoViewAccountInfoButtonTitle", @""); }
+ (NSString * const) UserInfoGetHelpSendButtonTitle { return NSLocalizedString(@"userInfoGetHelpSendButtonTitle", @""); }
+ (NSString * const) UserInfoUploadQueueButtonTitle { return NSLocalizedString(@"userInfoUploadQueueButtonTitle", @""); }
+ (NSString * const) UserInfoFeedbackTypeLabel { return NSLocalizedString(@"userInfoFeedbackTypeLabel", @""); }
+ (NSString * const) UserInfoUploadQualityButtonTitle { return NSLocalizedString(@"UserInfoUploadQualityButtonTitle", @""); }
+ (NSString * const) UserInfoUploadOptionButtonTitle { return NSLocalizedString(@"UserInfoUploadOptionButtonTitle", @""); }
+ (NSString * const) UserInfoInviteFriendsButtonTitle { return NSLocalizedString(@"UserInfoInviteFriendsButtonTitle", @""); }

/* User Info \ Version of the App */
+ (NSString * const) UserInfoVersionOfTheAppLinkToRelatedSitesButtonTitle { return NSLocalizedString(@"userInfoVersionOfTheAppLinkToRelatedSitesButtonTitle", @""); }

/* User Info \ View Account Info */
+ (NSString * const) UserInfoViewAccountInfoChangePasswordButtonTitle { return NSLocalizedString(@"userInfoViewAccountInfoChangePasswordButtonTitle", @""); }
+ (NSString * const) UserInfoViewAccountInfoChangePictureButtonTitle { return NSLocalizedString(@"userInfoViewAccountInfoChangePictureButtonTitle", @""); }
+ (NSString * const) UserInfoViewAccountInfoUpdateButtonTitle { return NSLocalizedString(@"userInfoViewAccountInfoUpdateButtonTitle", @""); }

/* User Info \ View Account Info \ Change Password */
+ (NSString * const) UserInfoViewAccountInfoChangePasswordChangePasswordButtonTitle { return NSLocalizedString(@"userInfoViewAccountInfoChangePasswordChangePasswordButtonTitle", @""); }

/* User Info \ View Account Info \ Change Picture */
+ (NSString * const) UserInfoViewAccountInfoChangePictureCloseButtonTitle { return NSLocalizedString(@"userInfoViewAccountInfoChangePictureCloseButtonTitle", @""); }
+ (NSString * const) UserInfoViewAccountInfoChangePicturePickFromLibraryButtonTitle { return NSLocalizedString(@"userInfoViewAccountInfoChangePicturePickFromLibraryButtonTitle", @""); }
+ (NSString * const) UserInfoViewAccountInfoChangePictureUseCameraButtonTitle { return NSLocalizedString(@"userInfoViewAccountInfoChangePictureUseCameraButtonTitle", @""); }
+ (NSString * const) UserInfoViewAccountInfoChangePictureUseCancelButtonTitle { return NSLocalizedString(@"userInfoViewAccountInfoChangePictureUseCancelButtonTitle", @""); }
+ (NSString * const) UserInfoViewAccountInfoChangePictureUseRetakeButtonTitle { return NSLocalizedString(@"userInfoViewAccountInfoChangePictureUseRetakeButtonTitle", @""); }
+ (NSString * const) UserInfoViewAccountInfoChangePictureUseUseButtonTitle { return NSLocalizedString(@"userInfoViewAccountInfoChangePictureUseUseButtonTitle", @""); }
+ (NSString * const) UserInfoViewAccountInfoChangePictureUsePreviewButtonTitle { return NSLocalizedString(@"userInfoViewAccountInfoChangePictureUsePreviewButtonTitle", @""); }

/* User Login */
+ (NSString * const) UserLoginLoginButtonTitle { return NSLocalizedString(@"userLoginLoginButtonTitle", @""); }
+ (NSString * const) UserLoginSignupButtonTitle { return NSLocalizedString(@"userLoginSignupButtonTitle", @""); }
+ (NSString * const) UserLoginForgotYourPasswordButtonTitle { return NSLocalizedString(@"userLoginForgotYourPasswordButtonTitle", @""); }
+ (NSString * const) UserLoginDoNotHaveAccountLabelText { return NSLocalizedString(@"userLoginDoNotHaveAccountLabelText", @""); }
+ (NSString * const) UserLoginRememberMeButtonTitle { return NSLocalizedString(@"userLoginRememberMeButtonTitle", @"Remember Me"); };

/* User Login Methods */
+ (NSString * const) UserLoginMethodsLoginButtonTitle { return NSLocalizedString(@"userLoginMethodsLoginButtonTitle", @""); }
+ (NSString * const) UserLoginMethodsLoginWithFacebookButtonTitle { return NSLocalizedString(@"userLoginMethodsLoginWithFacebookButtonTitle", @""); }
+ (NSString * const) UserLoginMethodsContinueOfflineButtonTitle { return NSLocalizedString(@"userLoginMethodsContinueOfflineButtonTitle", @""); }
+ (NSString * const) UserLoginMethodsDialogText {return NSLocalizedString(@"userLoginMethodsDialogText", @""); }

/* User Registration */
+ (NSString * const) UserRegistrationJoinVstratorButtonTitle { return NSLocalizedString(@"userRegistrationJoinVstratorButtonTitle", @""); }

/* User Welcome */
+ (NSString * const) UserWelcomeTipTitleLabel { return NSLocalizedString(@"UserWelcomeTipTitleLabel", @""); };
+ (NSString * const) UserWelcomeTipTextLabel1 { return NSLocalizedString(@"UserWelcomeTipTextLabel1", @""); };
+ (NSString * const) UserWelcomeTipTextLabel2 { return NSLocalizedString(@"UserWelcomeTipTextLabel2", @""); };
+ (NSString * const) UserWelcomeTipTextLabel3 { return NSLocalizedString(@"UserWelcomeTipTextLabel3", @""); };
+ (NSString * const) UserWelcomeTipTextLabel4 { return NSLocalizedString(@"UserWelcomeTipTextLabel4", @""); };
+ (NSString * const) UserWelcomeTipStepLabel1 { return NSLocalizedString(@"UserWelcomeTipStepLabel1", @""); };
+ (NSString * const) UserWelcomeTipStepLabel2 { return NSLocalizedString(@"UserWelcomeTipStepLabel2", @""); };
+ (NSString * const) UserWelcomeTipStepLabel3 { return NSLocalizedString(@"UserWelcomeTipStepLabel3", @""); };
+ (NSString * const) UserLegalTipTitleLabel { return NSLocalizedString(@"UserLegalTipTitleLabel", @""); };
+ (NSString * const) UserLegalTipTextLabel1 { return NSLocalizedString(@"UserLegalTipTextLabel1", @""); };
+ (NSString * const) UserLegalTipOkButton { return NSLocalizedString(@"UserLegalTipOkButton", @""); };
+ (NSString * const) UserCaptureTipTitleLabel { return NSLocalizedString(@"UserCaptureTipTitleLabel", @""); };
+ (NSString * const) UserCaptureTipTextLabel { return NSLocalizedString(@"UserCaptureTipTextLabel", @""); };
+ (NSString * const) UserCaptureTipDontShowAgainButtonTitle { return NSLocalizedString(@"UserCaptureTipDontShowAgainButtonTitle", @""); };
+ (NSString * const) UserCaptureTipOkButtonTitle { return NSLocalizedString(@"UserCaptureTipOkButtonTitle", @""); }
+ (NSString * const) UserTutorialDontShowAgainButtonTitle { return NSLocalizedString(@"UserTutorialDontShowAgainButtonTitle", @""); }

/* Upload Queue */
+ (NSString * const) UploadQueueAllButtonTitle { return NSLocalizedString(@"UploadQueueAllButtonTitle", @"All"); };
+ (NSString * const) UploadQueueInProgressButtonTitle { return NSLocalizedString(@"UploadQueueInProgressButtonTitle", @"In Progress"); };
+ (NSString * const) UploadQueueCompletedButtonTitle { return NSLocalizedString(@"UploadQueueCompletedButtonTitle", @"Completed"); };
+ (NSString * const) UploadQueueListEmptyText { return NSLocalizedString(@"UploadQueueListEmptyText", @"You don’t have any videos being uploaded"); }
+ (NSString * const) UploadQueueListNotFoundText { return NSLocalizedString(@"UploadQueueListEmptyText", @"You don’t have any videos being uploaded"); }
+ (NSString * const) UploadQueueRetryingActivityTitle { return NSLocalizedString(@"UploadQueueRetryingActivityTitle", @"Trying to retry..."); }

/* UploadRequestListViewCellRetryButtonTitle */
+ (NSString * const) UploadRequestListViewCellRetryButtonTitle { return NSLocalizedString(@"UploadRequestListViewCellRetryButtonTitle", @"Retry"); };

/* Error messages */
+ (NSString * const) ErrorAccessToTwitterAccountsDeniedText { return NSLocalizedString(@"ErrorAccessToTwitterAccountsDeniedText", @"Access to Twitter properties denied"); }
+ (NSString * const) ErrorAudioRecorderInitText { return NSLocalizedString(@"ErrorAudioRecorderInitText", @"Cannot initialize audio recorder"); }
+ (NSString * const) ErrorVideoPlayerInitText { return NSLocalizedString(@"ErrorVideoPlayerInitText", @"Cannot initialize video player"); }
+ (NSString * const) ErrorAudioRecorderRecordText { return NSLocalizedString(@"ErrorAudioRecorderRecordText", @"Cannot record audio"); }
+ (NSString * const) ErrorBaseUrlIsNilOrInvalidText { return NSLocalizedString(@"ErrorBaseUrlIsNilOrInvalidText", @"Base URL is NIL"); }
+ (NSString * const) ErrorClipAlreadyInTheLibraryText { return NSLocalizedString(@"ErrorClipAlreadyInTheLibraryText", @"Clip is already in the library"); }
+ (NSString * const) ErrorClipDurationExceedMaxText { return NSLocalizedString(@"ErrorClipDurationExceedMaxText", @"Duration of chosen clip exceeds maximum (15 seconds)"); }
+ (NSString * const) ErrorClipNotFoundInTheLibraryText { return NSLocalizedString(@"ErrorClipNotFoundInTheLibraryText", @"Clip not found in the library"); }
+ (NSString * const) ErrorCredentialsAreNilOrInvalidText { return NSLocalizedString(@"ErrorCredentialsAreNilOrInvalidText", @"Credentials are not set or invalid"); }
+ (NSString * const) ErrorCurrentUserHasIncompleteUploadsText { return NSLocalizedString(@"ErrorCurrentUserHasIncompleteUploadsText", @"You have incomplete uploads. Please wait them to complete before logout."); }
+ (NSString * const) ErrorCurrentUserNotFoundText { return NSLocalizedString(@"ErrorCurrentUserNotFoundText", @"Current user not found"); }
+ (NSString * const) ErrorDatabaseInitFailedText { return NSLocalizedString(@"ErrorDatabaseInitFailedText", @"Database init failure"); }
+ (NSString * const) ErrorDatabaseSelectText { return NSLocalizedString(@"ErrorDatabaseSelectText", @"Error querying data from the database"); }
+ (NSString * const) ErrorEmailAddressBeginsOrEndsWithSpacesText { return NSLocalizedString(@"ErrorEmailAddressBeginsOrEndsWithSpacesText", @"Email address begins or ends with spaces"); }
+ (NSString * const) ErrorEmailAddressHasInvalidLengthText { return [NSString stringWithFormat:NSLocalizedString(@"ErrorEmailAddressHasInvalidLengthText", @"Email address must have length no more than %d symbols"), VstratorConstants.MaxEmailLength]; }
+ (NSString * const) ErrorEmailAddressIsEmptyText { return NSLocalizedString(@"ErrorEmailAddressIsEmptyText", @"Email address is empty"); }
+ (NSString * const) ErrorEmailAddressIsInvalidText { return NSLocalizedString(@"ErrorEmailAddressIsInvalidText", @"Email address is invalid"); }
+ (NSString * const) ErrorFacebookResponseIsInvalidText { return NSLocalizedString(@"ErrorFacebookResponseIsInvalidText", @"Facebook response is invalid"); }
+ (NSString * const) ErrorFacebookResponseNotContainRequiredDataText { return NSLocalizedString(@"ErrorFacebookResponseNotContainRequiredDataText", @"Facebook does not provide all required information: first and last name and email. Please grant access to this information."); }
+ (NSString * const) ErrorFirstNameBeginsOrEndsWithSpacesText { return NSLocalizedString(@"ErrorFirstNameBeginsOrEndsWithSpacesText", @"First name begins or ends with spaces"); }
+ (NSString * const) ErrorFirstNameHasInvalidLengthText { return [NSString stringWithFormat:NSLocalizedString(@"ErrorFirstNameHasInvalidLengthText", @"First name must have length no more than %d symbols"), VstratorConstants.MaxNameLength]; }
+ (NSString * const) ErrorFirstNameIsEmptyText { return NSLocalizedString(@"ErrorFirstNameIsEmptyText", @"First name is empty"); }
+ (NSString * const) ErrorFirstNameIsInvalidText { return NSLocalizedString(@"ErrorFirstNameIsInvalidText", @"First name is invalid"); }
+ (NSString * const) ErrorGenericTitle { return NSLocalizedString(@"ErrorGenericTitle", @"Error!"); }
+ (NSString * const) ErrorIncompatibleVideoType { return NSLocalizedString(@"ErrorIncompatibleVideoType", @"Picked file is incompatible with Photo Library"); }
+ (NSString * const) ErrorInvalidParameterValue { return NSLocalizedString(@"ErrorInvalidParameterValue", @"Invalid parameter value"); }
+ (NSString * const) ErrorIssueDescriptionIsEmptyText { return NSLocalizedString(@"ErrorIssueDescriptionIsEmptyText", @"Issue description is empty"); }
+ (NSString * const) ErrorIssueDescriptionIsInvalidText { return NSLocalizedString(@"ErrorIssueDescriptionIsInvalidText", @"Issue description is invalid"); }
+ (NSString * const) ErrorIssueTypeIsEmptyText { return NSLocalizedString(@"ErrorIssueTypeIsEmptyText", @"Issue type is not selected"); }
+ (NSString * const) ErrorIssueTypeIsInvalidText { return NSLocalizedString(@"ErrorIssueTypeIsInvalidText", @"Issue type is invalid"); }
+ (NSString * const) ErrorMediaServiceAssertionFailureText { return NSLocalizedString(@"ErrorMediaServiceAssertionFailureText", @"Media Service assertion failure"); }
+ (NSString * const) ErrorMediaServiceThreadingInconsistencyText { return NSLocalizedString(@"ErrorMediaServiceThreadingInconsistencyText", @"Media Service threading inconsistency"); }
+ (NSString * const) ErrorMemoryWarningOnTelestrationText { return NSLocalizedString(@"ErrorMemoryWarningOnTelestrationText", @"Memory warning text while telestrating"); }
+ (NSString * const) ErrorMemoryWarningOnTelestrationTitle { return NSLocalizedString(@"ErrorMemoryWarningOnTelestrationTitle", @"Memory warning title while telestrating"); }
+ (NSString * const) ErrorNoMediaSourcesAvailableText { return NSLocalizedString(@"ErrorNoMediaSourcesAvailableText", @"Neither Camera nor Photo Library is available."); }
+ (NSString * const) ErrorOldPasswordIsNotValidText { return NSLocalizedString(@"ErrorOldPasswordIsNotValidText", @"Current password is invalid"); }
+ (NSString * const) ErrorPasswordHasInvalidLengthText { return NSLocalizedString(@"ErrorPasswordHasInvalidLengthText", @"Password must have length between 6 and 20 symbols"); }
+ (NSString * const) ErrorPasswordIsEmptyText { return NSLocalizedString(@"ErrorPasswordIsEmptyText", @"Password is empty"); }
+ (NSString * const) ErrorPasswordIsInvalidText { return NSLocalizedString(@"ErrorPasswordIsInvalidText", @"Password is invalid"); }
+ (NSString * const) ErrorPasswordsAreNotEqualText { return NSLocalizedString(@"ErrorPasswordsAreNotEqualText", @"Passwords do not match"); }
+ (NSString * const) ErrorPhotoLibraryIsUnavailable { return NSLocalizedString(@"ErrorPhotoLibraryIsUnavailable", @"Photo Library is unavailable"); }
+ (NSString * const) ErrorPrimarySportIsEmptyText { return NSLocalizedString(@"ErrorPrimarySportIsEmptyText", @"Primary sport is not selected"); }
+ (NSString * const) ErrorPrimarySportIsInvalidText { return NSLocalizedString(@"ErrorPrimarySportIsInvalidText", @"Primary sport is invalid"); }
+ (NSString * const) ErrorRetryingUploadRequestText { return NSLocalizedString(@"ErrorRetryingUploadRequestText", @"Sorry, attempt to retry has failed. Please try again."); }
+ (NSString * const) ErrorSecondNameBeginsOrEndsWithSpacesText { return NSLocalizedString(@"ErrorSecondNameBeginsOrEndsWithSpacesText", @"Last name begins or ends with spaces"); }
+ (NSString * const) ErrorSecondNameHasInvalidLengthText { return [NSString stringWithFormat:NSLocalizedString(@"ErrorSecondNameHasInvalidLengthText", @"Last name must have length no more than %d symbols"), VstratorConstants.MaxNameLength]; }
+ (NSString * const) ErrorSecondNameIsEmptyText { return NSLocalizedString(@"ErrorSecondNameIsEmptyText", @"Last name is empty"); }
+ (NSString * const) ErrorSecondNameIsInvalidText { return NSLocalizedString(@"ErrorSecondNameIsInvalidText", @"Last name is invalid"); }
+ (NSString * const) ErrorSelectedActionIsEmptyText { return NSLocalizedString(@"ErrorSelectedActionIsEmptyText", @"Action is not selected"); }
+ (NSString * const) ErrorSelectedActionIsInvalidText { return NSLocalizedString(@"ErrorSelectedActionIsInvalidText", @"Action is invalid"); }
+ (NSString * const) ErrorSelectedSportActionNotFoundText { return NSLocalizedString(@"ErrorSelectedSportActionNotFoundText", @"Sport and/or action not found"); }
+ (NSString * const) ErrorSelectedSportIsEmptyText { return NSLocalizedString(@"ErrorSelectedSportIsEmptyText", @"Sport is not selected"); }
+ (NSString * const) ErrorSelectedSportIsInvalidText { return NSLocalizedString(@"ErrorSelectedSportIsInvalidText", @"Sport is invalid"); }
+ (NSString * const) ErrorSideBySideClipsAreNotSelectedText { return NSLocalizedString(@"ErrorSideBySideClipsAreNotSelectedText", @"Please select both clips to Side By Side"); }
+ (NSString * const) ErrorTitleBeginsOrEndsWithSpacesText { return NSLocalizedString(@"ErrorTitleBeginsOrEndsWithSpacesText", @"Title begins or ends with spaces"); }
+ (NSString * const) ErrorTitleHasInvalidLengthText { return [NSString stringWithFormat:NSLocalizedString(@"ErrorTitleHasInvalidLengthText", @"Title must have length no more than %d symbols"), VstratorConstants.MaxTitleLength]; }
+ (NSString * const) ErrorTitleIsEmptyText { return NSLocalizedString(@"ErrorTitleIsEmptyText", @"Title is empty"); }
+ (NSString * const) ErrorTitleIsInvalidText { return NSLocalizedString(@"ErrorTitleIsInvalidText", @"Title is invalid"); }
+ (NSString * const) ErrorTitleCantSaveSession { return NSLocalizedString(@"ErrorTitleCantSaveSession", @"Can't save session"); };
+ (NSString * const) ErrorSavingSession { return NSLocalizedString(@"ErrorSavingSession", @"There was a problem saving this session. Please try again."); };
+ (NSString * const) ErrorTwitterAccountNotSelectedText { return NSLocalizedString(@"ErrorTwitterAccountNotSelectedText", @"Twitter account not selected or not set"); }
+ (NSString * const) ErrorTwitterAccountsNotFoundText { return NSLocalizedString(@"ErrorTwitterAccountsNotFoundText", @"Twitter accounts not found. Please add at least one."); }
+ (NSString * const) ErrorTwitterUnderDevelopmentForIOS4Text { return NSLocalizedString(@"ErrorTwitterUnderDevelopmentForIOS4Text", @"Twitter is only supported for iOS 5 and greater"); }
//+ (NSString * const) ErrorUnderDevelopmentText { return @"Under development"; }
+ (NSString * const) ErrorUnknownAccountTypeText { return NSLocalizedString(@"ErrorUnknownAccountTypeText", @"Unknown account type"); }
+ (NSString * const) ErrorUserIsLoggedInText { return NSLocalizedString(@"ErrorUserIsLoggedInText", @"User is already logged in.\nPlease logout first!"); }
+ (NSString * const) ErrorUserNotFoundText { return NSLocalizedString(@"ErrorUserNotFoundText", @"User not found"); }
+ (NSString * const) ErrorUserNotLoggedInText { return NSLocalizedString(@"ErrorUserNotLoggedInText", @"User not logged in.\nPlease login first!"); }
+ (NSString * const) ErrorValueIsEmptyText { return NSLocalizedString(@"ErrorValueIsEmptyText", @"Value is empty"); }
+ (NSString * const) ErrorValueIsInvalidText { return NSLocalizedString(@"ErrorValueIsInvalidText", @"Value is invalid"); }
+ (NSString * const) ErrorVideoFileDoesNotExists { return NSLocalizedString(@"ErrorVideoFileDoesNotExists", @"Video file does not exist"); }
+ (NSString * const) ErrorVstratorApiIsUnreachableText { return NSLocalizedString(@"ErrorVstratorApiIsUnreachableText", @"Vstrator site is unavailable now"); }
+ (NSString * const) ErrorWrongInputText { return NSLocalizedString(@"ErrorWrongInputText", @"One or more fields contain empty or invalid values.\nPlease input valid values."); }
+ (NSString * const) ErrorWrongInputTitle { return NSLocalizedString(@"ErrorWrongInputTitle", @"Wrong input!"); }
+ (NSString * const) ErrorLoadingSelectedClip { return NSLocalizedString(@"ErrorLoadingSelectedClip", @"Cannot load selected clip"); }
+ (NSString * const) ErrorLoadingSelectedSession { return NSLocalizedString(@"ErrorLoadingSelectedSession", @"Cannot load selected session"); }
+ (NSString * const) ErrorAudioSessionInitText { return NSLocalizedString(@"ErrorAudioSessionInitText", @"Error initializing audio session"); }
+ (NSString * const) ErrorActivatingAudioSessionOrPlayer { return NSLocalizedString(@"ErrorActivatingAudioSessionOrPlayer", @"Error initializing audio session or player"); }
+ (NSString * const) ErrorAudioPlayerInitText { return NSLocalizedString(@"ErrorAudioPlayerInitText", @"Error initializing player"); }
+ (NSString * const) ErrorLoginCanceled { return NSLocalizedString(@"ErrorLoginCanceled", @"Login canceled"); }
+ (NSString * const) ErrorLogoutCanceledDueIncompleteUploadsText { return NSLocalizedString(@"ErrorLogoutCanceledDueIncompleteUploadsText", @"Logout canceled because you have incomplete uploads. Please wait them to complete before logout."); }
+ (NSString * const) ErrorRecordingNotAvailableOnThisDevice { return NSLocalizedString(@"ErrorRecordingNotAvailableOnThisDevice", @"Video recording unavailable"); }
+ (NSString * const) ErrorRecordReason { return NSLocalizedString(@"ErrorRecordReason", @"Movies recorded on this device will only contain audio."); }
+ (NSString * const) ErrorUnableToOpenSafariWithURL { return NSLocalizedString(@"ErrorUnableToOpenSafariWithURL", "Unable to open Safari for Vstrator site"); }
+ (NSString * const) ErrorUnableToOpenURL { return NSLocalizedString(@"ErrorUnableToOpenURL", "Unable to open the Vstrator site"); }
+ (NSString * const) ErrorUploadThisVideoFirst { return NSLocalizedString(@"ErrorUploadThisVideoFirst", "You need to upload this video first"); }

+ (NSString * const)ErrorValidateDeleteMedia { return NSLocalizedString(@"ErrorValidateDeleteMedia", @"Cannot delete the media"); }
+ (NSString * const)ErrorValidateDeleteMediaWithExcercises { return NSLocalizedString(@"ErrorValidateDeleteMediaWithExcercises", @"Cannot delete the media. The media has linked object(s)"); }
+ (NSString * const)ErrorValidateDeleteMediaWithSessions { return NSLocalizedString(@"ErrorValidateDeleteMediaWithSessions", @"Cannot delete the media. The media has linked object(s)"); }
+ (NSString * const)ErrorValidateDeleteProcessingMedia { return NSLocalizedString(@"ErrorValidateDeleteProcessingMedia", @"Cannot delete processing media"); }
+ (NSString * const)ErrorCannotShareMedia { return NSLocalizedString(@"ErrorCannotShareMedia", @"Cannot share media"); }
+ (NSString * const)ErrorCannotSendMail { return NSLocalizedString(@"ErrorCannotSendMail", @"Cannot share media"); }
+ (NSString * const)ErrorCannotSendSms { return NSLocalizedString(@"ErrorCannotSendSms", @"Cannot share media"); }
+ (NSString * const)ErrorWithoutDescription { return NSLocalizedString(@"ErrorWithoutDescription", @"Unknown error"); }

/* Join the community */
+ (NSString *const)JoinCommunityCloseButtonTitle { return NSLocalizedString(@"JoinCommunityCloseButtonTitle", @""); }
+ (NSString *const)JoinCommunityGoButtonTitle { return NSLocalizedString(@"JoinCommunityGoButtonTitle", @""); }
+ (NSString *const)JoinCommunityReason1 { return NSLocalizedString(@"JoinCommunityReason1", @""); }
+ (NSString *const)JoinCommunityReason2 { return NSLocalizedString(@"JoinCommunityReason2", @""); }
+ (NSString *const)JoinCommunityReason3 { return NSLocalizedString(@"JoinCommunityReason3", @""); }

@end
