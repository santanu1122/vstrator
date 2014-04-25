//
//  VstratorConstants.h
//  VstratorApp
//
//  Created by Mac on 05.04.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <Foundation/Foundation.h>

//#define DEBUG_CORE_DATA

@interface VstratorConstants : NSObject

// screen bounds

//+ (CGSize) ScreenBoundsForPlatform4m;
+ (BOOL) ScreenOfPlatform4m;
+ (BOOL) ScreenOfPlatform5e;

// constants

+(NSString*) ApplicationId;

+(NSString*) AppIntroMoviePath;

+(NSInteger) MarkupScaleWidthForLandscape;
+(NSInteger) MarkupScaleHeightForLandscape;

+(NSInteger) MarkupScaleWidthForPortret;
+(NSInteger) MarkupScaleHeightForPortret;

+ (CGSize) PlaybackQualityVideoSize;

+ (CGSize) ScrollViewSizeForLandscape;

+ (CGFloat) ThumbnailJPEGQuality;
+ (NSUInteger) ThumbnailSize;

+ (CGFloat) ClipFrameJPEGQuality;
+ (NSTimeInterval) ClipMaxDuration;

+ (CGFloat) UserPictureJPEGQuality;
+ (CGFloat) UserPictureMaxSize;

+ (NSInteger) MaxNameLength;
+ (NSInteger) MaxEmailLength;
+ (NSInteger) MaxTitleLength;

+ (NSString *) AzureAccount;
+ (NSString *) AzureKey;
+ (NSString *) AzureBlobContainerName;

+ (NSInteger) IndexNotSelected;

+ (NSString * const) VstratorApiUrl;
+ (NSURL * const) VstratorWwwForgotPasswordURL;
+ (NSURL * const) VstratorWwwSupportSiteURL;
+ (NSURL * const) VstratorWwwTermsOfUseURL;
+ (NSURL * const) VstratorWwwLearnMoreURL;
+ (NSURL * const) AppStoreRateThisAppURL;
+ (NSURL * const) AppStoreWebAppURL;

+ (NSInteger const) VstratorUnauthorizedRequestErrorCode;

+ (NSString * const) ProUserIdentity;

+ (NSString * const) GenericSelectActionName;
+ (NSString * const) GenericCloseActionName;
+ (NSString * const) GenericCancelActionName;

+ (NSString * const) AssertionArgumentIsNilOrInvalid;
+ (NSString * const) AssertionErrorPointerIsNil;
+ (NSString * const) AssertionNibIsInvalid;
+ (NSString * const) AssertionNotMainThreadAccess;

+ (NSString * const) NotificationNeedsRotate;

+ (NSString * const) NavigationBarLogoTitle;

+ (NSString * const) DefaultSportName;
+ (NSString * const) DefaultSportActionName;

+ (NSString*) FaultNotification;

+ (float) TelestrationMinimumZoomScale;
+ (float) TelestrationMaximumZoomScale;

+(NSTimeInterval) DefaultTimeoutInterval;

+(NSString*)XVstratorAppIdHeader;
+(NSString*)XVstratorInternalUserIdHeader;

@end
