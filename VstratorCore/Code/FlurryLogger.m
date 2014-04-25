//
//  FlurryLogger.m
//  VstratorCore
//
//  Created by Admin on 04/12/2012.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "Flurry.h"
#import "FlurryLogger.h"
#import "VstratorAppServices.h"
#import "VstratorConstants.h"

FlurryEventType const FlurryEventTypeVideoCapture = @"Video Capture";
FlurryEventType const FlurryEventTypeVideoImport = @"Video Import";
FlurryEventType const FlurryEventTypeVideoSaveAndUse = @"Video Save screen Done button";
FlurryEventType const FlurryEventTypeVideoSaveAndVstrate = @"Video Save screen Vstrate button";
FlurryEventType const FlurryEventTypeVideoSaveAndRetry = @"Video Save screen Camera button";
FlurryEventType const FlurryEventTypeVideoPlayback = @"Video Playback";
FlurryEventType const FlurryEventTypeVideoVstrate = @"Video Vstrate";
FlurryEventType const FlurryEventTypeVideoSideBySide = @"Video Side-By-Side";
FlurryEventType const FlurryEventTypeVideoUpload = @"Video Upload";
FlurryEventType const FlurryEventTypeVideoShareToFacebook = @"Video Share To Facebook";
FlurryEventType const FlurryEventTypeVideoShareToTwitter = @"Video Share To Twitter";
FlurryEventType const FlurryEventTypeVideoShareByMail = @"Video Share By Mail";
FlurryEventType const FlurryEventTypeVideoShareBySms = @"Video Share By Sms";
FlurryEventType const FlurryEventTypeExerciseView = @"Exercise View";
FlurryEventType const FlurryEventTypeExerciseParamsChanged = @"Exercise Params Changed";
FlurryEventType const FlurryEventTypeWorkoutStart = @"Workout Start";
FlurryEventType const FlurryEventTypeMusicPlayerShown = @"Music Player Shown";
FlurryEventType const FlurryEventTypeLoginContinueOffline = @"Login Offline (Continue Offline)";
FlurryEventType const FlurryEventTypeLoginWithFacebook = @"Login With Facebook";
FlurryEventType const FlurryEventTypeLoginWithVstrator = @"Login With Vstrator";
FlurryEventType const FlurryEventTypeLogout = @"Logout";
FlurryEventType const FlurryEventTypeRegisterWithVstrator = @"Register With Vstrator";
FlurryEventType const FlurryEventTypeSettingsScreen = @"Settings Screen";
FlurryEventType const FlurryEventTypeSettingsFeedbackScreen = @"Settings - Feedback Screen";
FlurryEventType const FlurryEventTypeSettingsSupportSiteScreen = @"Settings - Support Site Screen";
FlurryEventType const FlurryEventTypeSettingsTutorialScreen = @"Settings - Tutorial Screen";
FlurryEventType const FlurryEventTypeSettingsUploadQueueScreen = @"Settings - Upload Queue Screen";


@implementation FlurryLogger

+ (void)initSession
{
#ifdef kVAFlurryActive
#ifdef kVAFlurryDebugLog
    [Flurry setDebugLogEnabled:YES];
#endif
    [Flurry setCrashReportingEnabled:YES];
    [Flurry startSession:VstratorAppServices.FlurryAnalyticsId];
#endif
}

+ (void)logTypedEvent:(FlurryEventType)eventType
{
#ifdef kVAFlurryActive
    [Flurry logEvent:eventType];
#endif
}

+ (void)logTypedEvent:(FlurryEventType)eventType withParameters:(NSDictionary *)parameters
{
#ifdef kVAFlurryActive
    [Flurry logEvent:eventType withParameters:parameters];
#endif
}

+ (NSString *)stringFromBool:(BOOL)value
{
    return value ? @"YES" : @"NO";
}

+ (NSString *)stringFromDouble:(double)value
{
    return [NSString stringWithFormat:@"%.2f", value];
}

@end
