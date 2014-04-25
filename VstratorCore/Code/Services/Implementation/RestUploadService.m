//
//  RestUploadService.m
//  VstratorApp
//
//  Created by user on 17.05.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import "RestUploadService.h"
#import "Media.h"
#import "NSError+Extensions.h"
#import "Session.h"
#import "UploadData.h"
#import "VideoStatusInfo.h"

static const NSTimeInterval GetUrlForVideoTimeout = 60.;

@implementation RestUploadService

-(void)uploadData:(UploadData *)data withCallback:(ErrorCallback)callback
{
    NSParameterAssert(data);
    NSParameterAssert(callback);
    NSParameterAssert(self.delegate);
    if (!data.content) {
        [self errorCallbackWrapper:callback](nil, [NSError errorWithText:@"No data content to upload"]);
        return;
    }
    NSURL* url = [data.url URLByAppendingPathComponent:data.name];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"PUT";
    request.HTTPBody = data.content;
    [request setValue:data.mimeType forHTTPHeaderField:@"Content-Type"];
    AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        callback(nil);
    } failure:[self errorCallbackWrapper:callback]];
    [[self.delegate objectManager].HTTPClient enqueueHTTPRequestOperation:requestOperation];
}

-(void)requestForUpload:(UploadType)type callback:(void (^)(UploadRequestInfo *, NSError *))callback
{
    NSParameterAssert(callback);
    NSParameterAssert(self.delegate);
    NSString* path = type == UploadTypeClip ? @"clip" : @"vstratedclip";
    [[self.delegate objectManager] getObjectsAtPath:path parameters:[self.delegate parameters] success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        callback(mappingResult.firstObject, nil);
    } failure:[self errorCallbackWrapper1:callback]];
}

-(void)processClipMetaInfo:(ClipMetaInfo *)clipMetaInfo isVstration:(BOOL)isVstration callback:(void (^)(VideoStatusInfo *, NSError *))callback
{
    NSParameterAssert(clipMetaInfo);
    NSParameterAssert(callback);
    NSParameterAssert(self.delegate);
    NSString* path = !isVstration ? @"clip" : @"vstratedclip";
    [[self.delegate objectManager] postObject:clipMetaInfo path:path parameters:[self.delegate parameters] success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        callback(mappingResult.firstObject, nil);
    } failure:[self errorCallbackWrapper1:callback]];
}

-(void)updateMedia:(Media*)media callback:(ErrorCallback)callback
{
    // Make media public in order to share it
    NSParameterAssert(callback);
    NSParameterAssert(media);
    NSParameterAssert(self.delegate);
    NSString* path = [media isKindOfClass:[Session class]] ? @"vstratedclip" : @"clip";
    [[self.delegate objectManager] putObject:media path:path parameters:[self.delegate parameters] success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        callback(nil);
    } failure:[self errorCallbackWrapper:callback]];
}

-(void)getURLForVideoKey:(NSString*)videoKey isVstration:(BOOL)isVstration callback:(void(^)(NSURL* url, NSError* error))callback
{
    NSParameterAssert(videoKey);
    NSParameterAssert(callback);
    NSParameterAssert(self.delegate);
    NSString* path = [NSString stringWithFormat:(isVstration ? @"vstratedclip/%@" : @"clip/%@"), videoKey];
    [[self.delegate objectManager] getObjectsAtPath:path parameters:[self.delegate parameters] success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        VideoStatusInfo* info = mappingResult.firstObject;
        int status = info.encodingStatus;
        switch (status) {
            case VideoEncodingStatusErrorRetrying:
            case VideoEncodingStatusError:
            case VideoEncodingStatusNotAvailable:
            {
                NSDictionary* userInfo = @{NSLocalizedDescriptionKey: @"Video processing ended with an error"};
                NSError* error = [NSError errorWithDomain:@"com.vstrator.videoProcessing" code:-1 userInfo:userInfo];
                [self errorCallbackWrapper1:callback](operation, error);
                break;
            }
            case VideoEncodingStatusReady:
            case VideoEncodingStatusUnencodedReady:
            {
                callback(info.videoURL, nil);
                break;
            }
            case VideoEncodingStatusNotStarted:
            case VideoEncodingStatusProcessing:
            default:
                callback(nil, nil);
                break;
        }
    } failure:[self errorCallbackWrapper1:callback]];
}

@end
