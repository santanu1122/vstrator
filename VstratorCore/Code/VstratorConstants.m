//
//  VstratorConstants.m
//  VstratorApp
//
//  Created by Mac on 05.04.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "VstratorConstants.h"
#import "VstratorAppServices.h"

@implementation VstratorConstants

#pragma mark Screen Bounds

static NSNumber *_ScreenOfPlatform4m;

+ (CGSize) ScreenBoundsForPlatform4m { return CGSizeMake(320, 480); }
+ (BOOL) ScreenOfPlatform4m {
    if (_ScreenOfPlatform4m == nil)
        _ScreenOfPlatform4m = [NSNumber numberWithBool:(UIScreen.mainScreen.bounds.size.height <= self.class.ScreenBoundsForPlatform4m.height)];
    return _ScreenOfPlatform4m.boolValue;
};
+ (BOOL) ScreenOfPlatform5e { return !self.class.ScreenOfPlatform4m; };

#pragma mark Constants

+(NSString*) ApplicationId { return VstratorAppServices.ApplicationId; }

+(NSString*) AppIntroMoviePath { return [NSBundle.mainBundle pathForResource:@"Intro" ofType:@"mp4" inDirectory:@"Content"]; }

+(NSInteger) MarkupScaleWidthForLandscape { return 960; }
+(NSInteger) MarkupScaleHeightForLandscape { return 540; }

+(NSInteger) MarkupScaleWidthForPortret { return 640; }
+(NSInteger) MarkupScaleHeightForPortret { return 360; }

+ (CGSize) PlaybackQualityVideoSize { return CGSizeMake(416, 234); }

+ (CGSize) ScrollViewSizeForLandscape { return CGSizeMake(416, 234); }

+ (CGFloat) ThumbnailJPEGQuality { return 0.5; }
+ (NSUInteger)ThumbnailSize { return 125; }

+ (CGFloat) ClipFrameJPEGQuality { return 0.7; }
+ (NSTimeInterval) ClipMaxDuration { return 15.0; }

+ (CGFloat) UserPictureJPEGQuality { return 0.8; }
+ (CGFloat) UserPictureMaxSize { return 300.0; }

+ (NSInteger) MaxNameLength { return 40; }
+ (NSInteger) MaxEmailLength { return 100; }
+ (NSInteger) MaxTitleLength { return 100; }

+ (NSString *) AzureAccount { return @"AZURE_ACCOUNT";}
+ (NSString *) AzureKey { return @"AZURE_KEY";}
+ (NSString *) AzureBlobContainerName { return @"AZURE_BLOB_CONTAINER_NAME"; }

+ (NSInteger) IndexNotSelected { return -1; }

+ (NSString * const) VstratorApiUrl { return @"https://api.vstrator.com/"; }
+ (NSURL * const) VstratorWwwForgotPasswordURL { return [NSURL URLWithString:@"https://www.vstrator.com/Account/ForgotPassword"]; }
+ (NSURL * const) VstratorWwwSupportSiteURL { return [NSURL URLWithString:@"http://help.vstrator.com/VstratorApp"]; }
+ (NSURL * const) VstratorWwwTermsOfUseURL { return [NSURL URLWithString:@"http://help.vstrator.com/VstratorApp/Terms"]; }
+ (NSURL * const) VstratorWwwLearnMoreURL { return [NSURL URLWithString:@"http://www.vstrator.com"]; }
+ (NSURL * const) AppStoreRateThisAppURL { return [NSURL URLWithString:@"itms-apps://itunes.apple.com/app/vstrator/id569512696"]; }
+ (NSURL * const) AppStoreWebAppURL { return [NSURL URLWithString:@"https://itunes.apple.com/app/vstrator/id569512696?mt=8"]; }

+ (NSInteger const) VstratorUnauthorizedRequestErrorCode { return 1004; }

+ (NSString * const) ProUserIdentity { return @"pro"; }

+ (NSString * const) GenericSelectActionName { return @"Select"; }
+ (NSString * const) GenericCloseActionName { return @"Close"; }
+ (NSString * const) GenericCancelActionName { return @"Close"; }

+ (NSString * const) AssertionArgumentIsNilOrInvalid { return @"Argument is NIL or invalid"; }
+ (NSString * const) AssertionErrorPointerIsNil { return @"Error pointer is NIL or invalid"; }
+ (NSString * const) AssertionNibIsInvalid { return @"NIB file loaded but content property not set."; }
+ (NSString * const) AssertionNotMainThreadAccess { return @"Not main thread access"; }

+ (NSString *const)NotificationNeedsRotate { return @"NeedsRotate"; }

+ (NSString *const)NavigationBarLogoTitle { return @"NavigationBarLogoTitle"; }

+ (NSString * const) DefaultSportName { return @"Tennis"; }
+ (NSString * const) DefaultSportActionName { return @"Other"; }

+ (NSString*) FaultNotification { return @"FaultNotification"; }

+ (float) TelestrationMinimumZoomScale { return 0.5; }
+ (float)TelestrationMaximumZoomScale { return 10; }

//+ (CGSize)ScreenSize
//{
//    CGSize screenSize = [UIScreen mainScreen].bounds.size;
//    return CGSizeMake(screenSize.width, screenSize.height - [UIApplication sharedApplication].statusBarFrame.size.height);
//}

+(NSTimeInterval)DefaultTimeoutInterval { return 20; }

+(NSString*)XVstratorAppIdHeader { return @"X-Vstrator-App-Id"; }
+(NSString*)XVstratorInternalUserIdHeader { return @"X-Vstrator-Internal-User-Id"; }

@end
