//
//  UploadService.h
//  VstratorApp
//
//  Created by user on 17.05.12.
//  Copyright (c) 2012 OnTarget. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Callbacks.h"

typedef enum {
    UploadTypeClip,
    UploadTypeSession
} UploadType;

@class UploadData, ClipMetaInfo, VideoStatusInfo;

@protocol UploadService

-(void)uploadData:(UploadData*)data withCallback:(ErrorCallback)callback;
-(void)requestForUpload:(UploadType)type callback:(void(^)(UploadRequestInfo* info, NSError* error))callback;
-(void)processClipMetaInfo:(ClipMetaInfo*)clipMetaInfo isVstration:(BOOL)isVstration callback:(void (^)(VideoStatusInfo* videoStatusInfo, NSError* error))callback;
-(void)getURLForVideoKey:(NSString*)videoKey isVstration:(BOOL)isVstration callback:(void(^)(NSURL* url, NSError* error))callback;
-(void)updateMedia:(Media*)media callback:(ErrorCallback)callback;

@end
