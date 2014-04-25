//
//  ServiceFactory.h
//  VstratorApp
//
//  Created by Mac on 03.05.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RemoteService.h"
#import "DownloadService.h"
#import "UploadService.h"
#import "UsersService.h"
#import "NotificationService.h"

@interface ServiceFactory : NSObject<RemoteServiceDelegate>

+(ServiceFactory*)sharedInstance;

@property (nonatomic, strong) NSURL* baseURL;

-(void) setVstratorAuthWithEmail:(NSString*)email password:(NSString*)password;
-(void) setFacebookAuthWithIdentity:(NSString*)identity accessToken:(NSString*)accessToken;
-(void) clearAuth;

-(id<DownloadService>)createDownloadService;
-(id<UploadService>)createUploadService;
-(id<UsersService>)createUsersService;
-(id<NotificationService>)createNotificationService;

@end
