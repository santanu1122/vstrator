//
//  FlurryLogger.h
//  VstratorCore
//
//  Created by Admin on 04/12/2012.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NSString* FlurryEventType;

extern FlurryEventType const FlurryEventTypeVideoCapture;
extern FlurryEventType const FlurryEventTypeVideoImport;
extern FlurryEventType const FlurryEventTypeVideoSaveAndUse;
extern FlurryEventType const FlurryEventTypeVideoSaveAndVstrate;
extern FlurryEventType const FlurryEventTypeVideoSaveAndRetry;
extern FlurryEventType const FlurryEventTypeVideoPlayback;
extern FlurryEventType const FlurryEventTypeVideoVstrate;
extern FlurryEventType const FlurryEventTypeVideoSideBySide;
extern FlurryEventType const FlurryEventTypeVideoUpload;
extern FlurryEventType const FlurryEventTypeVideoShareToFacebook;
extern FlurryEventType const FlurryEventTypeVideoShareToTwitter;
extern FlurryEventType const FlurryEventTypeVideoShareByMail;
extern FlurryEventType const FlurryEventTypeVideoShareBySms;
extern FlurryEventType const FlurryEventTypeExerciseView;
extern FlurryEventType const FlurryEventTypeExerciseParamsChanged;
extern FlurryEventType const FlurryEventTypeWorkoutStart;
extern FlurryEventType const FlurryEventTypeMusicPlayerShown;
extern FlurryEventType const FlurryEventTypeLoginContinueOffline;
extern FlurryEventType const FlurryEventTypeLoginWithFacebook;
extern FlurryEventType const FlurryEventTypeLoginWithVstrator;
extern FlurryEventType const FlurryEventTypeLogout;
extern FlurryEventType const FlurryEventTypeRegisterWithVstrator;
extern FlurryEventType const FlurryEventTypeSettingsScreen;
extern FlurryEventType const FlurryEventTypeSettingsFeedbackScreen;
extern FlurryEventType const FlurryEventTypeSettingsSupportSiteScreen;
extern FlurryEventType const FlurryEventTypeSettingsTutorialScreen;
extern FlurryEventType const FlurryEventTypeSettingsUploadQueueScreen;

@interface FlurryLogger : NSObject

+ (void)initSession;

+ (void)logTypedEvent:(FlurryEventType)eventType;
+ (void)logTypedEvent:(FlurryEventType)eventType withParameters:(NSDictionary *)parameters;

+ (NSString *)stringFromBool:(BOOL)value;
+ (NSString *)stringFromDouble:(double)value;

@end
