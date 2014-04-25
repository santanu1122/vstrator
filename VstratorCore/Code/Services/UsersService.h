//
//  UsersService.h
//  VstratorApp
//
//  Created by user on 24.02.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Callbacks.h"

@class Issue, RegistrationInfo, VstratorUserInfo;

typedef enum ImageFormat {
	pngImageFormat,
	jpegImageFormat,
	gifImageFormat
} ImageFormat;

@protocol UsersService

-(void) registerUser:(RegistrationInfo *)info callback:(ErrorCallback)callback;
-(void) getUserInfo:(void(^)(VstratorUserInfo* userInfo, NSError* error))callback;
-(void) getSportList:(void(^)(NSArray* sportList, NSError* error))callback;
-(void) getPicture:(void(^)(UIImage* image, NSError* error))callback;
-(void) changeUserInfo:(VstratorUserInfo *)info callback:(ErrorCallback)callback;
-(void) changeUserPassword:(NSString *)oldPassword toNewPassword:(NSString *)password callback:(ErrorCallback)callback;
-(void) changePicture:(NSData *)picture withFormat:(ImageFormat)imageFormat callback:(ErrorCallback)callback;
-(void) sendIssue:(Issue *)issue callback:(ErrorCallback)callback;

@end
