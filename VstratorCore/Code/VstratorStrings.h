//
//  VstratorLabels.h
//  VstratorApp
//
//  Created by Oleg Bragin on 14.07.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VstratorStrings : NSObject

+ (NSString * const) ProUserName;
+ (NSString * const) UnknownUserName;

/* Screen Titles */
+ (NSString * const) TitleLogin;
+ (NSString * const) TitleRegistration;
+ (NSString * const) TitleContentPro;
+ (NSString * const) TitleContentVstrate;
+ (NSString * const) TitleContentSideBySide;
+ (NSString * const) TitleContentUploadQueue;
+ (NSString * const) TitleSearch;

/* Feedback Type */
+ (NSString * const) IssueTypeBugReportName;
+ (NSString * const) IssueTypeFeedbackName;
+ (NSString * const) IssueTypeSuggestionName;
+ (NSString * const) IssueTypeEmpty;

/* Quality */
+ (NSString * const) UploadQualityHighName;
+ (NSString * const) UploadQualityLowName;

// Upload options
+ (NSString * const) UploadOnlyOnWiFiName;
+ (NSString * const) UploadOnWWANName;

/* Home \ Quick start */
+ (NSString * const) HomeQuickStartVstrateLabel;
+ (NSString * const) HomeQuickStartVstrateSubLabel1;
+ (NSString * const) HomeQuickStartVstrateSubLabel2;
+ (NSString * const) HomeQuickStartProLabel;
+ (NSString * const) HomeQuickStartProSubLabel1;
+ (NSString * const) HomeQuickStartProSubLabel2;

/* Home \ Pro */
+ (NSString * const) HomeProUserNoExtrasLabel;
+ (NSString * const) HomeProUserNoClipsLabel;

/* Home \ Side-by-Side */
+ (NSString * const) HomeSideBySideSelectClipLabel;
+ (NSString * const) HomeSideBySideLabel;

/* Home \ Vstrate */
+ (NSString * const) HomeVstrateLabel;

/* Media \ Clip Playback */
+ (NSString * const) MediaClipPlaybackLoadingActivityTitle;
+ (NSString * const) MediaClipPlaybackProcessingActivityTitle;

/* Media \ Clip/Session Creation */
+ (NSString * const) MediaClipSessionCreationSavingSessionActivityTitle;
+ (NSString * const) ProgressSavingVideo;

/* Media \ Clip/Session Edit */
+ (NSString * const) MediaClipSessionEditSavingMediaActivityTitle;
+ (NSString * const) MediaClipSessionEditClipTitleField;
+ (NSString * const) MediaClipSessionEditTitleLabel;
+ (NSString * const) MediaClipSessionEditActionLabel;
+ (NSString * const) MediaClipSessionEditSportActionLabel;
+ (NSString * const) MediaClipSessionEditSelectActionLabel;
+ (NSString * const) MediaClipSessionEditSelectSportLabel;
+ (NSString * const) MediaClipSessionEditSportLabel;
+ (NSString * const) MediaClipSessionEditNotesLabel;
+ (NSString * const) MediaClipSessionEditCompressingVideoMessage;
+ (NSString * const) MediaClipSessionEditDoYouWantToCancel;
+ (NSString * const) MediaClipSessionEditTitleEditMode;
+ (NSString * const) MediaClipSessionEditTitleVstrationMode;

/* Media \ Clip/Session View (Open) */
+ (NSString * const) MediaClipSessionViewSideBySide;
+ (NSString * const) MediaClipSessionViewClipTitleAndActionLabel;
+ (NSString * const) MediaClipSessionViewShareLabel;
+ (NSString * const) MediaClipSessionViewTwitterSubmitButtonTitle;
+ (NSString * const) MediaClipSessionViewTwitterMessageLabel;
+ (NSString * const) MediaClipSessionViewFacebookSubmitButtonTitle;
+ (NSString * const) MediaClipSessionViewFacebookMessageLabel;
+ (NSString * const) MediaClipSessionViewMailSubmitButtonTitle;
+ (NSString * const) MediaClipSessionViewMailMessageLabel;
+ (NSString * const) MediaClipSessionViewSmsSubmitButtonTitle;
+ (NSString * const) MediaClipSessionViewSmsMessageLabel;
+ (NSString * const) MediaClipSessionViewShareActivityTitle;
+ (NSString * const) MediaClipSessionViewSessionLogoTitle;

/* Media \ Lists */
+ (NSString * const) MediaListAllNoClipsExist;
+ (NSString * const) MediaListAllNoClipsFound;
+ (NSString * const) MediaListAllNoSessionsExist;
+ (NSString * const) MediaListAllNoSessionsFound;
+ (NSString * const) MediaListUserNoClipsExist;
+ (NSString * const) MediaListUserNoClipsFound;
+ (NSString * const) MediaListUserNoSessionsExist;
+ (NSString * const) MediaListUserNoSessionsFound;
+ (NSString * const) MediaListProNoClipsExist;
+ (NSString * const) MediaListProNoClipsFound;
+ (NSString * const) MediaListProNoSessionsExist;
+ (NSString * const) MediaListProNoSessionsFound;

/* Media \ Share Twitter */
+ (NSString * const) MediaClipShareTwitterMessage;
+ (NSString * const) MediaClipShareFacebookMessage;
+ (NSString * const) MediaClipShareMailMessage;
+ (NSString * const) MediaClipShareSmsMessage;
+ (NSString * const) MediaClipShareMailSubjectFormat;
+ (NSString * const) ShareMediaConfirmation;
+ (NSString * const) InviteFriendsConfirmation;
+ (NSString * const) InviteFriendsShareMessage;
+ (NSString * const) SharePopupDoneButtonTitle;
+ (NSString * const) SharePopupTitle;
+ (NSString * const) InviteFriendsPopupTitle;
+ (NSString * const) InviteFriendsBackButtonTitle;
+ (NSString * const) ShareWorkoutTitle;
+ (NSString * const) ShareWorkoutMessage;

/* User Info \ Get Help */
+ (NSString * const) UserInfoGetHelpSendingIssueActivityTitle;
+ (NSString * const) UserInfoGetHelpIssueDescriptionLabel;
+ (NSString * const) UserInfoGetHelpIssueSentMessage;
+ (NSString * const) UserInfoGetHelpIssueSentMessageTitle;

/* User Info \ Version of the App */
+ (NSString * const) UserInfoVersionOfTheAppLabel;
+ (NSString * const) UserInfoLicenseOfTheAppLabel;

/* User Info \ View Account Info */
+ (NSString * const) UserInfoViewAccountInfoUpdatingProfileActivityTitle;
+ (NSString * const) UserInfoViewAccountInfoProfileUpdatedMessage;
+ (NSString * const) UserInfoViewAccountInfoProfileUpdatedMessageTitle;
+ (NSString * const) UserInfoViewAccountInfoPasswordUpdatedMessage;
+ (NSString * const) UserInfoViewAccountInfoPasswordUpdatedMessageTitle;

/* User Info \ View Account Info \ Change Password */
+ (NSString * const) UserInfoViewAccountInfoChangePasswordUpdatingPasswordActivityTitle;
+ (NSString * const) UserInfoViewAccountInfoChangePasswordConfirmNewPasswordField;
+ (NSString * const) UserInfoViewAccountInfoChangePasswordCurrentPasswordField;
+ (NSString * const) UserInfoViewAccountInfoChangePasswordNewPasswordField;

/* User Info \ View Account Info \ Change Picture */
+ (NSString * const) UserInfoViewAccountInfoChangePictureUpdatingProfileActivityTitle;

/* User Info \ View Account Info \ Change Picture \ Use Camera */
+ (NSString * const) UserInfoViewAccountInfoChangePictureUseCameraPreviewLabel;

/* User Login */
+ (NSString * const) UserLoginLoggingInActivityTitle;
+ (NSString * const) UserLoginLoggingInFacebookActivityTitle;
+ (NSString * const) UserLoginLoggingOutActivityTitle;
+ (NSString * const) UserLoginEmailAddressField;
+ (NSString * const) UserLoginPasswordField;
+ (NSString * const) UserLoginLoginLabel;
+ (NSString * const) UserLoginOrLabel;

/* User Login Methods */
+ (NSString * const) UserLoginMethodsLoggingInFacebookActivityTitle;

/* User Registration */
+ (NSString * const) UserRegistrationRegisteringUserActivityTitle;
+ (NSString * const) UserRegistrationConfirmPasswordField;
+ (NSString * const) UserRegistrationEmailAddressField;
+ (NSString * const) UserRegistrationFirstNameField;
+ (NSString * const) UserRegistrationLastNameField;
+ (NSString * const) UserRegistrationPasswordField;
+ (NSString * const) UserRegistrationRegistrationLabel;

/* Notifications */
+ (NSString * const) ProcessingNotificationButtonActivityTitle;

/* Misc */
+ (NSString * const) LoadingActivityTitle;
+ (NSString * const) SecondsText;

/* Button titles */

/* Home \ Pro */
+ (NSString * const) HomeProUserStrokesButtonTitle;
+ (NSString * const) HomeProUserTutorialsButtonTitle;
+ (NSString * const) HomeProUserInterviewsButtonTitle;

/* Home \ Capture Clip */
+ (NSString * const) HomeCaptureClipDialogTitle;
+ (NSString * const) HomeCaptureClipCancelButtonTitle;
+ (NSString * const) HomeCaptureClipCloseButtonTitle;
+ (NSString * const) HomeCaptureClipImportButtonTitle;
+ (NSString * const) HomeCaptureClipPickFromLibraryButtonTitle;
+ (NSString * const) HomeCaptureClipUseCameraButtonTitle;
+ (NSString * const) HomeCaptureClipShowGuidesButtonTitle;
+ (NSString * const) HomeCaptureClipFpsLabel;

/* Home \ Side-by-Side */
+ (NSString * const) HomeSideBySideCaptureClipButtonTitle;
+ (NSString * const) HomeSideBySideSelectClipButtonTitle;
+ (NSString * const) HomeSideBySideStartSideBySideClipButtonTitle;

/* Home \ Vstrate */
+ (NSString * const) HomeVstrateAllButtonTitle;
+ (NSString * const) HomeVstrateProContentButtonTitle;
+ (NSString * const) HomeVstrateProClipsButtonTitle;
+ (NSString * const) HomeVstrateCaptureClipButtonTitle;
+ (NSString * const) HomeVstrateMyClipsButtonTitle;
+ (NSString * const) HomeVstrateSideBySideButtonTitle;
+ (NSString * const) HomeVstrateVstrateButtonTitle;
+ (NSString * const) HomeVstrateVstratedClipsButtonTitle;

/* Media \ Clip Playback */
+ (NSString * const) MediaClipPlaybackDoneButtonTitle;

/* Media \ Clip/Session Edit */
+ (NSString * const) MediaClipSessionEditCancelButtonTitle;
+ (NSString * const) MediaClipSessionEditYesButtonTitle;
+ (NSString * const) MediaClipSessionEditNoButtonTitle;
+ (NSString * const) MediaClipSessionEditDeleteClipButtonTitle;
+ (NSString * const) MediaClipSessionEditSaveAndShootButtonTitle;
+ (NSString * const) MediaClipSessionEditSaveAndUseButtonTitle;
+ (NSString * const) MediaClipSessionEditDeleteAndShootButtonTitle;
+ (NSString * const) MediaClipSessionEditDoYouWantToDelete;

/* Media \ Clip/Session View (Open) */
+ (NSString * const) MediaClipSessionViewCancelButtonTitle;
+ (NSString * const) MediaClipSessionViewDetailsButtonTitle;
+ (NSString * const) MediaClipSessionViewDoneButtonTitle;
+ (NSString * const) MediaClipSessionViewSaveButtonTitle;
+ (NSString * const) MediaClipSessionViewShareButtonTitle;
+ (NSString * const) MediaClipSessionViewSideBySideButtonTitle;
+ (NSString * const) MediaClipSessionViewTrimButtonTitle;
+ (NSString * const) MediaClipSessionViewUploadButtonTitle;
+ (NSString * const) MediaClipSessionViewUploadingButtonTitle;
+ (NSString * const) MediaClipSessionViewUploadedButtonTitle;
+ (NSString * const) MediaClipSessionViewUploadRetryButtonTitle;
+ (NSString * const) MediaClipSessionViewVstrateButtonTitle;
+ (NSString * const) MediaClipSessionViewDownloadButtonTitle;

/* Download Content */

+ (NSString * const) DownloadContentTitleText;

/* Media \ Session Creation */
+ (NSString * const) MediaClipSessionCreationColorsButtonTitle;
+ (NSString * const) MediaClipSessionCreationStartButtonTitle;
+ (NSString * const) MediaClipSessionCreationStopButtonTitle;
+ (NSString * const) MediaClipSessionCreationToolsButtonTitle;
+ (NSString * const) MediaClipSessionCreationUndoButtonTitle;
+ (NSString * const) MediaClipSessionCreationBackButtonTitle;
+ (NSString * const) MediaClipSessionCreationTimelineButtonTitle;
+ (NSString * const) MediaClipSessionCreationZoomButtonTitle;

/* Media \ Session Playback */
+ (NSString * const) MediaSessionPlaybackRedoButtonTitle;
+ (NSString * const) MediaSessionPlaybackSaveButtonTitle;

/* Media \ List/Cells */
+ (NSString * const) MediaListViewCellSelectButtonTitle;
+ (NSString * const) MediaListViewCellDeleteButtonTitle;
+ (NSString * const) MediaListViewHeaderSyncButtonTitle;
+ (NSString * const) MediaListViewProHeaderDownloadButtonTitle;

/* Navigation Bar */
+ (NSString * const) NavigationBarBackButtonTitle;
+ (NSString * const) NavigationBarCancelButtonTitle;
+ (NSString * const) NavigationBarDoneButtonTitle;
+ (NSString * const) NavigationBarInfoButtonTitle;
+ (NSString * const) NavigationBarSearchButtonTitle;

/* User Info */
+ (NSString * const) UserInfoAboutThisAppButtonTitle;
+ (NSString * const) UserInfoGetHelpButtonTitle;
+ (NSString * const) UserInfoLogoutButtonTitle;
+ (NSString * const) UserInfoRateThisAppButtonTitle;
+ (NSString * const) UserInfoSupportSiteButtonTitle;
+ (NSString * const) UserInfoTermsOfUseButtonTitle;
+ (NSString * const) UserInfoTutorialButtonTitle;
+ (NSString * const) UserInfoViewAccountInfoButtonTitle;
+ (NSString * const) UserInfoGetHelpSendButtonTitle;
+ (NSString * const) UserInfoUploadQueueButtonTitle;
+ (NSString * const) UserInfoFeedbackTypeLabel;
+ (NSString * const) UserInfoUploadQualityButtonTitle;
+ (NSString * const) UserInfoInviteFriendsButtonTitle;

/* User Info \ Version of the App */
+ (NSString * const) UserInfoVersionOfTheAppLinkToRelatedSitesButtonTitle;

/* User Info \ View Account Info */
+ (NSString * const) UserInfoViewAccountInfoChangePasswordButtonTitle;
+ (NSString * const) UserInfoViewAccountInfoChangePictureButtonTitle;
+ (NSString * const) UserInfoViewAccountInfoUpdateButtonTitle;

/* User Info \ View Account Info \ Change Password */
+ (NSString * const) UserInfoViewAccountInfoChangePasswordChangePasswordButtonTitle;

/* User Info \ View Account Info \ Change Picture */
+ (NSString * const) UserInfoViewAccountInfoChangePictureCloseButtonTitle;
+ (NSString * const) UserInfoViewAccountInfoChangePicturePickFromLibraryButtonTitle;
+ (NSString * const) UserInfoViewAccountInfoChangePictureUseCameraButtonTitle;
+ (NSString * const) UserInfoViewAccountInfoChangePictureUseCancelButtonTitle;
+ (NSString * const) UserInfoViewAccountInfoChangePictureUseRetakeButtonTitle;
+ (NSString * const) UserInfoViewAccountInfoChangePictureUseUseButtonTitle;
+ (NSString * const) UserInfoViewAccountInfoChangePictureUsePreviewButtonTitle;

/* User Login */
+ (NSString * const) UserLoginLoginButtonTitle;
+ (NSString * const) UserLoginSignupButtonTitle;
+ (NSString * const) UserLoginForgotYourPasswordButtonTitle;
+ (NSString * const) UserLoginDoNotHaveAccountLabelText;
+ (NSString * const) UserLoginRememberMeButtonTitle;

/* User Login Methods */
+ (NSString * const) UserLoginMethodsLoginButtonTitle;
+ (NSString * const) UserLoginMethodsLoginWithFacebookButtonTitle;
+ (NSString * const) UserLoginMethodsContinueOfflineButtonTitle;
+ (NSString * const) UserLoginMethodsDialogText;

/* User Registration */
+ (NSString * const) UserRegistrationJoinVstratorButtonTitle;

/* User Tips */
+ (NSString * const) UserWelcomeTipTitleLabel;
+ (NSString * const) UserWelcomeTipTextLabel1;
+ (NSString * const) UserWelcomeTipTextLabel2;
+ (NSString * const) UserWelcomeTipTextLabel3;
+ (NSString * const) UserWelcomeTipTextLabel4;
+ (NSString * const) UserWelcomeTipStepLabel1;
+ (NSString * const) UserWelcomeTipStepLabel2;
+ (NSString * const) UserWelcomeTipStepLabel3;
+ (NSString * const) UserLegalTipTitleLabel;
+ (NSString * const) UserLegalTipTextLabel1;
+ (NSString * const) UserLegalTipOkButton;
+ (NSString * const) UserCaptureTipTitleLabel;
+ (NSString * const) UserCaptureTipTextLabel;
+ (NSString * const) UserCaptureTipDontShowAgainButtonTitle;
+ (NSString * const) UserCaptureTipOkButtonTitle;
+ (NSString * const) UserTutorialDontShowAgainButtonTitle;

/* Upload Queue */
+ (NSString * const) UploadQueueAllButtonTitle;
+ (NSString * const) UploadQueueInProgressButtonTitle;
+ (NSString * const) UploadQueueCompletedButtonTitle;
+ (NSString * const) UploadQueueListEmptyText;
+ (NSString * const) UploadQueueListNotFoundText;
+ (NSString * const) UploadQueueRetryingActivityTitle;

/* UploadRequestListViewCellRetryButtonTitle */
+ (NSString * const) UploadRequestListViewCellRetryButtonTitle;

/* Error messages */
+ (NSString * const) ErrorAccessToTwitterAccountsDeniedText;
+ (NSString * const) ErrorAudioRecorderInitText;
+ (NSString * const) ErrorVideoPlayerInitText;
+ (NSString * const) ErrorAudioRecorderRecordText;
+ (NSString * const) ErrorBaseUrlIsNilOrInvalidText;
+ (NSString * const) ErrorClipAlreadyInTheLibraryText;
+ (NSString * const) ErrorClipDurationExceedMaxText;
+ (NSString * const) ErrorClipNotFoundInTheLibraryText;
+ (NSString * const) ErrorCredentialsAreNilOrInvalidText;
+ (NSString * const) ErrorCurrentUserNotFoundText;
+ (NSString * const) ErrorDatabaseInitFailedText;
+ (NSString * const) ErrorDatabaseSelectText;
+ (NSString * const) ErrorEmailAddressBeginsOrEndsWithSpacesText;
+ (NSString * const) ErrorEmailAddressHasInvalidLengthText;
+ (NSString * const) ErrorEmailAddressIsEmptyText;
+ (NSString * const) ErrorEmailAddressIsInvalidText;
+ (NSString * const) ErrorFacebookResponseIsInvalidText;
+ (NSString * const) ErrorFacebookResponseNotContainRequiredDataText;
+ (NSString * const) ErrorFirstNameBeginsOrEndsWithSpacesText;
+ (NSString * const) ErrorFirstNameHasInvalidLengthText;
+ (NSString * const) ErrorFirstNameIsEmptyText;
+ (NSString * const) ErrorFirstNameIsInvalidText;
+ (NSString * const) ErrorGenericTitle;
+ (NSString * const) ErrorIncompatibleVideoType;
+ (NSString * const) ErrorInvalidParameterValue;
+ (NSString * const) ErrorIssueDescriptionIsEmptyText;
+ (NSString * const) ErrorIssueDescriptionIsInvalidText;
+ (NSString * const) ErrorIssueTypeIsEmptyText;
+ (NSString * const) ErrorIssueTypeIsInvalidText;
+ (NSString * const) ErrorMediaServiceAssertionFailureText;
+ (NSString * const) ErrorMediaServiceThreadingInconsistencyText;
+ (NSString * const) ErrorMemoryWarningOnTelestrationText;
+ (NSString * const) ErrorMemoryWarningOnTelestrationTitle;
+ (NSString * const) ErrorNoMediaSourcesAvailableText;
+ (NSString * const) ErrorOldPasswordIsNotValidText;
+ (NSString * const) ErrorPasswordHasInvalidLengthText;
+ (NSString * const) ErrorPasswordIsEmptyText;
+ (NSString * const) ErrorPasswordIsInvalidText;
+ (NSString * const) ErrorPasswordsAreNotEqualText;
+ (NSString * const) ErrorPhotoLibraryIsUnavailable;
+ (NSString * const) ErrorPrimarySportIsEmptyText;
+ (NSString * const) ErrorPrimarySportIsInvalidText;
+ (NSString * const) ErrorRetryingUploadRequestText;
+ (NSString * const) ErrorSecondNameBeginsOrEndsWithSpacesText;
+ (NSString * const) ErrorSecondNameHasInvalidLengthText;
+ (NSString * const) ErrorSecondNameIsEmptyText;
+ (NSString * const) ErrorSecondNameIsInvalidText;
+ (NSString * const) ErrorSelectedActionIsEmptyText;
+ (NSString * const) ErrorSelectedActionIsInvalidText;
+ (NSString * const) ErrorSelectedSportActionNotFoundText;
+ (NSString * const) ErrorSelectedSportIsEmptyText;
+ (NSString * const) ErrorSelectedSportIsInvalidText;
+ (NSString * const) ErrorSideBySideClipsAreNotSelectedText;
+ (NSString * const) ErrorTitleBeginsOrEndsWithSpacesText;
+ (NSString * const) ErrorTitleHasInvalidLengthText;
+ (NSString * const) ErrorTitleIsEmptyText;
+ (NSString * const) ErrorTitleIsInvalidText;
+ (NSString * const) ErrorTitleCantSaveSession;
+ (NSString * const) ErrorSavingSession;
+ (NSString * const) ErrorTwitterAccountNotSelectedText;
+ (NSString * const) ErrorTwitterAccountsNotFoundText;
+ (NSString * const) ErrorTwitterUnderDevelopmentForIOS4Text;
//+ (NSString * const) ErrorUnderDevelopmentText;
+ (NSString * const) ErrorUnknownAccountTypeText;
+ (NSString * const) ErrorUserIsLoggedInText;
+ (NSString * const) ErrorUserNotFoundText;
+ (NSString * const) ErrorUserNotLoggedInText;
+ (NSString * const) ErrorValidateDeleteMedia;
+ (NSString * const) ErrorValidateDeleteMediaWithExcercises;
+ (NSString * const) ErrorValidateDeleteMediaWithSessions;
+ (NSString * const) ErrorValidateDeleteProcessingMedia;
+ (NSString * const) ErrorValueIsEmptyText;
+ (NSString * const) ErrorValueIsInvalidText;
+ (NSString * const) ErrorVideoFileDoesNotExists;
+ (NSString * const) ErrorVstratorApiIsUnreachableText;
+ (NSString * const) ErrorWrongInputText;
+ (NSString * const) ErrorWrongInputTitle;
+ (NSString * const) ErrorLoadingSelectedClip;
+ (NSString * const) ErrorLoadingSelectedSession;
+ (NSString * const) ErrorAudioSessionInitText;
+ (NSString * const) ErrorActivatingAudioSessionOrPlayer;
+ (NSString * const) ErrorAudioPlayerInitText;
+ (NSString * const) ErrorLoginCanceled;
+ (NSString * const) ErrorLogoutCanceledDueIncompleteUploadsText;
+ (NSString * const) ErrorRecordingNotAvailableOnThisDevice;
+ (NSString * const) ErrorRecordReason;
+ (NSString * const) ErrorUnableToOpenSafariWithURL;
+ (NSString * const) ErrorUnableToOpenURL;
+ (NSString * const) ErrorUploadThisVideoFirst;
+ (NSString * const) ErrorCannotShareMedia;
+ (NSString * const) ErrorCannotSendMail;
+ (NSString * const) ErrorCannotSendSms;
+ (NSString * const) ErrorWithoutDescription;

/* Join the community */
+ (NSString *const)JoinCommunityCloseButtonTitle;
+ (NSString *const)JoinCommunityGoButtonTitle;
+ (NSString *const)JoinCommunityReason1;
+ (NSString *const)JoinCommunityReason2;
+ (NSString *const)JoinCommunityReason3;

@end
