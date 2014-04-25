//
//  VstratorAppServices.h
//  VstratorCore
//
//  Created by Virtualler on 27.05.13.
//  Copyright (c) 2013 OnTarget. All rights reserved.
//

#import <Foundation/Foundation.h>

// Dispatchers

#define kVAUploadDispatcherActive

#if !defined(RELEASE_APPSTORE)
//#define kVAImporterActive
//#define kVADownloadDispatcherActive
#define kVANotificationDispatcherActive
#endif

// Services: ...Flurry

#if !defined(DEBUG)
#define kVAFlurryActive
//#define kVAFlurryDebugLog
#endif

// ...GoogleConversionTracking

#if defined(RELEASE_APPSTORE)
#define kVAGoogleConversionTrackingActive
#endif

// Interface

@interface VstratorAppServices : NSObject

+ (NSString *) ApplicationId;
+ (NSString *) FlurryAnalyticsId;
+ (NSString *) GoogleConversionId;
+ (NSString *) GoogleConversionLabel;
+ (NSString *) AppPriceValue;

@end
