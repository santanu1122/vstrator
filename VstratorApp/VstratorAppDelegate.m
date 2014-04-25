//
//  VstratorAppDelegate.m
//  VstratorApp
//
//  Created by Mac on 26.02.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "VstratorAppDelegate.h"

#import "AccountController2+Facebook.h"
#import "Logger.h"
#import "MediaService.h"
#import "VstratorAppServices.h"
#import "VstratorExtensions.h"
#import "VstratorStrings.h"
#import "ImportMediaDispatcher.h" // For kVAImporterActive
#import "TaskManager.h"
#import "UpdateManager.h"
#import "VstratorApplicationState.h"

#import "ContentRootViewController.h"
#import "LogoViewController.h"

#import <GoogleConversionTracking/GoogleConversionPing.h>
#import "FlurryLogger.h"

#import <RestKit/RestKit.h> // For kVARestKitLogActive

//#define kVARestKitLogActive

@interface VstratorAppDelegate () <LogoViewControllerDelegate>

@property (atomic) BOOL appDidFail;

@property (atomic) BOOL appDidInit0;
@property (atomic) BOOL appDidLogo;
@property (atomic) BOOL appIsReady;

@end

@implementation VstratorAppDelegate

#pragma mark View Switcher

- (void)switchViewsByState
{
    BaseViewController *currentViewController = (BaseViewController *)self.window.rootViewController;
    if (self.appDidFail) {
        NSError *failError = [NSError errorWithText:VstratorStrings.ErrorDatabaseInitFailedText];
        [currentViewController hideBGActivityIndicator:failError];
    } else if (self.appDidLogo) {
        if (self.appIsReady) {
            ContentRootViewController *vc = [[ContentRootViewController alloc] initWithNibName:NSStringFromClass(ContentRootViewController.class) bundle:nil];
            self.window.rootViewController = vc;
        } else {
            [currentViewController showBGActivityIndicator:VstratorStrings.UserLoginLoggingInActivityTitle];
        }
    }
}

#pragma mark LogoViewControllerDelegate

- (void)logoViewControllerDidLogo:(LogoViewController *)sender
{
    self.appDidLogo = YES;
    [self switchViewsByState];
}

#pragma mark Initializers

- (void)initTrackers
{
    [FlurryLogger initSession];
    
#ifdef kVAGoogleConversionTrackingActive
    [GoogleConversionPing pingWithConversionId:VstratorAppServices.GoogleConversionId label:VstratorAppServices.GoogleConversionLabel value:VstratorAppServices.AppPriceValue isRepeatable:NO];
#endif
    
#ifdef kVATestFlightActive
    NSString *deviceIdentifier = nil;
    if ([UIDevice.currentDevice respondsToSelector:@selector(identifierForVendor)])
        deviceIdentifier = ((NSUUID *)[UIDevice.currentDevice performSelector:@selector(identifierForVendor)]).UUIDString;
    else
        deviceIdentifier = (NSString *)[UIDevice.currentDevice performSelector:@selector(uniqueIdentifier)];
    [TestFlight setDeviceIdentifier:deviceIdentifier];
    [TestFlight takeOff:kVATestFlightTakeOff];
#endif
    
#ifdef kVARestKitLogActive
	RKLogConfigureByName("RestKit/Network", RKLogLevelTrace);
#endif
}

- (void)initInternals
{
	[MediaService initialize2];
    [AccountController2 initialize:^(NSError *error0) {
        if (error0 == nil) {
            // service notifications
            [NSNotificationCenter.defaultCenter addObserver:self
                                                   selector:@selector(didReceiveUserLoggedInChangedNotification)
                                                       name:VAUserLoggedInChangedNotification
                                                     object:nil];
            // set state
            self.appDidInit0 = YES;
            // preprocess database content
            [self processImportOrUpdates:^{
                // dispatchers
                [TaskManager.sharedInstance startPersistentDispatchers];
                // last login
                if (AccountController2.sharedInstance.userHasRecentLogin) {
                    [AccountController2.sharedInstance loginAsRecent:^(NSError *error1) {
                        self.appIsReady = YES;
                        [self switchViewsByState];
                    }];
                } else {
                    self.appIsReady = YES;
                    [self switchViewsByState];
                }
            }];
        } else {
            NSLog(@"%@", error0.localizedDescription);
            self.appDidFail = YES;
            [self switchViewsByState];
        }
    }];
}

- (void)processImportOrUpdates:(Callback0)callback
{
    NSParameterAssert(callback);
#ifdef kVAImporterActive
    [[ImportMediaDispatcher new] processImportWithCallback:^(NSError *error0) {
        if (error0 == nil) {
            [[UpdateManager new] updateSportsAndActions:^(NSError *error1) {
                if (error1 != nil)
                    NSLog(@"processImportOrUpdates: %@", error1.localizedDescription);
                callback();
            }];
        } else {
            NSLog(@"processImportOrUpdates: %@", error0.localizedDescription);
            dispatch_async(dispatch_get_main_queue(), callback);
        }
    }];
#else
    [[UpdateManager new] processUpdates:callback];
    [[UpdateManager new] updateSportsAndActions:^(NSError *error) {
        if (error) {
            NSLog(@"Can't update sports and actions: %@", error.localizedDescription);
        }
    }];
#endif
}

#pragma mark Services

- (void)didReceiveUserLoggedInChangedNotification
{
    //NOTE: this check should be useless, added for NSLog
    if (UIApplication.sharedApplication.applicationState != UIApplicationStateActive) {
        NSLog(@"VstratorAppDelegate: VAUserLoggedInChangedNotification received in the app inactive state");
        return;
    }
    // perform
    if (AccountController2.sharedInstance.userLoggedIn)
        [TaskManager.sharedInstance startTaskDispatchers];
    else
        [TaskManager.sharedInstance stopTaskDispatchers];
}

#pragma mark Application Events

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [Logger initLogger];
    // Logo
    UIApplication.sharedApplication.statusBarStyle = UIStatusBarStyleBlackOpaque;
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    LogoViewController *vc = [[LogoViewController alloc] init];
    vc.delegate = self;
    self.window.rootViewController = vc;
    [self.window makeKeyAndVisible];
    // Initializers
    [self initTrackers];
    [self initInternals];
    // We're done
    return YES;
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    if (!self.appDidInit0)
        return;
    // notifications
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(didReceiveUserLoggedInChangedNotification)
                                               name:VAUserLoggedInChangedNotification
                                             object:nil];
    // dispatchers
    [TaskManager.sharedInstance startPersistentDispatchers];
    if (self.appIsReady && AccountController2.sharedInstance.userLoggedIn)
        [TaskManager.sharedInstance startTaskDispatchers];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Although the SDK attempts to refresh its access tokens when it makes API calls,
    // it's a good practice to refresh the access token also when the app becomes active.
    // This gives apps that seldom make api calls a higher chance of having a non expired
    // access token.
    VstratorApplicationState.isInBackground = NO;
    if (self.appDidInit0)
        [AccountController2.sharedInstance handleFacebookDidBecomeActive];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    if (self.appDidInit0)
        return [AccountController2.sharedInstance handleFacebookOpenURL:url];
    return NO;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    if (self.appDidInit0)
        return [AccountController2.sharedInstance handleFacebookOpenURL:url];
    return NO;
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    VstratorApplicationState.isInBackground = YES;
    if (!self.appDidInit0)
        return;
    // give 30 seconds to all the background processes to finish
    __block UIBackgroundTaskIdentifier *delayTask = nil;
    Callback0 delayTaskCallback = ^{
        [application endBackgroundTask:delayTask];
        delayTask = UIBackgroundTaskInvalid;
    };
    delayTask = [application beginBackgroundTaskWithExpirationHandler:delayTaskCallback];
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(30.0 * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), delayTaskCallback);
    // dispatchers
    [TaskManager.sharedInstance stopPersistentDispatchers];
    [TaskManager.sharedInstance stopTaskDispatchers];
    // notification
    [NSNotificationCenter.defaultCenter removeObserver:self
                                                  name:VAUserLoggedInChangedNotification
                                                object:nil];
}

@end
