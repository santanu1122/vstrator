//
//  RestUsersService.m
//  VstratorApp
//
//  Created by user on 24.02.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "RestUsersService.h"
#import "ChangePasswordInfo.h"

#import <MobileCoreServices/UTType.h>
#import "Clip.h"
#import "Logger.h"
#import "NSError+Extensions.h"
#import "NSString+Extensions.h"
#import "VstratorConstants.h"

@implementation RestUsersService

-(void) registerUser:(RegistrationInfo *)info
            callback:(ErrorCallback) callback
{
    NSParameterAssert(info);
    NSParameterAssert(callback);
    NSParameterAssert(self.delegate);
    [[self.delegate objectManager] postObject:info path:@"user/register" parameters:[self.delegate parameters] success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        callback(nil);
    } failure:[self errorCallbackWrapper:callback]];
}

-(void) getUserInfo:(void(^)(VstratorUserInfo* userInfo, NSError* error))callback
{
    NSParameterAssert(callback);
    NSParameterAssert(self.delegate);
    [[self.delegate objectManager] getObjectsAtPath:@"user" parameters:[self.delegate parameters] success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        callback(mappingResult.firstObject, nil);
    } failure:[self errorCallbackWrapper1:callback]];
}

-(void)getSportList:(void (^)(NSArray *, NSError *))callback
{
    NSParameterAssert(callback);
    NSParameterAssert(self.delegate);
    [[self.delegate objectManager] getObjectsAtPath:@"sports" parameters:[self.delegate parameters] success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        callback(mappingResult.array, nil);
    } failure:[self errorCallbackWrapper1:callback]];
}

-(void) changeUserInfo:(VstratorUserInfo *)info callback:(ErrorCallback)callback
{
    NSParameterAssert(info);
    NSParameterAssert(callback);
    NSParameterAssert(self.delegate);
    [[self.delegate objectManager] putObject:info path:@"user" parameters:[self.delegate parameters] success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        callback(nil);
    } failure:[self errorCallbackWrapper:callback]];
}

-(void) changeUserPassword:(NSString *)oldPassword toNewPassword:(NSString *)password callback:(ErrorCallback)callback
{
    NSParameterAssert(oldPassword);
    NSParameterAssert(password);
    NSParameterAssert(callback);
    NSParameterAssert(self.delegate);
    ChangePasswordInfo* info = [ChangePasswordInfo new];
    info.oldPassword = oldPassword;
    info.password = password;
    [[self.delegate objectManager] postObject:info path:@"user/password" parameters:[self.delegate parameters] success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        callback(nil);
    } failure:[self errorCallbackWrapper:callback]];
}

-(void) getPicture:(void (^)(UIImage *, NSError *))callback
{
    NSParameterAssert(callback);
    NSParameterAssert(self.delegate);
    NSURL* url = [[self.delegate objectManager].baseURL URLByAppendingPathComponent:@"picture"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.allHTTPHeaderFields = [self.delegate objectManager].HTTPClient.defaultHeaders;
    AFHTTPRequestOperation *requestOperation = [[AFImageRequestOperation alloc] initWithRequest:request];
    [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        callback([UIImage imageWithData:operation.responseData], nil);
    } failure:[self errorCallbackWrapper1:callback]];
    [[self.delegate objectManager].HTTPClient enqueueHTTPRequestOperation:requestOperation];
}

-(void) changePicture:(NSData *)picture
		   withFormat:(ImageFormat)imageFormat
			 callback:(ErrorCallback)callback
{
    NSParameterAssert(picture);
    NSParameterAssert(callback);
    NSParameterAssert(self.delegate);
	NSString* mimeType;
	switch (imageFormat) {
		case pngImageFormat:
			mimeType = @"image/png";
			break;
		case jpegImageFormat:
			mimeType = @"image/jpeg";
			break;
		case gifImageFormat:
			mimeType = @"image/gif";
			break;
		default:
			@throw [NSException exceptionWithName:@"Image format"
										   reason:[NSString stringWithFormat:@"Unsupported image format: %d", imageFormat]
										 userInfo:nil];
			break;
	}
    NSMutableURLRequest* request = [[self.delegate objectManager] multipartFormRequestWithObject:nil method:RKRequestMethodPOST path:@"/picture" parameters:[self.delegate parameters] constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:picture name:@"userProfilePicture" fileName:@"userProfilePicture" mimeType:mimeType];
    }];
    RKObjectRequestOperation* op = [[self.delegate objectManager] objectRequestOperationWithRequest:request success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        callback(nil);
    } failure:[self errorCallbackWrapper:callback]];
    [[self.delegate objectManager] enqueueObjectRequestOperation:op];
}

-(void) sendIssue:(Issue *)issue
         callback:(ErrorCallback)callback
{
    NSParameterAssert(issue);
    NSParameterAssert(callback);
    NSParameterAssert(self.delegate);
    [[self.delegate objectManager] postObject:issue path:@"feedback" parameters:[self.delegate parameters] success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        callback(nil);
    } failure:[self errorCallbackWrapper:callback]];
}

@end
