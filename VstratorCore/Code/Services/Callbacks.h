//
//  Callbacks.h
//  VstratorApp
//
//  Created by user on 12.03.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#ifndef RestClient_Callbacks_h
#define RestClient_Callbacks_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class ACAccount;
@class AccountInfo;
@class Action;
@class User;
@class Clip;
@class Media;
@class Sport;
@class FacebookUserInfo;
@class VstratorUserInfo;
@class UploadRequest;
@class UploadRequestInfo;
@class Workout;
@class NSFetchedResultsController;

typedef void (^Callback0)();
typedef void (^Callback)(id result);
typedef void (^ErrorCallback)(NSError* error);

typedef void (^ACAccountCallback)(NSError *error, ACAccount *accountInfo);
typedef void (^AccountInfoCallback)(NSError *error, AccountInfo *accountInfo);
typedef void (^FacebookUserInfoCallback)(NSError *error, FacebookUserInfo *info);
typedef void (^FetchItemsCallback)(NSError *error, NSFetchedResultsController *result);
typedef void (^GetActionCallback)(NSError *error, Action *action);
typedef void (^GetAuthorCallback)(NSError *error, User *author);
typedef void (^GetClipCallback)(NSError *error, Clip *clip);
typedef void (^GetMediaCallback)(NSError *error, Media *media);
typedef void (^GetItemsCallback)(NSError *error, NSArray *result);
typedef void (^GetItemsCallback0)(NSArray *result);
typedef void (^GetSportCallback)(NSError *error, Sport *sport);
typedef void (^GetUploadRequestCallback)(NSError *error, UploadRequest *uploadRequest);
typedef void (^GetWorkoutCallback)(NSError *error, Workout *workout);
typedef void (^IdentityCallback)(NSError *error, NSString *identity);
typedef void (^ResultCallback)(NSError *error, id *result);
typedef void (^VstratorUserInfoCallback)(NSError *error, VstratorUserInfo *info);
typedef void (^VstratorUserInfoCallback0)(VstratorUserInfo *info);
typedef void (^UploadRequestInfoCallback)(UploadRequest* request, UploadRequestInfo *info, NSError *error);

#define kCallbackIf(callback, error)        if (callback) callback(error)
#define kCallbackIf_GCD(callback, error)    if (callback) { dispatch_async(dispatch_get_main_queue(), ^{ callback(error); }); }

#define kItemCallbackIf(callback, error, item)  if (callback) callback(error, item)

#endif
